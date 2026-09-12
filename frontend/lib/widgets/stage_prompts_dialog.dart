import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../models/sdlc_models.dart';
import '../theme/enterprise_theme.dart';

class StagePromptsDialog extends StatefulWidget {
  final Feature feature;

  const StagePromptsDialog({Key? key, required this.feature}) : super(key: key);

  static Future<void> show(BuildContext context, Feature feature) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StagePromptsDialog(feature: feature),
    );
  }

  @override
  State<StagePromptsDialog> createState() => _StagePromptsDialogState();
}

class _StagePromptConfig {
  final int stageIndex;
  final SDLCStageType stageType;
  final String title;
  final String agentRole;
  final IconData icon;
  final Color color;
  final String defaultPrompt;
  final TextEditingController controller;

  _StagePromptConfig({
    required this.stageIndex,
    required this.stageType,
    required this.title,
    required this.agentRole,
    required this.icon,
    required this.color,
    required this.defaultPrompt,
    required String initialValue,
  }) : controller = TextEditingController(text: initialValue.isNotEmpty ? initialValue : defaultPrompt);
}

class _StagePromptsDialogState extends State<StagePromptsDialog> {
  int _selectedStageIndex = 1;
  bool _isSaving = false;
  late final List<_StagePromptConfig> _stages;

