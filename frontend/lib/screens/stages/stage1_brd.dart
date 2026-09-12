import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../utils/doc_exporter.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';
import '../../services/api_service.dart';

class Stage1Brd extends StatefulWidget {
  const Stage1Brd({super.key});

  @override
  State<Stage1Brd> createState() => _Stage1BrdState();
}

class _Stage1BrdState extends State<Stage1Brd> {
  final TextEditingController _reqCtrl = TextEditingController();
  bool _isEditingReq = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<EnterpriseSDLCController>();
    if (controller.activeFeature.value != null) {
      _reqCtrl.text = controller.activeFeature.value!.baseRequirement;
    }
  }

  @override
  void dispose() {
    _reqCtrl.dispose();
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
        return const Center(child: Text("No Feature Selected"));
      }
      
      final isGenerating = controller.isProcessing.value;
      final brdText = wf?.stageData['brd_content'] as String?;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EnterpriseTheme.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: EnterpriseTheme.purple, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stage 1: Business Requirements Document', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
                    Text('AI-assisted analysis & feature specification', style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Editable Requirement Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getSubtleBg(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_quote, color: EnterpriseTheme.getPrimaryAccent(isDark), size: 18),
                          const SizedBox(width: 8),
                          Text('BASE REQUIREMENT', style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() => _isEditingReq = !_isEditingReq),
                        icon: Icon(_isEditingReq ? Icons.check : Icons.edit, size: 16),
                        label: Text(_isEditingReq ? 'Done' : 'Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: EnterpriseTheme.getPrimaryAccent(isDark),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isEditingReq)
                    TextField(
                      controller: _reqCtrl,
                      maxLines: 3,
                      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: EnterpriseTheme.getInputBg(isDark),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark))),
                      ),
                    )
                  else
                    Text(
                      _reqCtrl.text,
                      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 15, height: 1.5),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // BRD Output Box
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: EnterpriseTheme.getSurface(isDark),
                  border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: brdText == null 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner_outlined, size: 48, color: EnterpriseTheme.getTextMuted(isDark)),
                          const SizedBox(height: 16),
                          Text('Ready to Analyze', style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text("Click 'Generate BRD' to scan codebase and synthesize requirements.", style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark))),
                        ],
                      )
                    )
                  : SingleChildScrollView(
                      child: Text(brdText, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), height: 1.6, fontSize: 14)),
                    ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildGradientButton(
                  onPressed: isGenerating ? () {} : () async {
                    controller.isProcessing.value = true;
                    try {
                        final payload = {
                          'requirement': _reqCtrl.text,
                          'projectId': feature.id.toString(),
                          'repoUrl': feature.codeAccess['repoUrl'],
                          'brdPrompt': feature.brdPrompt,
                          'architecture': 'Zero-Trust Framework',
                          'compliance': 'NIST 800-207',
                        };
                      final res = await ApiService.generateDeliverables(payload);
                      
                      String brdContent = "Failed to generate.";
                      if (res['deliverables'] != null && res['deliverables'].length > 0) {
                        brdContent = res['deliverables'][0]['markdownContent'];
                      }

                      await controller.updateWorkflowStage(1, 'pending', {
                        'brd_content': brdContent,
                      });
                    } catch (e) {
                      controller.logTerminal("Synthesis failed: $e", level: "ERROR");
                      await controller.updateWorkflowStage(1, 'error', {
                        'brd_content': 'Error generating BRD: $e',
                      });
                    } finally {
                      controller.isProcessing.value = false;
                    }
                  },
                  icon: isGenerating ? Icons.hourglass_empty : Icons.generating_tokens,
                  label: isGenerating ? 'Synthesizing...' : (brdText == null ? 'Generate BRD' : 'Regenerate BRD'),
                  isDark: isDark,
                  gradient: brdText != null ? const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF4B5563)]) : null,
                ),
                if (brdText != null) ...[
                  const SizedBox(width: 12),
                  _buildGradientButton(
                    onPressed: () {
                      DocExporter.downloadAsWord(brdText, 'BRD_Document_${feature.name.replaceAll(' ', '_')}');
                    },
                    icon: Icons.file_download_outlined,
                    label: 'Download as Word',
                    isDark: isDark,
                    gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]), // Blue gradient
                  ),
                  const SizedBox(width: 12),
                  _buildGradientButton(
                    onPressed: () {
                      controller.updateWorkflowStage(2, 'approved', {});
                      controller.setStage(SDLCStageType.stage2Design);
                    },
                    icon: Icons.check_circle_outline,
                    label: 'Approve BRD & Continue',
                    isDark: isDark,
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]), // Emerald green gradient
                  ),
                ],
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildGradientButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isDark, Gradient? gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? EnterpriseTheme.brandGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? EnterpriseTheme.getPrimaryAccent(isDark)).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
