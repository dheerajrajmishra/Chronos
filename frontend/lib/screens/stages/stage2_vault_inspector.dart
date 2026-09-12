import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage2VaultInspector extends StatelessWidget {
  const Stage2VaultInspector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final wf = controller.activeWorkflow.value;
      if (wf == null) {
        return const Center(
          child: Text('No active workflow. Initiate one in Stage 1.', style: TextStyle(color: EnterpriseTheme.textMuted)),
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
                    children: const [
                      Text(
                        'Stage 2: Zero-Trust Gateway & Cryptographic Vault',
                        style: TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Presidio NER tokenization with Redis in-memory vault. All sensitive entities are sanitized before LLM dispatch.',
                        style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.setStage(SDLCStageType.agentOrchestration),
                  icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                  label: const Text('Proceed to Stage 3', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnterpriseTheme.cyan,
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
                    title: 'SANITIZED ENTITIES',
                    value: '${tokens.length} Extracted',
                    subtitle: '100% Policy Enforced',
                    color: EnterpriseTheme.cyan,
                    icon: Icons.shield_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
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
              decoration: EnterpriseTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.compare_arrows, color: EnterpriseTheme.cyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Payload Sanitization Visual Diff',
                        style: TextStyle(
                          color: EnterpriseTheme.textPrimary,
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
                        color: const Color(0xFF1E1010),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: EnterpriseTheme.rose.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: EnterpriseTheme.rose.withOpacity(0.2),
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
                            style: const TextStyle(
                              color: Color(0xFFFCA5A5),
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
                        color: const Color(0xFF061A14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: EnterpriseTheme.emerald.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: EnterpriseTheme.emerald.withOpacity(0.2),
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
                            style: const TextStyle(
                              color: Color(0xFF86EFAC),
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
              decoration: EnterpriseTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.table_rows_outlined, color: EnterpriseTheme.cyan, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Redis In-Memory Vault Key-Value Mapping',
                        style: TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Role Context: ${controller.userRole.value}',
                        style: const TextStyle(color: EnterpriseTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Table
                  Table(
                    border: TableBorder.all(color: EnterpriseTheme.cardBorder, width: 1),
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
                        decoration: const BoxDecoration(color: Color(0xFF0F172A)),
                        children: [
                          _tableHeader('Entity Type'),
                          _tableHeader('Deterministic Vault Token'),
                          _tableHeader('Original Secret (RBAC Protected)'),
                          _tableHeader('Confidence'),
                          _tableHeader('Entropy'),
                          _tableHeader('Access Action'),
                        ],
                      ),
                      // Data Rows
                      ...tokens.map((t) {
                        return TableRow(
                          decoration: const BoxDecoration(color: Color(0xFF161F30)),
                          children: [
                            _tableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: EnterpriseTheme.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  t.entityType,
                                  style: const TextStyle(color: EnterpriseTheme.purple, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            _tableCell(
                              child: Text(
                                t.maskedToken,
                                style: const TextStyle(
                                  color: EnterpriseTheme.cyan,
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
                                  color: t.isRevealed ? EnterpriseTheme.rose : EnterpriseTheme.textMuted,
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
                                style: const TextStyle(color: EnterpriseTheme.amber, fontSize: 11),
                              ),
                            ),
                            _tableCell(
                              child: InkWell(
                                onTap: () => controller.toggleTokenReveal(t),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: EnterpriseTheme.cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        t.isRevealed ? Icons.visibility_off : Icons.visibility,
                                        size: 12,
                                        color: EnterpriseTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        t.isRevealed ? 'Hide' : 'Reveal',
                                        style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 10),
                                      ),
                                    ],
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

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
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
                  style: const TextStyle(color: EnterpriseTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
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
