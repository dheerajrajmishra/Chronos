import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage2VaultInspector extends StatelessWidget {
  const Stage2VaultInspector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final wf = controller.activeWorkflow.value;
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
      final inputBg = EnterpriseTheme.getInputBg(isDark);
      final cardBgElevated = EnterpriseTheme.getCardBgElevated(isDark);

      if (wf == null) {
        return _emptyState(isDark, textMutedColor, primaryAccent);
      }

      final tokens = wf.tokens;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Page Header ─────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.cyberGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.vpn_key_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Token Vault Inspector',
                        style: GoogleFonts.inter(color: textColor, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Presidio NER tokenization with Redis vault. Sensitive entities sanitized before LLM dispatch.',
                        style: GoogleFonts.inter(color: textSecColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _actionButton(
                  'Proceed to Stage 3',
                  Icons.arrow_forward_rounded,
                  () => controller.setStage(SDLCStageType.agentOrchestration),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Metrics ─────────────────────────────────────
            Row(
              children: [
                Expanded(child: _metricCard(isDark: isDark, title: 'ENTITIES', value: '${tokens.length} Extracted', subtitle: 'Policy enforced', color: primaryAccent, icon: Icons.shield_outlined)),
                const SizedBox(width: 14),
                Expanded(child: _metricCard(isDark: isDark, title: 'VAULT KEY', value: 'vault:${wf.id}', subtitle: 'Redis engine', color: EnterpriseTheme.purple, icon: Icons.storage_outlined)),
                const SizedBox(width: 14),
                Expanded(child: _metricCard(isDark: isDark, title: 'CONFIDENCE', value: '98.6%', subtitle: 'Presidio NER', color: EnterpriseTheme.emerald, icon: Icons.check_circle_outline)),
                const SizedBox(width: 14),
                Expanded(child: _metricCard(isDark: isDark, title: 'LEAKAGE RISK', value: '0.00%', subtitle: 'Zero-trust', color: EnterpriseTheme.emeraldGlow, icon: Icons.lock_outline_rounded)),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Visual Diff ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.compare_arrows_rounded, color: primaryAccent, size: 18),
                      const SizedBox(width: 8),
                      Text('Payload Sanitization Diff', style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    final originalBox = _diffBox(
                      isDark: isDark,
                      label: 'ORIGINAL INPUT (UNTRUSTED)',
                      content: wf.rawRequirement,
                      isOriginal: true,
                    );
                    final sanitizedBox = _diffBox(
                      isDark: isDark,
                      label: 'SANITIZED PAYLOAD (SAFE)',
                      content: wf.maskedRequirement,
                      isOriginal: false,
                    );
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: originalBox),
                          const SizedBox(width: 14),
                          Expanded(child: sanitizedBox),
                        ],
                      );
                    }
                    return Column(children: [originalBox, const SizedBox(height: 14), sanitizedBox]);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Vault Table ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.table_rows_outlined, color: primaryAccent, size: 18),
                      const SizedBox(width: 8),
                      Text('Vault Key-Value Mapping', style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('Role: ${controller.userRole.value}', style: GoogleFonts.inter(color: textMutedColor, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: borderColor, width: 1, borderRadius: BorderRadius.circular(8)),
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(2.0),
                      2: FlexColumnWidth(2.4),
                      3: FlexColumnWidth(1.0),
                      4: FlexColumnWidth(0.8),
                      5: FlexColumnWidth(1.0),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: inputBg),
                        children: [
                          _th('Entity Type', isDark), _th('Vault Token', isDark), _th('Original Secret', isDark),
                          _th('Confidence', isDark), _th('Entropy', isDark), _th('Action', isDark),
                        ],
                      ),
                      ...tokens.map((t) => TableRow(
                        decoration: BoxDecoration(color: cardBgElevated),
                        children: [
                          _td(child: _pill(t.entityType, EnterpriseTheme.purple, isDark)),
                          _td(child: Text(t.maskedToken, style: GoogleFonts.jetBrainsMono(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.w600))),
                          _td(child: Text(
                            t.isRevealed ? t.originalValue : '••••••••••••••••',
                            style: GoogleFonts.jetBrainsMono(color: t.isRevealed ? EnterpriseTheme.rose : textMutedColor, fontSize: 11),
                          )),
                          _td(child: Text('${(t.confidence * 100).toStringAsFixed(1)}%', style: GoogleFonts.inter(color: EnterpriseTheme.emerald, fontSize: 11, fontWeight: FontWeight.w600))),
                          _td(child: Text('${t.entropy.toStringAsFixed(2)}', style: GoogleFonts.inter(color: EnterpriseTheme.amber, fontSize: 11))),
                          _td(child: _revealButton(controller, t, isDark, textColor, textSecColor, inputBg, borderColor)),
                        ],
                      )),
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

  // ─── Helpers ─────────────────────────────────────────────────────
  Widget _emptyState(bool isDark, Color textMutedColor, Color accent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vpn_key_outlined, size: 48, color: accent.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('No active workflow', style: GoogleFonts.inter(color: textMutedColor, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Initiate a pipeline in Stage 1 to begin.', style: GoogleFonts.inter(color: textMutedColor.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: EnterpriseTheme.brandGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Icon(icon, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard({required bool isDark, required String title, required String value, required String subtitle, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.1 : 0.08), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                Text(subtitle, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _diffBox({required bool isDark, required String label, required String content, required bool isOriginal}) {
    final color = isOriginal ? EnterpriseTheme.rose : EnterpriseTheme.emerald;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOriginal
            ? (isDark ? const Color(0xFF1A0F12) : const Color(0xFFFEF2F2))
            : (isDark ? const Color(0xFF0A1A14) : const Color(0xFFECFDF5)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill(label, color, isDark),
          const SizedBox(height: 10),
          SelectableText(
            content,
            style: GoogleFonts.jetBrainsMono(
              color: isOriginal
                  ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626))
                  : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF059669)),
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
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

  Widget _revealButton(EnterpriseSDLCController controller, VaultToken t, bool isDark, Color textColor, Color textSecColor, Color inputBg, Color borderColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.toggleTokenReveal(t),
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(t.isRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 12, color: textSecColor),
              const SizedBox(width: 4),
              Text(t.isRevealed ? 'Hide' : 'Reveal', style: GoogleFonts.inter(color: textColor, fontSize: 10, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
