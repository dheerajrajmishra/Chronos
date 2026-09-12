import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';
import '../../utils/doc_exporter.dart';

class Stage5UnitTest extends StatefulWidget {
  const Stage5UnitTest({super.key});

  @override
  State<Stage5UnitTest> createState() => _Stage5UnitTestState();
}

class _Stage5UnitTestState extends State<Stage5UnitTest> {
  final _promptCtrl = TextEditingController();
  String _selectedFramework = 'Jest / TypeScript';

  @override
  void initState() {
    super.initState();
    _promptCtrl.text = 'Generate comprehensive unit test suites covering edge cases, Presidio vault token mock, and database error handling.';
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

      final unitTestContent = wf?.stageData['unit_test_content'] as String?;

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
                      color: EnterpriseTheme.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: EnterpriseTheme.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.checklist_rounded, size: 14, color: EnterpriseTheme.cyan),
                        const SizedBox(width: 6),
                        Text(
                          'STAGE 05',
                          style: GoogleFonts.jetBrainsMono(
                            color: EnterpriseTheme.cyan,
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
                        'Unit Testing',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: EnterpriseTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Automated Unit Test Suites, Mock Fixtures, Code Coverage & Assertion Verification',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: EnterpriseTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (unitTestContent != null)
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
                          Icon(Icons.verified_rounded, size: 14, color: EnterpriseTheme.emerald),
                          const SizedBox(width: 6),
                          Text(
                            '14/14 PASSED • 96.2% COVERAGE',
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
                child: unitTestContent == null
                    ? _buildGeneratorView(isDark, controller, feature)
                    : _buildResultsView(isDark, unitTestContent, feature.name),
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
                    onPressed: () => controller.setStage(SDLCStageType.stage4Code),
                    icon: const Icon(Icons.arrow_back_rounded, size: 15),
                    label: Text('Back to Code', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                      side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const Spacer(),
                  if (unitTestContent != null) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        controller.updateWorkflowStage(5, 'approved', {'unit_tests_approved': true});
                        controller.logTerminal('Unit Tests approved by QA Lead.', level: 'SUCCESS');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Unit Tests Approved!'), backgroundColor: Color(0xFF059669)),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text('Approve Unit Tests', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
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
                    onPressed: () => controller.setStage(SDLCStageType.stage6Test),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text('Next: Testing', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
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
            Text('Test Runner Framework', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getInputBg(isDark),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
              ),
              child: DropdownButton<String>(
                value: _selectedFramework,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: EnterpriseTheme.getSurface(isDark),
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
                items: ['Jest / TypeScript', 'PyTest / Python', 'JUnit 5 / Java', 'Go Test', 'Flutter Test']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedFramework = val);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Custom Unit Test Instructions', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _promptCtrl,
              maxLines: 4,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Include test cases for invalid input payloads, Presidio token substitution failure, and SQL timeout...',
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
                  backgroundColor: EnterpriseTheme.cyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  controller.isProcessing.value = true;
                  controller.logTerminal("Synthesizing unit test suite and executing runner...", level: "TEST");
                  await Future.delayed(const Duration(seconds: 2));
                  final testOutput = '''=== ZERO-TRUST UNIT TEST SUITE ($_selectedFramework) ===
Feature: ${feature.name}
Test Runner: Jest v29.7.0 • Environment: Node 20 / Linux Sandbox

 PASS  tests/unit/zero_trust_vault.test.ts (1.184 s)
  ✓ [PresidioVaultClient] should successfully tokenize PII payload (42 ms)
  ✓ [PresidioVaultClient] should store surrogate tokens with 30m TTL in Redis (18 ms)
  ✓ [PresidioVaultClient] should prevent unmasked secrets from leaking to logs (12 ms)
  ✓ [PresidioVaultClient] should reject unauthorized decryption requests without dual-key (24 ms)

 PASS  tests/unit/database_isolation.test.ts (0.942 s)
  ✓ [DB Client] should execute parameterized query on feature record (31 ms)
  ✓ [DB Client] should reject raw unescaped SQL strings (injection prevention) (15 ms)
  ✓ [DB Client] should handle database timeout with circuit breaker backoff (55 ms)

 PASS  tests/unit/mtls_transport.test.ts (0.680 s)
  ✓ [mTLS Handshake] should enforce TLS 1.3 protocol requirement (20 ms)
  ✓ [mTLS Handshake] should verify client certificate thumbprint (19 ms)
  ✓ [mTLS Handshake] should invalidate revoked certificates against CRL (28 ms)

Test Suites: 3 passed, 3 total
Tests:       14 passed, 0 failed, 0 skipped, 14 total
Snapshots:   0 total
Time:        2.806 s
Ran all test suites.

Coverage Summary:
  Statements   : 96.2% ( 102/106 )
  Branches     : 92.8% ( 26/28 )
  Functions    : 100.0% ( 32/32 )
  Lines        : 96.0% ( 96/100 )
=========================================================
STATUS: ALL UNIT TESTS PASSED SUCCESSFULLY ✅
''';
                  await controller.updateWorkflowStage(5, 'unit_tests_ready', {
                    'unit_test_content': testOutput,
                    'framework': _selectedFramework,
                  });
                  controller.logTerminal("Unit tests executed: 14 passed (96.2% coverage)", level: "SUCCESS");
                  controller.isProcessing.value = false;
                },
                icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.white),
                label: Text('Generate & Run Unit Tests', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(bool isDark, String unitTestContent, String featureName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded, color: EnterpriseTheme.emerald, size: 16),
            const SizedBox(width: 8),
            Text(
              'Test Runner: $_selectedFramework • Execution Status: PASSED',
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
                DocExporter.downloadAsWord(unitTestContent, 'Unit_Test_Report_${featureName.replaceAll(' ', '_')}');
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
                unitTestContent,
                style: GoogleFonts.jetBrainsMono(color: const Color(0xFFA7F3D0), fontSize: 13, height: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
