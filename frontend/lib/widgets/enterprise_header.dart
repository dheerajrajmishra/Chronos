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
      final isDark = controller.isDarkMode.value;
      final wf = controller.activeWorkflow.value;
      final prj = controller.activeProject.value;
      final telemetry = controller.telemetry;

      final surfaceColor = EnterpriseTheme.getSurface(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF64748B).withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
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
                      color: EnterpriseTheme.getInputBg(isDark),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.folder, color: primaryAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          prj.projectKey,
                          style: TextStyle(
                            color: primaryAccent,
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
                    color: primaryAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: primaryAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.blur_on, color: primaryAccent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        wf.id,
                        style: TextStyle(
                          color: primaryAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(wf.status, isDark),
              ] else ...[
                Text(
                  'ZERO-TRUST AI SDLC PORTAL',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],

              const SizedBox(width: 16),

              // Live Telemetry Indicators
              _telemetryPill(
                isDark: isDark,
                label: 'TEMPORAL',
                value: telemetry['temporalStatus'] ?? 'ONLINE',
                color: EnterpriseTheme.emerald,
                icon: Icons.sync_alt,
              ),
              const SizedBox(width: 8),
              _telemetryPill(
                isDark: isDark,
                label: 'VAULT REDIS',
                value: "${telemetry['redisTokensCount']} TOKENS",
                color: primaryAccent,
                icon: Icons.vpn_key_outlined,
              ),
              const SizedBox(width: 8),
              _telemetryPill(
                isDark: isDark,
                label: 'DLP LATENCY',
                value: "${telemetry['gatewayLatencyMs']}ms",
                color: EnterpriseTheme.emeraldGlow,
                icon: Icons.speed,
              ),
              const SizedBox(width: 8),
              _telemetryPill(
                isDark: isDark,
                label: 'ZERO-TRUST SCORE',
                value: telemetry['zeroTrustScore'] ?? '99.4%',
                color: primaryAccent,
                icon: Icons.verified,
              ),

              const SizedBox(width: 16),

              // Theme Mode Toggle Button
              Container(
                decoration: BoxDecoration(
                  color: EnterpriseTheme.getInputBg(isDark),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
                    child: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      key: ValueKey<bool>(isDark),
                      size: 16,
                      color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
                    ),
                  ),
                  tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                  onPressed: controller.toggleTheme,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                ),
              ),

              const SizedBox(width: 8),

              // Live Terminal Console Toggle
              ElevatedButton.icon(
                onPressed: onToggleTerminal,
                icon: Icon(
                  Icons.terminal,
                  size: 14,
                  color: isTerminalOpen ? primaryAccent : (isDark ? Colors.white : const Color(0xFF1E293B)),
                ),
                label: Text(
                  isTerminalOpen ? 'Hide Logs' : 'Live Logs',
                  style: TextStyle(
                    fontSize: 11,
                    color: isTerminalOpen ? primaryAccent : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTerminalOpen
                      ? primaryAccent.withValues(alpha: 0.15)
                      : EnterpriseTheme.getInputBg(isDark),
                  side: BorderSide(
                    color: isTerminalOpen ? primaryAccent : borderColor,
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
                  backgroundColor: isDark ? EnterpriseTheme.cyan : const Color(0xFF00C9DB),
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

  Widget _statusBadge(String status, bool isDark) {
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
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
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
    required bool isDark,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getInputBg(isDark),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            "$label: ",
            style: TextStyle(
              color: EnterpriseTheme.getTextMuted(isDark),
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
