const { query } = require('./dist/db');
const bcrypt = require('bcrypt');

async function addDemoUser() {
  try {
    const hash = await bcrypt.hash('admin', 10);
    const tenantRes = await query('SELECT id FROM tenants WHERE slug = $1', ['sds-tenant']);
    let tenantId;
    if (tenantRes.rows.length === 0) {
      const res = await query("INSERT INTO tenants (name, slug, plan, status) VALUES ($1, $2, $3, $4) RETURNING id", ['SDS', 'sds-tenant', 'enterprise', 'active']);
      tenantId = res.rows[0].id;
      console.log('Created sds-tenant');
    } else {
      tenantId = tenantRes.rows[0].id;
    }

    const userRes = await query('SELECT id FROM users WHERE email = $1', ['sanjay.dhar@samsung.com']);
    let userId;
    if (userRes.rows.length === 0) {
      const res = await query("INSERT INTO users (email, name, password_hash, status) VALUES ($1, $2, $3, $4) RETURNING id", ['sanjay.dhar@samsung.com', 'Sanjay Dhar', hash, 'active']);
      userId = res.rows[0].id;
      console.log('Created user sanjay');
    } else {
      userId = userRes.rows[0].id;
      await query('UPDATE users SET password_hash = $1 WHERE id = $2', [hash, userId]);
      console.log('Updated user sanjay password');
    }

    await query("INSERT INTO tenant_users (tenant_id, user_id, role, status) VALUES ($1, $2, $3, $4) ON CONFLICT (tenant_id, user_id) DO UPDATE SET role = $3", [tenantId, userId, 'viewer', 'active']);
    console.log('Assigned sanjay to sds-tenant as viewer');

    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

addDemoUser();
