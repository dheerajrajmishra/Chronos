import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        duration: const Duration(milliseconds: 250),
        width: isCollapsed ? 74 : 260,
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(right: BorderSide(color: borderColor, width: 1)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF64748B).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(2, 0),
                  )
                ],
        ),
        child: Column(
          children: [
            // Brand Logo & Header
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: EnterpriseTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.black, size: 22),
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ZERO-TRUST',
                            style: TextStyle(
                              color: primaryAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'AI SDLC PLATFORM',
                            style: TextStyle(
                              color: textSecColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  IconButton(
                    icon: Icon(
                      isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: textSecColor,
                      size: 20,
                    ),
                    onPressed: () => controller.isSidebarCollapsed.toggle(),
                  ),
                ],
              ),
            ),

            // Active Project Workspace Switcher Banner
            if (!isCollapsed && activePrj != null)
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.folder_open, size: 14, color: primaryAccent),
                        const SizedBox(width: 6),
                        Text(
                          'ACTIVE PROJECT',
                          style: TextStyle(
                            color: textMutedColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            activePrj.projectKey,
                            style: TextStyle(color: primaryAccent, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    PopupMenuButton<ProjectWorkspace>(
                      initialValue: activePrj,
                      onSelected: controller.selectProject,
                      color: EnterpriseTheme.getCardBgElevated(isDark),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              activePrj.name,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.unfold_more, size: 14, color: textSecColor),
                        ],
                      ),
                      itemBuilder: (context) => projects.map((p) {
                        return PopupMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Text("[${p.projectKey}] ", style: TextStyle(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(p.name, style: TextStyle(color: textColor, fontSize: 12), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                children: [
                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 6, top: 4),
                      child: Text(
                        'PROJECT WORKSPACES',
                        style: TextStyle(
                          color: textMutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                  _navItem(
                    controller: controller,
                    stage: SDLCStageType.projectHub,
                    title: 'Projects & Access Hub',
                    icon: Icons.dashboard_customize_outlined,
                    badge: 'WORKSPACE',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),

                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 6, top: 12),
                      child: Text(
                        'SDLC PIPELINE STAGES',
                        style: TextStyle(
                          color: textMutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                  _navItem(
                    controller: controller,
                    stage: SDLCStageType.specStudio,
                    title: '1. Ingestion & Spec Studio',
                    icon: Icons.mic_none_outlined,
                    badge: 'VOICE/STT',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _navItem(
                    controller: controller,
                    stage: SDLCStageType.vaultInspector,
                    title: '2. Zero-Trust Token Vault',
                    icon: Icons.vpn_key_outlined,
                    badge: 'PRESIDIO',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _navItem(
                    controller: controller,
                    stage: SDLCStageType.agentOrchestration,
                    title: '3. Multi-Agent Synthesis',
                    icon: Icons.hub_outlined,
                    badge: 'TEMPORAL',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _navItem(
                    controller: controller,
                    stage: SDLCStageType.approvalGate,
                    title: '4. Governance & Approvals',
                    icon: Icons.how_to_reg_outlined,
                    badge: 'GATE',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _navItem(
                    controller: controller,
                    stage: SDLCStageType.codeGenSbom,
                    title: '5. Code Gen & SBOM Matrix',
                    icon: Icons.terminal_outlined,
                    badge: 'SBOM',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                  _navItem(
                    controller: controller,
                    stage: SDLCStageType.auditTelemetry,
                    title: '6. Immutable Audit & Telemetry',
                    icon: Icons.analytics_outlined,
                    badge: 'LIVE',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // User Role Selector & Security Context
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCollapsed) ...[
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: EnterpriseTheme.emerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SECURITY CONTEXT',
                          style: TextStyle(
                            color: textMutedColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: controller.toggleTheme,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              size: 14,
                              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    PopupMenuButton<String>(
                      initialValue: controller.userRole.value,
                      onSelected: controller.setUserRole,
                      color: EnterpriseTheme.getCardBgElevated(isDark),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user_outlined, size: 16, color: primaryAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.userRole.value,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, size: 16, color: textSecColor),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'Principal Security Architect',
                          child: Text('Principal Security Architect', style: TextStyle(color: textColor)),
                        ),
                        PopupMenuItem(
                          value: 'AppSec Compliance Officer',
                          child: Text('AppSec Compliance Officer', style: TextStyle(color: textColor)),
                        ),
                        PopupMenuItem(
                          value: 'Enterprise Lead Architect',
                          child: Text('Enterprise Lead Architect', style: TextStyle(color: textColor)),
                        ),
                        PopupMenuItem(
                          value: 'Product Governance Owner',
                          child: Text('Product Governance Owner', style: TextStyle(color: textColor)),
                        ),
                      ],
                    ),
                  ] else ...[
                    IconButton(
                      icon: Icon(Icons.admin_panel_settings_outlined, color: primaryAccent),
                      onPressed: () => controller.isSidebarCollapsed.value = false,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _navItem({
    required EnterpriseSDLCController controller,
    required SDLCStageType stage,
    required String title,
    required IconData icon,
    required String badge,
    required bool isCollapsed,
    required bool isDark,
  }) {
    final isSelected = controller.currentStage.value == stage;
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: () => controller.setStage(stage),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryAccent.withValues(alpha: isDark ? 0.12 : 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? primaryAccent.withValues(alpha: 0.6) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? primaryAccent : textSecColor,
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? textColor : textSecColor,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryAccent.withValues(alpha: 0.2) : inputBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isSelected ? primaryAccent : textMutedColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
