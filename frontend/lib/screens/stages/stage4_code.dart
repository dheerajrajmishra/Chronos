import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';
import '../../utils/doc_exporter.dart';
import '../../services/api_service.dart';

class Stage4Code extends StatefulWidget {
  const Stage4Code({super.key});

  @override
  State<Stage4Code> createState() => _Stage4CodeState();
}

class _Stage4CodeState extends State<Stage4Code> {
  bool _isApproving = false;
  final _branchCtrl = TextEditingController(text: 'feature/zero-trust-impl');
  final _promptCtrl = TextEditingController();
  final _editCtrl = TextEditingController();

  bool _showRaw = false;
  bool _isEditing = false;
  bool _isContextSourcesExpanded = false;
  bool _isGeneratingPlan = false;
  bool _isExecutingCode = false;

  // Toggle between viewing plan vs code in the right panel
  // 'plan' or 'code'
  String _activeTab = 'plan';

  @override
  void initState() {
    super.initState();
    final feature = Get.find<EnterpriseSDLCController>().activeFeature.value;
    if (feature != null && feature.codePrompt.isNotEmpty) {
      _promptCtrl.text = feature.codePrompt;
    } else {
      _promptCtrl.text =
          'Generate a detailed implementation plan that adheres strictly to the existing code architecture and repository patterns.\n'
          '1. Do not introduce new architectural patterns, frameworks, or dependencies unless explicitly requested; follow the conventions already established in the codebase.\n'
          '2. Plan out file modifications, creations, and deletions with exact paths and logic conforming to the current project structure.\n'
          '3. Provide a step-by-step breakdown of how the feature will be integrated into the existing endpoints, services, UI components, and state management.\n'
          '4. Focus on backward compatibility and safe integration within the constraints of the current architecture.';
    }
  }

