const axios = require('axios');
require('dotenv').config();

async function test() {
  const endpoint = process.env.AZURE_OPENAI_ENDPOINT.replace(/\/$/, '');
  const deployment = process.env.AZURE_OPENAI_DEPLOYMENT || 'gpt-4o';
  const apiVersion = '2024-02-15-preview';
  const url = `${endpoint}/openai/deployments/${deployment}/chat/completions?api-version=${apiVersion}`;
  
  console.log('Calling URL:', url);
  
  try {
    const res = await axios.post(url, {
      messages: [{ role: 'user', content: 'hello' }]
    }, {
      headers: {
        'api-key': process.env.AZURE_OPENAI_KEY,
        'Content-Type': 'application/json'
      }
    });
    console.log('Success:', res.data.choices[0].message);
  } catch (err) {
    console.error('Error:', err.response ? err.response.status + ' ' + JSON.stringify(err.response.data) : err.message);
  }
}

test();
