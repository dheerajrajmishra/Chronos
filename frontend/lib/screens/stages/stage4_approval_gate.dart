import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage4ApprovalGate extends StatefulWidget {
  const Stage4ApprovalGate({super.key});

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_outlined, size: 48, color: primaryAccent.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('No active workflow to review', style: GoogleFonts.inter(color: textMutedColor, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }

      final isPending = !wf.isApproved && wf.status != 'REJECTED';

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isPending ? EnterpriseTheme.cyberGradient : EnterpriseTheme.emeraldGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(isPending ? Icons.verified_outlined : Icons.verified, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPending ? 'Governance Gate' : 'Governance Gate (Completed)',
                        style: GoogleFonts.inter(color: textColor, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Temporal workflow halted awaiting human approval signal. Role verification enforced.',
                        style: GoogleFonts.inter(color: textSecColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (wf.isApproved)
                  _gradientButton('Proceed to Stage 5', Icons.arrow_forward_rounded,
                      () => controller.setStage(SDLCStageType.codeGenSbom)),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Role Cards ──────────────────────────────
            Row(
              children: [
                Expanded(child: _roleCard(isDark: isDark, roleName: 'Security Architect', authority: 'Mandatory sign-off', status: wf.isApproved ? 'APPROVED' : 'PENDING', color: wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber, icon: Icons.security_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _roleCard(isDark: isDark, roleName: 'Solutions Architect', authority: 'C4 & schema verified', status: wf.isApproved ? 'APPROVED' : 'PENDING', color: wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber, icon: Icons.architecture_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _roleCard(isDark: isDark, roleName: 'Compliance Auditor', authority: 'SOC2 / HIPAA verified', status: wf.isApproved ? 'APPROVED' : 'PENDING', color: wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber, icon: Icons.rule_outlined)),
              ],
            ),

            const SizedBox(height: 24),

            // ─── BRD Document ────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_outlined, color: primaryAccent, size: 18),
                      const SizedBox(width: 8),
                      Text('Business & Architecture Specification', style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      _pill(wf.complianceStandard, primaryAccent, isDark),
                    ],
                  ),
                  Divider(color: borderColor, height: 24),
                  if (wf.deliverables.isNotEmpty)
                    MarkdownBody(
                      data: wf.deliverables.first.markdownContent,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.inter(color: textColor, fontSize: 13, height: 1.6),
                        h1: GoogleFonts.inter(color: primaryAccent, fontSize: 18, fontWeight: FontWeight.w700),
                        h2: GoogleFonts.inter(color: textColor, fontSize: 15, fontWeight: FontWeight.w700),
                        code: GoogleFonts.jetBrainsMono(color: isDark ? EnterpriseTheme.brandBlue : EnterpriseTheme.brandBlueDark, backgroundColor: inputBg, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Approval Action Panel ───────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: EnterpriseTheme.cardDecoration(
                isDark: isDark,
                borderColor: isPending ? primaryAccent.withValues(alpha: 0.5) : EnterpriseTheme.emerald.withValues(alpha: 0.5),
                glow: isPending,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPending ? Icons.gavel_outlined : Icons.check_circle_outline_rounded,
                        color: isPending ? primaryAccent : EnterpriseTheme.emerald,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPending ? 'Approval Decision' : 'Approved & Dispatched',
                        style: GoogleFonts.inter(color: textColor, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (isPending) ...[
                    Text(
                      'Provide review notes before dispatching the signal:',
                      style: GoogleFonts.inter(color: textSecColor, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      style: GoogleFonts.inter(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g., Reviewed vault mappings. No raw PII in BRD. Approved for code generation.',
                        hintStyle: GoogleFonts.inter(color: textMutedColor, fontSize: 12),
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryAccent, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Reject
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.submitApproval(false, _commentController.text),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: EnterpriseTheme.rose.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cancel_outlined, color: EnterpriseTheme.rose, size: 16),
                                  const SizedBox(width: 6),
                                  Text('Reject', style: GoogleFonts.inter(color: EnterpriseTheme.rose, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Approve
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.submitApproval(true, _commentController.text),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: EnterpriseTheme.brandGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sign Off (${controller.userRole.value.split(' ').take(2).join(' ')})',
                                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: EnterpriseTheme.emerald.withValues(alpha: isDark ? 0.08 : 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: EnterpriseTheme.emerald.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: EnterpriseTheme.emerald, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Signed by ${wf.approvedBy ?? controller.userRole.value}',
                                style: GoogleFonts.inter(color: EnterpriseTheme.emerald, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '"${wf.approvalComment ?? 'Approved with Zero-Trust compliance signoff.'}"',
                            style: GoogleFonts.inter(color: textSecColor, fontSize: 12, fontStyle: FontStyle.italic),
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

  Widget _roleCard({required bool isDark, required String roleName, required String authority, required String status, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(roleName, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 6),
          Text(authority, style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 10)),
          const SizedBox(height: 8),
          _pill(status, color, isDark),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _gradientButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(gradient: EnterpriseTheme.brandGradient, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Icon(icon, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
