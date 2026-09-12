import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../services/api_service.dart';
import '../../models/workflow_model.dart';

class Stage0FeatureSetup extends StatefulWidget {
  const Stage0FeatureSetup({super.key});

  @override
  State<Stage0FeatureSetup> createState() => _Stage0FeatureSetupState();
}

class _Stage0FeatureSetupState extends State<Stage0FeatureSetup> {
  final _nameCtrl = TextEditingController();
  final _codeRepoCtrl = TextEditingController();
  final _dbUrlCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<EnterpriseSDLCController>();
    final feature = controller.activeFeature.value;
    if (feature != null) {
      _nameCtrl.text = feature.name;
      _codeRepoCtrl.text = feature.codeAccess['repoUrl'] ?? '';
      _dbUrlCtrl.text = feature.dbAccess['url'] ?? '';
      _reqCtrl.text = feature.baseRequirement;
      _promptCtrl.text = feature.brdPrompt;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeRepoCtrl.dispose();
    _dbUrlCtrl.dispose();
    _reqCtrl.dispose();
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      
      if (feature == null) {
        return const Center(child: Text("No Feature Selected"));
      }
      
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
                  child: const Icon(Icons.settings_applications_outlined, color: EnterpriseTheme.purple, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stage 0: Feature Setup', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
                    Text('Configure context for AI Agents and SDLC workflows', style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: Container(
                width: 800,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: EnterpriseTheme.getSurface(isDark),
                  border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField('Feature Name', _nameCtrl, isDark, Icons.label_outline),
                      const SizedBox(height: 24),
                      _buildInputField('Code Access (Git Repo URL)', _codeRepoCtrl, isDark, Icons.code),
                      const SizedBox(height: 24),
                      _buildInputField('Database Access URL', _dbUrlCtrl, isDark, Icons.dns_outlined),
                      const SizedBox(height: 24),
                      _buildInputField('Base Requirements (Plain English)', _reqCtrl, isDark, Icons.format_quote, maxLines: 4),
                      const SizedBox(height: 24),
                      _buildInputField('Custom BRD Generation Prompt', _promptCtrl, isDark, Icons.smart_toy_outlined, maxLines: 3),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildGradientButton(
                  onPressed: _isSaving ? () {} : () async {
                    setState(() => _isSaving = true);
                    try {
                      final updatedFeature = await ApiService.updateFeature(
                        feature.id,
                        name: _nameCtrl.text,
                        codeAccess: {'repoUrl': _codeRepoCtrl.text},
                        dbAccess: {'url': _dbUrlCtrl.text},
                        baseRequirement: _reqCtrl.text,
                        brdPrompt: _promptCtrl.text,
                      );
                      
                      // Update local state
                      controller.activeFeature.value = updatedFeature;
                      
                      // Also update list if project is selected
                      if (controller.activeProject.value?.id == updatedFeature.projectId) {
                        final index = controller.activeProjectFeatures.indexWhere((f) => f.id == updatedFeature.id);
                        if (index != -1) {
                          controller.activeProjectFeatures[index] = updatedFeature;
                        }
                      }
                      
                      controller.logTerminal("Feature updated successfully.", level: "SUCCESS");
                      
                      // Move to BRD stage after saving
                      controller.setStage(SDLCStageType.stage1Brd);
                      
                    } catch (e) {
                      controller.logTerminal("Failed to update feature: $e", level: "ERROR");
                    } finally {
                      setState(() => _isSaving = false);
                    }
                  },
                  icon: _isSaving ? Icons.hourglass_empty : Icons.save_outlined,
                  label: _isSaving ? 'Saving...' : 'Save & Proceed to BRD',
                  isDark: isDark,
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildInputField(String label, TextEditingController ctrl, bool isDark, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark)),
        prefixIcon: maxLines == 1 ? Icon(icon, color: EnterpriseTheme.getTextMuted(isDark), size: 18) : null,
        filled: true,
        fillColor: EnterpriseTheme.getInputBg(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark)),
        ),
      ),
    );
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
