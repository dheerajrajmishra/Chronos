import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage4ApprovalGate extends StatefulWidget {
  const Stage4ApprovalGate({Key? key}) : super(key: key);

  @override
  State<Stage4ApprovalGate> createState() => _Stage4ApprovalGateState();
}

class _Stage4ApprovalGateState extends State<Stage4ApprovalGate> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final wf = controller.activeWorkflow.value;
      if (wf == null) {
        return const Center(
          child: Text('No active workflow to review.', style: TextStyle(color: EnterpriseTheme.textMuted)),
        );
      }

      final isPending = !wf.isApproved && wf.status != 'REJECTED';

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
                    gradient: isPending ? EnterpriseTheme.cyberGradient : EnterpriseTheme.emeraldGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPending ? Icons.how_to_reg_outlined : Icons.verified,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPending
                            ? 'Stage 4: Enterprise Governance & Human-in-the-Loop Approval Gate'
                            : 'Stage 4: Governance Gate Sign-Off (COMPLETED)',
                        style: const TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Temporal Workflow execution is halted waiting for human signal `approvalSignal`. Role verification enforced.',
                        style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (wf.isApproved)
                  ElevatedButton.icon(
                    onPressed: () => controller.setStage(SDLCStageType.codeGenSbom),
                    icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                    label: const Text('Proceed to Stage 5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EnterpriseTheme.cyan,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 24),

            // Sign-off Roles Status Matrix
            Row(
              children: [
                Expanded(
                  child: _roleCard(
                    roleName: 'Principal Security Architect',
                    authority: 'Mandatory Sign-off',
                    status: wf.isApproved ? 'APPROVED' : 'PENDING ACTION',
                    color: wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber,
                    icon: Icons.security,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _roleCard(
                    roleName: 'Enterprise Solutions Architect',
                    authority: 'C4 & Schema Validated',
                    status: wf.isApproved ? 'APPROVED' : 'PENDING ACTION',
                    color: wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber,
                    icon: Icons.architecture,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _roleCard(
                    roleName: 'AppSec Compliance Auditor',
                    authority: 'SOC2 / HIPAA Verified',
                    status: wf.isApproved ? 'APPROVED' : 'PENDING ACTION',
                    color: wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber,
                    icon: Icons.rule,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Main Document Reviewer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: EnterpriseTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, color: EnterpriseTheme.cyan, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Generated Business & Architecture Specification (BRD)',
                        style: const TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: EnterpriseTheme.cardBorder),
                        ),
                        child: Text(
                          'Target: ${wf.complianceStandard}',
                          style: const TextStyle(color: EnterpriseTheme.cyan, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: EnterpriseTheme.cardBorder, height: 24),
                  if (wf.deliverables.isNotEmpty)
                    MarkdownBody(
                      data: wf.deliverables.first.markdownContent,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 13, height: 1.6),
                        h1: const TextStyle(color: EnterpriseTheme.cyan, fontSize: 18, fontWeight: FontWeight.bold),
                        h2: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                        code: const TextStyle(color: Color(0xFF38BDF8), backgroundColor: Color(0xFF0F172A), fontFamily: 'Consolas'),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Interactive Governance Action Panel
            Container(
              padding: const EdgeInsets.all(24),
              decoration: EnterpriseTheme.cardDecoration(
                borderColor: isPending ? EnterpriseTheme.cyan : EnterpriseTheme.emerald,
                glow: isPending,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPending ? Icons.gavel_outlined : Icons.check_circle_outline,
                        color: isPending ? EnterpriseTheme.cyan : EnterpriseTheme.emerald,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPending ? 'Human Approval Decision & Signal Dispatch' : 'Approval Granted & Workflow Dispatched',
                        style: const TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (isPending) ...[
                    const Text(
                      'Provide security justification and review notes before dispatching signal to Temporal engine:',
                      style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'e.g., Reviewed Zero-Trust vault mappings and verified no raw PII in BRD. Approved for automated code generation.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => controller.submitApproval(false, _commentController.text),
                          icon: const Icon(Icons.cancel_outlined, color: EnterpriseTheme.rose, size: 18),
                          label: const Text('Reject & Abort Workflow', style: TextStyle(color: EnterpriseTheme.rose)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: EnterpriseTheme.rose),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.submitApproval(true, _commentController.text),
                            icon: const Icon(Icons.verified, color: Colors.black, size: 20),
                            label: Text(
                              'Sign Off & Signal Temporal Workflow (As ${controller.userRole.value})',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EnterpriseTheme.cyan,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: EnterpriseTheme.emerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: EnterpriseTheme.emerald.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: EnterpriseTheme.emerald, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Signed by ${wf.approvedBy ?? controller.userRole.value} at ${DateTime.now().toLocal().toString().substring(0, 19)}',
                                style: const TextStyle(color: EnterpriseTheme.emerald, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Justification: "${wf.approvalComment ?? 'Approved with Zero-Trust compliance signoff.'}"',
                            style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _roleCard({
    required String roleName,
    required String authority,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  roleName,
                  style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            authority,
            style: const TextStyle(color: EnterpriseTheme.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
