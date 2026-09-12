import { proxyActivities, defineSignal, setHandler, condition } from '@temporalio/workflow';
import type * as activities from './activities';

const { maskSensitiveData, generateBRD, unmaskBRD } = proxyActivities<typeof activities>({
  startToCloseTimeout: '2 minutes',
});

export const approvalSignal = defineSignal<[boolean]>('approvalSignal');

export async function RequirementsToDesignWorkflow(requirementText: string): Promise<string> {
  // Step 1: Mask Data
  const maskedText = await maskSensitiveData(requirementText);
  
  // Step 2: Generate BRD
  const brdMasked = await generateBRD(maskedText);
  
  // Step 3: Unmask Data
  const brdUnmasked = await unmaskBRD(brdMasked);

  // Step 4: Wait for human approval signal
  let approved: boolean | undefined = undefined;
  setHandler(approvalSignal, (isApproved) => {
    approved = isApproved;
  });

  await condition(() => approved !== undefined);

  if (!approved) {
    throw new Error('BRD was rejected by human approver');
  }

  return brdUnmasked;
}
