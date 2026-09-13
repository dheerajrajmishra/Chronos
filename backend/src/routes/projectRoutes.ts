import express, { Request, Response } from 'express';
import { query, FACTORY_DEFAULT_PROMPTS } from '../db';
import { AuthRequest, requirePermission } from '../middleware/auth';

const router = express.Router();

// Helper to check if a user has access to a project and specific role (strictly scoped to user's active tenant)
async function checkProjectAccess(projectId: string, user: any, requiredRole?: string): Promise<boolean> {
  // 1. Verify project belongs to user's active tenant
  const pCheck = await query('SELECT id FROM projects WHERE id = $1 AND tenant_id = $2', [projectId, user.tenant_id]);
  if (pCheck.rows.length === 0) return false;

  // 2. System admins and Org admins have full access within their active tenant
  if (user.is_system_admin || user.role === 'org_admin') {
    return true;
  }

  // 3. Normal users need explicit project_users mapping
  const puCheck = await query('SELECT role FROM project_users WHERE project_id = $1 AND user_id = $2', [projectId, user.id]);
  if (puCheck.rows.length === 0) return false;

  const userRole = puCheck.rows[0].role;
  if (requiredRole === 'contributor' && userRole !== 'contributor') {
    return false; // Viewer cannot contribute
  }
  
  return true;
}

