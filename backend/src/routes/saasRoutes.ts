import express from 'express';
import bcrypt from 'bcrypt';
import { query, ROLE_PERMISSIONS } from '../db';
import { requireAuth, requireRole, requirePermission, AuthRequest, getEffectivePermissions } from '../middleware/auth';

const router = express.Router();

// --- USER MANAGEMENT (within tenant scope) ---

// GET /api/saas/users — List users in current tenant
router.get('/users', requireAuth, requirePermission('manage_users'), async (req: AuthRequest, res) => {
  try {
    const result = await query(
      `SELECT u.id, u.email, u.name, u.status as user_status, u.last_login, u.created_at,
              tu.role, tu.permissions, tu.status as membership_status
       FROM users u 
       JOIN tenant_users tu ON u.id = tu.user_id 
       WHERE tu.tenant_id = $1
       ORDER BY tu.created_at ASC`,
      [req.user!.tenant_id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load users' });
  }
});

// POST /api/saas/users — Create/add user to current tenant
router.post('/users', requireAuth, requirePermission('manage_users'), async (req: AuthRequest, res) => {
  const { email, password, name, role } = req.body;
  if (!email) return res.status(400).json({ error: 'Email is required' });

  try {
    // Check tenant max_users limit
    const tenantRes = await query('SELECT max_users FROM tenants WHERE id = $1', [req.user!.tenant_id]);
    const currentCount = await query(
      'SELECT COUNT(*) as count FROM tenant_users WHERE tenant_id = $1 AND status = \'active\'',
      [req.user!.tenant_id]
    );
    if (tenantRes.rows.length > 0 && parseInt(currentCount.rows[0].count) >= tenantRes.rows[0].max_users) {
      return res.status(403).json({ error: `Organization has reached the maximum user limit (${tenantRes.rows[0].max_users}). Upgrade your plan.` });
    }

    // Prevent non-system-admins from creating org_admin users (unless they are org_admin themselves)
    const validRoles = ['viewer', 'editor', 'org_admin'];
    const assignedRole = validRoles.includes(role) ? role : 'viewer';

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

    await query(
      `INSERT INTO tenant_users (tenant_id, user_id, role, status) VALUES ($1, $2, $3, 'active')
       ON CONFLICT (tenant_id, user_id) DO UPDATE SET role = $3, status = 'active'`,
      [req.user!.tenant_id, userId, assignedRole]
    );

    // Audit log
    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'add_user', 'user', $3, $4)`,
      [req.user!.tenant_id, req.user!.id, userId, JSON.stringify({ email, role: assignedRole })]
    );

    res.json({ success: true, user_id: userId });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create user' });
  }
});

// PUT /api/saas/users/:id — Update user role within tenant
router.put('/users/:id', requireAuth, requirePermission('manage_users'), async (req: AuthRequest, res) => {
  const { role, name } = req.body;
  try {
    if (role) {
      await query(
        `UPDATE tenant_users SET role = $1 WHERE tenant_id = $2 AND user_id = $3`,
        [role, req.user!.tenant_id, req.params.id]
      );
    }
    if (name !== undefined) {
      await query(`UPDATE users SET name = $1 WHERE id = $2`, [name, req.params.id]);
    }

    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'update_user_role', 'user', $3, $4)`,
      [req.user!.tenant_id, req.user!.id, req.params.id, JSON.stringify({ role, name })]
    );

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update user' });
  }
});

// PUT /api/saas/users/:id/permissions — Update user's granular permissions
router.put('/users/:id/permissions', requireAuth, requirePermission('manage_users'), async (req: AuthRequest, res) => {
  const { permissions } = req.body;
  try {
    await query(
      `UPDATE tenant_users SET permissions = $1 WHERE tenant_id = $2 AND user_id = $3`,
      [JSON.stringify(permissions || {}), req.user!.tenant_id, req.params.id]
    );

    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'update_user_permissions', 'user', $3, $4)`,
      [req.user!.tenant_id, req.user!.id, req.params.id, JSON.stringify({ permissions })]
    );

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update permissions' });
  }
});

// GET /api/saas/users/:id/permissions — Get user's effective permissions
router.get('/users/:id/permissions', requireAuth, requirePermission('manage_users'), async (req: AuthRequest, res) => {
  try {
    const tuRes = await query(
      `SELECT role, permissions FROM tenant_users WHERE tenant_id = $1 AND user_id = $2`,
      [req.user!.tenant_id, req.params.id]
    );
    if (tuRes.rows.length === 0) return res.status(404).json({ error: 'User not found in this organization' });
    
    const { role, permissions: overrides } = tuRes.rows[0];
    const effectivePerms = getEffectivePermissions(role, overrides || {});
    
    res.json({ 
      role, 
      role_permissions: ROLE_PERMISSIONS[role] || {},
      overrides: overrides || {},
      effective: effectivePerms 
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to get permissions' });
  }
});

// PUT /api/saas/users/:id/status — Activate/deactivate user within tenant
router.put('/users/:id/status', requireAuth, requirePermission('manage_users'), async (req: AuthRequest, res) => {
  const { status } = req.body;
  if (!['active', 'inactive'].includes(status)) {
    return res.status(400).json({ error: 'Invalid status. Must be "active" or "inactive"' });
  }

  try {
    // Prevent deactivating yourself
    if (parseInt(req.params.id as string) === req.user!.id) {
      return res.status(403).json({ error: 'Cannot change your own status' });
    }

    await query(
      `UPDATE tenant_users SET status = $1 WHERE tenant_id = $2 AND user_id = $3`,
      [status, req.user!.tenant_id, req.params.id]
    );

    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'change_user_status', 'user', $3, $4)`,
      [req.user!.tenant_id, req.user!.id, req.params.id, JSON.stringify({ status })]
    );

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to change user status' });
  }
});

