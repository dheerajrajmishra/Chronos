import express from 'express';
import bcrypt from 'bcrypt';
import { query, ROLE_PERMISSIONS } from '../db';
import { requireAuth, requireSystemAdmin, AuthRequest } from '../middleware/auth';

const router = express.Router();

// All routes require system_admin
router.use(requireAuth);
router.use(requireSystemAdmin);

// --- TENANT MANAGEMENT ---

// GET /api/admin/tenants — List all tenants
router.get('/tenants', async (req: AuthRequest, res) => {
  try {
    const result = await query(`
      SELECT t.*, 
        (SELECT COUNT(*) FROM tenant_users tu WHERE tu.tenant_id = t.id AND tu.status = 'active') as user_count,
        (SELECT COUNT(*) FROM projects p WHERE p.tenant_id = t.id) as project_count
      FROM tenants t 
      ORDER BY t.id ASC
    `);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to load tenants', details: err.message });
  }
});

// POST /api/admin/tenants — Create new tenant with initial admin
router.post('/tenants', async (req: AuthRequest, res) => {
  const { name, slug, plan, max_users, admin_email, admin_password, admin_name } = req.body;
  
  if (!name) {
    return res.status(400).json({ error: 'Tenant name is required' });
  }

  try {
    // Generate slug from name if not provided
    const tenantSlug = slug || name.replace(/[^a-z0-9]/gi, '-').toLowerCase();
    
    // Create tenant
    const tenantRes = await query(
      `INSERT INTO tenants (name, slug, status, plan, max_users) 
       VALUES ($1, $2, 'active', $3, $4) RETURNING *`,
      [name, tenantSlug, plan || 'free', max_users || 10]
    );
    const tenant = tenantRes.rows[0];

    // Seed default settings for new tenant
    await query(
      `INSERT INTO tenant_settings (tenant_id, key, value) VALUES ($1, 'theme', '{"mode": "light"}'::jsonb) ON CONFLICT DO NOTHING`,
      [tenant.id]
    );

    // If admin credentials provided, create user and assign as org_admin
    let adminUser = null;
    if (admin_email && admin_password) {
      const hash = await bcrypt.hash(admin_password, 10);
      const userRes = await query(
        `INSERT INTO users (email, name, password_hash, status) 
         VALUES ($1, $2, $3, 'active') 
         ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING *`,
        [admin_email, admin_name || '', hash]
      );
      adminUser = userRes.rows[0];

      await query(
        `INSERT INTO tenant_users (tenant_id, user_id, role, status) 
         VALUES ($1, $2, 'org_admin', 'active')
         ON CONFLICT (tenant_id, user_id) DO UPDATE SET role = 'org_admin'`,
        [tenant.id, adminUser.id]
      );
    }

    // Log the action
    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'create_tenant', 'tenant', $3, $4)`,
      [tenant.id, req.user!.id, tenant.id, JSON.stringify({ name, slug: tenantSlug, admin_email })]
    );

    res.json({ 
      ...tenant, 
      user_count: adminUser ? 1 : 0,
      project_count: 0,
      admin: adminUser ? { id: adminUser.id, email: adminUser.email, name: adminUser.name } : null 
    });
  } catch (err: any) {
    if (err.code === '23505') {
      return res.status(409).json({ error: 'Tenant with this slug already exists' });
    }
    res.status(500).json({ error: 'Failed to create tenant', details: err.message });
  }
});

// PUT /api/admin/tenants/:id — Update tenant
router.put('/tenants/:id', async (req: AuthRequest, res) => {
  const { name, slug, status, plan, max_users } = req.body;
  try {
    const result = await query(
      `UPDATE tenants SET 
        name = COALESCE($1, name), 
        slug = COALESCE($2, slug), 
        status = COALESCE($3, status), 
        plan = COALESCE($4, plan), 
        max_users = COALESCE($5, max_users) 
       WHERE id = $6 RETURNING *`,
      [name, slug, status, plan, max_users, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Tenant not found' });

    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'update_tenant', 'tenant', $1, $3)`,
      [req.params.id, req.user!.id, JSON.stringify({ name, status, plan })]
    );

    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to update tenant', details: err.message });
  }
});

