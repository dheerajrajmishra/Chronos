import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/enterprise_sdlc_controller.dart';
import '../models/workflow_model.dart';
import '../models/sdlc_models.dart';
import '../theme/enterprise_theme.dart';

class StagePromptsDialog extends StatefulWidget {
  final Feature feature;
  final int initialStageIndex;

  const StagePromptsDialog({Key? key, required this.feature, this.initialStageIndex = 0}) : super(key: key);

  static Future<void> show(BuildContext context, Feature feature, {int initialStageIndex = 0}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StagePromptsDialog(feature: feature, initialStageIndex: initialStageIndex),
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
  }) : controller = TextEditingController(
          text: (initialValue.isNotEmpty &&
                  !initialValue.contains('Focus strictly on the technical architecture'))
              ? initialValue
              : defaultPrompt,
        );
}

class _StagePromptsDialogState extends State<StagePromptsDialog> {
  late int _selectedStageIndex;
  bool _isSaving = false;
  late final List<_StagePromptConfig> _stages;

  @override
  void initState() {
    super.initState();
    _selectedStageIndex = widget.initialStageIndex;
    final f = widget.feature;
    final controller = Get.find<EnterpriseSDLCController>();

    String getStageDefault(String key, String fallback) {
      final configured = controller.globalDefaultPrompts[key];
      return (configured != null && configured.trim().isNotEmpty) ? configured.trim() : fallback;
    }

    _stages = [
      _StagePromptConfig(
        stageIndex: 0,
        stageType: SDLCStageType.stage0Setup,
        title: 'Stage 0: Setup & Memory',
        agentRole: 'Context Extraction Agent (Repository Analysis & memory.md)',
        icon: Icons.memory_rounded,
        color: const Color(0xFF0D9488),
        initialValue: f.memoryPrompt,
        defaultPrompt: getStageDefault('memoryPrompt', '''Analyze the connected repository structure, architectural layers, and security context to synthesize a comprehensive memory.md.
Extract:
1. Executive System Summary & Architectural Baseline
2. Core Technologies, Frameworks, and Runtime Stack
3. Key Modules, Directory Structure & Component Boundaries
4. Data Persistence, Schemas, and External Integration Points
5. Zero-Trust Security Policies, Authentication, and DLP Boundaries
6. Development Conventions, Build Workflows, and Quality Gates'''),
      ),
      _StagePromptConfig(
        stageIndex: 1,
        stageType: SDLCStageType.stage1Brd,
        title: 'Stage 1: BRD Generation',
        agentRole: 'Business Analyst Agent (Requirements & User Stories)',
        icon: Icons.article_outlined,
        color: EnterpriseTheme.brandBlue,
        initialValue: f.brdPrompt,
        defaultPrompt: getStageDefault('brdPrompt', '''Focus strictly on the FUNCTIONAL requirements and business aspects. Do NOT include technical implementation details, file names, or codebase file impact matrices in the BRD. Technical design will be handled separately.

Include the following sections with exhaustive depth:
1. Executive Summary & Problem Definition
2. Target Business Objectives & OKRs
3. Target Personas / User Roles
4. In-Scope and Out-of-Scope boundaries
5. Functional Requirements
6. Epics and Detailed User Stories (US-1.1, US-1.2, etc.)
7. Acceptance Criteria in Gherkin (Given-When-Then) format
8. Non-Functional Requirements & Security Controls (Functional perspective)'''),
      ),
      _StagePromptConfig(
        stageIndex: 2,
        stageType: SDLCStageType.stage2Design,
        title: 'Stage 2: Design Document',
        agentRole: 'Functional Solutions Architect (Functional Design & As-Is / To-Be)',
        icon: Icons.architecture_outlined,
        color: EnterpriseTheme.purple,
        initialValue: f.designPrompt,
        defaultPrompt: getStageDefault('designPrompt', '''Focus strictly on the FUNCTIONAL design and system capability level for the target application. Do NOT include low-level code implementation, database DDL scripts, or infrastructure provisioning configs (which belong to the Technical Specification stage).

Include the following sections with comprehensive functional depth:
1. Executive Functional Overview & Solution Vision
2. As-Is Process & System Architecture (Current baseline workflow, legacy systems, operational pain points, and capability gaps)
3. To-Be Functional Design & Target Architecture (Target operational flow, functional capability decomposition, component interactions, and state transitions)
4. As-Is vs. To-Be Gap Analysis & Transition Impact Matrix
5. Assumptions & Constraints of the New Design:
   - Assumptions (Business, operational, stakeholder, and environmental dependencies)
   - Constraints (Regulatory, compliance, security boundaries, organizational policies, and functional limitations)
6. Functional Component Decomposition & Operational Responsibilities
7. End-to-End Business Event & Data Flow Models (Entity relationships, functional life cycles, and trigger events)
8. User Role Journeys & Persona-Driven Functional Touchpoints'''),
      ),
      _StagePromptConfig(
        stageIndex: 3,
        stageType: SDLCStageType.stage3TechDoc,
        title: 'Stage 3: Technical Document',
        agentRole: 'Technical Lead Agent (Low-Level Design, APIs & Schemas)',
        icon: Icons.terminal_rounded,
        color: EnterpriseTheme.cyan,
        initialValue: f.techDocPrompt,
        defaultPrompt: getStageDefault('techDocPrompt', '''Provide exact, implementation-ready technical specifications:
1. Low-Level Module Architecture & Execution Flow
2. Concrete REST / gRPC API Endpoint Specifications (Paths, Methods, Request & Response JSON schemas, Header authentication)
3. Database DDL & Schema Definitions (PostgreSQL tables, fields, types, indexes, and tokenized vault references)
4. Data Contracts & State Transition Models
5. Cryptographic & Security Boundaries (mTLS 1.3, Presidio PII Gateway Tokenization, Vault Token lifecycle)
6. Error Handling, Resilience & Retry Matrix (HTTP status codes, circuit breakers, fallback patterns)'''),
      ),
      _StagePromptConfig(
        stageIndex: 4,
        stageType: SDLCStageType.stage4Code,
        title: 'Stage 4: Code Generation',
        agentRole: 'Software Engineer Agent (Clean Implementation & Branch Scaffolding)',
        icon: Icons.code_rounded,
        color: const Color(0xFF6366F1),
        initialValue: f.codePrompt,
        defaultPrompt: getStageDefault('codePrompt', '''Generate clean, modular, and type-safe implementation code strictly adhering to the API contracts and database DDL schema defined in the Technical Document.

Include the following:
1. Project scaffolding with proper directory structure and module boundaries
2. REST/gRPC endpoint handlers with full request validation and error handling
3. Database repository layer with parameterized queries (no raw SQL injection vectors)
4. Presidio DLP client wrappers for dynamic PII masking on sensitive fields
5. Authentication & authorization middleware (JWT/mTLS token verification)
6. Environment-aware configuration (dev, staging, production) with secrets vault integration'''),
      ),
      _StagePromptConfig(
        stageIndex: 5,
        stageType: SDLCStageType.stage5TestCaseCreation,
        title: 'Stage 5: Test Case Creation',
        agentRole: 'QA Test Designer (Functional & Security Cases)',
        icon: Icons.checklist_rounded,
        color: EnterpriseTheme.emerald,
        initialValue: f.testCaseCreationPrompt,
        defaultPrompt: getStageDefault('testCaseCreationPrompt', '''Generate comprehensive test cases covering functional, security, and edge-case scenarios.
1. Outline test objectives mapped to BRD requirements.
2. Define precondition states and necessary test data.
3. Detail step-by-step test execution sequences.
4. Specify expected outcomes and acceptance criteria.'''),
      ),
      _StagePromptConfig(
        stageIndex: 6,
        stageType: SDLCStageType.stage6TestAutomation,
        title: 'Stage 6: Test Automation Script',
        agentRole: 'QA Automation Engineer (Script Generation)',
        icon: Icons.integration_instructions_rounded,
        color: EnterpriseTheme.rose,
        initialValue: f.testAutomationPrompt,
        defaultPrompt: getStageDefault('testAutomationPrompt', '''Generate code-level test automation scripts using established testing frameworks.
1. Implement test cases using appropriate assertions.
2. Provide necessary mocks or stubs for external dependencies.
3. Structure scripts for execution in a CI/CD pipeline.'''),
      ),
      _StagePromptConfig(
        stageIndex: 7,
        stageType: SDLCStageType.stage7TestingResult,
        title: 'Stage 7: Testing & Result',
        agentRole: 'QA Analyst (Log Analysis & Remediation)',
        icon: Icons.fact_check_outlined,
        color: EnterpriseTheme.amber,
        initialValue: f.testingResultPrompt,
        defaultPrompt: getStageDefault('testingResultPrompt', '''Analyze testing logs and results, providing a summary of outcomes and remediation steps.
1. Summarize pass/fail rates.
2. Highlight any failing tests and suggest probable causes based on logs.
3. Recommend remediation steps for failed tests.'''),
      ),
      _StagePromptConfig(
        stageIndex: 8,
        stageType: SDLCStageType.stage8Deploy,
        title: 'Stage 8: Deployment',
        agentRole: 'DevSecOps Release Agent (Canary Enclave Rollout)',
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF10B981),
        initialValue: f.deployPrompt,
        defaultPrompt: getStageDefault('deployPrompt', '''Execute canary release rollout sequence within isolated zero-trust cloud enclave.

Include the following:
1. Pre-deployment checklist: all gates (BRD, Design, Code, Test, UAT) passed
2. Canary rollout phases: 10% -> 50% -> 100% traffic shift with health monitors
3. mTLS certificate provisioning and health verification
4. Database migration execution with rollback plan
5. Monitoring & alerting configuration (metrics, logs, traces)
6. Cryptographic release seal: SHA-256 state digest of deployed artifacts
7. Post-deployment smoke tests and rollback trigger conditions'''),
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
      String getPrompt(int stageIdx) =>
          _stages.firstWhere((s) => s.stageIndex == stageIdx, orElse: () => _stages[0]).controller.text;

      final memory = getPrompt(0);
      final brd = getPrompt(1);
      final design = getPrompt(2);
      final techDoc = getPrompt(3);
      final code = getPrompt(4);
      final testCaseCreation = getPrompt(5);
      final testAutomation = getPrompt(6);
      final testingResult = getPrompt(7);
      final deploy = getPrompt(8);

      final success = await controller.updateFeaturePrompts(
        memoryPrompt: memory,
        brdPrompt: brd,
        designPrompt: design,
        techDocPrompt: techDoc,
        codePrompt: code,
        testCaseCreationPrompt: testCaseCreation,
        testAutomationPrompt: testAutomation,
        testingResultPrompt: testingResult,
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