// DELETE /api/saas/users/:id — Remove user from tenant
router.delete('/users/:id', requireAuth, requirePermission('manage_users'), async (req: AuthRequest, res) => {
  try {
    if (parseInt(req.params.id as string) === req.user!.id) {
      return res.status(403).json({ error: 'Cannot remove yourself from the organization' });
    }

    await query(`DELETE FROM tenant_users WHERE tenant_id = $1 AND user_id = $2`, [req.user!.tenant_id, req.params.id]);

    await query(
      `INSERT INTO audit_logs (tenant_id, user_id, action, entity_type, entity_id, details)
       VALUES ($1, $2, 'remove_user', 'user', $3, '{}'::jsonb)`,
      [req.user!.tenant_id, req.user!.id, req.params.id]
    );

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to remove user' });
  }
});

// --- ROLES INFO ---

// GET /api/saas/roles — List available roles with descriptions
router.get('/roles', requireAuth, async (_req: AuthRequest, res) => {
  const roles = Object.entries(ROLE_PERMISSIONS).map(([role, permissions]) => ({
    role,
    label: role.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
    permissions,
    description: getRoleDescription(role),
  }));
  // Don't expose system_admin role to non-system-admins
  const filtered = _req.user?.is_system_admin ? roles : roles.filter(r => r.role !== 'system_admin');
  res.json(filtered);
});

// GET /api/saas/me/profile — Current user's full profile + permissions
router.get('/me/profile', requireAuth, async (req: AuthRequest, res) => {
  try {
    const userRes = await query('SELECT id, email, name, status, last_login, created_at FROM users WHERE id = $1', [req.user!.id]);
    const tuRes = await query(
      `SELECT tu.role, tu.permissions, tu.status as membership_status, t.name as tenant_name, t.plan
       FROM tenant_users tu JOIN tenants t ON tu.tenant_id = t.id
       WHERE tu.tenant_id = $1 AND tu.user_id = $2`,
      [req.user!.tenant_id, req.user!.id]
    );

    if (userRes.rows.length === 0) return res.status(404).json({ error: 'User not found' });

    const user = userRes.rows[0];
    const membership = tuRes.rows[0] || {};
    const effectivePerms = getEffectivePermissions(membership.role || 'viewer', membership.permissions || {});

    res.json({
      ...user,
      role: membership.role,
      tenant_name: membership.tenant_name,
      plan: membership.plan,
      permissions: effectivePerms,
      is_system_admin: req.user!.is_system_admin,
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to load profile' });
  }
});

// --- IP WHITELIST MANAGEMENT ---
router.get('/ips', requireAuth, requirePermission('manage_settings'), async (req: AuthRequest, res) => {
  try {
    const result = await query(`SELECT * FROM ip_whitelists WHERE tenant_id = $1`, [req.user!.tenant_id]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load IPs' });
  }
});

router.post('/ips', requireAuth, requirePermission('manage_settings'), async (req: AuthRequest, res) => {
  const { ip_cidr, description } = req.body;
  try {
    await query(
      `INSERT INTO ip_whitelists (tenant_id, ip_cidr, description) VALUES ($1, $2, $3)`,
      [req.user!.tenant_id, ip_cidr, description]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to add IP' });
  }
});

router.delete('/ips/:id', requireAuth, requirePermission('manage_settings'), async (req: AuthRequest, res) => {
  try {
    await query(`DELETE FROM ip_whitelists WHERE tenant_id = $1 AND id = $2`, [req.user!.tenant_id, req.params.id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete IP' });
  }
});

function getRoleDescription(role: string): string {
  switch (role) {
    case 'system_admin': return 'Full platform access. Manages tenants, users, and global configuration.';
    case 'org_admin': return 'Organization administrator. Manages users, projects, features, and settings within the tenant.';
    case 'editor': return 'Can create and edit projects, features, and run SDLC pipeline stages.';
    case 'viewer': return 'Read-only access to projects and features within the organization.';
    default: return 'Custom role';
  }
}

export default router;
