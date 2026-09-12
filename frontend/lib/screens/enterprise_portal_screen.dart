import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../theme/enterprise_theme.dart';
import '../widgets/enterprise_sidebar.dart';
import '../widgets/enterprise_header.dart';
import 'projects/project_hub_screen.dart';
import 'stages/stage0_feature_setup.dart';
import 'stages/stage1_brd.dart';
import 'stages/stage2_design.dart';
import 'stages/stage3_code.dart';
import 'stages/stage4_test.dart';
import 'stages/stage5_uat.dart';
import 'stages/stage6_deploy.dart';

class EnterprisePortalScreen extends StatefulWidget {
  const EnterprisePortalScreen({Key? key}) : super(key: key);

  @override
  State<EnterprisePortalScreen> createState() => _EnterprisePortalScreenState();
}

class _EnterprisePortalScreenState extends State<EnterprisePortalScreen> {
  bool _isTerminalOpen = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final backgroundColor = EnterpriseTheme.getBackground(isDark);

      return Scaffold(
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            // Collapsible Left Navigation Sidebar
            const EnterpriseSidebar(),

            // Main Center Viewport
            Expanded(
              child: Column(
                children: [
                  // Top Global Header
                  EnterpriseHeader(
                    isTerminalOpen: _isTerminalOpen,
                    onToggleTerminal: () {
                      setState(() => _isTerminalOpen = !_isTerminalOpen);
                    },
                  ),

                  // Active Stage Body Viewport
                  Expanded(
                    child: Obx(() {
                      switch (controller.currentStage.value) {
                        case SDLCStageType.projectHub:
                          return const ProjectHubScreen();
                        case SDLCStageType.stage0Setup:
                          return const Stage0FeatureSetup();
                        case SDLCStageType.stage1Brd:
                          return const Stage1Brd();
                        case SDLCStageType.stage2Design:
                          return const Stage2Design();
                        case SDLCStageType.stage3Code:
                          return const Stage3Code();
                        case SDLCStageType.stage4Test:
                          return const Stage4Test();
                        case SDLCStageType.stage5Uat:
                          return const Stage5Uat();
                        case SDLCStageType.stage6Deploy:
                          return const Stage6Deploy();
                        default:
                          return const Center(child: Text("Unknown Stage"));
                      }
                    }),
                  ),

                  // Live Terminal Drawer
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: _isTerminalOpen
                        ? _terminalDrawer(controller, isDark)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _terminalDrawer(EnterpriseSDLCController controller, bool isDark) {
    return Obx(() {
      final logs = controller.liveTerminalLogs;
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final headerBg = isDark ? const Color(0xFF0F1117) : const Color(0xFF18181B);
      final bodyBg = isDark ? const Color(0xFF09090B) : const Color(0xFF0C0D12);

      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: bodyBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: Column(
          children: [
            // Terminal Header
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: headerBg,
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  // Dot indicators
                  Row(
                    children: [
                      _termDot(EnterpriseTheme.emerald),
                      const SizedBox(width: 5),
                      _termDot(EnterpriseTheme.amber),
                      const SizedBox(width: 5),
                      _termDot(EnterpriseTheme.rose),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Orchestration Terminal',
                    style: GoogleFonts.inter(
                      color: EnterpriseTheme.darkTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _termAction(Icons.delete_outline_rounded, 'Clear',
                      () => controller.liveTerminalLogs.clear()),
                  const SizedBox(width: 4),
                  _termAction(Icons.close_rounded, 'Close',
                      () => setState(() => _isTerminalOpen = false)),
                ],
              ),
            ),

            // Logs Content Area
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  Color logColor = const Color(0xFF71717A);

                  if (log.contains('[WORKFLOW]') || log.contains('[SIGNAL]')) {
                    logColor = EnterpriseTheme.brandBlue;
                  } else if (log.contains('[VAULT]') || log.contains('[VAULT_AUDIT]')) {
                    logColor = EnterpriseTheme.purple;
                  } else if (log.contains('[TEMPORAL]') || log.contains('[AGENT_')) {
                    logColor = EnterpriseTheme.emerald;
                  } else if (log.contains('[STT]') || log.contains('[AUTH]') || log.contains('[THEME]')) {
                    logColor = EnterpriseTheme.amber;
                  } else if (log.contains('ERROR') || log.contains('BLOCKED')) {
                    logColor = EnterpriseTheme.rose;
                  } else if (log.contains('[NAV]') || log.contains('[PROJECT]')) {
                    logColor = const Color(0xFFA1A1AA);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                    child: Text(
                      log,
                      style: GoogleFonts.jetBrainsMono(
                        color: logColor,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _termDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _termAction(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 14, color: EnterpriseTheme.darkTextMuted),
          ),
        ),
      ),
    );
  }
}
