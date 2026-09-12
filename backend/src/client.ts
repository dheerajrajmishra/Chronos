import { Connection, Client } from '@temporalio/client';
import { RequirementsToDesignWorkflow } from './workflows';

async function run() {
  const connection = await Connection.connect();
  const client = new Client({ connection });

  const handle = await client.workflow.start(RequirementsToDesignWorkflow, {
    taskQueue: 'sdlc-queue',
    workflowId: 'brd-workflow-' + Date.now(),
    args: ['Create a new user authentication module.'],
  });

  console.log(`Started workflow ${handle.workflowId}`);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
