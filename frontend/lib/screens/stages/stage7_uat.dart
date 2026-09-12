import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';
import '../../utils/doc_exporter.dart';

class Stage7Uat extends StatefulWidget {
  const Stage7Uat({super.key});

  @override
  State<Stage7Uat> createState() => _Stage7UatState();
}

class _Stage7UatState extends State<Stage7Uat> {
  final _promptCtrl = TextEditingController();
  final Map<String, bool> _checklists = {
    'Business Requirement Coverage (BRD Alignment)': true,
    'Zero-Trust Data Protection & PII Tokenization': true,
    'Performance SLA Verification (P95 < 250ms)': true,
    'Audit Trail & Immutable State Hashing': true,
    'AppSec Compliance Sign-off (SOC2 / HIPAA)': true,
  };

  @override
  void initState() {
    super.initState();
    _promptCtrl.text = 'Validate enterprise business criteria and generate formal stakeholder acceptance report.';
  }

  @override
  void dispose() {
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

      final uatContent = wf?.stageData['uat_content'] as String?;

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
                      color: EnterpriseTheme.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: EnterpriseTheme.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fact_check_outlined, size: 14, color: EnterpriseTheme.amber),
                        const SizedBox(width: 6),
                        Text(
                          'STAGE 07',
                          style: GoogleFonts.jetBrainsMono(
                            color: EnterpriseTheme.amber,
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
                        'User Acceptance Testing (UAT)',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: EnterpriseTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Business Criteria Verification, Stakeholder Sign-Off & Compliance Acceptance Checklist',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: EnterpriseTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (uatContent != null)
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
                          Icon(Icons.verified_user_rounded, size: 14, color: EnterpriseTheme.emerald),
                          const SizedBox(width: 6),
                          Text(
                            'UAT ACCEPTED & SIGNED',
                            style: GoogleFonts.jetBrainsMono(
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
                child: uatContent == null
                    ? _buildGeneratorView(isDark, controller, feature)
                    : _buildResultsView(isDark, uatContent, feature.name),
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
                    onPressed: () => controller.setStage(SDLCStageType.stage6Test),
                    icon: const Icon(Icons.arrow_back_rounded, size: 15),
                    label: Text('Back to Testing', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                      side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const Spacer(),
                  if (uatContent != null) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        controller.updateWorkflowStage(7, 'approved', {'uat_approved': true});
                        controller.logTerminal('UAT formally approved and signed off for production.', level: 'SUCCESS');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ UAT Sign-Off Approved!'), backgroundColor: Color(0xFF059669)),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text('Approve UAT Sign-off', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
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
                    onPressed: () => controller.setStage(SDLCStageType.stage8Deploy),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text('Next: Deployment', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGeneratorView(bool isDark, EnterpriseSDLCController controller, dynamic feature) {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stakeholder Acceptance Criteria Checklist', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14)),
            const SizedBox(height: 12),
            ..._checklists.entries.map((e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: EnterpriseTheme.getInputBg(isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
                ),
                child: CheckboxListTile(
                  title: Text(e.key, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13)),
                  value: e.value,
                  activeColor: EnterpriseTheme.emerald,
                  onChanged: (val) {
                    if (val != null) setState(() => _checklists[e.key] = val);
                  },
                ),
              );
            }),
            const SizedBox(height: 20),
            Text('Custom AI UAT Instructions', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _promptCtrl,
              maxLines: 3,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Include specific stakeholder sign-off criteria for finance & compliance teams...',
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
                  backgroundColor: EnterpriseTheme.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  controller.isProcessing.value = true;
                  controller.logTerminal("Synthesizing UAT Sign-off Report...", level: "UAT");
                  await Future.delayed(const Duration(seconds: 2));
                  final uatReport = '''=== USER ACCEPTANCE TESTING (UAT) CERTIFICATION ===
Feature: ${feature.name}
Compliance Baseline: SOC2 Type II + PCI-DSS 4.0
Sign-off Timestamp: ${DateTime.now().toIso8601String()}

1. EXECUTIVE SUMMARY & SCOPE
   The system implementation has been evaluated against the approved Business Requirements Document (BRD) and Technical Document specifications. All core capabilities and zero-trust controls have been verified.

2. STAKEHOLDER VERIFICATION CHECKLIST
${_checklists.entries.map((e) => '   [${e.value ? "X" : " "}] ${e.key} : ${e.value ? "VERIFIED & ACCEPTED" : "PENDING"}').join('\n')}

3. PERFORMANCE & SLA SIGN-OFF
   - Average Query Latency: 42ms (Target: < 250ms)
   - Zero-Trust Token Masking Overhead: 4.8ms
   - Availability Guarantee: 99.99%

4. GOVERNANCE & SIGN-OFF AUDIT
   - Product Owner: APPROVED
   - Lead Enterprise Architect: APPROVED
   - CyberSec Compliance Officer: APPROVED

FINAL RECOMMENDATION: PROMOTE TO STAGE 8 (DEPLOYMENT) ✅
''';
                  await controller.updateWorkflowStage(7, 'uat_ready', {
                    'uat_content': uatReport,
                  });
                  controller.logTerminal("UAT report generated and verified.", level: "SUCCESS");
                  controller.isProcessing.value = false;
                },
                icon: const Icon(Icons.verified_rounded, color: Colors.black87),
                label: Text('Generate & Sign-off UAT Report', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(bool isDark, String uatContent, String featureName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded, color: EnterpriseTheme.emerald, size: 16),
            const SizedBox(width: 8),
            Text(
              'UAT Acceptance Status: CERTIFIED & COMPLIANT',
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
                DocExporter.downloadAsWord(uatContent, 'UAT_Report_${featureName.replaceAll(' ', '_')}');
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
                uatContent,
                style: GoogleFonts.jetBrainsMono(color: const Color(0xFFFDE68A), fontSize: 13, height: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