// DELETE /api/admin/tenants/:id — Suspend tenant (soft delete)
router.delete('/tenants/:id', async (req: AuthRequest, res) => {
  try {
    // Don't allow deleting the default Chronos Admin tenant
    if (req.params.id === '1') {
      return res.status(403).json({ error: 'Cannot delete the primary Chronos Admin tenant' });
    }

    const result = await query(
      `UPDATE tenants SET status = 'suspended' WHERE id = $1 RETURNING *`,
      [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Tenant not found' });

    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'suspend_tenant', 'tenant', $1, '{}'::jsonb)`,
      [req.params.id, req.user!.id]
    );

    res.json({ success: true, message: 'Tenant suspended' });
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to suspend tenant', details: err.message });
  }
});

// --- TENANT USER MANAGEMENT (cross-tenant, system admin only) ---

// GET /api/admin/tenants/:id/users — List users in a tenant
router.get('/tenants/:id/users', async (req: AuthRequest, res) => {
  try {
    const result = await query(
      `SELECT u.id, u.email, u.name, u.status as user_status, u.last_login, u.created_at,
              tu.role, tu.permissions, tu.status as membership_status
       FROM users u
       JOIN tenant_users tu ON u.id = tu.user_id
       WHERE tu.tenant_id = $1
       ORDER BY tu.created_at ASC`,
      [req.params.id]
    );
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to load tenant users', details: err.message });
  }
});

// POST /api/admin/tenants/:id/users — Add user to tenant
router.post('/tenants/:id/users', async (req: AuthRequest, res) => {
  const { email, password, name, role } = req.body;
  if (!email) return res.status(400).json({ error: 'Email is required' });

  try {
    // Check tenant max_users limit
    const tenantRes = await query('SELECT max_users FROM tenants WHERE id = $1', [req.params.id]);
    if (tenantRes.rows.length === 0) return res.status(404).json({ error: 'Tenant not found' });
    
    const currentCount = await query(
      'SELECT COUNT(*) as count FROM tenant_users WHERE tenant_id = $1 AND status = \'active\'',
      [req.params.id]
    );
    if (parseInt(currentCount.rows[0].count) >= tenantRes.rows[0].max_users) {
      return res.status(403).json({ error: `Tenant has reached the maximum user limit (${tenantRes.rows[0].max_users})` });
    }

    // Create or get user
    let userId: number;
    const existing = await query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      userId = existing.rows[0].id;
    } else {
      if (!password) return res.status(400).json({ error: 'Password is required for new users' });
      const hash = await bcrypt.hash(password, 10);
      const userRes = await query(
        `INSERT INTO users (email, name, password_hash, status) VALUES ($1, $2, $3, 'active') RETURNING id`,
        [email, name || '', hash]
      );
      userId = userRes.rows[0].id;
    }

    // Add to tenant
    await query(
      `INSERT INTO tenant_users (tenant_id, user_id, role, status) VALUES ($1, $2, $3, 'active')
       ON CONFLICT (tenant_id, user_id) DO UPDATE SET role = $3, status = 'active'`,
      [req.params.id, userId, role || 'viewer']
    );

    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'add_tenant_user', 'user', $3, $4)`,
      [req.params.id, req.user!.id, userId, JSON.stringify({ email, role: role || 'viewer' })]
    );

    res.json({ success: true, user_id: userId });
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to add user to tenant', details: err.message });
  }
});

// DELETE /api/admin/tenants/:id/users/:userId — Remove user from tenant
router.delete('/tenants/:id/users/:userId', async (req: AuthRequest, res) => {
  try {
    await query(
      `UPDATE tenant_users SET status = 'inactive' WHERE tenant_id = $1 AND user_id = $2`,
      [req.params.id, req.params.userId]
    );

    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'remove_tenant_user', 'user', $3, '{}'::jsonb)`,
      [req.params.id, req.user!.id, req.params.userId]
    );

    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to remove user', details: err.message });
  }
});

// --- TENANT SETTINGS (cross-tenant, system admin only) ---

// GET /api/admin/tenants/:id/settings — View tenant settings
router.get('/tenants/:id/settings', async (req: AuthRequest, res) => {
  try {
    const result = await query('SELECT key, value FROM tenant_settings WHERE tenant_id = $1', [req.params.id]);
    const settingsMap: Record<string, any> = {};
    for (const row of result.rows) {
      settingsMap[row.key] = row.value;
    }
    res.json(settingsMap);
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to load tenant settings', details: err.message });
  }
});

// PUT /api/admin/tenants/:id/settings — Update tenant settings
router.put('/tenants/:id/settings', async (req: AuthRequest, res) => {
  try {
    const { llm_config, theme } = req.body;
    
    if (llm_config) {
      await query(
        `INSERT INTO tenant_settings (tenant_id, key, value) VALUES ($1, 'llm_config', $2::jsonb)
         ON CONFLICT (tenant_id, key) DO UPDATE SET value = $2::jsonb`,
        [req.params.id, JSON.stringify(llm_config)]
      );
    }
    if (theme) {
      await query(
        `INSERT INTO tenant_settings (tenant_id, key, value) VALUES ($1, 'theme', $2::jsonb)
         ON CONFLICT (tenant_id, key) DO UPDATE SET value = $2::jsonb`,
        [req.params.id, JSON.stringify(theme)]
      );
    }

    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to update tenant settings', details: err.message });
  }
});

// --- DASHBOARD STATS ---

// GET /api/admin/stats — Platform-wide statistics
router.get('/stats', async (req: AuthRequest, res) => {
  try {
    const [tenants, users, projects, activeUsers] = await Promise.all([
      query('SELECT COUNT(*) as count FROM tenants WHERE status = \'active\''),
      query('SELECT COUNT(*) as count FROM users WHERE status = \'active\''),
      query('SELECT COUNT(*) as count FROM projects'),
      query('SELECT COUNT(DISTINCT user_id) as count FROM tenant_users WHERE status = \'active\''),
    ]);

    res.json({
      total_tenants: parseInt(tenants.rows[0].count),
      total_users: parseInt(users.rows[0].count),
      total_projects: parseInt(projects.rows[0].count),
      active_memberships: parseInt(activeUsers.rows[0].count),
    });
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to load stats', details: err.message });
  }
});

// --- AUDIT LOGS ---

// GET /api/admin/audit-logs — Platform-wide audit logs
router.get('/audit-logs', async (req: AuthRequest, res) => {
  try {
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = parseInt(req.query.offset as string) || 0;
    
    const result = await query(
      `SELECT al.*, u.email as user_email, t.name as tenant_name 
       FROM audit_logs al 
       LEFT JOIN users u ON al.user_id = u.id
       LEFT JOIN tenants t ON al.tenant_id = t.id
       ORDER BY al.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to load audit logs', details: err.message });
  }
});

// GET /api/admin/roles — List available roles with permissions
router.get('/roles', async (_req: AuthRequest, res) => {
  const roles = Object.entries(ROLE_PERMISSIONS).map(([role, permissions]) => ({
    role,
    label: role.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase()),
    permissions,
  }));
  res.json(roles);
});

export default router;
