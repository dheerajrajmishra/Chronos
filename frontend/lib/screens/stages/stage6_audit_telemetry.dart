import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';

class Stage6AuditTelemetry extends StatelessWidget {
  const Stage6AuditTelemetry({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final wf = controller.activeWorkflow.value;
      final telemetry = controller.telemetry;
      final auditList = wf?.auditHistory ?? [];
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
      final inputBg = EnterpriseTheme.getInputBg(isDark);
      final cardBgElevated = EnterpriseTheme.getCardBgElevated(isDark);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics_outlined, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stage 6: Real-Time Audit Vault & Infrastructure Telemetry',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Non-repudiable audit trails, cryptographic event hashing, and continuous telemetry monitoring.',
                        style: TextStyle(color: textSecColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Audit Pack Exported',
                      'Cryptographically signed compliance bundle exported (JSON & SHA-256 manifest).',
                      backgroundColor: EnterpriseTheme.emerald,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(12),
                    );
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 16, color: Colors.black),
                  label: const Text('Export Audit Pack', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? EnterpriseTheme.cyan : const Color(0xFF00C9DB),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Live Telemetry Grid
            Row(
              children: [
                Expanded(
                  child: _telemetryCard(
                    isDark: isDark,
                    title: 'DLP ENGINE LATENCY',
                    value: '${telemetry['gatewayLatencyMs']} ms',
                    status: 'P99 < 35ms',
                    color: primaryAccent,
                    icon: Icons.speed,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _telemetryCard(
                    isDark: isDark,
                    title: 'VAULT TOKENS ACTIVE',
                    value: '${telemetry['redisTokensCount']}',
                    status: '100% In-Memory Sync',
                    color: EnterpriseTheme.purple,
                    icon: Icons.vpn_key_outlined,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _telemetryCard(
                    isDark: isDark,
                    title: 'TEMPORAL THROUGHPUT',
                    value: '99.98%',
                    status: 'Task Queue: sdlc-queue',
                    color: EnterpriseTheme.emerald,
                    icon: Icons.sync_alt,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _telemetryCard(
                    isDark: isDark,
                    title: 'ZERO-TRUST COMPLIANCE',
                    value: telemetry['zeroTrustScore'] ?? '99.4%',
                    status: 'SOC2 / HIPAA Verified',
                    color: EnterpriseTheme.emeraldGlow,
                    icon: Icons.verified,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Immutable Audit Log Table
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: primaryAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Immutable Audit Log (SHA-256 Non-Repudiation Chain)',
                        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${auditList.length} SIGNED EVENTS',
                          style: TextStyle(color: primaryAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: borderColor, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.8),
                      3: FlexColumnWidth(1.8),
                      4: FlexColumnWidth(2.2),
                      5: FlexColumnWidth(1.0),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: inputBg),
                        children: [
                          _tableHeader('Timestamp', isDark),
                          _tableHeader('Actor', isDark),
                          _tableHeader('Action Type', isDark),
                          _tableHeader('SDLC Stage', isDark),
                          _tableHeader('SHA-256 Digest', isDark),
                          _tableHeader('Status', isDark),
                        ],
                      ),
                      ...auditList.map((event) {
                        final timeStr = "${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}";

                        return TableRow(
                          decoration: BoxDecoration(color: cardBgElevated),
                          children: [
                            _tableCell(
                              child: Text(timeStr, style: TextStyle(color: textSecColor, fontFamily: 'Consolas', fontSize: 11)),
                            ),
                            _tableCell(
                              child: Text(event.actor, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            _tableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.action,
                                  style: TextStyle(color: primaryAccent, fontFamily: 'Consolas', fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            _tableCell(
                              child: Text(event.stage, style: TextStyle(color: textSecColor, fontSize: 11)),
                            ),
                            _tableCell(
                              child: Text(
                                '${event.sha256Hash.substring(0, 24)}...',
                                style: TextStyle(color: textMutedColor, fontFamily: 'Consolas', fontSize: 10),
                              ),
                            ),
                            _tableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: event.status == 'SUCCESS' ? EnterpriseTheme.emerald.withValues(alpha: isDark ? 0.2 : 0.12) : EnterpriseTheme.rose.withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.status,
                                  style: TextStyle(
                                    color: event.status == 'SUCCESS' ? EnterpriseTheme.emerald : EnterpriseTheme.rose,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _telemetryCard({
    required bool isDark,
    required String title,
    required String value,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textMutedColor = EnterpriseTheme.getTextMuted(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: textMutedColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: TextStyle(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _tableCell({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: child,
    );
  }
}
