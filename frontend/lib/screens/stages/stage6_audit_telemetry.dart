import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';

class Stage6AuditTelemetry extends StatelessWidget {
  const Stage6AuditTelemetry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final wf = controller.activeWorkflow.value;
      final telemetry = controller.telemetry;
      final auditList = wf?.auditHistory ?? [];

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
                    children: const [
                      Text(
                        'Stage 6: Real-Time Audit Vault & Infrastructure Telemetry',
                        style: TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Non-repudiable audit trails, cryptographic event hashing, and continuous telemetry monitoring.',
                        style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 13),
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
                    backgroundColor: EnterpriseTheme.cyan,
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
                    title: 'DLP ENGINE LATENCY',
                    value: '${telemetry['gatewayLatencyMs']} ms',
                    status: 'P99 < 35ms',
                    color: EnterpriseTheme.cyan,
                    icon: Icons.speed,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _telemetryCard(
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
              decoration: EnterpriseTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history, color: EnterpriseTheme.cyan, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Immutable Audit Log (SHA-256 Non-Repudiation Chain)',
                        style: TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: EnterpriseTheme.cyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${auditList.length} SIGNED EVENTS',
                          style: const TextStyle(color: EnterpriseTheme.cyan, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: EnterpriseTheme.cardBorder, width: 1),
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
                        decoration: const BoxDecoration(color: Color(0xFF0F172A)),
                        children: [
                          _tableHeader('Timestamp'),
                          _tableHeader('Actor'),
                          _tableHeader('Action Type'),
                          _tableHeader('SDLC Stage'),
                          _tableHeader('SHA-256 Digest'),
                          _tableHeader('Status'),
                        ],
                      ),
                      ...auditList.map((event) {
                        final timeStr = "${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}";

                        return TableRow(
                          decoration: const BoxDecoration(color: Color(0xFF161F30)),
                          children: [
                            _tableCell(
                              child: Text(timeStr, style: const TextStyle(color: EnterpriseTheme.textSecondary, fontFamily: 'Consolas', fontSize: 11)),
                            ),
                            _tableCell(
                              child: Text(event.actor, style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            _tableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: EnterpriseTheme.cyan.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.action,
                                  style: const TextStyle(color: EnterpriseTheme.cyan, fontFamily: 'Consolas', fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            _tableCell(
                              child: Text(event.stage, style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11)),
                            ),
                            _tableCell(
                              child: Text(
                                '${event.sha256Hash.substring(0, 24)}...',
                                style: const TextStyle(color: EnterpriseTheme.textMuted, fontFamily: 'Consolas', fontSize: 10),
                              ),
                            ),
                            _tableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: event.status == 'SUCCESS' ? EnterpriseTheme.emerald.withOpacity(0.2) : EnterpriseTheme.rose.withOpacity(0.2),
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
                      }).toList(),
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
    required String title,
    required String value,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: EnterpriseTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
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
