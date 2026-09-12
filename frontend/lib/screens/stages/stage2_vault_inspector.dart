import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        return Center(
          child: Text('No active workflow. Initiate one in Stage 1.', style: TextStyle(color: textMutedColor)),
        );
      }

      final tokens = wf.tokens;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.cyberGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.vpn_key_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stage 2: Zero-Trust Gateway & Cryptographic Vault',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Presidio NER tokenization with Redis in-memory vault. All sensitive entities are sanitized before LLM dispatch.',
                        style: TextStyle(color: textSecColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.setStage(SDLCStageType.agentOrchestration),
                  icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                  label: const Text('Proceed to Stage 3', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? EnterpriseTheme.cyan : const Color(0xFF00C9DB),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // Top Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    isDark: isDark,
                    title: 'SANITIZED ENTITIES',
                    value: '${tokens.length} Extracted',
                    subtitle: '100% Policy Enforced',
                    color: primaryAccent,
                    icon: Icons.shield_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    isDark: isDark,
                    title: 'VAULT STORAGE HASH',
                    value: 'vault:${wf.id}',
                    subtitle: 'Redis In-Memory Engine',
                    color: EnterpriseTheme.purple,
                    icon: Icons.storage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    isDark: isDark,
                    title: 'AVG CONFIDENCE',
                    value: '98.6%',
                    subtitle: 'Presidio Named Entity NLP',
                    color: EnterpriseTheme.emerald,
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    isDark: isDark,
                    title: 'DATA LEAKAGE RISK',
                    value: '0.00%',
                    subtitle: 'Air-Gapped Zero-Trust',
                    color: EnterpriseTheme.emeraldGlow,
                    icon: Icons.lock_clock,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Side-by-Side Visual Diff
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.compare_arrows, color: primaryAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Payload Sanitization Visual Diff',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;

                    final originalBox = Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1010) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: EnterpriseTheme.rose.withValues(alpha: isDark ? 0.4 : 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: EnterpriseTheme.rose.withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ORIGINAL UNTRUSTED INPUT (CONTAINS SECRETS)',
                                  style: TextStyle(color: EnterpriseTheme.rose, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SelectableText(
                            wf.rawRequirement,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                              fontFamily: 'Consolas',
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );

                    final sanitizedBox = Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF061A14) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: EnterpriseTheme.emerald.withValues(alpha: isDark ? 0.4 : 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: EnterpriseTheme.emerald.withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SANITIZED ZERO-TRUST PAYLOAD (SENT TO LLM)',
                                  style: TextStyle(color: EnterpriseTheme.emerald, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SelectableText(
                            wf.maskedRequirement,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF059669),
                              fontFamily: 'Consolas',
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: originalBox),
                          const SizedBox(width: 16),
                          Expanded(child: sanitizedBox),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          originalBox,
                          const SizedBox(height: 14),
                          sanitizedBox,
                        ],
                      );
                    }
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cryptographic Vault Hash Table
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.table_rows_outlined, color: primaryAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Redis In-Memory Vault Key-Value Mapping',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Role Context: ${controller.userRole.value}',
                        style: TextStyle(color: textMutedColor, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Table
                  Table(
                    border: TableBorder.all(color: borderColor, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(2.0),
                      2: FlexColumnWidth(2.4),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.0),
                      5: FlexColumnWidth(1.2),
                    },
                    children: [
                      // Header Row
                      TableRow(
                        decoration: BoxDecoration(color: inputBg),
                        children: [
                          _tableHeader('Entity Type', isDark),
                          _tableHeader('Deterministic Vault Token', isDark),
                          _tableHeader('Original Secret (RBAC Protected)', isDark),
                          _tableHeader('Confidence', isDark),
                          _tableHeader('Entropy', isDark),
                          _tableHeader('Access Action', isDark),
                        ],
                      ),
                      // Data Rows
                      ...tokens.map((t) {
                        return TableRow(
                          decoration: BoxDecoration(color: cardBgElevated),
                          children: [
                            _tableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: EnterpriseTheme.purple.withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  t.entityType,
                                  style: TextStyle(color: isDark ? EnterpriseTheme.purple : EnterpriseTheme.purpleDark, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            _tableCell(
                              child: Text(
                                t.maskedToken,
                                style: TextStyle(
                                  color: primaryAccent,
                                  fontFamily: 'Consolas',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _tableCell(
                              child: Text(
                                t.isRevealed ? t.originalValue : '••••••••••••••••••••••',
                                style: TextStyle(
                                  color: t.isRevealed ? EnterpriseTheme.rose : textMutedColor,
                                  fontFamily: 'Consolas',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            _tableCell(
                              child: Text(
                                '${(t.confidence * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(color: EnterpriseTheme.emerald, fontSize: 11),
                              ),
                            ),
                            _tableCell(
                              child: Text(
                                '${t.entropy.toStringAsFixed(2)} bits',
                                style: TextStyle(color: isDark ? EnterpriseTheme.amber : EnterpriseTheme.amberDark, fontSize: 11),
                              ),
                            ),
                            _tableCell(
                              child: InkWell(
                                onTap: () => controller.toggleTokenReveal(t),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        t.isRevealed ? Icons.visibility_off : Icons.visibility,
                                        size: 12,
                                        color: textSecColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        t.isRevealed ? 'Hide' : 'Reveal',
                                        style: TextStyle(color: textColor, fontSize: 10),
                                      ),
                                    ],
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

  Widget _metricCard({
    required bool isDark,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textMutedColor = EnterpriseTheme.getTextMuted(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: textMutedColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
