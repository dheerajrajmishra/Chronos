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

class Stage1Brd extends StatefulWidget {
  const Stage1Brd({super.key});

  @override
  State<Stage1Brd> createState() => _Stage1BrdState();
}

class _Stage1BrdState extends State<Stage1Brd> {
  final _reqCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();
  bool _isEditingReq = false;
  bool _showRaw = false;

  @override
  void initState() {
    super.initState();
    final feature = Get.find<EnterpriseSDLCController>().activeFeature.value;
    if (feature != null) {
      _reqCtrl.text = feature.baseRequirement;
      _promptCtrl.text = feature.brdPrompt.isNotEmpty
          ? feature.brdPrompt
          : 'Generate an executive-grade Business Requirements Document (BRD) strictly following Zero-Trust principles (NIST 800-207), user stories with Given-When-Then Gherkin acceptance criteria, and compliance mapping.';
    }
  }

  @override
  void dispose() {
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
      final wf = controller.activeWorkflow.value;
      
      if (feature == null) return const Center(child: Text("No Feature Selected"));
      
      final isGenerating = controller.isProcessing.value;
      final brdText = wf?.stageData['brd_content'] as String?;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────
            _buildHeader(isDark, brdText != null),
            const SizedBox(height: 24),

            // ─── Main Content ────────────────────────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ LEFT PANEL: Inputs & Controls ═══
                  SizedBox(
                    width: 340,
                    child: _buildLeftPanel(isDark, controller, feature, isGenerating, brdText),
                  ),
                  const SizedBox(width: 24),
                  // ═══ RIGHT PANEL: BRD Document Output ═══
                  Expanded(
                    child: _buildDocumentPanel(isDark, brdText, isGenerating, feature),
                  ),
                ],
              ),
            ),

            // ─── Bottom Action Bar ───────────────────────────────
            const SizedBox(height: 20),
            _buildBottomBar(isDark, controller, feature, isGenerating, brdText),
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
            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF6366F1)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Business Requirements Document', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
              const SizedBox(height: 3),
              Text('AI-powered requirements analysis, user story extraction, and compliance mapping',
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
              Text(hasContent ? 'BRD Generated' : 'Pending Generation',
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
  Widget _buildLeftPanel(bool isDark, EnterpriseSDLCController controller, feature, bool isGenerating, String? brdText) {
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
            // ── Requirement Section ──
            _buildSectionLabel('BASE REQUIREMENT', Icons.format_quote_rounded, isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getInputBg(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditingReq)
                    TextField(
                      controller: _reqCtrl,
                      maxLines: 4,
                      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13.5, height: 1.5),
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                    )
                  else
                    Text(_reqCtrl.text, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13.5, height: 1.6)),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => setState(() => _isEditingReq = !_isEditingReq),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_isEditingReq ? Icons.check : Icons.edit_outlined, size: 12, color: EnterpriseTheme.getPrimaryAccent(isDark)),
                            const SizedBox(width: 4),
                            Text(_isEditingReq ? 'Done' : 'Edit', style: GoogleFonts.inter(fontSize: 11, color: EnterpriseTheme.getPrimaryAccent(isDark), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Custom Prompt ──
            _buildSectionLabel('AI INSTRUCTIONS', Icons.smart_toy_outlined, isDark),
            const SizedBox(height: 12),
            TextField(
              controller: _promptCtrl,
              maxLines: 3,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Focus on NIST 800-207, ignore mobile...',
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
                onPressed: isGenerating ? () {} : () => _generateBrd(controller, feature),
                icon: isGenerating ? Icons.hourglass_empty : Icons.auto_awesome_rounded,
                label: isGenerating ? 'Generating...' : (brdText == null ? 'Generate BRD' : 'Regenerate BRD'),
                isDark: isDark,
                gradient: isGenerating
                    ? LinearGradient(colors: [EnterpriseTheme.getCardBgElevated(isDark), EnterpriseTheme.getCardBgElevated(isDark)])
                    : const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
              ),
            ),
            const SizedBox(height: 20),

            // ── Context Info ──
            _buildSectionLabel('CONTEXT SOURCES', Icons.info_outline_rounded, isDark),
            const SizedBox(height: 12),
            _buildContextChip(Icons.code, 'Repository', feature.codeAccess['repoUrl']?.toString().split('/').last ?? 'None', feature.codeAccess['repoUrl'] != null && feature.codeAccess['repoUrl'].toString().isNotEmpty, isDark),
            const SizedBox(height: 8),
            _buildContextChip(Icons.memory_rounded, 'memory.md', feature.memoryMd.isNotEmpty ? '${(feature.memoryMd.length / 1024).toStringAsFixed(1)} KB' : 'Not generated', feature.memoryMd.isNotEmpty, isDark),
            const SizedBox(height: 8),
            _buildContextChip(Icons.shield_outlined, 'Compliance', 'NIST 800-207', true, isDark),
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
  Widget _buildDocumentPanel(bool isDark, String? brdText, bool isGenerating, feature) {
    return Container(
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border.all(color: brdText != null ? EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.3) : EnterpriseTheme.getCardBorder(isDark)),
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
                Icon(Icons.description_outlined, size: 16, color: EnterpriseTheme.getPrimaryAccent(isDark)),
                const SizedBox(width: 8),
                Text('BRD Output', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: EnterpriseTheme.getTextPrimary(isDark))),
                if (brdText != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: EnterpriseTheme.emerald.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text('${(brdText.length / 1024).toStringAsFixed(1)} KB', style: GoogleFonts.firaCode(fontSize: 10, color: EnterpriseTheme.emerald, fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                if (brdText != null) ...[
                  _buildToolbarAction(Icons.content_copy_rounded, 'Copy', isDark, () {
                    Clipboard.setData(ClipboardData(text: brdText));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!'), backgroundColor: Color(0xFF059669)));
                  }),
                  const SizedBox(width: 6),
                  _buildToolbarAction(Icons.file_download_outlined, 'Download .docx', isDark, () {
                    DocExporter.downloadAsWord(brdText, 'BRD_Document_${feature.name.replaceAll(' ', '_')}');
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
                          child: FittedBox(
                            child: Switch(value: !_showRaw, onChanged: (v) => setState(() => _showRaw = !v), activeColor: EnterpriseTheme.getPrimaryAccent(isDark)),
                          ),
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
            child: brdText == null
                ? _buildEmptyState(isDark, isGenerating)
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: _showRaw
                          ? SelectableText(brdText, style: GoogleFonts.firaCode(color: EnterpriseTheme.getTextPrimary(isDark), height: 1.7, fontSize: 12.5))
                          : MarkdownBody(
                              data: brdText,
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
            SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3, color: EnterpriseTheme.getPrimaryAccent(isDark))),
            const SizedBox(height: 24),
            Text('Generating BRD...', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
            const SizedBox(height: 8),
            Text('AI agents are analyzing your codebase and requirements.', style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
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
            decoration: BoxDecoration(color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.description_outlined, size: 44, color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text('Ready to Generate', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
          const SizedBox(height: 10),
          SizedBox(
            width: 360,
            child: Text(
              'Click "Generate BRD" to scan your codebase and synthesize a comprehensive Business Requirements Document with user stories, acceptance criteria, and compliance mapping.',
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
  Widget _buildBottomBar(bool isDark, EnterpriseSDLCController controller, feature, bool isGenerating, String? brdText) {
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
            onPressed: () => controller.setStage(SDLCStageType.stage0Setup),
            icon: Icons.arrow_back_rounded,
            label: 'Back to Setup',
            isDark: isDark,
          ),
          const Spacer(),
          Icon(Icons.info_outline, size: 14, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(width: 8),
          Text(brdText != null ? 'BRD generated • ${brdText.split('\n').length} lines' : 'Generate your BRD first',
            style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.getTextMuted(isDark))),
          const Spacer(),
          if (brdText != null) ...[
            // Approve button
            _buildGradientButton(
              onPressed: () {
                controller.updateWorkflowStage(1, 'approved', {});
                controller.logTerminal('BRD approved.', level: 'SUCCESS');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ BRD Approved!'), backgroundColor: Color(0xFF059669)));
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
            onPressed: () => controller.setStage(SDLCStageType.stage2Design),
            icon: Icons.arrow_forward_rounded,
            label: 'Next: Design',
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
  Future<void> _generateBrd(EnterpriseSDLCController controller, feature) async {
    controller.isProcessing.value = true;
    try {
      final payload = {
        'requirement': _reqCtrl.text,
        'projectId': feature.id.toString(),
        'repoUrl': feature.codeAccess['repoUrl'],
        'repoBranch': feature.codeAccess['branch'],
        'brdPrompt': _promptCtrl.text,
        'architecture': 'Zero-Trust Framework',
        'compliance': 'NIST 800-207',
        'memoryMd': feature.memoryMd,
      };
      final res = await ApiService.generateDeliverables(payload);
      
      String brdContent = "Failed to generate.";
      if (res['deliverables'] != null && res['deliverables'].length > 0) {
        brdContent = res['deliverables'][0]['markdownContent'];
      }

      await controller.updateWorkflowStage(1, 'pending', {'brd_content': brdContent});
    } catch (e) {
      controller.logTerminal("Synthesis failed: $e", level: "ERROR");
      await controller.updateWorkflowStage(1, 'error', {'brd_content': 'Error generating BRD: $e'});
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
        Icon(icon, size: 14, color: EnterpriseTheme.getPrimaryAccent(isDark)),
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
      blockquoteDecoration: BoxDecoration(border: Border(left: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark), width: 3))),
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
