import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';
import '../../utils/doc_exporter.dart';

class Stage4Code extends StatefulWidget {
  const Stage4Code({super.key});

  @override
  State<Stage4Code> createState() => _Stage4CodeState();
}

class _Stage4CodeState extends State<Stage4Code> {
  final _branchCtrl = TextEditingController(text: 'feature/zero-trust-impl');
  final _promptCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final feature = Get.find<EnterpriseSDLCController>().activeFeature.value;
    if (feature != null && feature.codePrompt.isNotEmpty) {
      _promptCtrl.text = feature.codePrompt;
    } else {
      _promptCtrl.text = 'Implement clean, type-safe code strictly conforming to the Technical Document API contracts and database DDL schema.';
    }
  }

  @override
  void dispose() {
    _branchCtrl.dispose();
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      final wf = controller.activeWorkflow.value;

      if (feature == null) {
        return Center(
          child: Text(
            "No Feature Selected",
            style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark)),
          ),
        );
      }

      final codeContent = wf?.stageData['code_content'] as String?;

      return Container(
        color: EnterpriseTheme.getBackground(isDark),
        child: Column(
          children: [
            // Stage Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getSurface(isDark),
                border: Border(bottom: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: EnterpriseTheme.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: EnterpriseTheme.purple.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.code_rounded, size: 14, color: EnterpriseTheme.purple),
                        const SizedBox(width: 6),
                        Text(
                          'STAGE 04',
                          style: GoogleFonts.jetBrainsMono(
                            color: EnterpriseTheme.purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code Implementation',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: EnterpriseTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Production Implementation, Branch Scaffolding & Zero-Trust Token Masking Wrappers',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: EnterpriseTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (codeContent != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: EnterpriseTheme.emerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: EnterpriseTheme.emerald.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: EnterpriseTheme.emerald,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'COMMITTED: ${_branchCtrl.text}',
                            style: GoogleFonts.inter(
                              color: EnterpriseTheme.emerald,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: codeContent == null
                    ? _buildGenerationForm(isDark, controller, feature)
                    : _buildCodeViewer(isDark, codeContent, feature.name),
              ),
            ),

            // Bottom Navigation & Approval Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getSurface(isDark),
                border: Border(top: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => controller.setStage(SDLCStageType.stage3TechDoc),
                    icon: const Icon(Icons.arrow_back_rounded, size: 15),
                    label: Text('Back to Technical Document', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                      side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const Spacer(),
                  if (codeContent != null) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        controller.updateWorkflowStage(4, 'approved', {'code_approved': true});
                        controller.logTerminal('Code approved and tagged for unit testing.', level: 'SUCCESS');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Code Implementation Approved!'), backgroundColor: Color(0xFF059669)),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text('Approve Code', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                  ],
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => controller.setStage(SDLCStageType.stage5UnitTest),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text('Next: Unit Testing', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGenerationForm(bool isDark, EnterpriseSDLCController controller, dynamic feature) {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Git Branch', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _branchCtrl,
              style: GoogleFonts.jetBrainsMono(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: EnterpriseTheme.getInputBg(isDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                prefixIcon: const Icon(Icons.fork_right_rounded, size: 18),
              ),
            ),
            const SizedBox(height: 20),
            Text('Custom AI Coding Instructions (Optional)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _promptCtrl,
              maxLines: 4,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Implement strict parameter validation, circuit breaker for DB queries, and Presidio token masking...',
                hintStyle: TextStyle(color: EnterpriseTheme.getTextMuted(isDark)),
                filled: true,
                fillColor: EnterpriseTheme.getInputBg(isDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EnterpriseTheme.brandBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  controller.isProcessing.value = true;
                  controller.logTerminal("Scaffolding codebase implementation in ${_branchCtrl.text}...", level: "CODE");
                  await Future.delayed(const Duration(seconds: 2));
                  final generatedCode = '''// Zero-Trust Implementation for ${feature.name}
// Branch: ${_branchCtrl.text}
// Generated with Zero-Trust Presidio DLP Protection

import { PresidioVaultClient } from '@enterprise/zero-trust-vault';
import { Pool } from 'pg';

export interface WorkflowPayload {
  featureId: number;
  rawRequirement: string;
  complianceBaseline: string;
}

export class ZeroTrustExecutionService {
  private db: Pool;
  private vaultClient: PresidioVaultClient;

  constructor() {
    this.db = new Pool({
      host: process.env.DB_HOST || '10.240.1.12',
      port: 5432,
      database: 'secure_sdlc_db',
      ssl: { rejectUnauthorized: true }
    });
    this.vaultClient = new PresidioVaultClient({
      vaultTtlMinutes: 30,
      enforceDynamicMasking: true
    });
  }

  /**
   * Securely process execution payload through Zero-Trust Presidio Gateway
   */
  async executeSecureTransaction(payload: WorkflowPayload): Promise<{ success: boolean; transactionId: string }> {
    // 1. DLP Gateway Sanitization
    const sanitized = await this.vaultClient.sanitize(payload.rawRequirement);
    
    // 2. Persist with Parameterized Query (SQL Injection Protected)
    const result = await this.db.query(
      `INSERT INTO feature_\$1_records (feature_id, sanitized_digest, status) 
       VALUES (\$1, \$2, 'ACTIVE') RETURNING id`,
      [payload.featureId, sanitized.sha256Hash]
    );

    return {
      success: true,
      transactionId: result.rows[0].id
    };
  }
}
''';
                  await controller.updateWorkflowStage(4, 'code_ready', {
                    'code_content': generatedCode,
                    'branch_name': _branchCtrl.text,
                  });
                  controller.logTerminal("Code written and committed to branch: ${_branchCtrl.text}", level: "GIT");
                  controller.isProcessing.value = false;
                },
                icon: const Icon(Icons.code_rounded, color: Colors.white),
                label: Text('Generate Code in Branch', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeViewer(bool isDark, String codeContent, String featureName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded, color: EnterpriseTheme.emerald, size: 16),
            const SizedBox(width: 8),
            Text(
              'Branch: ${_branchCtrl.text} • TypeScript / Node.js',
              style: GoogleFonts.jetBrainsMono(color: EnterpriseTheme.emerald, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                DocExporter.downloadAsWord(codeContent, 'Code_Implementation_${featureName.replaceAll(' ', '_')}');
              },
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: Text('Download as Word (.docx)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF090A10) : const Color(0xFF18181B),
              border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                codeContent,
                style: GoogleFonts.jetBrainsMono(color: const Color(0xFF34D399), fontSize: 13, height: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
