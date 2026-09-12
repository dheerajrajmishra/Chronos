import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../theme/enterprise_theme.dart';
import '../widgets/enterprise_sidebar.dart';
import '../widgets/enterprise_header.dart';
import 'projects/project_hub_screen.dart';
import 'stages/stage1_spec_studio.dart';
import 'stages/stage2_vault_inspector.dart';
import 'stages/stage3_agent_orchestration.dart';
import 'stages/stage4_approval_gate.dart';
import 'stages/stage5_codegen_sbom.dart';
import 'stages/stage6_audit_telemetry.dart';

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

    return Scaffold(
      backgroundColor: EnterpriseTheme.background,
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
                      case SDLCStageType.specStudio:
                        return const Stage1SpecStudio();
                      case SDLCStageType.vaultInspector:
                        return const Stage2VaultInspector();
                      case SDLCStageType.agentOrchestration:
                        return const Stage3AgentOrchestration();
                      case SDLCStageType.approvalGate:
                        return const Stage4ApprovalGate();
                      case SDLCStageType.codeGenSbom:
                        return const Stage5CodeGenSbom();
                      case SDLCStageType.auditTelemetry:
                        return const Stage6AuditTelemetry();
                    }
                  }),
                ),

                // Live Streaming Activity Terminal Drawer
                if (_isTerminalOpen) _terminalDrawer(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _terminalDrawer(EnterpriseSDLCController controller) {
    return Obx(() {
      final logs = controller.liveTerminalLogs;

      return Container(
        height: 220,
        decoration: const BoxDecoration(
          color: Color(0xFF06090F),
          border: Border(top: BorderSide(color: EnterpriseTheme.cardBorder, width: 1.5)),
        ),
        child: Column(
          children: [
            // Terminal Header
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: EnterpriseTheme.cardBorder, width: 1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.terminal, size: 14, color: EnterpriseTheme.cyan),
                  const SizedBox(width: 8),
                  const Text(
                    'ZERO-TRUST ORCHESTRATION TERMINAL & TELEMETRY STREAM',
                    style: TextStyle(
                      color: EnterpriseTheme.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 14, color: EnterpriseTheme.textMuted),
                    onPressed: () => controller.liveTerminalLogs.clear(),
                    tooltip: 'Clear Logs',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14, color: EnterpriseTheme.textMuted),
                    onPressed: () => setState(() => _isTerminalOpen = false),
                    tooltip: 'Close Terminal',
                  ),
                ],
              ),
            ),

            // Logs Content Area
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  Color logColor = const Color(0xFF94A3B8);

                  if (log.contains('[WORKFLOW]') || log.contains('[SIGNAL]')) {
                    logColor = EnterpriseTheme.cyan;
                  } else if (log.contains('[VAULT]') || log.contains('[VAULT_AUDIT]')) {
                    logColor = EnterpriseTheme.purple;
                  } else if (log.contains('[TEMPORAL]') || log.contains('[AGENT_')) {
                    logColor = EnterpriseTheme.emerald;
                  } else if (log.contains('[STT]') || log.contains('[AUTH]')) {
                    logColor = EnterpriseTheme.amber;
                  } else if (log.contains('ERROR') || log.contains('BLOCKED')) {
                    logColor = EnterpriseTheme.rose;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      log,
                      style: TextStyle(
                        color: logColor,
                        fontFamily: 'Consolas',
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
}
