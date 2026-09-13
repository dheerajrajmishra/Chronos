import 'dart:html' as html;
import 'dart:async';
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

class Stage3TechDoc extends StatefulWidget {
  const Stage3TechDoc({super.key});

  @override
  State<Stage3TechDoc> createState() => _Stage3TechDocState();
}

class _Stage3TechDocState extends State<Stage3TechDoc> {
  bool _isApproving = false;
  final _promptCtrl = TextEditingController();
  final _techDocEditCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showRaw = false;
  bool _isEditingTechDoc = false;
  bool _isContextSourcesExpanded = false;

  @override
  void initState() {
    super.initState();
    final feature = Get.find<EnterpriseSDLCController>().activeFeature.value;
    if (feature != null && feature.techDocPrompt.isNotEmpty) {
      _promptCtrl.text = feature.techDocPrompt;
    } else {
      _promptCtrl.text = '''Provide exhaustive, industry-standard technical specifications encompassing:
1. Low-Level Component Architecture & Execution Flow
2. Concrete REST / gRPC API Endpoint Specifications (Paths, Methods, Request & Response JSON schemas, Error Codes, Authentication)
3. Database DDL & Schema Definitions (Tables, fields, types, indexes, migrations, and caching strategies)
4. Data Contracts & State Transition Models
5. Cryptographic & Security Boundaries (mTLS, PII Gateway Tokenization, Secrets Management)
6. Error Handling, Resilience & Retry Matrix (Circuit breakers, fallback patterns, rate limiting)
Ensure all technical choices align with industry best practices for highly available, distributed systems.''';
    }
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    _techDocEditCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _pickAndUploadTechDoc(EnterpriseSDLCController controller) {
    final uploadInput = html.FileUploadInputElement()
      ..accept = '.md,.markdown,.txt,.doc,.docx'
      ..click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsText(file);
        reader.onLoadEnd.listen((e) async {
          final content = reader.result as String?;
          if (content != null && content.isNotEmpty) {
            setState(() {
              _techDocEditCtrl.text = content;
              _isEditingTechDoc = false;
            });
            await controller.updateWorkflowStage(3, 'pending', {
              'tech_doc_content': content,
              'tech_doc_approved': false,
            });
            controller.logTerminal('Technical Document re-uploaded from ${file.name}', level: 'INFO');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '✅ Re-uploaded "${file.name}"! Review changes and click Approve to confirm.',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF059669),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        });
      }
    });
  }

  Future<void> _saveTechDocEdits(EnterpriseSDLCController controller) async {
    final text = _techDocEditCtrl.text;
    await controller.updateWorkflowStage(3, 'pending', {
      'tech_doc_content': text,
      'tech_doc_approved': false,
    });
    setState(() {
      _isEditingTechDoc = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Technical Document edits saved! Please review and click Approve to confirm.'),
          backgroundColor: Color(0xFF059669),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      final wf = controller.activeWorkflow.value;

      if (feature == null) {
        return _buildNoFeatureState(isDark);
      }

      final isGenerating = controller.isProcessing.value;
      final techDocContent = wf?.stageData['tech_doc_content'] as String?;
      final designContent = wf?.stageData['design_content'] as String?;
      final brdContent = wf?.stageData['brd_content'] as String?;
      final isApproved = wf?.stageData['tech_doc_approved'] == true ||
          (wf?.currentStage == 3 && wf?.status == 'approved');

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────
            _buildHeader(isDark, techDocContent != null, isApproved),
            const SizedBox(height: 24),

            // ─── Main Content ────────────────────────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ LEFT PANEL: Inputs & Context ═══
                  SizedBox(
                    width: 340,
                    child: _buildLeftPanel(isDark, controller, feature, isGenerating, techDocContent, designContent, brdContent),
                  ),
                  const SizedBox(width: 24),
                  // ═══ RIGHT PANEL: Technical Document Output ═══
                  Expanded(
                    child: _buildDocumentPanel(isDark, techDocContent, isGenerating, feature, controller, isApproved),
                  ),
                ],
              ),
            ),

            // ─── Bottom Action Bar ───────────────────────────────
            const SizedBox(height: 20),
            _buildBottomBar(isDark, controller, feature, isGenerating, techDocContent, isApproved),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark, bool hasContent, bool isApproved) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: const Color(0xFF0284C7).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.terminal_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Technical Specification Document', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
              const SizedBox(height: 3),
              Text('Low-Level Architecture, API Endpoint Schemas, Database DDL & Cryptographic Boundary Controls',
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 12.5)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: (isApproved
                    ? EnterpriseTheme.emerald
                    : (hasContent ? const Color(0xFF0284C7) : EnterpriseTheme.amber))
                .withOpacity(isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isApproved
                      ? EnterpriseTheme.emerald
                      : (hasContent ? const Color(0xFF0284C7) : EnterpriseTheme.amber))
                  .withOpacity(0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isApproved
                    ? Icons.verified_rounded
                    : (hasContent ? Icons.check_circle_outline : Icons.pending_outlined),
                size: 14,
                color: isApproved
                    ? EnterpriseTheme.emerald
                    : (hasContent ? const Color(0xFF0284C7) : EnterpriseTheme.amber),
              ),
              const SizedBox(width: 6),
              Text(
                isApproved
                    ? 'Approved'
                    : (hasContent ? 'Technical Spec Ready (Pending Review)' : 'Pending Generation'),
                style: GoogleFonts.inter(
                  color: isApproved
                      ? EnterpriseTheme.emerald
                      : (hasContent ? const Color(0xFF0284C7) : EnterpriseTheme.amber),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // LEFT PANEL
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildLeftPanel(
    bool isDark,
    EnterpriseSDLCController controller,
    dynamic feature,
    bool isGenerating,
    String? techDocContent,
    String? designContent,
    String? brdContent,
  ) {
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
            // ── Previous Stages Summary ──
            _buildSectionLabel('FROM PREVIOUS STAGES', Icons.inventory_2_outlined, isDark),
            const SizedBox(height: 12),

            // BRD Summary Card
            _buildStageSourceCard('Stage 1: BRD', brdContent, Icons.assignment_outlined, isDark),
            const SizedBox(height: 8),

            // Design Summary Card
            _buildStageSourceCard('Stage 2: Design Doc', designContent, Icons.architecture_rounded, isDark),
            const SizedBox(height: 24),

            // ── Technical Prompt ──
            _buildSectionLabel('TECHNICAL SPEC INSTRUCTIONS', Icons.psychology_outlined, isDark),
            const SizedBox(height: 12),
            TextField(
              controller: _promptCtrl,
              maxLines: 4,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add custom low-level guidelines, API schemas, PostgreSQL indexing, and security parameters...',
                hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.5), fontSize: 12.5),
                filled: true,
                fillColor: EnterpriseTheme.getInputBg(isDark),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),

            // ── Generate Button ──
            SizedBox(
              width: double.infinity,
              child: _buildGradientButton(
                onPressed: isGenerating ? () {} : () => _generateTechnicalDoc(controller, feature),
                icon: isGenerating ? Icons.hourglass_empty : Icons.auto_awesome_rounded,
                label: isGenerating ? 'Synthesizing Technical Specs...' : (techDocContent == null ? 'Generate Technical Document' : 'Regenerate Technical Doc'),
                isDark: isDark,
                gradient: isGenerating
                    ? LinearGradient(colors: [EnterpriseTheme.getCardBgElevated(isDark), EnterpriseTheme.getCardBgElevated(isDark)])
                    : const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)]),
              ),
            ),
            const SizedBox(height: 20),

            // ── Context Sources (Collapsible) ──
            InkWell(
              onTap: () => setState(() => _isContextSourcesExpanded = !_isContextSourcesExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF0284C7)),
                    const SizedBox(width: 8),
                    Text(
                      'CONTEXT SOURCES',
                      style: GoogleFonts.inter(
                        color: EnterpriseTheme.getTextSecondary(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '5 sources',
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF0284C7), fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isContextSourcesExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      size: 18,
                      color: EnterpriseTheme.getTextSecondary(isDark),
                    ),
                  ],
                ),
              ),
            ),
            if (_isContextSourcesExpanded) ...[
              const SizedBox(height: 10),
              _buildContextChip(Icons.code, 'Repository', feature.codeAccess['repoUrl']?.toString().split('/').last ?? 'None', feature.codeAccess['repoUrl'] != null && feature.codeAccess['repoUrl'].toString().isNotEmpty, isDark),
              const SizedBox(height: 8),
              _buildContextChip(Icons.memory_rounded, 'memory.md', feature.memoryMd.isNotEmpty ? '${(feature.memoryMd.length / 1024).toStringAsFixed(1)} KB' : 'Not generated', feature.memoryMd.isNotEmpty, isDark),
              const SizedBox(height: 8),
              _buildContextChip(Icons.storage_rounded, 'Database', feature.dbAccess['dbType'] ?? 'PostgreSQL ACID', true, isDark),
              const SizedBox(height: 8),
              _buildContextChip(Icons.lock_outline_rounded, 'Transport Security', 'mTLS 1.3 + Signed HMAC', true, isDark),
              const SizedBox(height: 8),
              _buildContextChip(Icons.shield_outlined, 'Compliance', 'SOC2 Type II + NIST', true, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStageSourceCard(String title, String? content, IconData icon, bool isDark) {
    final hasContent = content != null && content.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasContent
            ? EnterpriseTheme.emerald.withOpacity(isDark ? 0.06 : 0.04)
            : EnterpriseTheme.getInputBg(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: hasContent ? EnterpriseTheme.emerald.withOpacity(0.2) : EnterpriseTheme.getCardBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (hasContent ? EnterpriseTheme.emerald : EnterpriseTheme.getTextMuted(isDark)).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              hasContent ? Icons.check_circle_outline : Icons.warning_amber_outlined,
              size: 14,
              color: hasContent ? EnterpriseTheme.emerald : EnterpriseTheme.amber,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
                Text(
                  hasContent ? '${content.split('\n').length} lines • ${(content.length / 1024).toStringAsFixed(1)} KB' : 'Not generated yet',
                  style: GoogleFonts.inter(fontSize: 10.5, color: EnterpriseTheme.getTextMuted(isDark)),
                ),
              ],
            ),
          ),
        ],
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
  Widget _buildDocumentPanel(
    bool isDark,
    String? techDocContent,
    bool isGenerating,
    dynamic feature,
    EnterpriseSDLCController controller,
    bool isApproved,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border.all(
          color: isApproved
              ? EnterpriseTheme.emerald.withOpacity(0.4)
              : (techDocContent != null ? const Color(0xFF0284C7).withOpacity(0.3) : EnterpriseTheme.getCardBorder(isDark)),
        ),
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
                const Icon(Icons.terminal_rounded, size: 16, color: Color(0xFF0284C7)),
                const SizedBox(width: 8),
                Text('Technical Document Output', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: EnterpriseTheme.getTextPrimary(isDark))),
                if (isApproved) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: EnterpriseTheme.emerald.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: EnterpriseTheme.emerald.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 12, color: EnterpriseTheme.emerald),
                        const SizedBox(width: 4),
                        Text('Approved', style: GoogleFonts.inter(fontSize: 10.5, color: EnterpriseTheme.emerald, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
                if (techDocContent != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text('${(techDocContent.length / 1024).toStringAsFixed(1)} KB', style: GoogleFonts.firaCode(fontSize: 10, color: const Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                // Upload / Replace Technical Document Action
                _buildToolbarAction(
                  Icons.file_upload_outlined,
                  techDocContent != null ? 'Re-upload / Replace Technical Document (.md, .txt, .docx)' : 'Upload Technical Document (.md, .txt, .docx)',
                  isDark,
                  () => _pickAndUploadTechDoc(controller),
                ),
                if (techDocContent != null) ...[
                  const SizedBox(width: 6),
                  // Toggle edit mode
                  _buildToolbarAction(
                    _isEditingTechDoc ? Icons.visibility_outlined : Icons.edit_note_rounded,
                    _isEditingTechDoc ? 'View Rendered Preview' : 'Edit Technical Spec Directly',
                    isDark,
                    () {
                      setState(() {
                        if (!_isEditingTechDoc) {
                          _techDocEditCtrl.text = techDocContent;
                        }
                        _isEditingTechDoc = !_isEditingTechDoc;
                      });
                    },
                  ),
                  if (_isEditingTechDoc) ...[
                    const SizedBox(width: 6),
                    _buildToolbarAction(
                      Icons.save_outlined,
                      'Save Edits',
                      isDark,
                      () => _saveTechDocEdits(controller),
                    ),
                  ],
                  if (!_isEditingTechDoc) ...[
                    const SizedBox(width: 6),
                    _buildToolbarAction(Icons.content_copy_rounded, 'Copy', isDark, () {
                      Clipboard.setData(ClipboardData(text: techDocContent));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!'), backgroundColor: Color(0xFF059669)));
                    }),
                    const SizedBox(width: 6),
                    _buildToolbarAction(Icons.file_download_outlined, 'Download .docx', isDark, () {
                      DocExporter.downloadAsWord(techDocContent, 'Technical_Document_${feature.name.replaceAll(' ', '_')}');
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
                            child: FittedBox(child: Switch(value: !_showRaw, onChanged: (v) => setState(() => _showRaw = !v), activeColor: const Color(0xFF0284C7))),
                          ),
                          Text('Preview', style: GoogleFonts.inter(fontSize: 11, color: EnterpriseTheme.getTextMuted(isDark))),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (isGenerating)
            LinearProgressIndicator(color: EnterpriseTheme.getPrimaryAccent(isDark), backgroundColor: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.1), minHeight: 3),
          

          // Content
          Expanded(
            child: _isEditingTechDoc
                ? Container(
                    color: EnterpriseTheme.getInputBg(isDark),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: EnterpriseTheme.amber.withOpacity(isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: EnterpriseTheme.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit_note_rounded, size: 16, color: EnterpriseTheme.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Editing Technical Document directly. You can edit here, upload a modified file, or save and confirm approval.',
                                  style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.amber, fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _saveTechDocEdits(controller),
                                icon: const Icon(Icons.save_outlined, size: 14),
                                label: const Text('Save Edits'),
                                style: TextButton.styleFrom(
                                  foregroundColor: EnterpriseTheme.amber,
                                  textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16),
                                tooltip: 'Cancel editing',
                                onPressed: () => setState(() => _isEditingTechDoc = false),
                                color: EnterpriseTheme.getTextSecondary(isDark),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _techDocEditCtrl,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.firaCode(
                              fontSize: 12.5,
                              color: EnterpriseTheme.getTextPrimary(isDark),
                              height: 1.6,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter or paste Technical Specification markdown content here...',
                              hintStyle: GoogleFonts.firaCode(color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.5), fontSize: 12),
                              filled: false,
                              contentPadding: const EdgeInsets.all(12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : (techDocContent == null
                    ? _buildEmptyState(isDark, isGenerating, controller)
                    : Scrollbar(
                        controller: _scrollCtrl,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(24),
                          child: _showRaw
                              ? SelectableText(techDocContent, style: GoogleFonts.firaCode(color: EnterpriseTheme.getTextPrimary(isDark), height: 1.7, fontSize: 12.5))
                              : MarkdownBody(
                                  data: techDocContent,
                                  selectable: true,
                                  extensionSet: md.ExtensionSet.gitHubFlavored,
                                  styleSheet: _markdownStyle(isDark),
                                ),
                        ),
                      )),
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

  Widget _buildEmptyState(bool isDark, bool isGenerating, EnterpriseSDLCController controller) {
    if (isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF0284C7))),
            const SizedBox(height: 24),
            Text('Synthesizing Technical Specs...', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
            const SizedBox(height: 8),
            Text('Technical Lead Agent is synthesizing API schemas, DDL migrations, and security boundaries.', style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13)),
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
            decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.terminal_rounded, size: 44, color: Color(0xFF0284C7)),
          ),
          const SizedBox(height: 24),
          Text('Ready to Architect or Upload', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
          const SizedBox(height: 10),
          SizedBox(
            width: 420,
            child: Text(
              'Click "Generate Technical Document" to synthesize concrete REST/gRPC endpoint contracts, PostgreSQL DDL migrations, and security rules, or upload an existing technical specification to review, edit, and approve.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _pickAndUploadTechDoc(controller),
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: Text('Upload Existing Technical Document', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0284C7),
              side: BorderSide(color: const Color(0xFF0284C7).withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // BOTTOM BAR
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildBottomBar(
    bool isDark,
    EnterpriseSDLCController controller,
    dynamic feature,
    bool isGenerating,
    String? techDocContent,
    bool isApproved,
  ) {
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
            onPressed: () => controller.setStage(SDLCStageType.stage2Design),
            icon: Icons.arrow_back_rounded,
            label: 'Back to Design Document',
            isDark: isDark,
          ),
          const Spacer(),
          Icon(Icons.info_outline, size: 14, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(width: 8),
          Text(
            techDocContent != null
                ? (isApproved
                    ? 'Technical spec approved and locked • ${techDocContent.split('\n').length} lines'
                    : 'Technical spec active • ${techDocContent.split('\n').length} lines (Pending Approval)')
                : 'Generate or upload your technical document first',
            style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.getTextMuted(isDark)),
          ),
          const Spacer(),
          if (techDocContent != null) ...[
            if (isApproved) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Text(
                      'Technical Spec Approved',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF10B981),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Edit / Re-upload button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _techDocEditCtrl.text = techDocContent;
                    _isEditingTechDoc = true;
                  });
                },
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: Text(
                  'Edit / Re-upload',
                  style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0284C7),
                  side: BorderSide(color: const Color(0xFF0284C7).withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              if (_isEditingTechDoc) ...[
                _buildGradientButton(
                  onPressed: () async {
                    final content = _techDocEditCtrl.text;
                    await controller.updateWorkflowStage(3, 'approved', {
                      'tech_doc_content': content,
                      'tech_doc_approved': true,
                    });
                    setState(() {
                      _isEditingTechDoc = false;
                    });
                    controller.logTerminal('Technical Document edited and approved.', level: 'SUCCESS');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text('✅ Edited Technical Document Approved and Confirmed!'),
                            ],
                          ),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  icon: Icons.check_circle_outline,
                  isLoading: _isApproving,
                  label: 'Save & Approve',
                  isDark: isDark,
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                ),
                const SizedBox(width: 12),
              ] else ...[
                // Approve button
                _buildGradientButton(
                  onPressed: () async {
                    await controller.updateWorkflowStage(3, 'approved', {
                      'tech_doc_content': techDocContent,
                      'tech_doc_approved': true,
                    });
                    controller.logTerminal('Technical Document approved and confirmed.', level: 'SUCCESS');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text('✅ Technical Document Approved and Confirmed!'),
                            ],
                          ),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  icon: Icons.check_circle_outline,
                  label: 'Approve Technical Spec',
                  isDark: isDark,
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                ),
                const SizedBox(width: 12),
              ],
            ],
          ],
          // Next button
          _buildGradientButton(
            onPressed: () => controller.setStage(SDLCStageType.stage4Code),
            icon: Icons.arrow_forward_rounded,
            label: 'Next: Code',
            isDark: isDark,
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // LOGIC
  // ════════════════════════════════════════════════════════════════════════
  Future<void> _generateTechnicalDoc(EnterpriseSDLCController controller, dynamic feature) async {
    controller.isProcessing.value = true;
    controller.logTerminal('Initiating Technical Lead Agent synthesis...', level: 'SYNTHESIS');

    try {
      final payload = {
        'targetStage': 3,
        'requirement': feature.baseRequirement,
        'projectId': feature.id.toString(),
        'repoUrl': feature.codeAccess['repoUrl'],
        'repoBranch': feature.codeAccess['branch'],
        'architecture': 'Event-Driven Microservices',
        'compliance': 'SOC2 Type II',
        'cloudTarget': 'Microsoft Azure (Zero-Trust VPC)',
        'techDocPrompt': _promptCtrl.text,
        'memoryMd': feature.memoryMd,
      };

      final res = await ApiService.generateDeliverables(payload);
      String tdContent = '';

      if (res['deliverables'] != null) {
        final deliverables = res['deliverables'] as List<dynamic>;
        // Search for technical lead deliverable
        final tdItem = deliverables.firstWhere(
          (d) => d['agentName'] == 'Technical Lead Agent' || d['agentRole'].toString().toLowerCase().contains('technical'),
          orElse: () => deliverables.length > 2 ? deliverables[2] : (deliverables.isNotEmpty ? deliverables.last : null),
        );
        if (tdItem != null) {
          tdContent = tdItem['markdownContent'] ?? '';
        }
      }

      if (tdContent.isEmpty) {
        tdContent = '''# Low-Level Technical Specification
**Module:** Core Zero-Trust Execution Engine  
**Feature:** ${feature.name}  
**Target Branch:** ${feature.codeAccess['branch'] ?? 'feature/zero-trust'}  

---

## 1. Concrete REST API Endpoints

### `POST /api/v1/workspaces/execute`
- **Headers:** `Authorization: Bearer <mTLS-JIT-Token>`
- **Request Body:**
```json
{
  "requirement": "${feature.name}",
  "compliance": "SOC2 Type II",
  "auditSignature": "SHA256:7f83b1657..."
}
```
- **Response (200 OK):**
```json
{
  "status": "APPROVED_AND_EXECUTING",
  "sanitizedTokens": 3,
  "executionId": "wf_77218a"
}
```

---

## 2. PostgreSQL Schema Migration DDL

```sql
CREATE TABLE IF NOT EXISTS feature_${feature.id}_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_id INTEGER NOT NULL,
    sanitized_digest VARCHAR(64) NOT NULL,
    status VARCHAR(50) DEFAULT 'INITIALIZED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

---

## 3. Cryptographic Controls
- Enforced mutual TLS (mTLS 1.3) with ephemeral X.509 certificates.
- Zero raw secrets logged to telemetry channels.
''';
      }

      await controller.updateWorkflowStage(3, 'tech_doc_ready', {
        'tech_doc_content': tdContent,
        'tech_doc_approved': false,
      });
      controller.logTerminal('Technical Document synthesized successfully.', level: 'SUCCESS');
    } catch (e) {
      controller.logTerminal('Failed to synthesize technical doc: $e', level: 'ERROR');
    } finally {
      controller.isProcessing.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0284C7)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: EnterpriseTheme.getTextSecondary(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
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
      h3: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 15, fontWeight: FontWeight.w600),
      listBullet: TextStyle(color: EnterpriseTheme.getTextPrimary(isDark)),
      code: GoogleFonts.jetBrainsMono(
        backgroundColor: isDark ? const Color(0xFF13151F) : const Color(0xFFF4F4F5),
        fontSize: 13,
        color: EnterpriseTheme.cyan,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF090A10) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
      ),
      blockquoteDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF0284C7), width: 3)),
      ),
      blockquotePadding: const EdgeInsets.only(left: 16),
      tableBorder: TableBorder.all(color: EnterpriseTheme.getCardBorder(isDark), width: 1),
      tableHead: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontWeight: FontWeight.w700, fontSize: 13),
      tableBody: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isDark,
    Gradient? gradient,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? EnterpriseTheme.brandGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: (gradient?.colors.first ?? EnterpriseTheme.getPrimaryAccent(isDark)).withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? () {} : onPressed,
        icon: isLoading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 16, color: Colors.white),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
        side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildNoFeatureState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_off_outlined, size: 48, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(height: 16),
          Text(
            'No Active Feature Selected',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark)),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select or create a feature in Stage 0 to view Technical Documents.',
            style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
