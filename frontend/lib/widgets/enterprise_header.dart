import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../theme/enterprise_theme.dart';

class EnterpriseHeader extends StatelessWidget {
  final VoidCallback onToggleTerminal;
  final bool isTerminalOpen;

  const EnterpriseHeader({
    Key? key,
    required this.onToggleTerminal,
    required this.isTerminalOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final wf = controller.activeWorkflow.value;
      final prj = controller.activeProject.value;
      final telemetry = controller.telemetry;

      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: EnterpriseTheme.surfaceDark,
          border: Border(bottom: BorderSide(color: EnterpriseTheme.cardBorder, width: 1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Active Project Identifier
              if (prj != null) ...[
                InkWell(
                  onTap: () => controller.setStage(SDLCStageType.projectHub),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: EnterpriseTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder, color: EnterpriseTheme.cyan, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          prj.projectKey,
                          style: const TextStyle(
                            color: EnterpriseTheme.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Active Workflow Identifier & Status
              if (wf != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: EnterpriseTheme.cyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: EnterpriseTheme.cyan.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.blur_on, color: EnterpriseTheme.cyan, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        wf.id,
                        style: const TextStyle(
                          color: EnterpriseTheme.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(wf.status),
              ] else ...[
                const Text(
                  'ZERO-TRUST AI SDLC PORTAL',
                  style: TextStyle(
                    color: EnterpriseTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],

              const SizedBox(width: 16),

              // Live Telemetry Indicators
              _telemetryPill(
                label: 'TEMPORAL',
                value: telemetry['temporalStatus'] ?? 'ONLINE',
                color: EnterpriseTheme.emerald,
                icon: Icons.sync_alt,
              ),
              const SizedBox(width: 8),
              _telemetryPill(
                label: 'VAULT REDIS',
                value: "${telemetry['redisTokensCount']} TOKENS",
                color: EnterpriseTheme.cyan,
                icon: Icons.vpn_key_outlined,
              ),
              const SizedBox(width: 8),
              _telemetryPill(
                label: 'DLP LATENCY',
                value: "${telemetry['gatewayLatencyMs']}ms",
                color: EnterpriseTheme.emeraldGlow,
                icon: Icons.speed,
              ),
              const SizedBox(width: 8),
              _telemetryPill(
                label: 'ZERO-TRUST SCORE',
                value: telemetry['zeroTrustScore'] ?? '99.4%',
                color: EnterpriseTheme.cyan,
                icon: Icons.verified,
              ),

              const SizedBox(width: 16),

              // Live Terminal Console Toggle
              ElevatedButton.icon(
                onPressed: onToggleTerminal,
                icon: Icon(
                  Icons.terminal,
                  size: 14,
                  color: isTerminalOpen ? EnterpriseTheme.cyan : Colors.white,
                ),
                label: Text(
                  isTerminalOpen ? 'Hide Logs' : 'Live Logs',
                  style: TextStyle(
                    fontSize: 11,
                    color: isTerminalOpen ? EnterpriseTheme.cyan : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTerminalOpen
                      ? EnterpriseTheme.cyan.withValues(alpha: 0.15)
                      : const Color(0xFF1E293B),
                  side: BorderSide(
                    color: isTerminalOpen ? EnterpriseTheme.cyan : EnterpriseTheme.cardBorder,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
              ),

              const SizedBox(width: 10),

              // New Workflow Button
              ElevatedButton.icon(
                onPressed: () {
                  controller.setStage(SDLCStageType.specStudio);
                },
                icon: const Icon(Icons.add_circle_outline, size: 14, color: Colors.black),
                label: const Text(
                  'New Pipeline',
                  style: TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EnterpriseTheme.cyan,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _statusBadge(String status) {
    Color color = EnterpriseTheme.cyan;
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _telemetryPill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: EnterpriseTheme.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            "$label: ",
            style: const TextStyle(
              color: EnterpriseTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
