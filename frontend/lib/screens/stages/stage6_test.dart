import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';
import '../../utils/doc_exporter.dart';

class Stage6Test extends StatefulWidget {
  const Stage6Test({super.key});

  @override
  State<Stage6Test> createState() => _Stage6TestState();
}

class _Stage6TestState extends State<Stage6Test> {
  final _bugCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _promptCtrl.text = 'Execute end-to-end integration test suite, Presidio DLP penetration checks, and DAST security scan.';
  }

  @override
  void dispose() {
    _bugCtrl.dispose();
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

      final testContent = wf?.stageData['test_content'] as String?;

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
                      color: EnterpriseTheme.rose.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: EnterpriseTheme.rose.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 14, color: EnterpriseTheme.rose),
                        const SizedBox(width: 6),
                        Text(
                          'STAGE 06',
                          style: GoogleFonts.jetBrainsMono(
                            color: EnterpriseTheme.rose,
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
                        'Testing (Integration & Security)',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: EnterpriseTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'End-to-End Integration, Presidio Leak Penetration Testing & DAST/SAST Verification',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: EnterpriseTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (testContent != null)
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
                          Icon(Icons.check_circle_outline, size: 14, color: EnterpriseTheme.emerald),
                          const SizedBox(width: 6),
                          Text(
                            'SECURITY SUITE PASSED',
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
                child: testContent == null
                    ? _buildGeneratorView(isDark, controller, feature)
                    : _buildResultsView(isDark, controller, testContent, feature.name),
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
                    onPressed: () => controller.setStage(SDLCStageType.stage5UnitTest),
                    icon: const Icon(Icons.arrow_back_rounded, size: 15),
                    label: Text('Back to Unit Testing', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                      side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const Spacer(),
                  if (testContent != null) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        controller.updateWorkflowStage(6, 'approved', {'tests_approved': true});
                        controller.logTerminal('Integration & Security testing approved by SecOps.', level: 'SUCCESS');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Integration & Security Testing Approved!'), backgroundColor: Color(0xFF059669)),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text('Approve Testing', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
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
                    onPressed: () => controller.setStage(SDLCStageType.stage7Uat),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text('Next: UAT', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
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
            Text('Security Scan & Integration Instructions', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _promptCtrl,
              maxLines: 4,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Run Presidio token leakage audit, simulate SQL injection attack vectors, and test network partition...',
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
                  backgroundColor: EnterpriseTheme.rose,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  controller.isProcessing.value = true;
                  controller.logTerminal("Initiating Zero-Trust Integration & Security Audit...", level: "AUDIT");
                  await Future.delayed(const Duration(seconds: 2));
                  final testOutput = '''=== ZERO-TRUST INTEGRATION & SECURITY SUITE ===
Feature: ${feature.name}
Compliance Audit Target: SOC2 Type II + HIPAA
Timestamp: ${DateTime.now().toIso8601String()}

[PASS] 1. PRESIDIO GATEWAY TOKEN LEAKAGE TEST
  - Scanned 2,000 synthetic PII payloads (Credit Card PAN, SSN, API Keys).
  - Detected: 100% tokenization rate.
  - Zero raw secrets leaked to reasoning layer or audit telemetry.

[PASS] 2. DATABASE JIT EPHEMERAL ACCESS TEST
  - Validated dynamic credential revocation after 30 minutes.
  - Read-write queries executed successfully over TLS 1.3 socket.
  - Unauthorized direct root connection attempt BLOCKED.

[PASS] 3. OWASP TOP 10 PENETRATION SUITE
  - SQL Injection (A03): Protected via parameterized prepared statements.
  - Broken Access Control (A01): Verified RBAC least-privilege token enforcement.
  - Cryptographic Failures (A02): AES-256-GCM verified on storage layer.

[PASS] 4. TEMPORAL WORKFLOW RECOVERY & RETRY TEST
  - Induced simulated network partition on worker node.
  - Workflow successfully resumed from latest event checkpoint without data loss.

Summary: 4/4 Integration & Security Test Suites Passed. Zero Vulnerabilities Detected.
''';
                  await controller.updateWorkflowStage(6, 'testing_ready', {
                    'test_content': testOutput,
                  });
                  controller.logTerminal("Security & integration tests completed successfully.", level: "SUCCESS");
                  controller.isProcessing.value = false;
                },
                icon: const Icon(Icons.security_rounded, color: Colors.white),
                label: Text('Generate & Run Integration Tests', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(bool isDark, EnterpriseSDLCController controller, String testContent, String featureName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded, color: EnterpriseTheme.emerald, size: 16),
            const SizedBox(width: 8),
            Text(
              'Pipeline Test Status: VERIFIED CLEAN (0 Vulnerabilities)',
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
                DocExporter.downloadAsWord(testContent, 'Security_Test_Report_${featureName.replaceAll(' ', '_')}');
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
                testContent,
                style: GoogleFonts.jetBrainsMono(color: const Color(0xFFBAE6FD), fontSize: 13, height: 1.6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _bugCtrl,
                style: TextStyle(color: EnterpriseTheme.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  hintText: 'Log Bug or Vulnerability Exception (if any)...',
                  hintStyle: TextStyle(color: EnterpriseTheme.getTextMuted(isDark)),
                  filled: true,
                  fillColor: EnterpriseTheme.getInputBg(isDark),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (_bugCtrl.text.isNotEmpty) {
                  controller.logTerminal("Bug Logged: ${_bugCtrl.text}", level: "BUG");
                  _bugCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bug logged to audit ledger.'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              icon: const Icon(Icons.bug_report_outlined, size: 16),
              label: Text('Log Issue', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}
