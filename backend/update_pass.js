const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  password: 'postgres',
  host: 'localhost',
  port: 5433,
  database: 'zero_trust_db'
});

async function run() {
  const hash = await bcrypt.hash('admin', 10);
  await pool.query('UPDATE users SET password_hash = $1 WHERE email = $2', [hash, 'admin@zerotrust.com']);
  console.log('Updated admin password');
  await pool.end();
}

run();
