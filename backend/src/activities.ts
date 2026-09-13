import axios from 'axios';
import { getLlmClient } from './llmFactory';
import { Client } from 'pg';
import { Context } from '@temporalio/activity';

const GATEWAY_URL = 'http://localhost:8000';

async function getDbClient() {
  const client = new Client({
    user: 'postgres',
    password: 'postgres',
    host: 'localhost',
    port: 5433,
    database: 'zero_trust_db',
  });
  await client.connect();
  return client;
}

export async function maskSensitiveData(input: string): Promise<string> {
  const workflowId = Context.current().info.workflowExecution.workflowId;
  const res = await axios.post(`${GATEWAY_URL}/mask`, {
    workflow_id: workflowId,
    text: input,
  });
  return res.data.masked_text;
}

export async function generateBRD(maskedInput: string): Promise<string> {
  const llm = await getLlmClient();
  const response = await llm.invoke(`
    You are an AI Business Analyst. Create a detailed Markdown Business Requirements Document (BRD) 
    based on the following requirement:
    
    ${maskedInput}
  `);
  return response.content as string;
}

export async function unmaskBRD(maskedBrd: string): Promise<string> {
  const workflowId = Context.current().info.workflowExecution.workflowId;
  const res = await axios.post(`${GATEWAY_URL}/unmask`, {
    workflow_id: workflowId,
    text: maskedBrd,
  });
  
  const unmaskedText = res.data.unmasked_text;
  
  // Save to DB
  const db = await getDbClient();
  try {
    // Basic table creation if not exists (for demo purposes)
    await db.query(`
      CREATE TABLE IF NOT EXISTS brds (
        id SERIAL PRIMARY KEY,
        workflow_id VARCHAR(255),
        content TEXT,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    
    await db.query(
      `INSERT INTO brds (workflow_id, content) VALUES ($1, $2)`,
      [workflowId, unmaskedText]
    );
  } finally {
    await db.end();
  }
  
  return unmaskedText;
}
