import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../models/sdlc_models.dart';
import '../theme/enterprise_theme.dart';
import 'stage_prompts_dialog.dart';

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
      final activeFeature = controller.activeFeature.value;
      final activeWf = controller.activeWorkflow.value;

      final surfaceColor = EnterpriseTheme.getSurface(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final inputBg = EnterpriseTheme.getInputBg(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

      // Compute pipeline progress (0 to 8 stages)
      int currentWfStage = activeWf?.currentStage ?? 0;
      if (activeFeature == null) currentWfStage = 0;
      final isCompleted = activeWf?.status == 'completed' || activeWf?.status == 'deployed';
      final completedCount = isCompleted
          ? 9
          : (activeFeature != null
              ? (currentWfStage > 0 ? (currentWfStage >= 8 ? 8 : currentWfStage) : 1)
              : 0);
      final progressPercent = completedCount / 9.0;

      final currentStage = controller.currentStage.value;
      final showPipelineStages = currentStage != SDLCStageType.projectHub && activeFeature != null;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isCollapsed ? 68 : 280,
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

            // ─── Overall Pipeline Progress Indicator ──────────
            if (!isCollapsed && activeFeature != null && showPipelineStages)
              _buildProgressOverview(
                isDark: isDark,
                featureName: activeFeature.name,
                completedCount: completedCount,
                percent: progressPercent,
                primaryAccent: primaryAccent,
                borderColor: borderColor,
              ),

            // ─── Stage AI Prompts Trigger Card ────────────────
            if (activeFeature != null && showPipelineStages)
              _buildPromptsTriggerCard(context, activeFeature, isCollapsed, isDark, primaryAccent, borderColor),

            // ─── Navigation & Stages Stepper ───────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: isCollapsed ? 6 : 10),
                children: [
                  if (!isCollapsed) _sectionLabel('Workspaces', textMutedColor),
                  _WorkspaceNavItem(
                    controller: controller,
                    stage: SDLCStageType.projectHub,
                    title: 'Projects & Access',
                    icon: Icons.grid_view_rounded,
                    badge: 'HUB',
                    isCollapsed: isCollapsed,
                    isDark: isDark,
                  ),

                  if (showPipelineStages) ...[
                    if (!isCollapsed) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _sectionLabel('SDLC Pipeline Stages', textMutedColor),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$completedCount/9 READY',
                              style: GoogleFonts.jetBrainsMono(
                                color: primaryAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Stage 0: Feature Setup
                    _PipelineStageNavItem(
                      key: const ValueKey('stage0'),
                      controller: controller,
                      stage: SDLCStageType.stage0Setup,
                      stageIndex: 0,
                      title: 'Feature Setup',
                      icon: Icons.settings_applications_outlined,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: activeFeature != null,
                      isWfActive: activeFeature != null && currentWfStage == 0,
                    ),

                    // Stage 1: BRD
                    _PipelineStageNavItem(
                      key: const ValueKey('stage1'),
                      controller: controller,
                      stage: SDLCStageType.stage1Brd,
                      stageIndex: 1,
                      title: 'BRD',
                      icon: Icons.article_outlined,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: activeFeature != null && currentWfStage > 1,
                      isWfActive: activeFeature != null && currentWfStage == 1,
                    ),

                    // Stage 2: Design Document
                    _PipelineStageNavItem(
                      key: const ValueKey('stage2'),
                      controller: controller,
                      stage: SDLCStageType.stage2Design,
                      stageIndex: 2,
                      title: 'Design Document',
                      icon: Icons.architecture_outlined,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: activeFeature != null && currentWfStage > 2,
                      isWfActive: activeFeature != null && currentWfStage == 2,
                    ),

                    // Stage 3: Technical Document
                    _PipelineStageNavItem(
                      key: const ValueKey('stage3'),
                      controller: controller,
                      stage: SDLCStageType.stage3TechDoc,
                      stageIndex: 3,
                      title: 'Technical Document',
                      icon: Icons.terminal_rounded,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: activeFeature != null && currentWfStage > 3,
                      isWfActive: activeFeature != null && currentWfStage == 3,
                    ),

                    // Stage 4: Code
                    _PipelineStageNavItem(
                      key: const ValueKey('stage4'),
                      controller: controller,
                      stage: SDLCStageType.stage4Code,
                      stageIndex: 4,
                      title: 'Code',
                      icon: Icons.code_rounded,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: activeFeature != null && currentWfStage > 4,
                      isWfActive: activeFeature != null && currentWfStage == 4,
                    ),

                    // Stage 5: Unit Testing
                    _PipelineStageNavItem(
                      key: const ValueKey('stage5'),
                      controller: controller,
                      stage: SDLCStageType.stage5UnitTest,
                      stageIndex: 5,
                      title: 'Unit Testing',
                      icon: Icons.checklist_rounded,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: activeFeature != null && currentWfStage > 5,
                      isWfActive: activeFeature != null && currentWfStage == 5,
                    ),

                    // Stage 6: Testing
                    _PipelineStageNavItem(
                      key: const ValueKey('stage6'),
                      controller: controller,
                      stage: SDLCStageType.stage6Test,
                      stageIndex: 6,
                      title: 'Testing',
                      icon: Icons.security_rounded,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: activeFeature != null && currentWfStage > 6,
                      isWfActive: activeFeature != null && currentWfStage == 6,
                    ),

                    // Stage 7: UAT
                    _PipelineStageNavItem(
                      key: const ValueKey('stage7'),
                      controller: controller,
                      stage: SDLCStageType.stage7Uat,
                      stageIndex: 7,
                      title: 'UAT',
                      icon: Icons.fact_check_outlined,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: activeFeature != null && currentWfStage > 7,
                      isWfActive: activeFeature != null && currentWfStage == 7,
                    ),

                    // Stage 8: Deployment
                    _PipelineStageNavItem(
                      key: const ValueKey('stage8'),
                      controller: controller,
                      stage: SDLCStageType.stage8Deploy,
                      stageIndex: 8,
                      title: 'Deployment',
                      icon: Icons.rocket_launch_rounded,
                      isCollapsed: isCollapsed,
                      isDark: isDark,
                      isDone: isCompleted,
                      isWfActive: activeFeature != null && currentWfStage == 8 && !isCompleted,
                    ),
                  ],
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

  // ─── Stage AI Prompts Trigger Button / Card ─────────────────────────
  Widget _buildPromptsTriggerCard(
    BuildContext context,
    Feature feature,
    bool isCollapsed,
    bool isDark,
    Color primaryAccent,
    Color borderColor,
  ) {
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: 'Stage AI Prompts (Configure & Edit)',
          child: InkWell(
            onTap: () => StagePromptsDialog.show(context, feature),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: EnterpriseTheme.brandGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => StagePromptsDialog.show(context, feature),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF161A2B), const Color(0xFF101321)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryAccent.withValues(alpha: 0.35), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.brandGradient,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.psychology_rounded, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Stage AI Prompts',
                            style: GoogleFonts.inter(
                              color: EnterpriseTheme.getTextPrimary(isDark),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'EDIT',
                              style: GoogleFonts.jetBrainsMono(
                                color: primaryAccent,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'View & customize prompts for all stages',
                        style: GoogleFonts.inter(
                          color: EnterpriseTheme.getTextMuted(isDark),
                          fontSize: 9.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.tune_rounded, size: 15, color: primaryAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Pipeline Progress Overview Widget ──────────────────────────────
  Widget _buildProgressOverview({
    required bool isDark,
    required String featureName,
    required int completedCount,
    required double percent,
    required Color primaryAccent,
    required Color borderColor,
  }) {
    final int pctInt = (percent * 100).toInt();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10131F) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 14, color: primaryAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pipeline Progress',
                  style: GoogleFonts.inter(
                    color: EnterpriseTheme.getTextPrimary(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$pctInt%',
                style: GoogleFonts.jetBrainsMono(
                  color: pctInt == 100 ? EnterpriseTheme.emerald : primaryAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.02, 1.0),
              minHeight: 5,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                pctInt == 100 ? EnterpriseTheme.emerald : const Color(0xFF38BDF8),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Feature: $featureName',
            style: GoogleFonts.inter(
              color: EnterpriseTheme.getTextMuted(isDark),
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
    Project activePrj,
    List<Project> projects,
    bool isDark,
    Color inputBg,
    Color primaryAccent,
    Color textColor,
    Color textSecColor,
    Color textMutedColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      child: PopupMenuButton<Project>(
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
                      'PRJ-${activePrj.id}',
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
                  "[PRJ-${p.id}] ",
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
      padding: const EdgeInsets.only(left: 8, bottom: 4, top: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          color: color.withValues(alpha: 0.7),
          fontSize: 10,
          fontWeight: FontWeight.w700,
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
            Row(
              children: [
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
                ),
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

// ─── Workspace Hub Nav Item ──────────────────────────────────────────
class _WorkspaceNavItem extends StatefulWidget {
  final EnterpriseSDLCController controller;
  final SDLCStageType stage;
  final String title;
  final IconData icon;
  final String badge;
  final bool isCollapsed;
  final bool isDark;

  const _WorkspaceNavItem({
    required this.controller,
    required this.stage,
    required this.title,
    required this.icon,
    required this.badge,
    required this.isCollapsed,
    required this.isDark,
  });

  @override
  State<_WorkspaceNavItem> createState() => _WorkspaceNavItemState();
}

class _WorkspaceNavItemState extends State<_WorkspaceNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = widget.controller.currentStage.value == widget.stage;
      final isDark = widget.isDark;
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () => widget.controller.setStage(widget.stage),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed ? 0 : 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryAccent.withValues(alpha: isDark ? 0.16 : 0.10)
                    : (_isHovered ? EnterpriseTheme.getSubtleBg(isDark) : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? primaryAccent.withValues(alpha: 0.35) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  if (!widget.isCollapsed)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 3.5,
                      height: isSelected ? 18 : 0,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  Icon(
                    widget.icon,
                    color: isSelected ? primaryAccent : (_isHovered ? textColor : textSecColor),
                    size: 18,
                  ),
                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          color: isSelected ? textColor : (_isHovered ? textColor : textSecColor),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryAccent.withValues(alpha: 0.2)
                            : EnterpriseTheme.getCardBorder(isDark).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.badge,
                        style: GoogleFonts.jetBrainsMono(
                          color: isSelected ? primaryAccent : EnterpriseTheme.getTextMuted(isDark),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
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
    });
  }
}

// ─── Pipeline Stage Nav Item with Left Stepper & Pure Obx Highlighting ──
class _PipelineStageNavItem extends StatefulWidget {
  final EnterpriseSDLCController controller;
  final SDLCStageType stage;
  final int stageIndex;
  final String title;
  final IconData icon;
  final bool isCollapsed;
  final bool isDark;
  final bool isDone;
  final bool isWfActive;

  const _PipelineStageNavItem({
    Key? key,
    required this.controller,
    required this.stage,
    required this.stageIndex,
    required this.title,
    required this.icon,
    required this.isCollapsed,
    required this.isDark,
    required this.isDone,
    required this.isWfActive,
  }) : super(key: key);

  @override
  State<_PipelineStageNavItem> createState() => _PipelineStageNavItemState();
}

class _PipelineStageNavItemState extends State<_PipelineStageNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // PURE REACTIVE CURRENT TAB HIGHLIGHT: Exactly and ONLY one tab is selected!
      final isSelected = widget.controller.currentStage.value == widget.stage;
      final isDark = widget.isDark;
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () => widget.controller.setStage(widget.stage),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed ? 0 : 8,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          primaryAccent.withValues(alpha: isDark ? 0.22 : 0.15),
                          primaryAccent.withValues(alpha: isDark ? 0.08 : 0.04),
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (_isHovered ? EnterpriseTheme.getSubtleBg(isDark) : Colors.transparent),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isSelected
                      ? primaryAccent.withValues(alpha: 0.4)
                      : Colors.transparent,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: isDark ? 0.15 : 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  // ─── Left Stepper Progress Indicator ──────────
                  if (!widget.isCollapsed)
                    _buildStepperIndicator(isSelected, isDark, primaryAccent),

                  if (!widget.isCollapsed) const SizedBox(width: 8),

                  // Icon
                  Tooltip(
                    message: widget.isCollapsed ? '${widget.stageIndex}. ${widget.title}' : '',
                    child: Icon(
                      widget.icon,
                      color: isSelected
                          ? primaryAccent
                          : (widget.isDone
                              ? EnterpriseTheme.emerald
                              : (_isHovered ? textColor : textSecColor)),
                      size: 17,
                    ),
                  ),

                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: 9),

                    // Stage Title
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          color: isSelected
                              ? textColor
                              : (_isHovered ? textColor : textSecColor),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Status Badge Pill
                    _buildStatusPill(isSelected, isDark, primaryAccent, textMutedColor),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Stepper Progress Node ──────────────────────────────────────────
  Widget _buildStepperIndicator(bool isSelected, bool isDark, Color primaryAccent) {
    if (isSelected) {
      // Current selected stage: Glowing active cyan/blue ring
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: primaryAccent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: primaryAccent, width: 2),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: primaryAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else if (widget.isDone) {
      // Completed Stage: Green circular badge with checkmark
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: EnterpriseTheme.emerald,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check_rounded, size: 12, color: Colors.white),
        ),
      );
    } else if (widget.isWfActive) {
      // Active in workflow: Amber pulsating ring
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: EnterpriseTheme.amber.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: EnterpriseTheme.amber, width: 1.5),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: EnterpriseTheme.amber,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      // Pending stage: Hollow circular outline with stage index
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: EnterpriseTheme.getCardBorder(isDark).withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '${widget.stageIndex}',
            style: GoogleFonts.jetBrainsMono(
              color: EnterpriseTheme.getTextMuted(isDark),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  // ─── Status Pill on Right ───────────────────────────────────────────
  Widget _buildStatusPill(bool isSelected, bool isDark, Color primaryAccent, Color textMutedColor) {
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: EnterpriseTheme.brandGradient,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'CURRENT',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      );
    } else if (widget.isDone) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: EnterpriseTheme.emerald.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: EnterpriseTheme.emerald.withValues(alpha: 0.3)),
        ),
        child: Text(
          'DONE',
          style: GoogleFonts.jetBrainsMono(
            color: EnterpriseTheme.emerald,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: EnterpriseTheme.getCardBorder(isDark).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${widget.stageIndex}',
          style: GoogleFonts.jetBrainsMono(
            color: textMutedColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}
