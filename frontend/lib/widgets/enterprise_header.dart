import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../theme/enterprise_theme.dart';

class EnterpriseHeader extends StatefulWidget {
  final VoidCallback onToggleTerminal;
  final bool isTerminalOpen;

  const EnterpriseHeader({
    Key? key,
    required this.onToggleTerminal,
    required this.isTerminalOpen,
  }) : super(key: key);

  @override
  State<EnterpriseHeader> createState() => _EnterpriseHeaderState();
}

class _EnterpriseHeaderState extends State<EnterpriseHeader> {
  bool _showHealth = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final wf = controller.activeWorkflow.value;
      final prj = controller.activeProject.value;
      final telemetry = controller.telemetry;

      final surfaceColor = EnterpriseTheme.getSurface(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

      return Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: Row(
          children: [
            // ─── Breadcrumb Navigation ─────────────────────
            _breadcrumbItem(
              'Chronos',
              primaryAccent,
              textMutedColor,
              onTap: () => controller.setStage(SDLCStageType.projectHub),
            ),
            _breadcrumbSeparator(textMutedColor),
            if (prj != null) ...[
              _breadcrumbItem(prj.projectKey, textColor, textMutedColor),
              _breadcrumbSeparator(textMutedColor),
            ],
            if (wf != null) ...[
              _breadcrumbItem(wf.id, primaryAccent, textMutedColor),
              const SizedBox(width: 10),
              _statusChip(wf.status, isDark),
            ] else ...[
              Text(
                _stageDisplayName(controller.currentStage.value),
                style: GoogleFonts.inter(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],

            const Spacer(),

            // ─── System Health Indicator ─────────────────────
            MouseRegion(
              onEnter: (_) => setState(() => _showHealth = true),
              onExit: (_) => setState(() => _showHealth = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: _showHealth ? 12 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: EnterpriseTheme.getSubtleBg(isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: EnterpriseTheme.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Systems Online',
                      style: GoogleFonts.inter(
                        color: EnterpriseTheme.emerald,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_showHealth) ...[
                      const SizedBox(width: 10),
                      _healthStat('Vault', '${telemetry['redisTokensCount']}', EnterpriseTheme.purple, textMutedColor),
                      const SizedBox(width: 8),
                      _healthStat('Latency', '${telemetry['gatewayLatencyMs']}ms', primaryAccent, textMutedColor),
                      const SizedBox(width: 8),
                      _healthStat('Trust', telemetry['zeroTrustScore'] ?? '99.4%', EnterpriseTheme.emerald, textMutedColor),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ─── Theme Toggle ────────────────────────────────
            _headerIconButton(
              icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              onTap: controller.toggleTheme,
              isDark: isDark,
            ),

            const SizedBox(width: 4),

            // ─── Terminal Toggle ─────────────────────────────
            _headerIconButton(
              icon: Icons.terminal_rounded,
              color: widget.isTerminalOpen ? primaryAccent : textSecColor,
              tooltip: widget.isTerminalOpen ? 'Hide terminal' : 'Show terminal',
              onTap: widget.onToggleTerminal,
              isDark: isDark,
              isActive: widget.isTerminalOpen,
              activeAccent: primaryAccent,
            ),

            const SizedBox(width: 8),

            // ─── New Pipeline CTA ────────────────────────────
            _ActionButton(
              label: 'New Pipeline',
              icon: Icons.add_rounded,
              onTap: () => controller.setStage(SDLCStageType.specStudio),
              isDark: isDark,
            ),
          ],
        ),
      );
    });
  }

  // ─── Breadcrumb Item ──────────────────────────────────────────
  Widget _breadcrumbItem(String label, Color color, Color mutedColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _breadcrumbSeparator(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.chevron_right_rounded, size: 14, color: color.withValues(alpha: 0.5)),
    );
  }

  // ─── Status Chip ──────────────────────────────────────────────
  Widget _statusChip(String status, bool isDark) {
    Color color = EnterpriseTheme.getPrimaryAccent(isDark);
    if (status.contains('WAITING') || status.contains('APPROVAL')) {
      color = EnterpriseTheme.amber;
    } else if (status.contains('APPROVED') || status.contains('COMPLETED')) {
      color = EnterpriseTheme.emerald;
    } else if (status.contains('REJECTED')) {
      color = EnterpriseTheme.rose;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Health Stat ──────────────────────────────────────────────
  Widget _healthStat(String label, String value, Color color, Color mutedColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: GoogleFonts.inter(color: mutedColor, fontSize: 9, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: GoogleFonts.inter(color: color, fontSize: 9, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // ─── Header Icon Button ───────────────────────────────────────
  Widget _headerIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
    bool isActive = false,
    Color? activeAccent,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          hoverColor: EnterpriseTheme.getSubtleBg(isDark),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: isActive
                  ? (activeAccent ?? color).withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  // ─── Stage Display Name ───────────────────────────────────────
  String _stageDisplayName(SDLCStageType stage) {
    switch (stage) {
      case SDLCStageType.projectHub:
        return 'Projects & Access Hub';
      case SDLCStageType.specStudio:
        return 'Ingestion & Spec Studio';
      case SDLCStageType.vaultInspector:
        return 'Token Vault Inspector';
      case SDLCStageType.agentOrchestration:
        return 'Agent Orchestration';
      case SDLCStageType.approvalGate:
        return 'Governance Gate';
      case SDLCStageType.codeGenSbom:
        return 'Code Gen & SBOM';
      case SDLCStageType.auditTelemetry:
        return 'Audit & Telemetry';
    }
  }
}

// ─── Action Button ──────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: EnterpriseTheme.brandGradient,
            borderRadius: BorderRadius.circular(7),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: EnterpriseTheme.brandBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
