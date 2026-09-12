require('dotenv/config');
const { AzureChatOpenAI } = require('@langchain/openai');

async function test() {
  const llm = new AzureChatOpenAI({
    azureOpenAIApiKey: process.env.AZURE_OPENAI_KEY,
    azureOpenAIEndpoint: process.env.AZURE_OPENAI_ENDPOINT,
    azureOpenAIApiDeploymentName: process.env.AZURE_OPENAI_DEPLOYMENT || 'gpt-4o',
    azureOpenAIApiVersion: '2024-02-15-preview',
    temperature: 0.2,
  });
  
  try {
    const res = await llm.invoke("Hello");
    console.log(res);
  } catch (err) {
    console.error("Error from Langchain:", err.message);
  }
}

test();
