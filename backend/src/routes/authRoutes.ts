import express from 'express';
import bcrypt from 'bcrypt';
import { query } from '../db';
import { generateToken, requireAuth, AuthRequest, getEffectivePermissions } from '../middleware/auth';

const router = express.Router();

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  try {
    const userRes = await query('SELECT * FROM users WHERE email = $1', [email]);
    if (userRes.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = userRes.rows[0];
    
    // Check if user is active
    if (user.status === 'inactive') {
      return res.status(403).json({ error: 'Account has been deactivated. Contact your administrator.' });
    }

    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Update last_login timestamp
    await query('UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1', [user.id]);

    // Find all tenants this user belongs to
    const tenantsRes = await query(
      `SELECT tu.tenant_id, tu.role, tu.permissions, tu.status as membership_status,
              t.name as tenant_name, t.slug as tenant_slug, t.status as tenant_status, t.plan
       FROM tenant_users tu 
       JOIN tenants t ON tu.tenant_id = t.id 
       WHERE tu.user_id = $1 AND tu.status = 'active' AND t.status = 'active'
       ORDER BY tu.tenant_id ASC`,
      [user.id]
    );
    
    if (tenantsRes.rows.length === 0) {
      return res.status(403).json({ error: 'User does not belong to any active organization' });
    }

    // Use the first active tenant as default (or the one specified by the client)
    const tenantUser = tenantsRes.rows[0];
    const permissions = getEffectivePermissions(tenantUser.role, tenantUser.permissions || {});
    
    const token = generateToken(user, tenantUser.tenant_id, tenantUser.role, permissions);

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name || '',
        role: tenantUser.role,
        tenant_id: tenantUser.tenant_id,
        tenant_name: tenantUser.tenant_name,
        is_system_admin: user.is_system_admin,
        permissions,
      },
      tenants: tenantsRes.rows.map((t: any) => ({
        tenant_id: t.tenant_id,
        tenant_name: t.tenant_name,
        tenant_slug: t.tenant_slug,
        role: t.role,
        plan: t.plan,
      })),
    });

  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Register a new user (creates user + optionally joins a tenant)
router.post('/register', async (req, res) => {
  const { email, password, name } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  try {
    // Check if user already exists
    const existing = await query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'User with this email already exists' });
    }

    const hash = await bcrypt.hash(password, 10);
    const userRes = await query(
      `INSERT INTO users (email, name, password_hash, status) VALUES ($1, $2, $3, 'active') RETURNING *`,
      [email, name || '', hash]
    );
    const newUser = userRes.rows[0];

    // Create a personal tenant for self-registration
    const tenantSlug = email.split('@')[0].replace(/[^a-z0-9-]/gi, '-').toLowerCase();
    const tenantRes = await query(
      `INSERT INTO tenants (name, slug, status, plan) VALUES ($1, $2, 'active', 'free') RETURNING *`,
      [`${name || email}'s Workspace`, tenantSlug]
    );
    const newTenant = tenantRes.rows[0];

    // Add user as org_admin of their own tenant
    await query(
      `INSERT INTO tenant_users (tenant_id, user_id, role, status) VALUES ($1, $2, 'org_admin', 'active')`,
      [newTenant.id, newUser.id]
    );

    // Seed default settings for the new tenant
    await query(
      `INSERT INTO tenant_settings (tenant_id, key, value) VALUES ($1, 'theme', '{"mode": "light"}'::jsonb) ON CONFLICT DO NOTHING`,
      [newTenant.id]
    );

    const permissions = getEffectivePermissions('org_admin');
    const token = generateToken(newUser, newTenant.id, 'org_admin', permissions);

    res.json({
      token,
      user: {
        id: newUser.id,
        email: newUser.email,
        name: newUser.name,
        role: 'org_admin',
        tenant_id: newTenant.id,
        tenant_name: newTenant.name,
        is_system_admin: false,
        permissions,
      },
      tenants: [{
        tenant_id: newTenant.id,
        tenant_name: newTenant.name,
        tenant_slug: newTenant.slug,
        role: 'org_admin',
        plan: 'free',
      }],
    });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Switch tenant context (for users belonging to multiple tenants)
router.post('/switch-tenant', requireAuth, async (req: AuthRequest, res) => {
  const { tenant_id } = req.body;
  if (!tenant_id) {
    return res.status(400).json({ error: 'tenant_id is required' });
  }

  try {
    // Verify user belongs to this tenant
    const tuRes = await query(
      `SELECT tu.*, t.name as tenant_name, t.slug as tenant_slug, t.status as tenant_status, t.plan 
       FROM tenant_users tu JOIN tenants t ON tu.tenant_id = t.id
       WHERE tu.user_id = $1 AND tu.tenant_id = $2 AND tu.status = 'active' AND t.status = 'active'`,
      [req.user!.id, tenant_id]
    );
    
    if (tuRes.rows.length === 0) {
      return res.status(403).json({ error: 'You do not have access to this organization' });
    }

    const membership = tuRes.rows[0];
    const userRes = await query('SELECT * FROM users WHERE id = $1', [req.user!.id]);
    const user = userRes.rows[0];
    
    const permissions = getEffectivePermissions(membership.role, membership.permissions || {});
    const token = generateToken(user, tenant_id, membership.role, permissions);

    // Fetch all tenants for the response
    const tenantsRes = await query(
      `SELECT tu.tenant_id, tu.role, t.name as tenant_name, t.slug as tenant_slug, t.plan
       FROM tenant_users tu JOIN tenants t ON tu.tenant_id = t.id
       WHERE tu.user_id = $1 AND tu.status = 'active' AND t.status = 'active'`,
      [req.user!.id]
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name || '',
        role: membership.role,
        tenant_id: tenant_id,
        tenant_name: membership.tenant_name,
        is_system_admin: user.is_system_admin,
        permissions,
      },
      tenants: tenantsRes.rows.map((t: any) => ({
        tenant_id: t.tenant_id,
        tenant_name: t.tenant_name,
        tenant_slug: t.tenant_slug,
        role: t.role,
        plan: t.plan,
      })),
    });
  } catch (err) {
    console.error('Switch tenant error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/me', requireAuth, async (req: AuthRequest, res) => {
  try {
    // Fetch user's tenants
    const tenantsRes = await query(
      `SELECT tu.tenant_id, tu.role, t.name as tenant_name, t.slug as tenant_slug, t.plan
       FROM tenant_users tu JOIN tenants t ON tu.tenant_id = t.id
       WHERE tu.user_id = $1 AND tu.status = 'active' AND t.status = 'active'`,
      [req.user!.id]
    );

    res.json({ 
      user: req.user,
      tenants: tenantsRes.rows.map((t: any) => ({
        tenant_id: t.tenant_id,
        tenant_name: t.tenant_name,
        tenant_slug: t.tenant_slug,
        role: t.role,
        plan: t.plan,
      })),
    });
  } catch (err) {
    res.json({ user: req.user, tenants: [] });
  }
});

export default router;
