const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'zero_trust_db',
  password: 'postgres',
  port: 5433,
});

async function run() {
  try {
    await pool.query(`
      INSERT INTO project_users (project_id, user_id, role)
      SELECT p.id, tu.user_id, 'contributor'
      FROM projects p
      JOIN tenant_users tu ON p.tenant_id = tu.tenant_id
      ON CONFLICT DO NOTHING;
    `);
    console.log('Migrated existing projects to project_users table.');
    const res = await pool.query('SELECT * FROM project_users');
    console.log(res.rows);
  } catch (err) {
    console.error('Error migrating projects:', err);
  } finally {
    pool.end();
  }
}

run();
