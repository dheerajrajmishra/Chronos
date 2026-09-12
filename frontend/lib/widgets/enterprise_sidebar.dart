import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../theme/enterprise_theme.dart';

class EnterpriseSidebar extends StatelessWidget {
  const EnterpriseSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final isCollapsed = controller.isSidebarCollapsed.value;
      final activePrj = controller.activeProject.value;
      final projects = controller.projectList;

      final surfaceColor = EnterpriseTheme.getSurface(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final inputBg = EnterpriseTheme.getInputBg(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isCollapsed ? 68 : 256,
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(right: BorderSide(color: borderColor, width: 1)),
        ),
        child: Column(
          children: [
            // ─── Brand Header ──────────────────────────────────
            _buildBrandHeader(controller, isCollapsed, isDark, primaryAccent, textSecColor, borderColor),

            // ─── Active Project Switcher ───────────────────────
            if (!isCollapsed && activePrj != null)
              _buildProjectSwitcher(controller, activePrj, projects, isDark, inputBg, primaryAccent, textColor, textSecColor, textMutedColor),

            // ─── Navigation Items ──────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: isCollapsed ? 8 : 12),
                children: [
                  if (!isCollapsed) _sectionLabel('Workspaces', textMutedColor),
                  _NavItem(
                    controller: controller,
                    stage: SDLCStageType.projectHub,
                    title: 'Projects & Access',
                    icon: Icons.grid_view_rounded,
                    badge: 'HUB',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(height: 8),
                    _sectionLabel('Pipeline Stages', textMutedColor),
                  ],
                  _NavItem(
                    controller: controller,
                    stage: SDLCStageType.specStudio,
                    title: 'Ingestion & Spec Studio',
                    icon: Icons.auto_awesome_outlined,
                    badge: '1',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _NavItem(
                    controller: controller,
                    stage: SDLCStageType.vaultInspector,
                    title: 'Token Vault Inspector',
                    icon: Icons.vpn_key_outlined,
                    badge: '2',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _NavItem(
                    controller: controller,
                    stage: SDLCStageType.agentOrchestration,
                    title: 'Agent Orchestration',
                    icon: Icons.hub_outlined,
                    badge: '3',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _NavItem(
                    controller: controller,
                    stage: SDLCStageType.approvalGate,
                    title: 'Governance Gate',
                    icon: Icons.verified_outlined,
                    badge: '4',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _NavItem(
                    controller: controller,
                    stage: SDLCStageType.codeGenSbom,
                    title: 'Code Gen & SBOM',
                    icon: Icons.terminal_outlined,
                    badge: '5',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _NavItem(
                    controller: controller,
                    stage: SDLCStageType.auditTelemetry,
                    title: 'Audit & Telemetry',
                    icon: Icons.insights_outlined,
                    badge: '6',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // ─── User / Security Footer ───────────────────────
            _buildFooter(controller, isCollapsed, isDark, borderColor, primaryAccent, textColor, textSecColor, textMutedColor, inputBg),
          ],
        ),
      );
    });
  }

  // ─── Brand Header ──────────────────────────────────────────────────
  Widget _buildBrandHeader(
    EnterpriseSDLCController controller,
    bool isCollapsed,
    bool isDark,
    Color primaryAccent,
    Color textSecColor,
    Color borderColor,
  ) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          // Logo mark
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: EnterpriseTheme.brandGradient,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Icon(Icons.shield_outlined, color: Colors.white, size: 18),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => EnterpriseTheme.brandGradient.createShader(bounds),
                    child: Text(
                      'Chronos',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Text(
                    'Zero-Trust SDLC',
                    style: GoogleFonts.inter(
                      color: textSecColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          _hoverIcon(
            icon: isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            color: textSecColor,
            onTap: () => controller.isSidebarCollapsed.toggle(),
            isDark: isDark,
            size: 18,
          ),
        ],
      ),
    );
  }

  // ─── Project Switcher ──────────────────────────────────────────────
  Widget _buildProjectSwitcher(
    EnterpriseSDLCController controller,
    ProjectWorkspace activePrj,
    List<ProjectWorkspace> projects,
    bool isDark,
    Color inputBg,
    Color primaryAccent,
    Color textColor,
    Color textSecColor,
    Color textMutedColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: PopupMenuButton<ProjectWorkspace>(
        initialValue: activePrj,
        onSelected: controller.selectProject,
        color: EnterpriseTheme.getCardBgElevated(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        ),
        offset: const Offset(0, 42),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(Icons.folder_outlined, size: 14, color: primaryAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activePrj.projectKey,
                      style: GoogleFonts.inter(
                        color: primaryAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      activePrj.name,
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.unfold_more_rounded, size: 14, color: textMutedColor),
            ],
          ),
        ),
        itemBuilder: (context) => projects.map((p) {
          final isActive = p.id == activePrj.id;
          return PopupMenuItem(
            value: p,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? EnterpriseTheme.emerald : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "[${p.projectKey}] ",
                  style: GoogleFonts.inter(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.w700),
                ),
                Expanded(
                  child: Text(
                    p.name,
                    style: GoogleFonts.inter(color: textColor, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Section Label ─────────────────────────────────────────────────
  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 4, top: 6),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          color: color.withValues(alpha: 0.6),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ─── Footer ────────────────────────────────────────────────────────
  Widget _buildFooter(
    EnterpriseSDLCController controller,
    bool isCollapsed,
    bool isDark,
    Color borderColor,
    Color primaryAccent,
    Color textColor,
    Color textSecColor,
    Color textMutedColor,
    Color inputBg,
  ) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 8 : 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCollapsed) ...[
            // User info row
            Row(
              children: [
                // Avatar
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      controller.userRole.value.substring(0, 1),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PopupMenuButton<String>(
                    initialValue: controller.userRole.value,
                    onSelected: controller.setUserRole,
                    color: EnterpriseTheme.getCardBgElevated(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.userRole.value.split(' ').take(2).join(' '),
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: EnterpriseTheme.emerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Online',
                              style: GoogleFonts.inter(
                                color: EnterpriseTheme.emerald,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    itemBuilder: (context) => [
                      _roleMenuItem('Principal Security Architect', textColor),
                      _roleMenuItem('AppSec Compliance Officer', textColor),
                      _roleMenuItem('Enterprise Lead Architect', textColor),
                      _roleMenuItem('Product Governance Owner', textColor),
                    ],
                  ),
                ),
                // Theme toggle
                _hoverIcon(
                  icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
                  onTap: controller.toggleTheme,
                  isDark: isDark,
                  size: 16,
                ),
              ],
            ),
          ] else ...[
            Center(
              child: _hoverIcon(
                icon: Icons.person_outline_rounded,
                color: primaryAccent,
                onTap: () => controller.isSidebarCollapsed.value = false,
                isDark: isDark,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<String> _roleMenuItem(String role, Color textColor) {
    return PopupMenuItem(
      value: role,
      child: Text(
        role,
        style: GoogleFonts.inter(color: textColor, fontSize: 12),
      ),
    );
  }

  Widget _hoverIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    double size = 18,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: EnterpriseTheme.getSubtleBg(isDark),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}

// ─── Stateful Nav Item with hover ────────────────────────────────────
class _NavItem extends StatefulWidget {
  final EnterpriseSDLCController controller;
  final SDLCStageType stage;
  final String title;
  final IconData icon;
  final String badge;
  final bool isCollapsed;
  final bool isDark;

  const _NavItem({
    required this.controller,
    required this.stage,
    required this.title,
    required this.icon,
    required this.badge,
    required this.isCollapsed,
    required this.isDark,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.controller.currentStage.value == widget.stage;
    final isDark = widget.isDark;
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
    final textColor = EnterpriseTheme.getTextPrimary(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => widget.controller.setStage(widget.stage),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryAccent.withValues(alpha: isDark ? 0.1 : 0.08)
                  : (_isHovered
                      ? EnterpriseTheme.getSubtleBg(isDark)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                // Left accent bar for active item
                if (!widget.isCollapsed)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 3,
                    height: isSelected ? 18 : 0,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                // Icon
                Tooltip(
                  message: widget.isCollapsed ? widget.title : '',
                  child: Icon(
                    widget.icon,
                    color: isSelected
                        ? primaryAccent
                        : (_isHovered ? textColor : textSecColor),
                    size: 18,
                  ),
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? textColor
                            : (_isHovered ? textColor : textSecColor),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Stage number badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryAccent.withValues(alpha: 0.15)
                          : (_isHovered
                              ? EnterpriseTheme.getCardBorder(isDark).withValues(alpha: 0.5)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      widget.badge,
                      style: GoogleFonts.inter(
                        color: isSelected ? primaryAccent : textMutedColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
