import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../utils/doc_exporter.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';
import '../../services/api_service.dart';

class Stage2Design extends StatefulWidget {
  const Stage2Design({super.key});

  @override
  State<Stage2Design> createState() => _Stage2DesignState();
}

class _Stage2DesignState extends State<Stage2Design> {
  final _promptCtrl = TextEditingController();
  bool _isEditingReq = false;

  @override
  void initState() {
    super.initState();
    // Default prompt if empty
    _promptCtrl.text = 'Generate a zero-trust Technical Design Document mapping to the BRD requirements.';
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
      
      if (feature == null) return const Center(child: Text("No Feature Selected"));
      
      final isGenerating = controller.isProcessing.value;
      final designContent = wf?.stageData['design_content'] as String?;
      
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
                  child: const Icon(Icons.architecture_outlined, color: EnterpriseTheme.purple, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stage 2: Technical Design', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
                    Text('AI-assisted architectural & systems design', style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Editable Prompt Box
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
                          Icon(Icons.terminal_outlined, color: EnterpriseTheme.getPrimaryAccent(isDark), size: 18),
                          const SizedBox(width: 8),
                          Text('DESIGN GENERATION PROMPT', style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              controller.logTerminal("Uploaded sample design document.", level: "UPLOAD");
                            },
                            icon: const Icon(Icons.upload_file, size: 16),
                            label: const Text('Upload Sample Design'),
                            style: TextButton.styleFrom(
                              foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => setState(() => _isEditingReq = !_isEditingReq),
                            icon: Icon(_isEditingReq ? Icons.check : Icons.edit, size: 16),
                            label: Text(_isEditingReq ? 'Done' : 'Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: EnterpriseTheme.getPrimaryAccent(isDark),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isEditingReq)
                    TextField(
                      controller: _promptCtrl,
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
                      _promptCtrl.text,
                      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 15, height: 1.5),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Design Output Box
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
                child: designContent == null 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.architecture_outlined, size: 48, color: EnterpriseTheme.getTextMuted(isDark)),
                          const SizedBox(height: 16),
                          Text('Ready to Architect', style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text("Click 'Generate Design' to synthesize technical documents.", style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark))),
                        ],
                      )
                    )
                  : SingleChildScrollView(
                      child: Text(designContent, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), height: 1.6, fontSize: 14)),
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
                        'requirement': _promptCtrl.text.isEmpty ? 'Generate technical design document' : _promptCtrl.text,
                        'projectId': feature.id.toString(),
                        'repoUrl': feature.codeAccess['repoUrl'],
                        'architecture': 'Event-Driven Microservices',
                        'compliance': 'SOC2 Type II',
                      };
                      final res = await ApiService.generateDeliverables(payload);
                      
                      String ddContent = "Failed to generate design.";
                      if (res['deliverables'] != null && res['deliverables'].length > 1) {
                        ddContent = res['deliverables'][1]['markdownContent'];
                      } else if (res['deliverables'] != null && res['deliverables'].length > 0) {
                        ddContent = res['deliverables'][0]['markdownContent'];
                      }

                      await controller.updateWorkflowStage(2, 'designing', {
                        'design_content': ddContent,
                      });
                    } catch (e) {
                      controller.logTerminal("Design synthesis failed: $e", level: "ERROR");
                      await controller.updateWorkflowStage(2, 'error', {
                        'design_content': 'Error generating Design: $e',
                      });
                    } finally {
                      controller.isProcessing.value = false;
                    }
                  },
                  icon: isGenerating ? Icons.hourglass_empty : Icons.generating_tokens,
                  label: isGenerating ? 'Synthesizing...' : (designContent == null ? 'Generate Design' : 'Regenerate Design'),
                  isDark: isDark,
                  gradient: designContent != null ? const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF4B5563)]) : null,
                ),
                if (designContent != null) ...[
                  const SizedBox(width: 12),
                  _buildGradientButton(
                    onPressed: () {
                      DocExporter.downloadAsWord(designContent, 'memory_design_document');
                    },
                    icon: Icons.file_download_outlined,
                    label: 'Download memory.md',
                    isDark: isDark,
                    gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]), // Blue gradient
                  ),
                  const SizedBox(width: 12),
                  _buildGradientButton(
                    onPressed: () {
                      controller.updateWorkflowStage(3, 'approved', {});
                      controller.setStage(SDLCStageType.stage3Code);
                    },
                    icon: Icons.check_circle_outline,
                    label: 'Approve & Proceed to Code',
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
