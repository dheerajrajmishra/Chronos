import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../theme/enterprise_theme.dart';
import '../controllers/auth_controller.dart';

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
            _breadcrumbItem(
              Get.find<AuthController>().currentTenantName,
              textColor,
              textMutedColor,
            ),
            _breadcrumbSeparator(textMutedColor),
            if (prj != null) ...[
              _breadcrumbItem(prj.name, textColor, textMutedColor),
              _breadcrumbSeparator(textMutedColor),
            ],
            if (wf != null) ...[
              _breadcrumbItem(wf.id.toString(), primaryAccent, textMutedColor),
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


            // ─── Logout Button ───────────────────────────────
            _headerIconButton(
              icon: Icons.logout_rounded,
              color: const Color(0xFFEF4444), // Red for logout
              tooltip: 'Logout',
              onTap: () => _confirmLogout(context, isDark, textColor, textSecColor),
              isDark: isDark,
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

            const SizedBox(width: 4),

            // ─── Settings Button ─────────────────────────────
            if (Get.find<AuthController>().hasPermission('manage_settings') || Get.find<AuthController>().isOrgAdmin)
              _headerIconButton(
                icon: Icons.tune_rounded,
                color: controller.currentStage.value == SDLCStageType.settings ? primaryAccent : textSecColor,
                tooltip: 'Settings & Prompts Configuration',
                onTap: () => controller.setStage(SDLCStageType.settings),
                isDark: isDark,
                isActive: controller.currentStage.value == SDLCStageType.settings,
                activeAccent: primaryAccent,
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
    } else if (status.contains('REJECTED') || status.contains('FAILED')) {
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
      case SDLCStageType.stage0Setup:
        return 'Stage 0: Feature Setup';
      case SDLCStageType.stage1Brd:
        return 'Stage 1: BRD';
      case SDLCStageType.stage2Design:
        return 'Stage 2: Design Document';
      case SDLCStageType.stage3TechDoc:
        return 'Stage 3: Technical Document';
      case SDLCStageType.stage4Code:
        return 'Stage 4: Code';
      case SDLCStageType.stage5TestCaseCreation:
        return 'Stage 5: Test Case Creation';
      case SDLCStageType.stage6TestAutomation:
        return 'Stage 6: Test Automation Script';
      case SDLCStageType.stage7TestingResult:
        return 'Stage 7: Testing & Result';
      case SDLCStageType.stage8Deploy:
        return 'Stage 8: Deployment';
      case SDLCStageType.settings:
        return 'Global Settings & Prompts Configuration';
      case SDLCStageType.tenantAdmin:
        return 'Tenant Management (Chronos Admin)';
      case SDLCStageType.userManagement:
        return 'User & Permission Management';
    }
  }

  void _confirmLogout(BuildContext context, bool isDark, Color textColor, Color textSecColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EnterpriseTheme.getSurface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
        content: Text('Are you sure you want to log out?', style: GoogleFonts.inter(fontSize: 13, color: textSecColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: textSecColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<AuthController>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('Logout', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
