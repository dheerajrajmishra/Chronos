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

class Stage1Brd extends StatefulWidget {
  const Stage1Brd({super.key});

  @override
  State<Stage1Brd> createState() => _Stage1BrdState();
}

class _Stage1BrdState extends State<Stage1Brd> {
  bool _isApproving = false;
  final _reqCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();
  final _brdEditCtrl = TextEditingController();
  bool _showRaw = false;
  bool _isEditingBrd = false;

  // Document upload state
  String? _uploadedDocName;

  // Voice recording state
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  html.SpeechRecognition? _speechRecognition;

  // Collapsible Context Sources (collapsed by default)
  bool _isContextSourcesExpanded = false;

  @override
  void initState() {
    super.initState();
    final feature = Get.find<EnterpriseSDLCController>().activeFeature.value;
    if (feature != null) {
      _reqCtrl.text = feature.baseRequirement;
      // AI instruction is by default blank! If the user previously saved custom instructions, preserve them.
      _promptCtrl.text = (feature.brdPrompt.isNotEmpty && !feature.brdPrompt.contains('Focus strictly on the FUNCTIONAL requirements'))
          ? feature.brdPrompt
          : 'Generate a comprehensive, industry-standard Business Requirements Document (BRD).\n'
            'Ensure the document includes:\n'
            '1. Executive Summary and Project Goals\n'
            '2. In-Scope and Out-of-Scope Definitions\n'
            '3. Detailed Functional Requirements (User Stories & Acceptance Criteria)\n'
            '4. Non-Functional Requirements (Performance, Security, Scalability, Compliance)\n'
            '5. External Dependencies and Assumptions\n'
            'Use standard Markdown headers and lists for maximum readability.';
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    try {
      _speechRecognition?.stop();
    } catch (_) {}
    _reqCtrl.dispose();
    _promptCtrl.dispose();
    _brdEditCtrl.dispose();
    super.dispose();
  }

  String get _formattedRecordingTime {
    final mins = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_recordingSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _pickDocument() {
    final uploadInput = html.FileUploadInputElement()
      ..accept = '.txt,.md,.doc,.docx,.pdf,.json,.csv,.yaml,.yml'
      ..click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsText(file);
        reader.onLoadEnd.listen((e) {
          final content = reader.result as String?;
          if (content != null && content.isNotEmpty) {
            setState(() {
              _uploadedDocName = file.name;
              if (_reqCtrl.text.trim().isEmpty) {
                _reqCtrl.text = content;
              } else {
                _reqCtrl.text = '${_reqCtrl.text.trim()}\n\n--- IMPORTED FROM ${file.name} ---\n$content';
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Document imported: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)')),
                  ],
                ),
                backgroundColor: const Color(0xFF059669),
              ),
            );
          }
        });
      }
    });
  }

  void _toggleVoiceRecording() {
    if (_isRecording) {
      _stopVoiceRecording();
    } else {
      _startVoiceRecording();
    }
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });

    try {
      if (html.SpeechRecognition.supported) {
        _speechRecognition = html.SpeechRecognition()
          ..continuous = true
          ..interimResults = true
          ..lang = 'en-US';

        _speechRecognition?.onResult.listen((event) {
          final results = event.results;
          if (results != null && results.isNotEmpty) {
            final transcript = results.last.item(0)?.transcript;
            if (transcript != null && transcript.trim().isNotEmpty) {
              setState(() {
                if (_reqCtrl.text.isEmpty) {
                  _reqCtrl.text = transcript.trim();
                } else if (!_reqCtrl.text.endsWith(transcript.trim())) {
                  _reqCtrl.text = '${_reqCtrl.text.trim()} ${transcript.trim()}';
                }
              });
            }
          }
        });

        _speechRecognition?.onError.listen((e) {
          // Fallback gracefully without breaking UI
        });

        _speechRecognition?.start();
      }
    } catch (_) {
      // SpeechRecognition not supported or permission denied
    }
  }

  void _stopVoiceRecording() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    try {
      _speechRecognition?.stop();
    } catch (_) {}
    setState(() {
      _isRecording = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.mic_none_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Voice recording captured to requirement.'),
          ],
        ),
        backgroundColor: Color(0xFF2563EB),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pickAndUploadBrd(EnterpriseSDLCController controller) {
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
              _brdEditCtrl.text = content;
              _isEditingBrd = false;
            });
            setState(() => _isApproving = true);
                    await controller.updateWorkflowStage(1, 'pending', {'brd_content': content});
                    setState(() => _isApproving = false);
            controller.logTerminal('BRD document re-uploaded from ${file.name}', level: 'INFO');
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

  Future<void> _saveBrdEdits(EnterpriseSDLCController controller) async {
    final text = _brdEditCtrl.text;
    setState(() => _isApproving = true);
                    await controller.updateWorkflowStage(1, 'pending', {'brd_content': text});
                    setState(() => _isApproving = false);
    setState(() {
      _isEditingBrd = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ BRD edits saved! Please review and click Approve to confirm.'),
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
      
      if (feature == null) return const Center(child: Text("No Feature Selected"));
      
      final isGenerating = controller.isProcessing.value;
      final brdText = wf?.stageData['brd_content'] as String?;
      final isApproved = wf?.status == 'approved';
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────
            _buildHeader(isDark, brdText != null, isApproved),
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
                    child: _buildDocumentPanel(isDark, brdText, isGenerating, feature, controller, isApproved),
                  ),
                ],
              ),
            ),

            // ─── Bottom Action Bar ───────────────────────────────
            const SizedBox(height: 20),
            _buildBottomBar(isDark, controller, feature, isGenerating, brdText, isApproved),
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
            color: (isApproved
                    ? EnterpriseTheme.emerald
                    : (hasContent ? const Color(0xFF3B82F6) : EnterpriseTheme.amber))
                .withOpacity(isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isApproved
                      ? EnterpriseTheme.emerald
                      : (hasContent ? const Color(0xFF3B82F6) : EnterpriseTheme.amber))
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
                    : (hasContent ? const Color(0xFF3B82F6) : EnterpriseTheme.amber),
              ),
              const SizedBox(width: 6),
              Text(
                isApproved
                    ? 'Approved'
                    : (hasContent ? 'Generated (Pending Review)' : 'Pending Generation'),
                style: GoogleFonts.inter(
                  color: isApproved
                      ? EnterpriseTheme.emerald
                      : (hasContent ? const Color(0xFF3B82F6) : EnterpriseTheme.amber),
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
            _buildSectionLabel('FEATURE REQUIREMENT', Icons.format_quote_rounded, isDark),
            const SizedBox(height: 10),

            // Action toolbar: Upload Document & Record Voice
            Row(
              children: [
                // Upload Document Button
                InkWell(
                  onTap: _pickDocument,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file_rounded, size: 14, color: EnterpriseTheme.getPrimaryAccent(isDark)),
                        const SizedBox(width: 5),
                        Text(
                          'Upload Document',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: EnterpriseTheme.getPrimaryAccent(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Record Voice Button
                InkWell(
                  onTap: _toggleVoiceRecording,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? Colors.redAccent.withOpacity(0.15)
                          : EnterpriseTheme.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isRecording
                            ? Colors.redAccent
                            : EnterpriseTheme.purple.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                          size: 14,
                          color: _isRecording ? Colors.redAccent : EnterpriseTheme.purple,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isRecording ? 'Recording ($_formattedRecordingTime)' : 'Record Voice',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isRecording ? Colors.redAccent : EnterpriseTheme.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_uploadedDocName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file_rounded, size: 12, color: Color(0xFF059669)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _uploadedDocName!,
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF059669), fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => setState(() => _uploadedDocName = null),
                      child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            TextField(
              controller: _reqCtrl,
              maxLines: 4,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13.5, height: 1.5),
              decoration: InputDecoration(
                hintText: 'Enter feature requirements in plain English, upload a document, or record your voice...',
                hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.5), fontSize: 12.5),
                filled: true,
                fillColor: EnterpriseTheme.getInputBg(isDark),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark), width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),

            // ── AI Instructions ──
            _buildSectionLabel('AI INSTRUCTIONS', Icons.smart_toy_outlined, isDark),
            const SizedBox(height: 10),
            TextField(
              controller: _promptCtrl,
              maxLines: 3,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Optional instructions to append to the BRD prompt (e.g. Focus on NIST 800-207, ignore mobile views, add audit trails)...',
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
                isLoading: isGenerating,
                label: isGenerating ? 'Generating...' : (brdText == null ? 'Generate BRD' : 'Regenerate BRD'),
                isDark: isDark,
                gradient: isGenerating
                    ? LinearGradient(colors: [EnterpriseTheme.getCardBgElevated(isDark), EnterpriseTheme.getCardBgElevated(isDark)])
                    : const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
              ),
            ),
            const SizedBox(height: 20),

            // ── Context Info (Collapsible, collapsed by default) ──
            InkWell(
              onTap: () => setState(() => _isContextSourcesExpanded = !_isContextSourcesExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: EnterpriseTheme.getPrimaryAccent(isDark)),
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
                        color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '3 sources',
                        style: GoogleFonts.inter(fontSize: 10, color: EnterpriseTheme.getPrimaryAccent(isDark), fontWeight: FontWeight.w600),
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
              _buildContextChip(
                Icons.code,
                'Repository',
                feature.codeAccess['repoUrl']?.toString().split('/').last ?? 'None',
                feature.codeAccess['repoUrl'] != null && feature.codeAccess['repoUrl'].toString().isNotEmpty,
                isDark,
              ),
              const SizedBox(height: 8),
              _buildContextChip(
                Icons.memory_rounded,
                'memory.md',
                feature.memoryMd.isNotEmpty ? '${(feature.memoryMd.length / 1024).toStringAsFixed(1)} KB' : 'Not generated',
                feature.memoryMd.isNotEmpty,
                isDark,
              ),
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
  Widget _buildDocumentPanel(
    bool isDark,
    String? brdText,
    bool isGenerating,
    feature,
    EnterpriseSDLCController controller,
    bool isApproved,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border.all(
          color: isApproved
              ? EnterpriseTheme.emerald.withOpacity(0.4)
              : (brdText != null
                  ? EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.3)
                  : EnterpriseTheme.getCardBorder(isDark)),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
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
                if (brdText != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: EnterpriseTheme.emerald.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text('${(brdText.length / 1024).toStringAsFixed(1)} KB', style: GoogleFonts.firaCode(fontSize: 10, color: EnterpriseTheme.emerald, fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                // Upload / Replace BRD Action
                _buildToolbarAction(
                  Icons.file_upload_outlined,
                  brdText != null ? 'Re-upload / Replace BRD (.md, .txt, .docx)' : 'Upload BRD Document (.md, .txt, .docx)',
                  isDark,
                  () => _pickAndUploadBrd(controller),
                ),
                if (brdText != null) ...[
                  const SizedBox(width: 6),
                  // Toggle edit mode
                  _buildToolbarAction(
                    _isEditingBrd ? Icons.visibility_outlined : Icons.edit_note_rounded,
                    _isEditingBrd ? 'View Rendered Preview' : 'Edit BRD Directly',
                    isDark,
                    () {
                      setState(() {
                        if (!_isEditingBrd) {
                          _brdEditCtrl.text = brdText;
                        }
                        _isEditingBrd = !_isEditingBrd;
                      });
                    },
                  ),
                  if (_isEditingBrd) ...[
                    const SizedBox(width: 6),
                    _buildToolbarAction(
                      Icons.save_outlined,
                      'Save Edits',
                      isDark,
                      () => _saveBrdEdits(controller),
                    ),
                  ],
                  if (!_isEditingBrd) ...[
                    const SizedBox(width: 6),
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
              ],
            ),
          ),
          if (isGenerating)
            LinearProgressIndicator(color: EnterpriseTheme.getPrimaryAccent(isDark), backgroundColor: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.1), minHeight: 3),
          

          // Content
          Expanded(
            child: _isEditingBrd
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
                                  'Editing BRD directly. You can edit here, upload a modified file, or save and confirm approval.',
                                  style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.amber, fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _saveBrdEdits(controller),
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
                                onPressed: () => setState(() => _isEditingBrd = false),
                                color: EnterpriseTheme.getTextSecondary(isDark),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _brdEditCtrl,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.firaCode(
                              fontSize: 12.5,
                              color: EnterpriseTheme.getTextPrimary(isDark),
                              height: 1.6,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter or paste BRD markdown content here...',
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
                : (brdText == null
                    ? _buildEmptyState(isDark, isGenerating, controller)
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
          Text('Ready to Generate or Upload', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
          const SizedBox(height: 10),
          SizedBox(
            width: 380,
            child: Text(
              'Click "Generate BRD" to scan your codebase and synthesize a comprehensive BRD, or upload an existing BRD document to review, edit, and approve.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _pickAndUploadBrd(controller),
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: Text('Upload Existing BRD Document', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: EnterpriseTheme.getPrimaryAccent(isDark),
              side: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.4)),
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
    feature,
    bool isGenerating,
    String? brdText,
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
            onPressed: () => controller.setStage(SDLCStageType.stage0Setup),
            icon: Icons.arrow_back_rounded,
            label: 'Back to Setup',
            isDark: isDark,
          ),
          const Spacer(),
          Icon(Icons.info_outline, size: 14, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(width: 8),
          Text(
            brdText != null
                ? (isApproved
                    ? 'BRD approved and locked • ${brdText.split('\n').length} lines'
                    : 'BRD generated • ${brdText.split('\n').length} lines (Pending Approval)')
                : 'Generate or upload your BRD first',
            style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.getTextMuted(isDark)),
          ),
          const Spacer(),
          if (brdText != null) ...[
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
                      'BRD Approved',
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
                    _brdEditCtrl.text = brdText;
                    _isEditingBrd = true;
                  });
                },
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: Text(
                  'Edit / Re-upload',
                  style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: EnterpriseTheme.getPrimaryAccent(isDark),
                  side: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              if (_isEditingBrd) ...[
                _buildGradientButton(
                  onPressed: () async {
                    final content = _brdEditCtrl.text;
                    setState(() => _isApproving = true);
                    await controller.updateWorkflowStage(1, 'approved', {'brd_content': content});
                    setState(() => _isApproving = false);
                    setState(() {
                      _isEditingBrd = false;
                    });
                    controller.logTerminal('BRD edited and approved.', level: 'SUCCESS');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text('✅ Edited BRD Approved and Confirmed!'),
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
                    setState(() => _isApproving = true);
                    await controller.updateWorkflowStage(1, 'approved', {'brd_content': brdText});
                    setState(() => _isApproving = false);
                    controller.logTerminal('BRD approved and confirmed.', level: 'SUCCESS');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text('✅ BRD Approved and Confirmed!'),
                            ],
                          ),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  icon: Icons.check_circle_outline,
                  isLoading: _isApproving,
                  label: 'Approve & Confirm',
                  isDark: isDark,
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                ),
                const SizedBox(width: 12),
              ],
            ],
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
      if (_reqCtrl.text.trim().isNotEmpty && _reqCtrl.text != feature.baseRequirement) {
        try {
          final updated = await ApiService.updateFeature(
            feature.id,
            name: feature.name,
            codeAccess: feature.codeAccess,
            dbAccess: feature.dbAccess,
            baseRequirement: _reqCtrl.text.trim(),
            brdPrompt: _promptCtrl.text,
            designPrompt: feature.designPrompt,
            codePrompt: feature.codePrompt,
            testPrompt: feature.testPrompt,
            memoryMd: feature.memoryMd,
            memoryPrompt: feature.memoryPrompt,
          );
          controller.activeFeature.value = updated;
        } catch (_) {}
      }

      final baseBrdPrompt = (controller.globalDefaultPrompts['brdPrompt'] ??
              controller.factoryDefaultPrompts['brdPrompt'] ??
              '''Focus strictly on the FUNCTIONAL requirements and business aspects. Do NOT include technical implementation details, file names, or codebase file impact matrices in the BRD. Technical design will be handled separately.

Include the following sections with exhaustive depth:
1. Executive Summary & Problem Definition
2. Target Business Objectives & OKRs
3. Target Personas / User Roles
4. In-Scope and Out-of-Scope boundaries
5. Functional Requirements
6. Epics and Detailed User Stories (US-1.1, US-1.2, etc.)
7. Acceptance Criteria in Gherkin (Given-When-Then) format
8. Non-Functional Requirements & Security Controls (Functional perspective)''')
          .trim();

      final aiInstruction = _promptCtrl.text.trim();
      final finalBrdPrompt = aiInstruction.isNotEmpty
          ? '$baseBrdPrompt\n\n--- ADDITIONAL AI INSTRUCTIONS ---\n$aiInstruction'
          : baseBrdPrompt;

      final payload = {
        'targetStage': 1,
        'requirement': _reqCtrl.text,
        'projectId': feature.id.toString(),
        'repoUrl': feature.codeAccess['repoUrl'],
        'repoBranch': feature.codeAccess['branch'],
        'brdPrompt': finalBrdPrompt,
        'architecture': 'Zero-Trust Framework',
        'compliance': 'NIST 800-207',
        'memoryMd': feature.memoryMd,
      };
      final res = await ApiService.generateDeliverables(payload);
      
      String brdContent = "Failed to generate.";
      if (res['deliverables'] != null && res['deliverables'].length > 0) {
        brdContent = res['deliverables'][0]['markdownContent'];
      }

      setState(() => _isApproving = true);
                    await controller.updateWorkflowStage(1, 'pending', {'brd_content': brdContent});
                    setState(() => _isApproving = false);
    } catch (e) {
      controller.logTerminal("Synthesis failed: $e", level: "ERROR");
      setState(() => _isApproving = true);
                    await controller.updateWorkflowStage(1, 'error', {'brd_content': 'Error generating BRD: $e'});
                    setState(() => _isApproving = false);
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
