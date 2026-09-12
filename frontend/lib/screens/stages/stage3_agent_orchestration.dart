import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage3AgentOrchestration extends StatefulWidget {
  const Stage3AgentOrchestration({super.key});

  @override
  State<Stage3AgentOrchestration> createState() => _Stage3AgentOrchestrationState();
}

class _Stage3AgentOrchestrationState extends State<Stage3AgentOrchestration> {
  int _selectedAgentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final wf = controller.activeWorkflow.value;
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
      final inputBg = EnterpriseTheme.getInputBg(isDark);

      if (wf == null) {
        return Center(
          child: Text('No active workflow. Initiate one in Stage 1.', style: TextStyle(color: textMutedColor)),
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
                    children: [
                      Text(
                        'Stage 3: Multi-Agent AI Synthesis & Temporal Orchestration',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Durable state machine executing on Temporal task queue sdlc-queue with specialized AI agent personas.',
                        style: TextStyle(color: textSecColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.setStage(SDLCStageType.approvalGate),
                  icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                  label: const Text('Proceed to Stage 4 (Governance Gate)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? EnterpriseTheme.cyan : const Color(0xFF00C9DB),
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
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_tree_outlined, color: primaryAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Temporal Durable Workflow DAG (RequirementsToDesignWorkflow)',
                        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: EnterpriseTheme.emerald.withValues(alpha: isDark ? 0.15 : 0.12),
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
                        _workflowStep('1. Ingestion', 'Voice / Spec', true, primaryAccent, isDark),
                        _stepConnector(true, isDark),
                        _workflowStep('2. DLP Vault', 'Presidio Masking', true, EnterpriseTheme.purple, isDark),
                        _stepConnector(true, isDark),
                        _workflowStep('3. Agent Synthesis', 'BA + Arch + SecOps', true, EnterpriseTheme.indigo, isDark),
                        _stepConnector(true, isDark),
                        _workflowStep('4. Unmask Vault', 'Reverse Mapping', true, EnterpriseTheme.emerald, isDark),
                        _stepConnector(true, isDark),
                        _workflowStep('5. Human Gate', 'Temporal Signal', wf.isApproved, wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber, isDark),
                        _stepConnector(wf.isApproved, isDark),
                        _workflowStep('6. CI/CD Code Gen', 'Dispatch & SBOM', wf.isApproved, wf.isApproved ? primaryAccent : textMutedColor, isDark),
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
                            color: isSelected
                                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE))
                                : inputBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? primaryAccent : borderColor,
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
                                    color: isSelected ? primaryAccent : textSecColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      del.agentName,
                                      style: TextStyle(
                                        color: isSelected ? primaryAccent : textColor,
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
                                style: TextStyle(color: textMutedColor, fontSize: 11),
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
                decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          deliverables[_selectedAgentIndex].agentName.toUpperCase(),
                          style: TextStyle(
                            color: primaryAccent,
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
                                color: inputBg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: borderColor),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(color: textSecColor, fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Divider(color: borderColor, height: 24),
                    MarkdownBody(
                      data: deliverables[_selectedAgentIndex].markdownContent,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: textColor, fontSize: 13, height: 1.6),
                        h1: TextStyle(color: primaryAccent, fontSize: 18, fontWeight: FontWeight.bold),
                        h2: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                        h3: TextStyle(color: textSecColor, fontSize: 13, fontWeight: FontWeight.w600),
                        code: TextStyle(
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          backgroundColor: inputBg,
                          fontFamily: 'Consolas',
                          fontSize: 12,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isDark ? const Color(0xFF06090F) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor),
                        ),
                        tableBorder: TableBorder.all(color: borderColor),
                        tableHead: TextStyle(color: primaryAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        tableBody: TextStyle(color: textColor, fontSize: 12),
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

  Widget _workflowStep(String title, String desc, bool isDone, Color color, bool isDark) {
    final borderColor = EnterpriseTheme.getCardBorder(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDone ? color : borderColor, width: isDone ? 1.5 : 1.0),
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
            style: TextStyle(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _stepConnector(bool active, bool isDark) {
    return Container(
      width: 20,
      height: 2,
      color: active ? EnterpriseTheme.getPrimaryAccent(isDark) : EnterpriseTheme.getCardBorder(isDark),
    );
  }
}
