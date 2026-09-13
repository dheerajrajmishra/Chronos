import express from 'express';
import bcrypt from 'bcrypt';
import { query } from '../db';
import { generateToken, requireAuth, AuthRequest } from '../middleware/auth';

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
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Find the default tenant for this user
    // For a multi-tenant app, the user might belong to multiple tenants, but we just grab the first one for simplicity,
    // or let the frontend supply a tenant_id they want to login to.
    const tuRes = await query('SELECT tenant_id, role FROM tenant_users WHERE user_id = $1 LIMIT 1', [user.id]);
    
    if (tuRes.rows.length === 0) {
      return res.status(403).json({ error: 'User does not belong to any organization' });
    }

    const tenantUser = tuRes.rows[0];
    
    const token = generateToken(user, tenantUser.tenant_id, tenantUser.role);

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        role: tenantUser.role,
        tenant_id: tenantUser.tenant_id
      }
    });

  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/me', requireAuth, (req: AuthRequest, res) => {
  res.json({ user: req.user });
});

export default router;