  @override
  void dispose() {
    _branchCtrl.dispose();
    _promptCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  void _pickAndUploadDocument(EnterpriseSDLCController controller, String dataKey) {
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
              _editCtrl.text = content;
              _isEditing = false;
            });
            await controller.updateWorkflowStage(4, 'pending', {
              dataKey: content,
            });
            controller.logTerminal('Document uploaded from ${file.name}', level: 'INFO');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Uploaded "${file.name}" successfully!'),
                  backgroundColor: const Color(0xFF059669),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        });
      }
    });
  }

  Future<void> _saveEdits(EnterpriseSDLCController controller, String dataKey) async {
    final text = _editCtrl.text;
    await controller.updateWorkflowStage(4, 'pending', {
      dataKey: text,
    });
    setState(() {
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Edits saved!'),
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
        return Center(
          child: Text(
            "No Feature Selected",
            style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark)),
          ),
        );
      }

      final implPlanContent = wf?.stageData['impl_plan_content'] as String?;
      final codeContent = wf?.stageData['code_content'] as String?;
      final techDocContent = wf?.stageData['tech_doc_content'] as String?;
      final isApproved = wf?.stageData['code_approved'] == true;

      // Auto-switch active tab based on state
      if (codeContent != null && _activeTab == 'plan' && implPlanContent != null) {
        // Keep user's choice
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────
            _buildHeader(isDark, implPlanContent != null, codeContent != null, isApproved),
            const SizedBox(height: 24),

            // ─── Main Content (2-column) ─────────────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ LEFT PANEL: Inputs & Context ═══
                  SizedBox(
                    width: 340,
                    child: _buildLeftPanel(isDark, controller, feature, implPlanContent, codeContent, techDocContent),
                  ),
                  const SizedBox(width: 24),
                  // ═══ RIGHT PANEL: Document Output ═══
                  Expanded(
                    child: _buildDocumentPanel(isDark, implPlanContent, codeContent, feature, controller, isApproved),
                  ),
                ],
              ),
            ),

            // ─── Bottom Action Bar ───────────────────────────────
            const SizedBox(height: 20),
            _buildBottomBar(isDark, controller, feature, implPlanContent, codeContent, isApproved),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark, bool hasPlan, bool hasCode, bool isApproved) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.code_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Code Implementation', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
              const SizedBox(height: 3),
              Text('Generate implementation plan, then execute code scaffolding & commit to branch',
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 12.5)),
            ],
          ),
        ),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: (isApproved
                    ? EnterpriseTheme.emerald
                    : (hasCode
                        ? const Color(0xFF0EA5E9)
                        : (hasPlan ? const Color(0xFF8B5CF6) : EnterpriseTheme.amber)))
                .withOpacity(isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isApproved
                      ? EnterpriseTheme.emerald
                      : (hasCode
                          ? const Color(0xFF0EA5E9)
                          : (hasPlan ? const Color(0xFF8B5CF6) : EnterpriseTheme.amber)))
                  .withOpacity(0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isApproved
                    ? Icons.verified_rounded
                    : (hasCode
                        ? Icons.check_circle_outline
                        : (hasPlan ? Icons.description_outlined : Icons.pending_outlined)),
                size: 14,
                color: isApproved
                    ? EnterpriseTheme.emerald
                    : (hasCode
                        ? const Color(0xFF0EA5E9)
                        : (hasPlan ? const Color(0xFF8B5CF6) : EnterpriseTheme.amber)),
              ),
              const SizedBox(width: 6),
              Text(
                isApproved
                    ? 'Code Approved'
                    : (hasCode
                        ? 'Code Ready (Pending Review)'
                        : (hasPlan ? 'Plan Ready — Execute Code' : 'Pending Generation')),
                style: GoogleFonts.inter(
                  color: isApproved
                      ? EnterpriseTheme.emerald
                      : (hasCode
                          ? const Color(0xFF0EA5E9)
                          : (hasPlan ? const Color(0xFF8B5CF6) : EnterpriseTheme.amber)),
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
  Widget _buildLeftPanel(bool isDark, EnterpriseSDLCController controller, dynamic feature, String? implPlanContent, String? codeContent, String? techDocContent) {
    final isProcessing = _isGeneratingPlan || _isExecutingCode;

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
            // ── Previous Stage Context ──
            _buildSectionLabel('FROM PREVIOUS STAGE', Icons.assignment_outlined, isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: techDocContent != null
                    ? EnterpriseTheme.emerald.withOpacity(isDark ? 0.06 : 0.04)
                    : EnterpriseTheme.getInputBg(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: techDocContent != null ? EnterpriseTheme.emerald.withOpacity(0.2) : EnterpriseTheme.getCardBorder(isDark)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (techDocContent != null ? EnterpriseTheme.emerald : EnterpriseTheme.getTextMuted(isDark)).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      techDocContent != null ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                      size: 14,
                      color: techDocContent != null ? EnterpriseTheme.emerald : EnterpriseTheme.amber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Technical Document', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
                        Text(
                          techDocContent != null ? '${techDocContent.split('\n').length} lines • ${(techDocContent.length / 1024).toStringAsFixed(1)} KB' : 'Not generated yet',
                          style: GoogleFonts.inter(fontSize: 10.5, color: EnterpriseTheme.getTextMuted(isDark)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Branch Name ──
            _buildSectionLabel('TARGET GIT BRANCH', Icons.fork_right_rounded, isDark),
            const SizedBox(height: 12),
            TextField(
              controller: _branchCtrl,
              style: GoogleFonts.jetBrainsMono(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. feature/my-feature',
                hintStyle: GoogleFonts.jetBrainsMono(color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.5), fontSize: 12),
                filled: true,
                fillColor: EnterpriseTheme.getInputBg(isDark),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: Icon(Icons.fork_right_rounded, size: 16, color: EnterpriseTheme.getTextMuted(isDark)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.purple, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),

            // ── AI Coding Instructions ──
            _buildSectionLabel('AI CODING INSTRUCTIONS', Icons.smart_toy_outlined, isDark),
            const SizedBox(height: 12),
            TextField(
              controller: _promptCtrl,
              maxLines: 5,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Implement strict parameter validation, circuit breaker for DB queries...',
                hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.5), fontSize: 12.5),
                filled: true,
                fillColor: EnterpriseTheme.getInputBg(isDark),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.purple, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),

            // ── Generate Implementation Plan Button ──
            SizedBox(
              width: double.infinity,
              child: _buildGradientButton(
                onPressed: isProcessing ? () {} : () => _generateImplementationPlan(controller, feature),
                icon: _isGeneratingPlan ? Icons.hourglass_empty : Icons.description_outlined,
                label: _isGeneratingPlan
                    ? 'Generating Plan...'
                    : (implPlanContent == null ? 'Generate Implementation Plan' : 'Regenerate Plan'),
                isDark: isDark,
                gradient: _isGeneratingPlan
                    ? LinearGradient(colors: [EnterpriseTheme.getCardBgElevated(isDark), EnterpriseTheme.getCardBgElevated(isDark)])
                    : const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
              ),
            ),

            // ── Execute Code Button (only when plan exists) ──
            if (implPlanContent != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildGradientButton(
                  onPressed: isProcessing ? () {} : () => _executeCode(controller, feature, implPlanContent),
                  icon: _isExecutingCode ? Icons.hourglass_empty : Icons.play_arrow_rounded,
                  label: _isExecutingCode
                      ? 'Executing Code...'
                      : (codeContent == null ? 'Execute — Generate Code' : 'Re-execute Code'),
                  isDark: isDark,
                  gradient: _isExecutingCode
                      ? LinearGradient(colors: [EnterpriseTheme.getCardBgElevated(isDark), EnterpriseTheme.getCardBgElevated(isDark)])
                      : const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ── Context Sources (Collapsible) ──
            InkWell(
              onTap: () => setState(() => _isContextSourcesExpanded = !_isContextSourcesExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: EnterpriseTheme.purple),
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
                        color: EnterpriseTheme.purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '4 sources',
                        style: GoogleFonts.inter(fontSize: 10, color: EnterpriseTheme.purple, fontWeight: FontWeight.w600),
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
              _buildContextChip(Icons.architecture_rounded, 'Architecture', 'Zero-Trust Framework', true, isDark),
              const SizedBox(height: 8),
              _buildContextChip(Icons.shield_outlined, 'Compliance', 'NIST 800-207', true, isDark),
            ],
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
  Widget _buildDocumentPanel(bool isDark, String? implPlanContent, String? codeContent, dynamic feature, EnterpriseSDLCController controller, bool isApproved) {
    // Determine what to show
    final String? activeContent = _activeTab == 'code' && codeContent != null ? codeContent : implPlanContent;
    final String activeDataKey = _activeTab == 'code' ? 'code_content' : 'impl_plan_content';
    final bool isShowingCode = _activeTab == 'code' && codeContent != null;

    return Container(
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border.all(
          color: isApproved
              ? EnterpriseTheme.emerald.withOpacity(0.4)
              : (activeContent != null ? EnterpriseTheme.purple.withOpacity(0.3) : EnterpriseTheme.getCardBorder(isDark)),
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
                // Tab toggle: Plan / Code
                if (implPlanContent != null || codeContent != null) ...[
                  _buildTabButton('Plan', 'plan', Icons.description_outlined, isDark),
                  if (codeContent != null) ...[
                    const SizedBox(width: 6),
                    _buildTabButton('Code', 'code', Icons.code_rounded, isDark),
                  ],
                  const SizedBox(width: 12),
                  Container(width: 1, height: 20, color: EnterpriseTheme.getCardBorder(isDark)),
                  const SizedBox(width: 12),
                ],
                Icon(
                  isShowingCode ? Icons.code_rounded : Icons.description_outlined,
                  size: 16,
                  color: EnterpriseTheme.purple,
                ),
                const SizedBox(width: 8),
                Text(
                  isShowingCode ? 'Generated Code' : 'Implementation Plan',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: EnterpriseTheme.getTextPrimary(isDark)),
                ),
                if (isApproved && isShowingCode) ...[
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
                if (activeContent != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: EnterpriseTheme.purple.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text('${(activeContent.length / 1024).toStringAsFixed(1)} KB', style: GoogleFonts.firaCode(fontSize: 10, color: EnterpriseTheme.purple, fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                // Upload
                _buildToolbarAction(
                  Icons.file_upload_outlined,
                  'Upload Document',
                  isDark,
                  () => _pickAndUploadDocument(controller, activeDataKey),
                ),
                if (activeContent != null) ...[
                  const SizedBox(width: 6),
                  _buildToolbarAction(
                    _isEditing ? Icons.visibility_outlined : Icons.edit_note_rounded,
                    _isEditing ? 'View Preview' : 'Edit Directly',
                    isDark,
                    () {
                      setState(() {
                        if (!_isEditing) {
                          _editCtrl.text = activeContent;
                        }
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                  if (_isEditing) ...[
                    const SizedBox(width: 6),
                    _buildToolbarAction(
                      Icons.save_outlined,
                      'Save Edits',
                      isDark,
                      () => _saveEdits(controller, activeDataKey),
                    ),
                  ],
                  if (!_isEditing) ...[
                    const SizedBox(width: 6),
                    _buildToolbarAction(Icons.content_copy_rounded, 'Copy', isDark, () {
                      Clipboard.setData(ClipboardData(text: activeContent));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!'), backgroundColor: Color(0xFF059669)));
                    }),
                    const SizedBox(width: 6),
                    _buildToolbarAction(Icons.file_download_outlined, 'Download .docx', isDark, () {
                      final prefix = isShowingCode ? 'Code_Implementation' : 'Implementation_Plan';
                      DocExporter.downloadAsWord(activeContent, '${prefix}_${feature.name.replaceAll(' ', '_')}');
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
                            child: FittedBox(child: Switch(value: !_showRaw, onChanged: (v) => setState(() => _showRaw = !v), activeColor: EnterpriseTheme.purple)),
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
          if ((_isGeneratingPlan || _isExecutingCode))
            LinearProgressIndicator(color: EnterpriseTheme.getPrimaryAccent(isDark), backgroundColor: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.1), minHeight: 3),
          

          // Content Area
          Expanded(
            child: _isEditing
                ? _buildEditMode(isDark, controller, activeDataKey)
                : (activeContent == null
                    ? _buildEmptyState(isDark)
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: SingleChildScrollView(
                          child: _showRaw
                              ? SelectableText(
                                  activeContent,
                                  style: GoogleFonts.firaCode(
                                    color: isShowingCode ? const Color(0xFF34D399) : EnterpriseTheme.getTextPrimary(isDark),
                                    height: 1.7,
                                    fontSize: 12.5,
                                  ),
                                )
                              : MarkdownBody(
                                  data: activeContent,
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

  Widget _buildTabButton(String label, String tab, IconData icon, bool isDark) {
    final isActive = _activeTab == tab;
    return InkWell(
      onTap: () => setState(() {
        _activeTab = tab;
        _isEditing = false;
      }),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? EnterpriseTheme.purple.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? EnterpriseTheme.purple.withOpacity(0.4) : EnterpriseTheme.getCardBorder(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? EnterpriseTheme.purple : EnterpriseTheme.getTextMuted(isDark)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? EnterpriseTheme.purple : EnterpriseTheme.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode(bool isDark, EnterpriseSDLCController controller, String dataKey) {
    return Container(
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
                    'Editing document directly. Save your changes when done.',
                    style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.amber, fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _saveEdits(controller, dataKey),
                  icon: const Icon(Icons.save_outlined, size: 14),
                  label: const Text('Save'),
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
                  onPressed: () => setState(() => _isEditing = false),
                  color: EnterpriseTheme.getTextSecondary(isDark),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: _editCtrl,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: GoogleFonts.firaCode(
                fontSize: 12.5,
                color: EnterpriseTheme.getTextPrimary(isDark),
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Enter or paste content here...',
                hintStyle: GoogleFonts.firaCode(color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.5), fontSize: 12),
                filled: false,
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
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

  Widget _buildEmptyState(bool isDark) {
    final isProcessing = _isGeneratingPlan || _isExecutingCode;
    if (isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3, color: EnterpriseTheme.purple)),
            const SizedBox(height: 24),
            Text(
              _isGeneratingPlan ? 'Generating Implementation Plan...' : 'Executing Code Generation...',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark)),
            ),
            const SizedBox(height: 8),
            Text(
              _isGeneratingPlan
                  ? 'AI is synthesizing a detailed implementation plan from your requirements and codebase context.'
                  : 'AI is generating production code based on the implementation plan.',
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13),
              textAlign: TextAlign.center,
            ),
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
            decoration: BoxDecoration(color: EnterpriseTheme.purple.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.code_rounded, size: 44, color: EnterpriseTheme.purple.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text('Ready to Generate', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
          const SizedBox(height: 10),
          SizedBox(
            width: 380,
            child: Text(
              'Click "Generate Implementation Plan" to create a detailed step-by-step plan, then "Execute" to generate the actual code.',
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
  Widget _buildBottomBar(bool isDark, EnterpriseSDLCController controller, dynamic feature, String? implPlanContent, String? codeContent, bool isApproved) {
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
            onPressed: () => controller.setStage(SDLCStageType.stage3TechDoc),
            icon: Icons.arrow_back_rounded,
            label: 'Back to Tech Doc',
            isDark: isDark,
          ),
          const Spacer(),
          // Status
          Icon(Icons.info_outline, size: 14, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(width: 8),
          Text(
            codeContent != null
                ? (isApproved
                    ? 'Code approved • ${codeContent.split('\n').length} lines'
                    : 'Code generated • ${codeContent.split('\n').length} lines (Pending Approval)')
                : (implPlanContent != null
                    ? 'Plan ready • Click Execute to generate code'
                    : 'Generate your implementation plan first'),
            style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.getTextMuted(isDark)),
          ),
          const Spacer(),
          if (codeContent != null) ...[
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
                    Text('Code Approved', style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              // Approve button
              _buildGradientButton(
                onPressed: () async {
                  await controller.updateWorkflowStage(4, 'approved', {'code_approved': true});
                  controller.logTerminal('Code approved and tagged for unit testing.', level: 'SUCCESS');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Code Implementation Approved!'), backgroundColor: Color(0xFF059669)),
                    );
                  }
                },
                icon: Icons.check_circle_outline,
                label: 'Approve Code',
                isDark: isDark,
                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              ),
              const SizedBox(width: 10),
              // Commit to branch button
              _buildGradientButton(
                onPressed: () async {
                  try {
                    final payload = {
        'targetStage': 4,
                      'projectId': feature.projectId.toString(),
                      'repoUrl': feature.codeAccess['repoUrl'],
                      'baseBranch': 'main',
                      'targetBranch': _branchCtrl.text,
                      'markdownContent': codeContent,
                    };
                    final res = await ApiService.applyCodeToBranch(payload);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Code committed to branch: ${res['branch']}'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error committing: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                icon: Icons.merge_type_rounded,
                label: 'Commit to Branch',
                isDark: isDark,
                gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
              ),
              const SizedBox(width: 10),
            ],
          ],
          // Next button
          _buildGradientButton(
            onPressed: () => controller.setStage(SDLCStageType.stage5TestCaseCreation),
            icon: Icons.arrow_forward_rounded,
            label: 'Next: Unit Testing',
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
  Future<void> _generateImplementationPlan(EnterpriseSDLCController controller, dynamic feature) async {
    setState(() => _isGeneratingPlan = true);
    controller.logTerminal("Generating implementation plan for branch: ${_branchCtrl.text}...", level: "CODE");

    try {
      final payload = {
        'requirement': feature.baseRequirement,
        'projectId': feature.id.toString(),
        'repoUrl': feature.codeAccess['repoUrl'],
        'repoBranch': _branchCtrl.text,
        'codePrompt': 'Generate a comprehensive implementation_plan.md document. ${_promptCtrl.text}\n\n'
            'The plan should include:\n'
            '- Detailed file-by-file breakdown of all code to be written\n'
            '- Module dependencies and execution order\n'
            '- API endpoint specifications with request/response contracts\n'
            '- Database schema changes (if any)\n'
            '- Configuration and environment setup steps\n'
            '- Testing strategy outline\n\n'
            'Format as a well-structured Markdown document titled "Implementation Plan".',
        'architecture': 'Zero-Trust Framework',
        'compliance': 'NIST 800-207',
        'memoryMd': feature.memoryMd,
      };

      final res = await ApiService.generateDeliverables(payload);

      String planContent = "# Implementation Plan\n\nFailed to generate plan.";
      if (res['deliverables'] != null) {
        final codeDeliverable = res['deliverables'].firstWhere(
          (d) => d['agentName'] == 'Software Engineer Agent' || (d['tags'] != null && d['tags'].contains('Code Generation')),
          orElse: () => res['deliverables'].isNotEmpty ? res['deliverables'][0] : null,
        );
        if (codeDeliverable != null) {
          planContent = codeDeliverable['markdownContent'];
        }
      }

      await controller.updateWorkflowStage(4, 'plan_ready', {
        'impl_plan_content': planContent,
        'branch_name': _branchCtrl.text,
      });

      setState(() => _activeTab = 'plan');
      controller.logTerminal("Implementation plan generated successfully.", level: "SUCCESS");
    } catch (e) {
      controller.logTerminal("Error generating implementation plan: $e", level: "ERROR");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating plan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isGeneratingPlan = false);
    }
  }

  Future<void> _executeCode(EnterpriseSDLCController controller, dynamic feature, String implPlanContent) async {
    setState(() => _isExecutingCode = true);
    controller.logTerminal("Executing code generation from implementation plan...", level: "CODE");

    try {
      final payload = {
        'requirement': '${feature.baseRequirement}\n\n--- IMPLEMENTATION PLAN ---\n\n$implPlanContent',
        'projectId': feature.id.toString(),
        'repoUrl': feature.codeAccess['repoUrl'],
        'repoBranch': _branchCtrl.text,
        'codePrompt': 'Generate clean, modular, and type-safe implementation code STRICTLY following the provided Implementation Plan above.\n\n'
            'Format each file exactly as:\n'
            '### FILE: <filepath>\n'
            '```<language>\n'
            '<code>\n'
            '```\n\n'
            '${_promptCtrl.text}',
        'architecture': 'Zero-Trust Framework',
        'compliance': 'NIST 800-207',
        'memoryMd': feature.memoryMd,
      };

      final res = await ApiService.generateDeliverables(payload);

      String generatedCode = "// Failed to generate code.";
      if (res['deliverables'] != null) {
        final codeDeliverable = res['deliverables'].firstWhere(
          (d) => d['agentName'] == 'Software Engineer Agent' || (d['tags'] != null && d['tags'].contains('Code Generation')),
          orElse: () => res['deliverables'].isNotEmpty ? res['deliverables'][0] : null,
        );
        if (codeDeliverable != null) {
          generatedCode = codeDeliverable['markdownContent'];
        }
      }

      await controller.updateWorkflowStage(4, 'code_ready', {
        'code_content': generatedCode,
        'branch_name': _branchCtrl.text,
      });

      setState(() => _activeTab = 'code');
      controller.logTerminal("Code generated and ready for review. Branch: ${_branchCtrl.text}", level: "GIT");
    } catch (e) {
      controller.logTerminal("Error executing code generation: $e", level: "ERROR");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating code: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isExecutingCode = false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: EnterpriseTheme.purple),
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
      blockquoteDecoration: BoxDecoration(border: Border(left: BorderSide(color: EnterpriseTheme.purple, width: 3))),
      blockquotePadding: const EdgeInsets.only(left: 16),
      tableBorder: TableBorder.all(color: EnterpriseTheme.getCardBorder(isDark), width: 1),
      tableHead: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontWeight: FontWeight.w600, fontSize: 13),
      tableBody: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13),
    );
  }

  Widget _buildGradientButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isDark, Gradient? gradient, bool isLoading = false}) {
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
