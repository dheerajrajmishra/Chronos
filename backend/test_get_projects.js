const http = require('http');

async function test() {
  const loginRes = await fetch('http://localhost:4000/api/v1/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'admin@chronos.local', password: 'password123' })
  });
  const loginData = await loginRes.json();
  const token = loginData.token;
  console.log('Token received');

  const projRes = await fetch('http://localhost:4000/api/v1/projects', {
    headers: { 'Authorization': 'Bearer ' + token }
  });
  const projs = await projRes.json();
  console.log('Projects API:', JSON.stringify(projs, null, 2));
}
test();
