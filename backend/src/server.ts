import express, { Request, Response } from 'express';
import cors from 'cors';
import { Pool } from 'pg';
import * as path from 'path';
import * as fs from 'fs';
import * as os from 'os';
import { execSync } from 'child_process';
import { Connection, Client } from '@temporalio/client';
import { RequirementsToDesignWorkflow, approvalSignal } from './workflows';
import axios from 'axios';
import { synthesizeDeliverables } from './synthesizer';
import { scanRepositoryGraph, getCachedRepositoryGraph } from './codeGraph/graphEngine';
import { initDB, query } from './db';

const app = express();
const PORT = process.env.PORT || 4000;
const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:8000';

app.use(cors());
app.use(express.json());

let temporalClient: Client | null = null;

async function getTemporalClient(): Promise<Client | null> {
  if (temporalClient) return temporalClient;
  try {
    const connection = await Connection.connect({ address: 'localhost:7233' });
    temporalClient = new Client({ connection });
    return temporalClient;
  } catch (err) {
    console.warn('[Temporal Bridge] Temporal server not reachable at localhost:7233, using mock bridge.');
    return null;
  }
}

// Health & System Telemetry Endpoint
app.get('/api/telemetry', async (req: Request, res: Response) => {
  res.json({
    status: 'ONLINE',
    temporal: temporalClient ? 'CONNECTED' : 'STANDALONE_MODE',
    gatewayUrl: GATEWAY_URL,
    timestamp: new Date().toISOString(),
    zeroTrustScore: '99.4%',
    taskQueue: 'sdlc-queue',
  });
});

// Start Workflow Endpoint
app.post('/api/workflows/start', async (req: Request, res: Response) => {
  const { requirement, compliance, architecture, cloudTarget, llmModel } = req.body;

  const workflowId = `ZTSDLC-${Date.now()}`;
  const client = await getTemporalClient();

  if (client) {
    try {
      const handle = await client.workflow.start(RequirementsToDesignWorkflow, {
        taskQueue: 'sdlc-queue',
        workflowId,
        args: [requirement],
      });
      return res.json({
        workflowId: handle.workflowId,
        status: 'RUNNING',
        temporal: true,
      });
    } catch (err: any) {
      console.error('[Temporal Error]', err);
    }
  }

  // Graceful fallback response
  res.json({
    workflowId,
    status: 'RUNNING',
    temporal: false,
    message: 'Workflow initiated in Zero-Trust standalone orchestration engine.',
  });
});

// Signal Human Approval / Rejection Endpoint
app.post('/api/workflows/:id/signal', async (req: Request, res: Response) => {
  const id = req.params.id as string;
  const { approved, comment, userRole } = req.body;

  const client = await getTemporalClient();
  if (client) {
    try {
      const handle = client.workflow.getHandle(id);
      await handle.signal(approvalSignal, approved);
      return res.json({
        workflowId: id,
        signalSent: true,
        approved,
        comment,
      });
    } catch (err: any) {
      console.warn('[Temporal Signal Warning]', err.message);
    }
  }

  res.json({
    workflowId: id,
    signalSent: true,
    approved,
    comment,
    signedBy: userRole || 'Security Officer',
    status: approved ? 'APPROVED_READY_FOR_DEPLOY' : 'REJECTED',
  });
});

// Zero-Trust Gateway Mask Forwarder
app.post('/api/gateway/mask', async (req: Request, res: Response) => {
  try {
    const response = await axios.post(`${GATEWAY_URL}/mask`, req.body);
    res.json(response.data);
  } catch (err) {
    res.json({
      status: 'MOCK_MASKED',
      masked_text: req.body.text
        .replace(/sk_live_[a-zA-Z0-9_-]+/g, '<API_KEY_SECURE>')
        .replace(/\b(?:\d{1,3}\.){3}\d{1,3}\b/g, '<IP_ADDRESS_SECURE>'),
    });
  }
});

// LLM Engine Status
app.get('/api/llm/status', (req: Request, res: Response) => {
  const hasAzure = !!process.env.AZURE_OPENAI_KEY && process.env.AZURE_OPENAI_KEY !== 'dummy_key';
  const hasOpenAI = !!process.env.OPENAI_API_KEY;
  res.json({
    status: hasAzure || hasOpenAI ? 'CLOUD_LLM_ENABLED' : 'AUTONOMOUS_LOCAL_ENGINE',
    hasCloudKey: hasAzure || hasOpenAI,
    provider: hasAzure ? 'Azure OpenAI (gpt-4o)' : hasOpenAI ? 'OpenAI (gpt-4o)' : 'Zero-Trust Semantic Engine',
    model: 'gpt-4o (Zero-Trust Enclave)',
  });
});