  @override
  void initState() {
    super.initState();
    final f = widget.feature;

    _stages = [
      _StagePromptConfig(
        stageIndex: 1,
        stageType: SDLCStageType.stage1Brd,
        title: 'Stage 1: BRD Generation',
        agentRole: 'Business Analyst Agent (Requirements & User Stories)',
        icon: Icons.article_outlined,
        color: EnterpriseTheme.brandBlue,
        initialValue: f.brdPrompt,
        defaultPrompt: 'Generate an executive-grade Business Requirements Document (BRD) strictly following Zero-Trust principles (NIST 800-207), user stories with Given-When-Then Gherkin acceptance criteria, and compliance mapping.',
      ),
      _StagePromptConfig(
        stageIndex: 2,
        stageType: SDLCStageType.stage2Design,
        title: 'Stage 2: Design Document',
        agentRole: 'Cloud Architect Agent (System Architecture & C4 Blueprints)',
        icon: Icons.architecture_outlined,
        color: EnterpriseTheme.purple,
        initialValue: f.designPrompt,
        defaultPrompt: 'Generate a comprehensive System Architecture and Technical Design Document (DD) including C4 container diagrams, component boundaries, data flow diagrams, and event-driven microservice patterns for the target application.',
      ),
      _StagePromptConfig(
        stageIndex: 3,
        stageType: SDLCStageType.stage3TechDoc,
        title: 'Stage 3: Technical Document',
        agentRole: 'Technical Lead Agent (Low-Level Design, APIs & Schemas)',
        icon: Icons.terminal_rounded,
        color: EnterpriseTheme.cyan,
        initialValue: f.techDocPrompt,
        defaultPrompt: 'Generate a low-level Technical Specification (LLD) with exact REST/gRPC API contracts, request/response JSON schemas, PostgreSQL DDL migrations, and Zero-Trust cryptographic boundary controls.',
      ),
      _StagePromptConfig(
        stageIndex: 4,
        stageType: SDLCStageType.stage4Code,
        title: 'Stage 4: Code Generation',
        agentRole: 'Software Engineer Agent (Clean Implementation & Branch Scaffolding)',
        icon: Icons.code_rounded,
        color: const Color(0xFF6366F1),
        initialValue: f.codePrompt,
        defaultPrompt: 'Generate clean, modular, and type-safe implementation code strictly adhering to the API contracts and database DDL schema. Integrate Presidio DLP client wrappers for dynamic PII masking.',
      ),
      _StagePromptConfig(
        stageIndex: 5,
        stageType: SDLCStageType.stage5UnitTest,
        title: 'Stage 5: Unit Testing',
        agentRole: 'QA Automation Agent (Test Fixtures, Mocks & Assertions)',
        icon: Icons.checklist_rounded,
        color: EnterpriseTheme.emerald,
        initialValue: f.unitTestPrompt,
        defaultPrompt: 'Generate comprehensive unit test suites with Jest/PyTest covering edge cases, Presidio vault tokenization mocks, circuit breaker failure scenarios, and database timeout resilience.',
      ),
      _StagePromptConfig(
        stageIndex: 6,
        stageType: SDLCStageType.stage6Test,
        title: 'Stage 6: Testing & Security',
        agentRole: 'CyberSec Ops Agent (DAST/SAST & Penetration Audits)',
        icon: Icons.security_rounded,
        color: EnterpriseTheme.rose,
        initialValue: f.testPrompt,
        defaultPrompt: 'Execute end-to-end integration test suites, Presidio gateway token leakage audits, SQL injection prevention verification, and DAST vulnerability scans against OWASP Top 10 standards.',
      ),
      _StagePromptConfig(
        stageIndex: 7,
        stageType: SDLCStageType.stage7Uat,
        title: 'Stage 7: UAT (User Acceptance)',
        agentRole: 'Product Governance Agent (Business Acceptance & Compliance)',
        icon: Icons.fact_check_outlined,
        color: EnterpriseTheme.amber,
        initialValue: f.uatPrompt,
        defaultPrompt: 'Validate enterprise business criteria and generate formal stakeholder acceptance report covering Product Owner sign-off, SLA performance verification (< 250ms), and compliance checklists.',
      ),
      _StagePromptConfig(
        stageIndex: 8,
        stageType: SDLCStageType.stage8Deploy,
        title: 'Stage 8: Deployment',
        agentRole: 'DevSecOps Release Agent (Canary Enclave Rollout)',
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF10B981),
        initialValue: f.deployPrompt,
        defaultPrompt: 'Execute canary release rollout sequence within isolated zero-trust cloud enclave (10% -> 50% -> 100%), verify mTLS certificate health, and seal release with cryptographic SHA-256 state digest.',
      ),
    ];
  }

  @override
  void dispose() {
    for (final s in _stages) {
      s.controller.dispose();
    }
    super.dispose();
  }

  _StagePromptConfig get _currentStage => _stages.firstWhere(
        (s) => s.stageIndex == _selectedStageIndex,
        orElse: () => _stages[0],
      );

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    final isDark = controller.isDarkMode.value;
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);
    final surfaceColor = EnterpriseTheme.getSurface(isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Container(
        width: 1020,
        height: 720,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
              blurRadius: 36,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // ─── Modal Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111420) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: EnterpriseTheme.brandGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Stage AI Prompt Engineering Matrix',
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: EnterpriseTheme.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'PERSISTENT IN DB',
                              style: GoogleFonts.jetBrainsMono(
                                color: primaryAccent,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Configure and edit the custom prompt instructions utilized across each pipeline stage for: "${widget.feature.name}"',
                        style: GoogleFonts.inter(
                          color: EnterpriseTheme.getTextSecondary(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: EnterpriseTheme.getTextMuted(isDark)),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // ─── Body: Split View ──────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  // Left Stage Tab Column
                  Container(
                    width: 310,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0C0E17) : const Color(0xFFF1F5F9),
                      border: Border(right: BorderSide(color: borderColor)),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _stages.length,
                      itemBuilder: (context, index) {
                        final stage = _stages[index];
                        final isSelected = stage.stageIndex == _selectedStageIndex;
                        final hasCustom = stage.controller.text != stage.defaultPrompt && stage.controller.text.isNotEmpty;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () => setState(() => _selectedStageIndex = stage.stageIndex),
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF1E2235) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? stage.color.withValues(alpha: 0.5)
                                      : Colors.transparent,
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: stage.color.withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: stage.color.withValues(alpha: isSelected ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Icon(stage.icon, size: 16, color: stage.color),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stage.title,
                                          style: GoogleFonts.inter(
                                            color: isSelected
                                                ? EnterpriseTheme.getTextPrimary(isDark)
                                                : EnterpriseTheme.getTextSecondary(isDark),
                                            fontSize: 12.5,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          hasCustom ? 'Custom Prompt • Configured' : 'Default Template',
                                          style: GoogleFonts.inter(
                                            color: hasCustom ? EnterpriseTheme.emerald : EnterpriseTheme.getTextMuted(isDark),
                                            fontSize: 10,
                                            fontWeight: hasCustom ? FontWeight.w600 : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: isSelected ? stage.color : Colors.transparent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Right Editor Area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      color: surfaceColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stage Editor Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _currentStage.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(_currentStage.icon, size: 20, color: _currentStage.color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentStage.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: EnterpriseTheme.getTextPrimary(isDark),
                                      ),
                                    ),
                                    Text(
                                      _currentStage.agentRole,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: EnterpriseTheme.getTextSecondary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                                  side: BorderSide(color: borderColor),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _currentStage.controller.text = _currentStage.defaultPrompt;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Prompt reset to default template.')),
                                  );
                                },
                                icon: const Icon(Icons.restart_alt_rounded, size: 15),
                                label: Text('Reset to Default', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Context Pills Bar
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildContextBadge('Includes memory.md Project Context', Icons.memory_rounded, isDark),
                              _buildContextBadge('Presidio DLP Sanitized', Icons.lock_outline_rounded, isDark),
                              _buildContextBadge('Zero-Trust Architecture Contract', Icons.shield_outlined, isDark),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Editable Prompt TextField
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF090A11) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: TextField(
                                controller: _currentStage.controller,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  color: EnterpriseTheme.getTextPrimary(isDark),
                                  height: 1.6,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter custom prompt instructions for this stage...',
                                  hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 13),
                                  contentPadding: const EdgeInsets.all(18),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 13, color: EnterpriseTheme.getTextMuted(isDark)),
                              const SizedBox(width: 6),
                              Text(
                                'This prompt will be injected into AI agents whenever "${_currentStage.title}" is generated or regenerated.',
                                style: GoogleFonts.inter(fontSize: 11, color: EnterpriseTheme.getTextMuted(isDark)),
                              ),
                              const Spacer(),
                              ValueListenableBuilder(
                                valueListenable: _currentStage.controller,
                                builder: (context, value, child) {
                                  return Text(
                                    '${_currentStage.controller.text.length} characters',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      color: EnterpriseTheme.getTextMuted(isDark),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Modal Footer: Save to Database ───────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111420) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.storage_rounded, size: 16, color: EnterpriseTheme.emerald),
                  const SizedBox(width: 8),
                  Text(
                    'Prompts are persisted in PostgreSQL for feature: "${widget.feature.name}"',
                    style: GoogleFonts.inter(
                      color: EnterpriseTheme.getTextSecondary(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: EnterpriseTheme.getTextSecondary(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    decoration: BoxDecoration(
                      gradient: EnterpriseTheme.brandGradient,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      onPressed: _isSaving ? null : () => _saveAllPrompts(controller),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_rounded, size: 17, color: Colors.white),
                      label: Text(
                        _isSaving ? 'Saving to Database...' : 'Save Prompts to Database',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextBadge(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getInputBg(isDark),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: EnterpriseTheme.getTextSecondary(isDark)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10.5, color: EnterpriseTheme.getTextSecondary(isDark), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAllPrompts(EnterpriseSDLCController controller) async {
    setState(() => _isSaving = true);

    try {
      final brd = _stages[0].controller.text;
      final design = _stages[1].controller.text;
      final techDoc = _stages[2].controller.text;
      final code = _stages[3].controller.text;
      final unitTest = _stages[4].controller.text;
      final test = _stages[5].controller.text;
      final uat = _stages[6].controller.text;
      final deploy = _stages[7].controller.text;

      final success = await controller.updateFeaturePrompts(
        brdPrompt: brd,
        designPrompt: design,
        techDocPrompt: techDoc,
        codePrompt: code,
        unitTestPrompt: unitTest,
        testPrompt: test,
        uatPrompt: uat,
        deployPrompt: deploy,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Stage AI Prompts successfully saved to database!'),
              backgroundColor: Color(0xFF059669),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save prompts to database.'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
