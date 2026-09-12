const axios = require('axios');
require('dotenv').config();

async function test() {
  const endpoint = process.env.AZURE_OPENAI_ENDPOINT.replace(/\/$/, '');
  const url = `${endpoint}/v1/chat/completions`;
  
  console.log('Calling URL:', url);
  
  try {
    const res = await axios.post(url, {
      model: 'gpt-4o',
      messages: [{ role: 'user', content: 'hello' }]
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.AZURE_OPENAI_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    console.log('Success:', res.data.choices[0].message);
  } catch (err) {
    console.error('Error:', err.response ? err.response.status + ' ' + JSON.stringify(err.response.data) : err.message);
  }
}

test();