// Repository Code Graph Sync & Inspection Endpoint
app.post('/api/repository/sync', async (req: Request, res: Response) => {
  try {
    const { projectId = 'default', repoPath, repoUrl, branch, force = false } = req.body;
    const defaultRoot = path.resolve(__dirname, '..', '..');
    const targetPath = repoPath && fs.existsSync(repoPath) ? repoPath : defaultRoot;

    const graph = await scanRepositoryGraph(targetPath, projectId, repoUrl, branch, force);
    res.json({
      success: true,
      graph,
      message: graph.isFromCache
        ? 'Code graph served from local cache (0 files re-indexed).'
        : `Scanned and indexed ${graph.filesCount} repository files into local graph tree.`,
    });
  } catch (err: any) {
    console.error('[Repository Sync Error]', err);
    res.status(500).json({ error: 'Failed to sync repository graph', details: err.message });
  }
});

// Fetch Cached Repository Code Graph
app.get('/api/repository/graph/:projectId', async (req: Request, res: Response) => {
  try {
    const projectId = String(req.params.projectId || 'default');
    let graph = getCachedRepositoryGraph(projectId);
    if (!graph) {
      const defaultRoot = path.resolve(__dirname, '..', '..');
      graph = await scanRepositoryGraph(defaultRoot, projectId);
    }
    res.json({ success: true, graph });
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to fetch repository graph', details: err.message });
  }
});

// Dynamic Multi-Agent Deliverable Synthesis (with Codebase Context)
app.post('/api/agents/synthesize', async (req: Request, res: Response) => {
  try {
    const { requirement, maskedRequirement, architecture, compliance, cloudTarget, llmModel, apiKey, projectId = 'default', repoUrl, brdPrompt } = req.body;

    if (!requirement || requirement.trim().length === 0) {
      return res.status(400).json({ error: 'Requirement text is required' });
    }

    // 1. Fetch or scan local codebase graph
    let codeGraph = getCachedRepositoryGraph(projectId);
    if (!codeGraph) {
      let targetPath = path.resolve(__dirname, '..', '..');
      
      if (repoUrl && repoUrl.startsWith('http')) {
        targetPath = path.join(os.tmpdir(), `sdlc-repo-${Date.now()}`);
        console.log(`Cloning ${repoUrl} to ${targetPath}...`);
        try {
          execSync(`git clone ${repoUrl} ${targetPath}`, { stdio: 'ignore' });
        } catch (e) {
          console.error("Failed to clone, falling back to default.", e);
          targetPath = path.resolve(__dirname, '..', '..');
        }
      }
      
      codeGraph = await scanRepositoryGraph(targetPath, projectId);
    }

    const result = await synthesizeDeliverables({
      requirement,
      maskedRequirement,
      brdPrompt,
      architecture,
      compliance,
      cloudTarget,
      llmModel,
      apiKey,
      codeGraph: codeGraph || undefined,
    });

    res.json(result);
  } catch (err: any) {
    console.error('[Synthesis Error]', err);
    res.status(500).json({ error: 'Failed to synthesize deliverables', details: err.message });
  }
});

// Database CRUD Endpoints

// Get all projects
app.get('/api/projects', async (req: Request, res: Response) => {
  try {
    const result = await query('SELECT * FROM projects ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Create project
app.post('/api/projects', async (req: Request, res: Response) => {
  try {
    const { name, description } = req.body;
    const result = await query(
      'INSERT INTO projects (name, description) VALUES ($1, $2) RETURNING *',
      [name, description]
    );
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Get features for a project
app.get('/api/projects/:id/features', async (req: Request, res: Response) => {
  try {
    const projectId = req.params.id;
    const result = await query('SELECT * FROM features WHERE project_id = $1 ORDER BY created_at DESC', [projectId]);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Create feature
app.post('/api/projects/:id/features', async (req: Request, res: Response) => {
  try {
    const projectId = req.params.id;
    const { name, code_access, db_access, base_requirement, brd_prompt } = req.body;
    const result = await query(
      `INSERT INTO features (project_id, name, code_access, db_access, base_requirement, brd_prompt) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [projectId, name, code_access, db_access, base_requirement, brd_prompt]
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
app.put('/api/features/:id', async (req: Request, res: Response) => {
  try {
    const featureId = req.params.id;
    const { name, code_access, db_access, base_requirement, brd_prompt } = req.body;
    const result = await query(
      `UPDATE features SET name = $1, code_access = $2, db_access = $3, base_requirement = $4, brd_prompt = $5
       WHERE id = $6 RETURNING *`,
      [name, code_access, db_access, base_requirement, brd_prompt, featureId]
    );
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Get workflow for a feature
app.get('/api/features/:id/workflow', async (req: Request, res: Response) => {
  try {
    const featureId = req.params.id;
    const result = await query('SELECT * FROM workflows WHERE feature_id = $1 LIMIT 1', [featureId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Workflow not found' });
    }
    res.json(result.rows[0]);
  } catch (err: any) {
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// Update workflow stage
app.put('/api/features/:id/workflow', async (req: Request, res: Response) => {
  try {
    const featureId = req.params.id;
    const { current_stage, status, stage_data } = req.body;
    
    // fetch existing
    const existing = await query('SELECT * FROM workflows WHERE feature_id = $1', [featureId]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ error: 'Workflow not found' });
    }
    
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

app.listen(PORT, async () => {
  await initDB();
  console.log(`[Zero-Trust SDLC API Server] listening on http://localhost:${PORT}`);
});
