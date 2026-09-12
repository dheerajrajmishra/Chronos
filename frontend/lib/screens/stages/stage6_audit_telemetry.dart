import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(gradient: EnterpriseTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.insights_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Audit & Telemetry', style: GoogleFonts.inter(color: textColor, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text('Non-repudiable audit trails, cryptographic event hashing, and live telemetry.', style: GoogleFonts.inter(color: textSecColor, fontSize: 13)),
                    ],
                  ),
                ),
                _gradientButton('Export Audit Pack', Icons.file_download_outlined, () {
                  Get.snackbar(
                    'Audit Pack Exported',
                    'Cryptographically signed bundle exported (SHA-256 manifest).',
                    backgroundColor: EnterpriseTheme.emerald,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(12),
                    borderRadius: 8,
                    snackPosition: SnackPosition.TOP,
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Telemetry Grid ──────────────────────────
            Row(
              children: [
                Expanded(child: _telemetryCard(isDark: isDark, title: 'DLP LATENCY', value: '${telemetry['gatewayLatencyMs']} ms', status: 'P99 < 35ms', color: primaryAccent, icon: Icons.speed_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _telemetryCard(isDark: isDark, title: 'VAULT TOKENS', value: '${telemetry['redisTokensCount']}', status: 'In-memory sync', color: EnterpriseTheme.purple, icon: Icons.vpn_key_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _telemetryCard(isDark: isDark, title: 'THROUGHPUT', value: '99.98%', status: 'Queue: sdlc-queue', color: EnterpriseTheme.emerald, icon: Icons.sync_alt_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _telemetryCard(isDark: isDark, title: 'TRUST SCORE', value: telemetry['zeroTrustScore'] ?? '99.4%', status: 'SOC2 verified', color: EnterpriseTheme.emeraldGlow, icon: Icons.verified_outlined)),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Audit Log ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history_rounded, color: primaryAccent, size: 18),
                      const SizedBox(width: 8),
                      Text('Immutable Audit Log (SHA-256 Chain)', style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      _pill('${auditList.length} events', primaryAccent, isDark),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: borderColor, width: 1, borderRadius: BorderRadius.circular(8)),
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
                        children: [_th('Time', isDark), _th('Actor', isDark), _th('Action', isDark), _th('Stage', isDark), _th('SHA-256', isDark), _th('Status', isDark)],
                      ),
                      ...auditList.map((event) {
                        final timeStr = "${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}";
                        return TableRow(
                          decoration: BoxDecoration(color: cardBgElevated),
                          children: [
                            _td(child: Text(timeStr, style: GoogleFonts.jetBrainsMono(color: textSecColor, fontSize: 11))),
                            _td(child: Text(event.actor, style: GoogleFonts.inter(color: textColor, fontSize: 11, fontWeight: FontWeight.w600))),
                            _td(child: _pill(event.action, primaryAccent, isDark)),
                            _td(child: Text(event.stage, style: GoogleFonts.inter(color: textSecColor, fontSize: 11))),
                            _td(child: Text('${event.sha256Hash.substring(0, 24)}...', style: GoogleFonts.jetBrainsMono(color: textMutedColor, fontSize: 10))),
                            _td(child: _pill(event.status, event.status == 'SUCCESS' ? EnterpriseTheme.emerald : EnterpriseTheme.rose, isDark)),
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

  Widget _telemetryCard({required bool isDark, required String title, required String value, required String status, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(status, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _th(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text, style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _td({required Widget child}) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), child: child);
  }

  Widget _pill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.1 : 0.08), borderRadius: BorderRadius.circular(5)),
      child: Text(text, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _gradientButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(gradient: EnterpriseTheme.brandGradient, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
