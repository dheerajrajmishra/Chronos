import express from 'express';
import bcrypt from 'bcrypt';
import { query } from '../db';
import { requireAuth, requireRole, AuthRequest } from '../middleware/auth';

const router = express.Router();

// --- USER MANAGEMENT ---
router.get('/users', requireAuth, requireRole(['org_admin', 'system_admin']), async (req: AuthRequest, res) => {
  try {
    const result = await query(
      `SELECT u.id, u.email, tu.role, tu.created_at 
       FROM users u 
       JOIN tenant_users tu ON u.id = tu.user_id 
       WHERE tu.tenant_id = $1`,
      [req.user!.tenant_id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load users' });
  }
});

router.post('/users', requireAuth, requireRole(['org_admin']), async (req: AuthRequest, res) => {
  const { email, password, role } = req.body;
  try {
    const hash = await bcrypt.hash(password, 10);
    const userRes = await query(
      `INSERT INTO users (email, password_hash) VALUES ($1, $2) ON CONFLICT (email) DO UPDATE SET email=EXCLUDED.email RETURNING id`,
      [email, hash]
    );
    const userId = userRes.rows[0].id;

    await query(
      `INSERT INTO tenant_users (tenant_id, user_id, role) VALUES ($1, $2, $3) ON CONFLICT (tenant_id, user_id) DO UPDATE SET role = $3`,
      [req.user!.tenant_id, userId, role]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create user' });
  }
});

router.delete('/users/:id', requireAuth, requireRole(['org_admin']), async (req: AuthRequest, res) => {
  try {
    // Just remove from tenant, don't delete user completely
    await query(`DELETE FROM tenant_users WHERE tenant_id = $1 AND user_id = $2`, [req.user!.tenant_id, req.params.id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to remove user' });
  }
});

// --- IP WHITELIST MANAGEMENT ---
router.get('/ips', requireAuth, requireRole(['org_admin', 'system_admin']), async (req: AuthRequest, res) => {
  try {
    const result = await query(`SELECT * FROM ip_whitelists WHERE tenant_id = $1`, [req.user!.tenant_id]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load IPs' });
  }
});

router.post('/ips', requireAuth, requireRole(['org_admin']), async (req: AuthRequest, res) => {
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

router.delete('/ips/:id', requireAuth, requireRole(['org_admin']), async (req: AuthRequest, res) => {
  try {
    await query(`DELETE FROM ip_whitelists WHERE tenant_id = $1 AND id = $2`, [req.user!.tenant_id, req.params.id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete IP' });
  }
});

export default router;
