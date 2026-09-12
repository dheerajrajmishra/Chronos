import { Pool } from 'pg';

const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  database: process.env.POSTGRES_DB || 'zero_trust_db',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  port: parseInt(process.env.POSTGRES_PORT || '5433', 10),
});

export const initDB = async () => {
  try {
    const client = await pool.connect();
    console.log('[DB] Connected to PostgreSQL successfully.');
    
    // Create Projects Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS projects (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create Features Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS features (
        id SERIAL PRIMARY KEY,
        project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        code_access JSONB,
        db_access JSONB,
        base_requirement TEXT,
        brd_prompt TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create Workflows Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS workflows (
        id SERIAL PRIMARY KEY,
        feature_id INTEGER REFERENCES features(id) ON DELETE CASCADE,
        current_stage INTEGER DEFAULT 1,
        status VARCHAR(50) DEFAULT 'pending',
        stage_data JSONB DEFAULT '{}',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    client.release();
    console.log('[DB] Database schema initialized.');
  } catch (err) {
    console.error('[DB] Failed to initialize database:', err);
  }
};

export const query = (text: string, params?: any[]) => pool.query(text, params);
