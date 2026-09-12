import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
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
  bool _showRaw = false;

  @override
  void initState() {
    super.initState();
    final feature = Get.find<EnterpriseSDLCController>().activeFeature.value;
    if (feature != null && feature.designPrompt.isNotEmpty) {
      _promptCtrl.text = feature.designPrompt;
    } else {
      _promptCtrl.text = 'Generate a zero-trust Technical Design Document mapping to the BRD requirements.';
    }
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
      final brdContent = wf?.stageData['brd_content'] as String?;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────
            _buildHeader(isDark, designContent != null),
            const SizedBox(height: 24),

            // ─── Main Content ────────────────────────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ LEFT PANEL: Inputs & Context ═══
                  SizedBox(
                    width: 340,
                    child: _buildLeftPanel(isDark, controller, feature, isGenerating, designContent, brdContent),
                  ),
                  const SizedBox(width: 24),
                  // ═══ RIGHT PANEL: Design Document Output ═══
                  Expanded(
                    child: _buildDocumentPanel(isDark, designContent, isGenerating, feature),
                  ),
                ],
              ),
            ),

            // ─── Bottom Action Bar ───────────────────────────────
            const SizedBox(height: 20),
            _buildBottomBar(isDark, controller, feature, isGenerating, designContent),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark, bool hasContent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.architecture_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Technical Design Document', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
              const SizedBox(height: 3),
              Text('AI-powered architecture blueprints, API contracts, and system design specifications',
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 12.5)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: (hasContent ? EnterpriseTheme.emerald : EnterpriseTheme.amber).withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (hasContent ? EnterpriseTheme.emerald : EnterpriseTheme.amber).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(hasContent ? Icons.check_circle_outline : Icons.pending_outlined, size: 14, color: hasContent ? EnterpriseTheme.emerald : EnterpriseTheme.amber),
              const SizedBox(width: 6),
              Text(hasContent ? 'Design Ready' : 'Pending Generation',
                style: GoogleFonts.inter(color: hasContent ? EnterpriseTheme.emerald : EnterpriseTheme.amber, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // LEFT PANEL
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildLeftPanel(bool isDark, EnterpriseSDLCController controller, feature, bool isGenerating, String? designContent, String? brdContent) {
    return Container(
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.04), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── BRD Summary ──
            _buildSectionLabel('FROM PREVIOUS STAGE', Icons.assignment_outlined, isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: brdContent != null
                    ? EnterpriseTheme.emerald.withOpacity(isDark ? 0.06 : 0.04)
                    : EnterpriseTheme.getInputBg(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: brdContent != null ? EnterpriseTheme.emerald.withOpacity(0.2) : EnterpriseTheme.getCardBorder(isDark)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (brdContent != null ? EnterpriseTheme.emerald : EnterpriseTheme.getTextMuted(isDark)).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      brdContent != null ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                      size: 14,
                      color: brdContent != null ? EnterpriseTheme.emerald : EnterpriseTheme.amber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BRD Document', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
                        Text(
                          brdContent != null ? '${brdContent.split('\n').length} lines • ${(brdContent.length / 1024).toStringAsFixed(1)} KB' : 'Not generated yet',
                          style: GoogleFonts.inter(fontSize: 10.5, color: EnterpriseTheme.getTextMuted(isDark)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Architecture Prompt ──
            _buildSectionLabel('DESIGN INSTRUCTIONS', Icons.smart_toy_outlined, isDark),
            const SizedBox(height: 12),
            TextField(
              controller: _promptCtrl,
              maxLines: 4,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Use Redis for caching, design for microservices...',
                hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.5), fontSize: 12.5),
                filled: true,
                fillColor: EnterpriseTheme.getInputBg(isDark),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark), width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),

            // ── Generate Button ──
            SizedBox(
              width: double.infinity,
              child: _buildGradientButton(
                onPressed: isGenerating ? () {} : () => _generateDesign(controller, feature),
                icon: isGenerating ? Icons.hourglass_empty : Icons.auto_awesome_rounded,
                label: isGenerating ? 'Generating...' : (designContent == null ? 'Generate Design' : 'Regenerate Design'),
                isDark: isDark,
                gradient: isGenerating
                    ? LinearGradient(colors: [EnterpriseTheme.getCardBgElevated(isDark), EnterpriseTheme.getCardBgElevated(isDark)])
                    : const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              ),
            ),
            const SizedBox(height: 20),

            // ── Context Sources ──
            _buildSectionLabel('CONTEXT SOURCES', Icons.info_outline_rounded, isDark),
            const SizedBox(height: 12),
            _buildContextChip(Icons.code, 'Repository', feature.codeAccess['repoUrl']?.toString().split('/').last ?? 'None', feature.codeAccess['repoUrl'] != null && feature.codeAccess['repoUrl'].toString().isNotEmpty, isDark),
            const SizedBox(height: 8),
            _buildContextChip(Icons.memory_rounded, 'memory.md', feature.memoryMd.isNotEmpty ? '${(feature.memoryMd.length / 1024).toStringAsFixed(1)} KB' : 'Not generated', feature.memoryMd.isNotEmpty, isDark),
            const SizedBox(height: 8),
            _buildContextChip(Icons.architecture_rounded, 'Architecture', 'Event-Driven Microservices', true, isDark),
            const SizedBox(height: 8),
            _buildContextChip(Icons.shield_outlined, 'Compliance', 'SOC2 Type II', true, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildContextChip(IconData icon, String label, String value, bool isActive, bool isDark) {
    final color = isActive ? EnterpriseTheme.emerald : EnterpriseTheme.getTextMuted(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: EnterpriseTheme.getTextSecondary(isDark), fontWeight: FontWeight.w500)),
          const Spacer(),
          Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // DOCUMENT PANEL (RIGHT)
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildDocumentPanel(bool isDark, String? designContent, bool isGenerating, feature) {
    return Container(
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border.all(color: designContent != null ? EnterpriseTheme.indigo.withOpacity(0.3) : EnterpriseTheme.getCardBorder(isDark)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.04), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: EnterpriseTheme.getSubtleBg(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
            ),
            child: Row(
              children: [
                Icon(Icons.architecture_rounded, size: 16, color: EnterpriseTheme.indigo),
                const SizedBox(width: 8),
                Text('Design Output', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: EnterpriseTheme.getTextPrimary(isDark))),
                if (designContent != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: EnterpriseTheme.indigo.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text('${(designContent.length / 1024).toStringAsFixed(1)} KB', style: GoogleFonts.firaCode(fontSize: 10, color: EnterpriseTheme.indigo, fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                if (designContent != null) ...[
                  _buildToolbarAction(Icons.content_copy_rounded, 'Copy', isDark, () {
                    Clipboard.setData(ClipboardData(text: designContent));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!'), backgroundColor: Color(0xFF059669)));
                  }),
                  const SizedBox(width: 6),
                  _buildToolbarAction(Icons.file_download_outlined, 'Download .docx', isDark, () {
                    DocExporter.downloadAsWord(designContent, 'Design_Document_${feature.name.replaceAll(' ', '_')}');
                  }),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: EnterpriseTheme.getInputBg(isDark), borderRadius: BorderRadius.circular(6), border: Border.all(color: EnterpriseTheme.getCardBorder(isDark))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Raw', style: GoogleFonts.inter(fontSize: 11, color: EnterpriseTheme.getTextMuted(isDark))),
                        SizedBox(
                          width: 36, height: 20,
                          child: FittedBox(child: Switch(value: !_showRaw, onChanged: (v) => setState(() => _showRaw = !v), activeColor: EnterpriseTheme.indigo)),
                        ),
                        Text('Preview', style: GoogleFonts.inter(fontSize: 11, color: EnterpriseTheme.getTextMuted(isDark))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: designContent == null
                ? _buildEmptyState(isDark, isGenerating)
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: _showRaw
                          ? SelectableText(designContent, style: GoogleFonts.firaCode(color: EnterpriseTheme.getTextPrimary(isDark), height: 1.7, fontSize: 12.5))
                          : MarkdownBody(
                              data: designContent,
                              selectable: true,
                              extensionSet: md.ExtensionSet.gitHubFlavored,
                              styleSheet: _markdownStyle(isDark),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarAction(IconData icon, String tooltip, bool isDark, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: EnterpriseTheme.getInputBg(isDark), borderRadius: BorderRadius.circular(6), border: Border.all(color: EnterpriseTheme.getCardBorder(isDark))),
          child: Icon(icon, size: 14, color: EnterpriseTheme.getTextSecondary(isDark)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isGenerating) {
    if (isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3, color: EnterpriseTheme.indigo)),
            const SizedBox(height: 24),
            Text('Generating Design...', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
            const SizedBox(height: 8),
            Text('AI architects are synthesizing system blueprints and API contracts.', style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: EnterpriseTheme.indigo.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.architecture_outlined, size: 44, color: EnterpriseTheme.indigo.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text('Ready to Architect', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
          const SizedBox(height: 10),
          SizedBox(
            width: 380,
            child: Text(
              'Click "Generate Design" to synthesize a comprehensive Technical Design Document including C4 architecture diagrams, API contracts, data models, and infrastructure specifications.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // BOTTOM BAR
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildBottomBar(bool isDark, EnterpriseSDLCController controller, feature, bool isGenerating, String? designContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.12 : 0.04), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Back button
          _buildNavButton(
            onPressed: () => controller.setStage(SDLCStageType.stage1Brd),
            icon: Icons.arrow_back_rounded,
            label: 'Back to BRD',
            isDark: isDark,
          ),
          const Spacer(),
          Icon(Icons.info_outline, size: 14, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(width: 8),
          Text(designContent != null ? 'Design generated • ${designContent.split('\n').length} lines' : 'Generate your technical design',
            style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.getTextMuted(isDark))),
          const Spacer(),
          if (designContent != null) ...[
            // Approve button
            _buildGradientButton(
              onPressed: () {
                controller.updateWorkflowStage(2, 'approved', {});
                controller.logTerminal('Design approved.', level: 'SUCCESS');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Design Approved!'), backgroundColor: Color(0xFF059669)));
              },
              icon: Icons.check_circle_outline,
              label: 'Approve',
              isDark: isDark,
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
            ),
            const SizedBox(width: 12),
          ],
          // Next button
          _buildGradientButton(
            onPressed: () => controller.setStage(SDLCStageType.stage3TechDoc),
            icon: Icons.arrow_forward_rounded,
            label: 'Next: Technical Document',
            isDark: isDark,
            gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ════════════════════════════════════════════════════════════════════════
  Future<void> _generateDesign(EnterpriseSDLCController controller, feature) async {
    controller.isProcessing.value = true;
    try {
      final payload = {
        'requirement': feature.baseRequirement,
        'projectId': feature.id.toString(),
        'repoUrl': feature.codeAccess['repoUrl'],
        'repoBranch': feature.codeAccess['branch'],
        'architecture': 'Event-Driven Microservices',
        'compliance': 'SOC2 Type II',
        'designPrompt': _promptCtrl.text,
        'memoryMd': feature.memoryMd,
      };
      final res = await ApiService.generateDeliverables(payload);
      
      String ddContent = "Failed to generate design.";
      if (res['deliverables'] != null && res['deliverables'].length > 1) {
        ddContent = res['deliverables'][1]['markdownContent'];
      } else if (res['deliverables'] != null && res['deliverables'].length > 0) {
        ddContent = res['deliverables'][0]['markdownContent'];
      }

      await controller.updateWorkflowStage(2, 'designing', {'design_content': ddContent});
    } catch (e) {
      controller.logTerminal("Design synthesis failed: $e", level: "ERROR");
      await controller.updateWorkflowStage(2, 'error', {'design_content': 'Error generating Design: $e'});
    } finally {
      controller.isProcessing.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: EnterpriseTheme.indigo),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: EnterpriseTheme.getCardBorder(isDark), height: 1)),
      ],
    );
  }

  MarkdownStyleSheet _markdownStyle(bool isDark) {
    return MarkdownStyleSheet(
      p: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14, height: 1.7),
      h1: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 22, fontWeight: FontWeight.bold),
      h2: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 18, fontWeight: FontWeight.w600),
      h3: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 16, fontWeight: FontWeight.w600),
      listBullet: TextStyle(color: EnterpriseTheme.getTextPrimary(isDark)),
      code: GoogleFonts.firaCode(backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.grey[200], fontSize: 13, color: EnterpriseTheme.cyan),
      codeblockDecoration: BoxDecoration(color: isDark ? const Color(0xFF0D0D14) : Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: EnterpriseTheme.getCardBorder(isDark))),
      blockquoteDecoration: BoxDecoration(border: Border(left: BorderSide(color: EnterpriseTheme.indigo, width: 3))),
      blockquotePadding: const EdgeInsets.only(left: 16),
      tableBorder: TableBorder.all(color: EnterpriseTheme.getCardBorder(isDark), width: 1),
      tableHead: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontWeight: FontWeight.w600, fontSize: 13),
      tableBody: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13),
    );
  }

  Widget _buildGradientButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isDark, Gradient? gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? EnterpriseTheme.brandGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: (gradient?.colors.first ?? EnterpriseTheme.getPrimaryAccent(isDark)).withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  Widget _buildNavButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isDark}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
        side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