// Get projects (Scoped to tenant & user access)
router.get('/projects', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const user = authReq.user!;
    let queryStr = '';
    let params: any[] = [];
    
    if (user.is_system_admin || user.role === 'org_admin') {
      queryStr = 'SELECT *, \'contributor\' as user_role FROM projects WHERE tenant_id = $1 ORDER BY id DESC';
      params = [user.tenant_id];
    } else {
      queryStr = `
        SELECT p.*, pu.role as user_role
        FROM projects p
        JOIN project_users pu ON p.id = pu.project_id
        WHERE p.tenant_id = $1 AND pu.user_id = $2
        ORDER BY p.id DESC
      `;
      params = [user.tenant_id, user.id];
    }
    const result = await query(queryStr, params);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Create project
router.post('/projects', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const { name, description } = req.body;
    const result = await query(
      'INSERT INTO projects (name, description, tenant_id) VALUES ($1, $2, $3) RETURNING *',
      [name, description, authReq.user!.tenant_id]
    );
    const newProject = result.rows[0];

    // Add creator as contributor
    await query(
      'INSERT INTO project_users (project_id, user_id, role) VALUES ($1, $2, $3)',
      [newProject.id, authReq.user!.id, 'contributor']
    );

    res.json(newProject);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Update project
router.put('/projects/:id', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    const { name, description } = req.body;
    const result = await query(
      'UPDATE projects SET name = $1, description = $2 WHERE id = $3 RETURNING *',
      [name, description, projectId]
    );
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Delete project
router.delete('/projects/:id', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    await query('DELETE FROM projects WHERE id = $1', [projectId]);
    res.json({ success: true, message: 'Project deleted successfully' });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// --- PROJECT USERS (Permissions) ---

router.get('/projects/:id/users', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!);
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized' });

    const result = await query(`
      SELECT pu.user_id, pu.role, u.email, u.name 
      FROM project_users pu
      JOIN users u ON pu.user_id = u.id
      WHERE pu.project_id = $1
    `, [projectId]);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.get('/projects/:id/available-users', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!);
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized' });

    const pRes = await query('SELECT tenant_id FROM projects WHERE id = $1', [projectId]);
    if (pRes.rows.length === 0) return res.status(404).json({ error: 'Project not found' });
    const tenantId = pRes.rows[0].tenant_id;

    const result = await query(`
      SELECT u.id, u.email, u.name 
      FROM users u
      JOIN tenant_users tu ON u.id = tu.user_id
      WHERE tu.tenant_id = $1 AND tu.status = 'active'
    `, [tenantId]);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.post('/projects/:id/users', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    let { user_id, email, role } = req.body;
    if (!user_id && email) {
      const uRes = await query('SELECT id FROM users WHERE LOWER(email) = LOWER($1)', [email.trim()]);
      if (uRes.rows.length === 0) return res.status(404).json({ error: 'User with this email not found' });
      user_id = uRes.rows[0].id;
    }

    if (!user_id) {
      return res.status(400).json({ error: 'user_id or email is required' });
    }

    // Verify user exists in tenant (unless system admin)
    const pRes = await query('SELECT tenant_id FROM projects WHERE id = $1', [projectId]);
    const tenantId = pRes.rows.length > 0 ? pRes.rows[0].tenant_id : authReq.user!.tenant_id;

    const tCheck = await query('SELECT * FROM tenant_users WHERE tenant_id = $1 AND user_id = $2', [tenantId, user_id]);
    if (tCheck.rows.length === 0 && !authReq.user!.is_system_admin) {
      return res.status(400).json({ error: 'User is not a member of this tenant' });
    }

    const result = await query(
      'INSERT INTO project_users (project_id, user_id, role) VALUES ($1, $2, $3) ON CONFLICT (project_id, user_id) DO UPDATE SET role = $3 RETURNING *',
      [projectId, user_id, role || 'viewer']
    );

    const uInfo = await query('SELECT email, name FROM users WHERE id = $1', [user_id]);
    const userRow = uInfo.rows[0] || {};

    res.json({
      ...result.rows[0],
      email: userRow.email || '',
      name: userRow.name || ''
    });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.put('/projects/:id/users/:userId', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    const { role } = req.body;
    const result = await query(
      'UPDATE project_users SET role = $1 WHERE project_id = $2 AND user_id = $3 RETURNING *',
      [role, projectId, req.params.userId]
    );

    const uInfo = await query('SELECT email, name FROM users WHERE id = $1', [req.params.userId]);
    const userRow = uInfo.rows[0] || {};

    res.json({
      ...result.rows[0],
      email: userRow.email || '',
      name: userRow.name || ''
    });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.delete('/projects/:id/users/:userId', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    await query('DELETE FROM project_users WHERE project_id = $1 AND user_id = $2', [projectId, req.params.userId]);
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// --- FEATURES ---

router.get('/projects/:id/features', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!);
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized' });

    const result = await query('SELECT * FROM features WHERE project_id = $1 ORDER BY id DESC', [projectId]);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.post('/projects/:id/features', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id as string;
    const hasAccess = await checkProjectAccess(projectId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    const { name, code_access, db_access, base_requirement, brd_prompt, design_prompt, code_prompt, test_prompt, memory_md } = req.body;
    const result = await query(
      `INSERT INTO features (project_id, name, code_access, db_access, base_requirement, brd_prompt, design_prompt, code_prompt, test_prompt, memory_md) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
      [projectId, name, code_access, db_access, base_requirement, brd_prompt, design_prompt, code_prompt, test_prompt, memory_md]
    );
    const featureId = result.rows[0].id;
    await query('INSERT INTO workflows (feature_id, current_stage, status) VALUES ($1, 1, $2)', [featureId, 'pending']);
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Helper for feature access
async function checkFeatureAccess(featureId: string, user: any, requiredRole?: string): Promise<boolean> {
  const fCheck = await query('SELECT project_id FROM features WHERE id = $1', [featureId]);
  if (fCheck.rows.length === 0) return false;
  return checkProjectAccess(fCheck.rows[0].project_id.toString(), user, requiredRole);
}

router.put('/features/:id', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const featureId = req.params.id as string;
    const hasAccess = await checkFeatureAccess(featureId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    const { name, code_access, db_access, base_requirement, brd_prompt, design_prompt, code_prompt, test_prompt, memory_md, memory_prompt } = req.body;
    const result = await query(
      `UPDATE features SET name = $1, code_access = $2, db_access = $3, base_requirement = $4, brd_prompt = $5, design_prompt = $6, code_prompt = $7, test_prompt = $8, memory_md = $9, memory_prompt = COALESCE($10, memory_prompt)
       WHERE id = $11 RETURNING *`,
      [name, code_access, db_access, base_requirement, brd_prompt, design_prompt, code_prompt, test_prompt, memory_md, memory_prompt, featureId]
    );
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.delete('/features/:id', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const featureId = req.params.id as string;
    const hasAccess = await checkFeatureAccess(featureId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    await query('DELETE FROM workflows WHERE feature_id = $1', [featureId]);
    await query('DELETE FROM features WHERE id = $1', [featureId]);
    res.json({ success: true, message: 'Feature deleted successfully' });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.put('/features/:id/prompts', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const featureId = req.params.id as string;
    const hasAccess = await checkFeatureAccess(featureId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    const {
      memory_prompt, brd_prompt, design_prompt, tech_doc_prompt, code_prompt,
      unit_test_prompt, test_prompt, uat_prompt, deploy_prompt,
      test_case_creation_prompt, test_automation_prompt, testing_result_prompt, stage_prompts,
    } = req.body;

    const result = await query(
      `UPDATE features 
       SET memory_prompt = COALESCE($1, memory_prompt),
           brd_prompt = COALESCE($2, brd_prompt),
           design_prompt = COALESCE($3, design_prompt),
           tech_doc_prompt = COALESCE($4, tech_doc_prompt),
           code_prompt = COALESCE($5, code_prompt),
           unit_test_prompt = COALESCE($6, unit_test_prompt),
           test_prompt = COALESCE($7, test_prompt),
           uat_prompt = COALESCE($8, uat_prompt),
           deploy_prompt = COALESCE($9, deploy_prompt),
           test_case_creation_prompt = COALESCE($10, test_case_creation_prompt),
           test_automation_prompt = COALESCE($11, test_automation_prompt),
           testing_result_prompt = COALESCE($12, testing_result_prompt),
           stage_prompts = COALESCE($13, stage_prompts)
       WHERE id = $14 RETURNING *`,
      [
        memory_prompt, brd_prompt, design_prompt, tech_doc_prompt, code_prompt,
        unit_test_prompt, test_prompt, uat_prompt, deploy_prompt,
        test_case_creation_prompt, test_automation_prompt, testing_result_prompt,
        stage_prompts ? JSON.stringify(stage_prompts) : null, featureId,
      ]
    );
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.get('/features/:id/workflow', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const featureId = req.params.id as string;
    const hasAccess = await checkFeatureAccess(featureId, authReq.user!);
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized' });

    const result = await query('SELECT * FROM workflows WHERE feature_id = $1 LIMIT 1', [featureId]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Workflow not found' });
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.put('/features/:id/workflow', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const featureId = req.params.id as string;
    const hasAccess = await checkFeatureAccess(featureId, authReq.user!, 'contributor');
    if (!hasAccess) return res.status(403).json({ error: 'Unauthorized or insufficient permissions' });

    const { current_stage, status, stage_data } = req.body;
    
    const existing = await query('SELECT * FROM workflows WHERE feature_id = $1', [featureId]);
    if (existing.rows.length === 0) return res.status(404).json({ error: 'Workflow not found' });
    
    const currentData = existing.rows[0].stage_data || {};
    const newData = { ...currentData, ...stage_data };
    
    const result = await query(
      `UPDATE workflows 
       SET current_stage = COALESCE($1, current_stage), 
           status = COALESCE($2, status), 
           stage_data = $3,
           updated_at = CURRENT_TIMESTAMP
       WHERE feature_id = $4 RETURNING *`,
      [current_stage, status, newData, featureId]
    );
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Settings Endpoints
router.get('/settings', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const result = await query('SELECT key, value FROM tenant_settings WHERE tenant_id = $1', [authReq.user!.tenant_id]);
    const settingsMap: Record<string, any> = {};
    for (const row of result.rows) {
      settingsMap[row.key] = row.value;
    }
    
    const theme = settingsMap['theme'] || { mode: 'light' };
    const defaultPrompts = settingsMap['default_prompts'] || FACTORY_DEFAULT_PROMPTS;

    res.json({ theme, defaultPrompts, factoryDefaults: FACTORY_DEFAULT_PROMPTS });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.post('/settings', requirePermission('manage_settings'), async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const { theme, defaultPrompts } = req.body;
    
    if (theme) {
      await query(
        `INSERT INTO tenant_settings (tenant_id, key, value) 
         VALUES ($1, 'theme', $2::jsonb)
         ON CONFLICT (tenant_id, key) DO UPDATE SET value = $2::jsonb`,
        [authReq.user!.tenant_id, JSON.stringify(theme)]
      );
    }
    
    if (defaultPrompts) {
      await query(
        `INSERT INTO tenant_settings (tenant_id, key, value) 
         VALUES ($1, 'default_prompts', $2::jsonb)
         ON CONFLICT (tenant_id, key) DO UPDATE SET value = $2::jsonb`,
        [authReq.user!.tenant_id, JSON.stringify(defaultPrompts)]
      );
    }
    
    res.json({ success: true, message: 'Settings saved successfully' });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

router.post('/settings/reset-prompts', requirePermission('manage_settings'), async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    await query(
      `DELETE FROM tenant_settings WHERE tenant_id = $1 AND key = 'default_prompts'`,
      [authReq.user!.tenant_id]
    );
    res.json({ success: true, message: 'Prompts reset to factory defaults' });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

export default router;
