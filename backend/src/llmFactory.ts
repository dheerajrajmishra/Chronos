import { ChatOpenAI, AzureChatOpenAI } from '@langchain/openai';
import { ChatAnthropic } from '@langchain/anthropic';
import { ChatGoogleGenerativeAI } from '@langchain/google-genai';
import { query } from './db';

export async function getLlmClient(fallbackModel?: string, fallbackApiKey?: string) {
  let llmConfig: any = null;
  try {
    const res = await query("SELECT value FROM global_settings WHERE key = 'llm_config'");
    if (res.rows.length > 0) {
      llmConfig = res.rows[0].value;
    }
  } catch (e) {
    console.error("Failed to load llm_config from DB:", e);
  }

  if (llmConfig) {
    const provider = (llmConfig.provider || 'openai').toLowerCase();
    const apiKey = llmConfig.apiKey || fallbackApiKey || process.env.OPENAI_API_KEY || '';
    const model = llmConfig.textModel || fallbackModel || 'gpt-4o';

    if (provider === 'azure') {
      return new AzureChatOpenAI({
        azureOpenAIApiKey: apiKey,
        azureOpenAIApiInstanceName: process.env.AZURE_OPENAI_INSTANCE || 'pitchperfectllmengine2',
        azureOpenAIApiDeploymentName: model,
        azureOpenAIApiVersion: '2024-02-15-preview',
        azureOpenAIBasePath: llmConfig.apiUrl ? llmConfig.apiUrl : undefined,
      });
    } else if (provider === 'anthropic') {
      return new ChatAnthropic({
        anthropicApiKey: apiKey,
        modelName: model,
      });
    } else if (provider === 'gemini') {
      return new ChatGoogleGenerativeAI({
        apiKey: apiKey,
        model: model,
      });
    } else if (provider === 'custom' || provider === 'on-prem') {
      return new ChatOpenAI({
        openAIApiKey: apiKey,
        modelName: model,
        configuration: {
          baseURL: llmConfig.apiUrl
        }
      });
    } else {
      // Default to OpenAI
      return new ChatOpenAI({
        openAIApiKey: apiKey,
        modelName: model,
      });
    }
  }

  // Fallback to purely env vars if no DB config
  const apiKey = fallbackApiKey || process.env.OPENAI_API_KEY || process.env.AZURE_OPENAI_KEY;
  if (process.env.AZURE_OPENAI_KEY) {
    return new AzureChatOpenAI({
      azureOpenAIApiKey: apiKey,
      azureOpenAIApiInstanceName: process.env.AZURE_OPENAI_INSTANCE || 'pitchperfectllmengine2',
      azureOpenAIApiDeploymentName: fallbackModel || 'gpt-4o',
      azureOpenAIApiVersion: '2024-02-15-preview',
    });
  }

  return new ChatOpenAI({
    openAIApiKey: apiKey,
    modelName: fallbackModel || 'gpt-4o',
  });
}
