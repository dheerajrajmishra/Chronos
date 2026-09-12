import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStageIndex = 0;
  bool _isSaving = false;

  // Controllers for each stage's prompt
  final List<TextEditingController> _promptControllers = [];

  static const List<Map<String, dynamic>> _stageDefs = [
    {
      'key': 'memoryPrompt',
      'stageNum': 0,
      'title': 'Stage 0: Project Setup & Memory (memory.md)',
      'shortTitle': 'Stage 0: Setup',
      'agent': 'Context Extraction Agent',
      'icon': Icons.memory_rounded,
      'color': Color(0xFF0D9488),
      'desc': 'Directives for scanning repository structure and synthesizing foundational memory.md project context.',
    },
    {
      'key': 'brdPrompt',
      'stageNum': 1,
      'title': 'Stage 1: Business Requirements (BRD)',
      'shortTitle': 'Stage 1: BRD',
      'agent': 'Business Analyst Agent',
      'icon': Icons.assignment_outlined,
      'color': Color(0xFF2563EB),
      'desc': 'Functional requirements, business problem definition, user stories (US-x.x), and Gherkin acceptance criteria.',
    },
    {
      'key': 'designPrompt',
      'stageNum': 2,
      'title': 'Stage 2: Functional Design Document',
      'shortTitle': 'Stage 2: Design',
      'agent': 'Functional Solutions Architect',
      'icon': Icons.architecture_rounded,
      'color': Color(0xFF7C3AED),
      'desc': 'Strictly functional-level system design: As-Is vs To-Be architecture, capability models, and assumptions & constraints.',
    },
    {
      'key': 'techDocPrompt',
      'stageNum': 3,
      'title': 'Stage 3: Technical Document & Schemas',
      'shortTitle': 'Stage 3: Tech Doc',
      'agent': 'Technical Lead Agent',
      'icon': Icons.terminal_rounded,
      'color': Color(0xFF0284C7),
      'desc': 'Low-level API contracts (OpenAPI/gRPC), PostgreSQL DDL schemas, security boundary protocols, and retry strategies.',
    },
    {
      'key': 'codePrompt',
      'stageNum': 4,
      'title': 'Stage 4: Implementation & Code Generation',
      'shortTitle': 'Stage 4: Code Gen',
      'agent': 'Software Engineer Agent',
      'icon': Icons.code_rounded,
      'color': Color(0xFF6366F1),
      'desc': 'Modular codebase scaffolding, zero-trust API handlers, secure parameterized database queries, and DLP wrappers.',
    },
    {
      'key': 'unitTestPrompt',
      'stageNum': 5,
      'title': 'Stage 5: Unit Testing & Fixtures',
      'shortTitle': 'Stage 5: Unit Test',
      'agent': 'QA Automation Agent',
      'icon': Icons.checklist_rounded,
      'color': Color(0xFF059669),
      'desc': 'Automated unit test suites, table-driven test cases, mock repositories, negative boundaries, and PII leakage assertions.',
    },
    {
      'key': 'testPrompt',
      'stageNum': 6,
      'title': 'Stage 6: Integration & Security Testing',
      'shortTitle': 'Stage 6: Testing',
      'agent': 'Security & QA Agent',
      'icon': Icons.verified_user_outlined,
      'color': Color(0xFFD97706),
      'desc': 'End-to-end integration workflows, OpenAPI contract testing, zero-trust token tampering defense, and load benchmarks.',
    },
    {
      'key': 'uatPrompt',
      'stageNum': 7,
      'title': 'Stage 7: User Acceptance Testing (UAT)',
      'shortTitle': 'Stage 7: UAT',
      'agent': 'Product Owner Agent',
      'icon': Icons.fact_check_outlined,
      'color': Color(0xFFDB2777),
      'desc': 'Persona-based walkthroughs, business verification checklists, failure severity matrix, and stakeholder sign-offs.',
    },
    {
      'key': 'deployPrompt',
      'stageNum': 8,
      'title': 'Stage 8: Deployment & Cloud Release',
      'shortTitle': 'Stage 8: Deploy',
      'agent': 'DevSecOps Release Agent',
      'icon': Icons.cloud_done_outlined,
      'color': Color(0xFF0D9488),
      'desc': 'Zero-trust Kubernetes manifests, CI/CD automated security gates, blue/green rollback triggers, and release seals.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final controller = Get.find<EnterpriseSDLCController>();

    for (int i = 0; i < _stageDefs.length; i++) {
      final key = _stageDefs[i]['key'] as String;
      final configured = controller.globalDefaultPrompts[key];
      final factoryDefault = controller.factoryDefaultPrompts[key] ?? '';
      _promptControllers.add(
        TextEditingController(
          text: (configured != null && configured.isNotEmpty) ? configured : factoryDefault,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _promptControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncWithController() {
    final controller = Get.find<EnterpriseSDLCController>();
    for (int i = 0; i < _stageDefs.length; i++) {
      final key = _stageDefs[i]['key'] as String;
      final configured = controller.globalDefaultPrompts[key];
      final factoryDefault = controller.factoryDefaultPrompts[key] ?? '';
      final text = (configured != null && configured.isNotEmpty) ? configured : factoryDefault;
      if (_promptControllers[i].text != text) {
        _promptControllers[i].text = text;
      }
    }
  }

  Future<void> _saveAllPrompts() async {
    setState(() => _isSaving = true);
    final controller = Get.find<EnterpriseSDLCController>();

    final Map<String, String> promptsToSave = {};
    for (int i = 0; i < _stageDefs.length; i++) {
      final key = _stageDefs[i]['key'] as String;
      promptsToSave[key] = _promptControllers[i].text;
    }

    final success = await controller.saveGlobalPrompts(promptsToSave);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(success ? Icons.check_circle : Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                success
                    ? 'Global default prompts successfully saved to database!'
                    : 'Failed to save global default prompts.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: success ? const Color(0xFF059669) : Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _resetToFactoryDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset to Factory Defaults?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'This will revert all 9 stage default prompts (Stages 0–8) to the standard factory templates. Custom edits will be overwritten.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isSaving = true);
      final controller = Get.find<EnterpriseSDLCController>();
      final success = await controller.resetGlobalPrompts();
      if (success) {
        _syncWithController();
      }
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Prompts reset to factory defaults!' : 'Failed to reset prompts.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: success ? const Color(0xFF059669) : Colors.redAccent,
          ),
        );
      }
    }
  }

  void _resetSingleStage(int index) {
    final controller = Get.find<EnterpriseSDLCController>();
    final key = _stageDefs[index]['key'] as String;
    final factoryPrompt = controller.factoryDefaultPrompts[key] ?? '';
    if (factoryPrompt.isNotEmpty) {
      setState(() {
        _promptControllers[index].text = factoryPrompt;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_stageDefs[index]['shortTitle']} reset to factory default.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final surfaceColor = EnterpriseTheme.getSurface(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

      return Container(
        color: EnterpriseTheme.getBackground(isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: EnterpriseTheme.brandGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Global System Settings',
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: EnterpriseTheme.emerald.withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: EnterpriseTheme.emerald.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                'CONFIG ACTIVE',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: EnterpriseTheme.emerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Configure enterprise theme preference and customize AI prompt directives for each SDLC stage via UI',
                          style: GoogleFonts.inter(fontSize: 12.5, color: textSecColor),
                        ),
                      ],
                    ),
                  ),
                  // Back button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecColor,
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      controller.setStage(controller.activeFeature.value != null
                          ? SDLCStageType.stage1Brd
                          : SDLCStageType.projectHub);
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: Text('Back to Pipeline', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // ─── Tab Bar Navigation ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: primaryAccent,
                unselectedLabelColor: textSecColor,
                indicatorColor: primaryAccent,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.palette_outlined, size: 18),
                    text: 'Theme & Appearance',
                  ),
                  Tab(
                    icon: Icon(Icons.psychology_outlined, size: 18),
                    text: 'Default Stage Prompts (Global)',
                  ),
                ],
              ),
            ),

            // ─── Tab View Body ────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Theme Setup
                  _buildThemeSetupTab(isDark, controller, surfaceColor, borderColor, textColor, textSecColor, primaryAccent),

                  // Tab 2: Prompt Configuration Screen
                  _buildPromptsConfigTab(isDark, controller, surfaceColor, borderColor, textColor, textSecColor, primaryAccent),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 1: THEME SETUP
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildThemeSetupTab(
    bool isDark,
    EnterpriseSDLCController controller,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecColor,
    Color primaryAccent,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interface Theme Configuration',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Select your preferred workspace theme. By default, the application opens in clean Light Mode for maximum clarity, but you can switch to Dark Mode anytime.',
                style: GoogleFonts.inter(fontSize: 13, color: textSecColor, height: 1.5),
              ),
              const SizedBox(height: 24),

              // Theme Cards (Light vs Dark)
              Row(
                children: [
                  // Light Mode Card (Default)
                  Expanded(
                    child: _buildThemeCard(
                      title: 'Light Theme (Default)',
                      description: 'Crisp, high-contrast light interface optimized for daytime readability and enterprise compliance workflows.',
                      isCurrentActive: !isDark,
                      accentColor: const Color(0xFF2563EB),
                      icon: Icons.light_mode_rounded,
                      isDarkPreview: false,
                      onSelect: () => controller.setThemeMode(false),
                      isDarkUi: isDark,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Dark Mode Card
                  Expanded(
                    child: _buildThemeCard(
                      title: 'Dark Theme',
                      description: 'Deep navy-slate interface designed for low-light environments, code-level focus, and reduced eye strain.',
                      isCurrentActive: isDark,
                      accentColor: const Color(0xFF6366F1),
                      icon: Icons.dark_mode_rounded,
                      isDarkPreview: true,
                      onSelect: () => controller.setThemeMode(true),
                      isDarkUi: isDark,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // System Defaults Notice Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131728) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.info_outline_rounded, color: primaryAccent, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Persistence & Default State',
                            style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your theme selection is immediately saved to the enterprise PostgreSQL database and applied to all browser tabs and subsequent sessions.',
                            style: GoogleFonts.inter(fontSize: 12, color: textSecColor, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (val) => controller.setThemeMode(val),
                      activeColor: const Color(0xFF6366F1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String description,
    required bool isCurrentActive,
    required Color accentColor,
    required IconData icon,
    required bool isDarkPreview,
    required VoidCallback onSelect,
    required bool isDarkUi,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkUi ? const Color(0xFF131728) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrentActive ? accentColor : borderColor,
            width: isCurrentActive ? 2.0 : 1.0,
          ),
          boxShadow: isCurrentActive
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: EnterpriseTheme.getTextPrimary(isDarkUi),
                    ),
                  ),
                ),
                if (isCurrentActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: EnterpriseTheme.getTextSecondary(isDarkUi),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),

            // Mini Mock UI Preview
            Container(
              height: 72,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkPreview ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkPreview ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    decoration: BoxDecoration(
                      color: isDarkPreview ? const Color(0xFF1A1F30) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 140,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDarkPreview ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
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

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 2: GLOBAL STAGE DEFAULT PROMPTS CONFIGURATION
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildPromptsConfigTab(
    bool isDark,
    EnterpriseSDLCController controller,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecColor,
    Color primaryAccent,
  ) {
    final activeStage = _stageDefs[_selectedStageIndex];
    final Color stageColor = activeStage['color'] as Color;
    final activeController = _promptControllers[_selectedStageIndex];

    return Row(
      children: [
        // ─── Left: Stages Selector Sidebar ────────────────────────
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SDLC Stages (1 - 8)',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Select a stage to view and customize its default prompt template',
                      style: GoogleFonts.inter(fontSize: 11, color: textSecColor),
                    ),
                  ],
                ),
              ),

              // List of Stages
              Expanded(
                child: ListView.builder(
                  itemCount: _stageDefs.length,
                  itemBuilder: (context, index) {
                    final stage = _stageDefs[index];
                    final isSelected = index == _selectedStageIndex;
                    final Color color = stage['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: isDark ? 0.15 : 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        onTap: () {
                          setState(() => _selectedStageIndex = index);
                        },
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(stage['icon'] as IconData, size: 16, color: color),
                          ),
                        ),
                        title: Text(
                          stage['shortTitle'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? color : textColor,
                          ),
                        ),
                        subtitle: Text(
                          stage['agent'] as String,
                          style: GoogleFonts.inter(fontSize: 10, color: textSecColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSelected
                            ? Icon(Icons.chevron_right_rounded, size: 18, color: color)
                            : null,
                      ),
                    );
                  },
                ),
              ),

              // Bottom Actions in Stage List
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    minimumSize: const Size.fromHeight(38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _resetToFactoryDefaults,
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: Text('Reset All to Factory Defaults', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),

        // ─── Right: Prompt Editor Pane ────────────────────────────
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Info Bar for Selected Stage
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: stageColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(activeStage['icon'] as IconData, size: 22, color: stageColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  activeStage['title'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: stageColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    activeStage['agent'] as String,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: stageColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              activeStage['desc'] as String,
                              style: GoogleFonts.inter(fontSize: 12, color: textSecColor),
                            ),
                          ],
                        ),
                      ),
                      // Copy button
                      IconButton(
                        tooltip: 'Copy Prompt',
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: activeController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Prompt copied to clipboard!'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      // Reset single stage
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textSecColor,
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _resetSingleStage(_selectedStageIndex),
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: Text('Reset to Factory', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Multi-Line Code Editor Box
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF090A11) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.2),
                    ),
                    child: TextField(
                      controller: activeController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        color: textColor,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter default prompt instructions for this stage...',
                        hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 13),
                        contentPadding: const EdgeInsets.all(20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Bottom Status & Save Bar
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: EnterpriseTheme.getTextMuted(isDark)),
                    const SizedBox(width: 6),
                    Text(
                      'Changes saved here will serve as the system-wide baseline for newly created features & AI prompts.',
                      style: GoogleFonts.inter(fontSize: 11.5, color: EnterpriseTheme.getTextMuted(isDark)),
                    ),
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: activeController,
                      builder: (context, value, child) {
                        return Text(
                          '${activeController.text.length} chars | ~${(activeController.text.length / 4).round()} tokens',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: EnterpriseTheme.getTextMuted(isDark),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EnterpriseTheme.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isSaving ? null : _saveAllPrompts,
                      icon: _isSaving
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded, size: 16),
                      label: Text(
                        _isSaving ? 'Saving...' : 'Save All Default Prompts',
                        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
