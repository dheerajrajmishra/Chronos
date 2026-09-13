import express, { Request, Response } from 'express';
import { query, FACTORY_DEFAULT_PROMPTS } from '../db';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Get projects (Scoped to tenant)
router.get('/projects', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const result = await query('SELECT * FROM projects WHERE tenant_id = $1 ORDER BY id DESC', [authReq.user!.tenant_id]);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Create project (Scoped to tenant)
router.post('/projects', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const { name, description } = req.body;
    const result = await query(
      'INSERT INTO projects (name, description, tenant_id) VALUES ($1, $2, $3) RETURNING *',
      [name, description, authReq.user!.tenant_id]
    );
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Update project
router.put('/projects/:id', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id;
    const { name, description } = req.body;
    const result = await query(
      'UPDATE projects SET name = $1, description = $2 WHERE id = $3 AND tenant_id = $4 RETURNING *',
      [name, description, projectId, authReq.user!.tenant_id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Project not found or unauthorized' });
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Delete project
router.delete('/projects/:id', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    const projectId = req.params.id;
    const result = await query('DELETE FROM projects WHERE id = $1 AND tenant_id = $2 RETURNING *', [projectId, authReq.user!.tenant_id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Project not found or unauthorized' });
    res.json({ success: true, message: 'Project deleted successfully' });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Get features for project
router.get('/projects/:id/features', async (req: Request, res: Response) => {
  try {
    const projectId = req.params.id;
    const result = await query('SELECT * FROM features WHERE project_id = $1 ORDER BY id DESC', [projectId]);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Create feature
router.post('/projects/:id/features', async (req: Request, res: Response) => {
  try {
    const projectId = req.params.id;
    const { name, code_access, db_access, base_requirement, brd_prompt, design_prompt, code_prompt, test_prompt, memory_md } = req.body;
    const result = await query(
      `INSERT INTO features (project_id, name, code_access, db_access, base_requirement, brd_prompt, design_prompt, code_prompt, test_prompt, memory_md) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
      [projectId, name, code_access, db_access, base_requirement, brd_prompt, design_prompt, code_prompt, test_prompt, memory_md]
    );
    const featureId = result.rows[0].id;
    // Auto-create initial workflow state
    await query('INSERT INTO workflows (feature_id, current_stage, status) VALUES ($1, 1, $2)', [featureId, 'pending']);
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Update feature
router.put('/features/:id', async (req: Request, res: Response) => {
  try {
    const featureId = req.params.id;
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

// Delete feature
router.delete('/features/:id', async (req: Request, res: Response) => {
  try {
    const featureId = req.params.id;
    await query('DELETE FROM workflows WHERE feature_id = $1', [featureId]);
    await query('DELETE FROM features WHERE id = $1', [featureId]);
    res.json({ success: true, message: 'Feature deleted successfully' });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Update feature prompts
router.put('/features/:id/prompts', async (req: Request, res: Response) => {
  try {
    const featureId = req.params.id;
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

// Get workflow
router.get('/features/:id/workflow', async (req: Request, res: Response) => {
  try {
    const featureId = req.params.id;
    const result = await query('SELECT * FROM workflows WHERE feature_id = $1 LIMIT 1', [featureId]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Workflow not found' });
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Update workflow stage
router.put('/features/:id/workflow', async (req: Request, res: Response) => {
  try {
    const featureId = req.params.id;
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

router.post('/settings', async (req: Request, res: Response) => {
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

router.post('/settings/reset-prompts', async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  try {
    await query(
      `INSERT INTO tenant_settings (tenant_id, key, value) 
       VALUES ($1, 'default_prompts', $2::jsonb)
       ON CONFLICT (tenant_id, key) DO UPDATE SET value = $2::jsonb`,
      [authReq.user!.tenant_id, JSON.stringify(FACTORY_DEFAULT_PROMPTS)]
    );
    res.json({ success: true, defaultPrompts: FACTORY_DEFAULT_PROMPTS });
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

export default router;
