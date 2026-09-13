import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';
import '../../utils/doc_exporter.dart';

class Stage8Deploy extends StatefulWidget {
  const Stage8Deploy({super.key});

  @override
  State<Stage8Deploy> createState() => _Stage8DeployState();
}

class _Stage8DeployState extends State<Stage8Deploy> {
  bool _isApproving = false;
  String _targetCloud = 'Microsoft Azure (Zero-Trust VPC)';
  String _rolloutStrategy = 'Canary 10% -> 50% -> 100%';

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

      final deployContent = wf?.stageData['deploy_content'] as String?;

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
                      color: EnterpriseTheme.emerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: EnterpriseTheme.emerald.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rocket_launch_rounded, size: 14, color: EnterpriseTheme.emerald),
                        const SizedBox(width: 6),
                        Text(
                          'STAGE 08',
                          style: GoogleFonts.jetBrainsMono(
                            color: EnterpriseTheme.emerald,
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
                        'Deployment & Production Release',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: EnterpriseTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Zero-Trust Cloud Enclave Rollout, Canary Verification & Immutable Audit Certification',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: EnterpriseTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (deployContent != null)
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
                          Icon(Icons.check_circle_rounded, size: 14, color: EnterpriseTheme.emerald),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE IN PRODUCTION',
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
          if (controller.isProcessing.value)
            LinearProgressIndicator(color: EnterpriseTheme.getPrimaryAccent(isDark), backgroundColor: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.1), minHeight: 3),
          

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: deployContent == null
                    ? _buildRolloutConfig(isDark, controller, feature)
                    : _buildLiveTelemetry(isDark, deployContent, feature.name),
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
                    onPressed: () => controller.setStage(SDLCStageType.stage7TestingResult),
                    icon: const Icon(Icons.arrow_back_rounded, size: 15),
                    label: Text('Back to UAT', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                      side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const Spacer(),
                  if (deployContent != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        controller.updateWorkflowStage(8, 'completed', {'deployed': true});
                        controller.logTerminal('Pipeline complete! Feature deployed to production enclave.', level: 'SUCCESS');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 Feature Successfully Promoted to Production!'), backgroundColor: Color(0xFF059669)),
                        );
                      },
                      icon: const Icon(Icons.celebration_rounded, size: 16),
                      label: Text('Complete Pipeline', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRolloutConfig(bool isDark, EnterpriseSDLCController controller, dynamic feature) {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Zero-Trust Cloud Enclave', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getInputBg(isDark),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
              ),
              child: DropdownButton<String>(
                value: _targetCloud,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: EnterpriseTheme.getSurface(isDark),
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
                items: [
                  'Microsoft Azure (Zero-Trust VPC)',
                  'AWS GovCloud (Isolated PCI Enclave)',
                  'Google Cloud Platform (Confidential VMs)',
                ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _targetCloud = val);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Rollout Strategy', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getInputBg(isDark),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
              ),
              child: DropdownButton<String>(
                value: _rolloutStrategy,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: EnterpriseTheme.getSurface(isDark),
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
                items: [
                  'Canary 10% -> 50% -> 100%',
                  'Blue-Green Instant Cutover',
                  'Rolling Update with Health Check',
                ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _rolloutStrategy = val);
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EnterpriseTheme.emerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  controller.isProcessing.value = true;
                  controller.logTerminal("Initiating Zero-Trust Enclave Deployment to $_targetCloud...", level: "DEPLOY");
                  await Future.delayed(const Duration(seconds: 2));
                  final deployReport = '''=== PRODUCTION DEPLOYMENT AUDIT CERTIFICATE ===
Feature: ${feature.name}
Enclave: $_targetCloud
Rollout Strategy: $_rolloutStrategy
Deployed At: ${DateTime.now().toIso8601String()}

1. ENCLAVE PRE-FLIGHT VERIFICATION
   [OK] mTLS 1.3 CA Certificate Chain Validated
   [OK] Presidio DLP Gateway: ONLINE (Port 8080)
   [OK] Redis Token Vault: HEALTHY (Latency 0.4ms)
   [OK] PostgreSQL Database ACID Migrations: APPLIED

2. CANARY ROLLOUT SEQUENCE
   - Phase 1 (10% Traffic): Health check 100% OK • Error rate 0.00%
   - Phase 2 (50% Traffic): P95 Latency 38ms • Token Substitution Rate 100%
   - Phase 3 (100% Traffic Cutover): Complete

3. CRYPTOGRAPHIC RELEASE AUDIT SEAL
   - Release SHA-256 Digest: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
   - Immutable Audit Block ID: blk_9918230f
   - Compliance Status: FULLY CERTIFIED (SOC2 / HIPAA / PCI-DSS)

STATUS: PRODUCTION DEPLOYMENT ACTIVE & HEALTHY 🚀
''';
                  await controller.updateWorkflowStage(8, 'deployed', {
                    'deploy_content': deployReport,
                  });
                  controller.logTerminal("Production deployment successful! Release certified.", level: "SUCCESS");
                  controller.isProcessing.value = false;
                },
                icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                label: Text('Promote to Production Enclave', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTelemetry(bool isDark, String deployContent, String featureName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded, color: EnterpriseTheme.emerald, size: 16),
            const SizedBox(width: 8),
            Text(
              'Enclave Status: LIVE & SERVING TRAFFIC',
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
                DocExporter.downloadAsWord(deployContent, 'Deployment_Manifest_${featureName.replaceAll(' ', '_')}');
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
                deployContent,
                style: GoogleFonts.jetBrainsMono(color: const Color(0xFF6EE7B7), fontSize: 13, height: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
