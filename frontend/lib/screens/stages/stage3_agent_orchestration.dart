import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage3AgentOrchestration extends StatefulWidget {
  const Stage3AgentOrchestration({Key? key}) : super(key: key);

  @override
  State<Stage3AgentOrchestration> createState() => _Stage3AgentOrchestrationState();
}

class _Stage3AgentOrchestrationState extends State<Stage3AgentOrchestration> {
  int _selectedAgentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final wf = controller.activeWorkflow.value;
      if (wf == null) {
        return const Center(
          child: Text('No active workflow. Initiate one in Stage 1.', style: TextStyle(color: EnterpriseTheme.textMuted)),
        );
      }

      final deliverables = wf.deliverables;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hub_outlined, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Stage 3: Multi-Agent AI Synthesis & Temporal Orchestration',
                        style: TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Durable state machine executing on Temporal task queue sdlc-queue with specialized AI agent personas.',
                        style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.setStage(SDLCStageType.approvalGate),
                  icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                  label: const Text('Proceed to Stage 4 (Governance Gate)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnterpriseTheme.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // Temporal Workflow Visual Pipeline State Machine
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_tree_outlined, color: EnterpriseTheme.cyan, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Temporal Durable Workflow DAG (RequirementsToDesignWorkflow)',
                        style: TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: EnterpriseTheme.emerald.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'QUEUE: sdlc-queue',
                          style: TextStyle(color: EnterpriseTheme.emerald, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _workflowStep('1. Ingestion', 'Voice / Spec', true, EnterpriseTheme.cyan),
                        _stepConnector(true),
                        _workflowStep('2. DLP Vault', 'Presidio Masking', true, EnterpriseTheme.purple),
                        _stepConnector(true),
                        _workflowStep('3. Agent Synthesis', 'BA + Arch + SecOps', true, EnterpriseTheme.indigo),
                        _stepConnector(true),
                        _workflowStep('4. Unmask Vault', 'Reverse Mapping', true, EnterpriseTheme.emerald),
                        _stepConnector(true),
                        _workflowStep('5. Human Gate', 'Temporal Signal', wf.isApproved, wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber),
                        _stepConnector(wf.isApproved),
                        _workflowStep('6. CI/CD Code Gen', 'Dispatch & SBOM', wf.isApproved, wf.isApproved ? EnterpriseTheme.cyan : EnterpriseTheme.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Agent Deliverables Selector & Viewer
            if (deliverables.isNotEmpty) ...[
              // Agent Persona Tabs
              Row(
                children: List.generate(deliverables.length, (idx) {
                  final del = deliverables[idx];
                  final isSelected = _selectedAgentIndex == idx;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: idx == deliverables.length - 1 ? 0 : 12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedAgentIndex = idx),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.cardBorder,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    idx == 0
                                        ? Icons.assignment_outlined
                                        : idx == 1
                                            ? Icons.architecture_outlined
                                            : Icons.security_outlined,
                                    color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.textSecondary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      del.agentName,
                                      style: TextStyle(
                                        color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                del.agentRole,
                                style: const TextStyle(color: EnterpriseTheme.textMuted, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Deliverable Markdown Document Surface
              Container(
                padding: const EdgeInsets.all(24),
                decoration: EnterpriseTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          deliverables[_selectedAgentIndex].agentName.toUpperCase(),
                          style: const TextStyle(
                            color: EnterpriseTheme.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 6,
                          children: deliverables[_selectedAgentIndex].tags.map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: EnterpriseTheme.cardBorder),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const Divider(color: EnterpriseTheme.cardBorder, height: 24),
                    MarkdownBody(
                      data: deliverables[_selectedAgentIndex].markdownContent,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 13, height: 1.6),
                        h1: const TextStyle(color: EnterpriseTheme.cyan, fontSize: 18, fontWeight: FontWeight.bold),
                        h2: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                        h3: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                        code: const TextStyle(
                          color: Color(0xFF38BDF8),
                          backgroundColor: Color(0xFF0F172A),
                          fontFamily: 'Consolas',
                          fontSize: 12,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: const Color(0xFF06090F),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: EnterpriseTheme.cardBorder),
                        ),
                        tableBorder: TableBorder.all(color: EnterpriseTheme.cardBorder),
                        tableHead: const TextStyle(color: EnterpriseTheme.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                        tableBody: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _workflowStep(String title, String desc, bool isDone, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDone ? color : EnterpriseTheme.cardBorder, width: isDone ? 1.5 : 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(color: EnterpriseTheme.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _stepConnector(bool active) {
    return Container(
      width: 20,
      height: 2,
      color: active ? EnterpriseTheme.cyan : EnterpriseTheme.cardBorder,
    );
  }
}
