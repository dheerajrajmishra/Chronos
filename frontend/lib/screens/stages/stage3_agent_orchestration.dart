import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hub_outlined, size: 48, color: primaryAccent.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('No active workflow', style: GoogleFonts.inter(color: textMutedColor, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('Initiate a pipeline in Stage 1 to begin.', style: GoogleFonts.inter(color: textMutedColor.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
        );
      }

      final deliverables = wf.deliverables;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(gradient: EnterpriseTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.hub_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Agent Orchestration', style: GoogleFonts.inter(color: textColor, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text('Temporal durable workflow with specialized AI agent personas on task queue sdlc-queue.', style: GoogleFonts.inter(color: textSecColor, fontSize: 13)),
                    ],
                  ),
                ),
                _gradientButton('Proceed to Stage 4', Icons.arrow_forward_rounded, () => controller.setStage(SDLCStageType.approvalGate)),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Workflow DAG ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_tree_outlined, color: primaryAccent, size: 16),
                      const SizedBox(width: 8),
                      Text('Workflow Pipeline', style: GoogleFonts.inter(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      _pill('sdlc-queue', EnterpriseTheme.emerald, isDark),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _workflowStep('1. Ingestion', 'Voice / Spec', true, primaryAccent, isDark),
                        _stepConnector(true, isDark),
                        _workflowStep('2. DLP Vault', 'Presidio', true, EnterpriseTheme.purple, isDark),
                        _stepConnector(true, isDark),
                        _workflowStep('3. Synthesis', 'Multi-Agent', true, EnterpriseTheme.indigo, isDark),
                        _stepConnector(true, isDark),
                        _workflowStep('4. Unmask', 'Reverse Map', true, EnterpriseTheme.emerald, isDark),
                        _stepConnector(true, isDark),
                        _workflowStep('5. Gate', 'Signal', wf.isApproved, wf.isApproved ? EnterpriseTheme.emerald : EnterpriseTheme.amber, isDark),
                        _stepConnector(wf.isApproved, isDark),
                        _workflowStep('6. Code Gen', 'SBOM', wf.isApproved, wf.isApproved ? primaryAccent : textMutedColor, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Agent Tabs & Deliverables ───────────────────
            if (deliverables.isNotEmpty) ...[
              Row(
                children: List.generate(deliverables.length, (idx) {
                  final del = deliverables[idx];
                  final isSelected = _selectedAgentIndex == idx;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: idx == deliverables.length - 1 ? 0 : 10),
                      child: _AgentTab(
                        name: del.agentName,
                        role: del.agentRole,
                        icon: idx == 0 ? Icons.assignment_outlined : idx == 1 ? Icons.architecture_outlined : Icons.security_outlined,
                        isSelected: isSelected,
                        isDark: isDark,
                        onTap: () => setState(() => _selectedAgentIndex = idx),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Deliverable content
              Container(
                padding: const EdgeInsets.all(24),
                decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          deliverables[_selectedAgentIndex].agentName,
                          style: GoogleFonts.inter(color: primaryAccent, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 6,
                          children: deliverables[_selectedAgentIndex].tags.map((t) => _pill(t, textSecColor, isDark)).toList(),
                        ),
                      ],
                    ),
                    Divider(color: borderColor, height: 24),
                    MarkdownBody(
                      data: deliverables[_selectedAgentIndex].markdownContent,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.inter(color: textColor, fontSize: 13, height: 1.6),
                        h1: GoogleFonts.inter(color: primaryAccent, fontSize: 18, fontWeight: FontWeight.w700),
                        h2: GoogleFonts.inter(color: textColor, fontSize: 15, fontWeight: FontWeight.w700),
                        h3: GoogleFonts.inter(color: textSecColor, fontSize: 13, fontWeight: FontWeight.w600),
                        code: GoogleFonts.jetBrainsMono(
                          color: isDark ? EnterpriseTheme.brandBlue : EnterpriseTheme.brandBlueDark,
                          backgroundColor: inputBg,
                          fontSize: 12,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isDark ? const Color(0xFF09090B) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        tableBorder: TableBorder.all(color: borderColor),
                        tableHead: GoogleFonts.inter(color: primaryAccent, fontWeight: FontWeight.w600, fontSize: 12),
                        tableBody: GoogleFonts.inter(color: textColor, fontSize: 12),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getInputBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDone ? color.withValues(alpha: 0.5) : EnterpriseTheme.getCardBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 13, color: color),
              const SizedBox(width: 5),
              Text(title, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(desc, style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _stepConnector(bool active, bool isDark) {
    return Container(
      width: 16,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: active ? EnterpriseTheme.getPrimaryAccent(isDark).withValues(alpha: 0.5) : EnterpriseTheme.getCardBorder(isDark),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _pill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
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

// ─── Agent Tab with hover ───────────────────────────────────────────
class _AgentTab extends StatefulWidget {
  final String name;
  final String role;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _AgentTab({required this.name, required this.role, required this.icon, required this.isSelected, required this.isDark, required this.onTap});

  @override
  State<_AgentTab> createState() => _AgentTabState();
}

class _AgentTabState extends State<_AgentTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(widget.isDark);
    final textColor = EnterpriseTheme.getTextPrimary(widget.isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(widget.isDark);
    final textMutedColor = EnterpriseTheme.getTextMuted(widget.isDark);
    final borderColor = EnterpriseTheme.getCardBorder(widget.isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? primaryAccent.withValues(alpha: widget.isDark ? 0.08 : 0.06)
                : (_isHovered ? EnterpriseTheme.getSubtleBg(widget.isDark) : EnterpriseTheme.getInputBg(widget.isDark)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected ? primaryAccent.withValues(alpha: 0.5) : borderColor,
              width: widget.isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(widget.icon, color: widget.isSelected ? primaryAccent : textSecColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: GoogleFonts.inter(color: widget.isSelected ? primaryAccent : textColor, fontWeight: FontWeight.w600, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(widget.role, style: GoogleFonts.inter(color: textMutedColor, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
