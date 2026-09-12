import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage1SpecStudio extends StatefulWidget {
  const Stage1SpecStudio({super.key});

  @override
  State<Stage1SpecStudio> createState() => _Stage1SpecStudioState();
}

class _Stage1SpecStudioState extends State<Stage1SpecStudio> {
  final TextEditingController _reqController = TextEditingController();
  String _selectedCompliance = 'SOC2 Type II + PCI-DSS 4.0';
  String _selectedArchitecture = 'Event-Driven Microservices';
  String _selectedCloud = 'Microsoft Azure (Zero-Trust VPC)';
  String _selectedLlm = 'Azure OpenAI GPT-4o (PitchPerfect Engine)';
  String _sensitivityMode = 'Strict Zero-Trust (Full NER Tokenization)';

  @override
  void initState() {
    super.initState();
    _reqController.text =
        "Deploy a zero-trust payments gateway with Stripe API key sk_live_51N8e2A93jK198LmN04B2 and connect customer DB postgres://admin:SuperSecret99@10.0.4.12:5432/finance for user john.doe@enterprise.com with IP 192.168.1.104.";
    _reqController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final prj = controller.activeProject.value;
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final inputBg = EnterpriseTheme.getInputBg(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Page Header ─────────────────────────────────────
            _pageHeader(isDark, textColor, textSecColor, primaryAccent, controller),

            const SizedBox(height: 20),

            // ─── Active Project Context ──────────────────────────
            if (prj != null) _projectContextBanner(prj, isDark, inputBg, primaryAccent, textSecColor, borderColor),

            const SizedBox(height: 24),

            // ─── Main 2-Column Layout ────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              final leftColumn = _buildInputPanel(
                controller, isDark, textColor, textSecColor, textMutedColor,
                inputBg, borderColor, primaryAccent, prj,
              );

              final rightColumn = _buildConfigPanel(
                isDark, textColor, textSecColor, inputBg, borderColor,
                primaryAccent, controller, prj,
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: leftColumn),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: rightColumn),
                  ],
                );
              } else {
                return Column(
                  children: [
                    leftColumn,
                    const SizedBox(height: 24),
                    rightColumn,
                  ],
                );
              }
            }),
          ],
        ),
      );
    });
  }

  // ─── Page Header ────────────────────────────────────────────────
  Widget _pageHeader(bool isDark, Color textColor, Color textSecColor, Color primaryAccent, EnterpriseSDLCController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: EnterpriseTheme.brandGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingestion & Spec Studio',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Natural language input with speech-to-text and project-scoped governance.',
                style: GoogleFonts.inter(color: textSecColor, fontSize: 13),
              ),
            ],
          ),
        ),
        _outlinedAction(
          'Switch Project',
          Icons.swap_horiz_rounded,
          primaryAccent,
          isDark,
          () => controller.setStage(SDLCStageType.projectHub),
        ),
      ],
    );
  }

  // ─── Project Context Banner ─────────────────────────────────────
  Widget _projectContextBanner(
    ProjectWorkspace prj, bool isDark, Color inputBg,
    Color primaryAccent, Color textSecColor, Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shield_outlined, color: primaryAccent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '[${prj.projectKey}]',
                      style: GoogleFonts.inter(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prj.name,
                      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    _pill(prj.environment, EnterpriseTheme.emerald, isDark),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 14,
                  children: [
                    _infoChip(Icons.code, '${prj.codeAccess.provider}', EnterpriseTheme.purple, textSecColor),
                    _infoChip(Icons.dns_outlined, '${prj.dbAccess.dbType.split(' ').first} · JIT ${prj.dbAccess.jitTtlMinutes}m', EnterpriseTheme.amber, textSecColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input Panel (Left Column) ──────────────────────────────────
  Widget _buildInputPanel(
    EnterpriseSDLCController controller, bool isDark,
    Color textColor, Color textSecColor, Color textMutedColor,
    Color inputBg, Color borderColor, Color primaryAccent,
    ProjectWorkspace? prj,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: primaryAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Requirement Specification',
                style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _aiEngineButton(controller, isDark, inputBg, borderColor, primaryAccent),
              const SizedBox(width: 8),
              _scenarioMenu(isDark, inputBg, borderColor, primaryAccent),
            ],
          ),

          const SizedBox(height: 14),

          // STT bar
          _sttBar(controller, isDark, inputBg, borderColor, textColor, textMutedColor),

          const SizedBox(height: 14),

          // Text input area
          TextField(
            controller: _reqController,
            maxLines: 8,
            style: GoogleFonts.jetBrainsMono(
              color: textColor,
              fontSize: 12,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: 'Enter feature requirements, API keys, database connections...',
              hintStyle: GoogleFonts.inter(color: textMutedColor, fontSize: 12),
              filled: true,
              fillColor: inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryAccent, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Real-time Semantic Analysis Chips
          _buildRealTimeAnalysisChips(isDark, primaryAccent, textMutedColor),

          const SizedBox(height: 12),

          // Zero-trust notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: isDark ? 0.06 : 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryAccent.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: primaryAccent, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'API keys, IP addresses, database passwords, and PII will be intercepted and replaced with cryptographic tokens at Stage 2.',
                    style: GoogleFonts.inter(color: textSecColor, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Config Panel (Right Column) ─────────────────────────────────
  Widget _buildConfigPanel(
    bool isDark, Color textColor, Color textSecColor,
    Color inputBg, Color borderColor, Color primaryAccent,
    EnterpriseSDLCController controller, ProjectWorkspace? prj,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: primaryAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Pipeline Configuration',
                style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _configDropdown(isDark: isDark, label: 'Compliance Framework', icon: Icons.verified_user_outlined, value: _selectedCompliance, items: [
            'SOC2 Type II + PCI-DSS 4.0', 'HIPAA Security & Privacy Rule', 'ISO/IEC 27001:2022 ISMS',
            'FedRAMP High Baseline (GovCloud)', 'GDPR / CCPA Data Privacy',
          ], onChanged: (v) => setState(() => _selectedCompliance = v!)),

          const SizedBox(height: 12),
          _configDropdown(isDark: isDark, label: 'Architecture Pattern', icon: Icons.account_tree_outlined, value: _selectedArchitecture, items: [
            'Event-Driven Microservices', 'Zero-Trust Service Mesh (mTLS)', 'Serverless Event Sourcing',
            'Layered Hexagonal Architecture', 'High-Throughput CQRS Pipeline',
          ], onChanged: (v) => setState(() => _selectedArchitecture = v!)),

          const SizedBox(height: 12),
          _configDropdown(isDark: isDark, label: 'Target Cloud', icon: Icons.cloud_outlined, value: _selectedCloud, items: [
            'Microsoft Azure (Zero-Trust VPC)', 'AWS GovCloud (Air-Gapped VPC)',
            'Google Cloud Platform (Confidential VMs)', 'On-Premises Kubernetes Private Cluster',
          ], onChanged: (v) => setState(() => _selectedCloud = v!)),

          const SizedBox(height: 12),
          _configDropdown(isDark: isDark, label: 'AI Model Engine', icon: Icons.smart_toy_outlined, value: _selectedLlm, items: [
            'Azure OpenAI GPT-4o (PitchPerfect Engine)', 'Anthropic Claude 3.5 Sonnet (Enclave Hosted)',
            'Google Gemini 1.5 Pro (Enterprise Vertex)', 'Local Llama-3 70B (Air-Gapped Private LLM)',
          ], onChanged: (v) => setState(() => _selectedLlm = v!)),

          const SizedBox(height: 12),
          _configDropdown(isDark: isDark, label: 'Tokenization Policy', icon: Icons.lock_outline, value: _sensitivityMode, items: [
            'Strict Zero-Trust (Full NER Tokenization)', 'High Entropy Secret Masking Only',
            'Selective PII Masking (HIPAA Strict)',
          ], onChanged: (v) => setState(() => _sensitivityMode = v!)),

          const SizedBox(height: 24),

          // ─── Execute CTA ────────────────────────────────────
          Obx(() {
            final isBusy = controller.isProcessing.value;
            return _ExecuteButton(
              isDark: isDark,
              isProcessing: isBusy,
              projectKey: prj?.projectKey ?? 'DEFAULT',
              onTap: isBusy ? null : () {
                controller.executePipeline(
                  rawRequirement: _reqController.text,
                  compliance: _selectedCompliance,
                  architecture: _selectedArchitecture,
                  cloudTarget: _selectedCloud,
                  llmModel: _selectedLlm,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // ─── STT Bar ─────────────────────────────────────────────────────
  Widget _sttBar(EnterpriseSDLCController controller, bool isDark, Color inputBg, Color borderColor, Color textColor, Color textMutedColor) {
    return Obx(() {
      final isRec = controller.isRecordingAudio.value;
      final level = controller.audioLevel.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isRec
              ? (isDark ? const Color(0xFF1A0F15) : const Color(0xFFFEE2E2))
              : inputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRec ? EnterpriseTheme.rose.withValues(alpha: 0.5) : borderColor,
            width: isRec ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => controller.toggleAudioRecording(_reqController),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRec ? EnterpriseTheme.rose : EnterpriseTheme.getSubtleBg(isDark),
                  shape: BoxShape.circle,
                  boxShadow: isRec ? [
                    BoxShadow(color: EnterpriseTheme.rose.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1),
                  ] : [],
                ),
                child: Icon(
                  isRec ? Icons.stop_rounded : Icons.mic_none_rounded,
                  color: isRec ? Colors.white : EnterpriseTheme.rose,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isRec ? 'Streaming audio...' : 'Voice input',
                        style: GoogleFonts.inter(
                          color: isRec ? EnterpriseTheme.rose : textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isRec) ...[
                        const SizedBox(width: 6),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: EnterpriseTheme.rose, shape: BoxShape.circle)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (isRec)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: level,
                        backgroundColor: isDark ? const Color(0xFF2D1B28) : const Color(0xFFFECDD3),
                        color: EnterpriseTheme.rose,
                        minHeight: 3,
                      ),
                    )
                  else
                    Text(
                      'Click to dictate via encrypted voice stream',
                      style: GoogleFonts.inter(color: textMutedColor, fontSize: 11),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── Scenario Menu ───────────────────────────────────────────────
  Widget _scenarioMenu(bool isDark, Color inputBg, Color borderColor, Color primaryAccent) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    return PopupMenuButton<String>(
      tooltip: 'Load sample scenarios',
      color: EnterpriseTheme.getCardBgElevated(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor),
      ),
      onSelected: (val) => _reqController.text = val,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_stories_outlined, size: 13, color: primaryAccent),
            const SizedBox(width: 5),
            Text('Samples', style: GoogleFonts.inter(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "Deploy a zero-trust payments gateway with Stripe API key sk_live_51N8e2A93jK198LmN04B2 and connect customer DB postgres://admin:SuperSecret99@10.0.4.12:5432/finance for user john.doe@enterprise.com with IP 192.168.1.104.",
          child: Text('Fintech Gateway & DB Connector', style: GoogleFonts.inter(color: textColor, fontSize: 12)),
        ),
        PopupMenuItem(
          value: "Build HIPAA-compliant FHIR Patient Ingestion API integrating AWS S3 bucket s3://health-records-private-prod with access key AKIAIOSFODNN7EXAMPLE and secret key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY.",
          child: Text('Healthcare HIPAA Patient Records', style: GoogleFonts.inter(color: textColor, fontSize: 12)),
        ),
        PopupMenuItem(
          value: "Develop an automated microservices authentication broker connecting Okta tenant dev-99482.okta.com with client secret sec_99ab21cd88ef and Redis cluster 10.128.0.45:6379.",
          child: Text('Enterprise SSO & Auth Broker', style: GoogleFonts.inter(color: textColor, fontSize: 12)),
        ),
      ],
    );
  }

  // ─── Real-Time Semantic Analysis Chips ──────────────────────────
  Widget _buildRealTimeAnalysisChips(bool isDark, Color primaryAccent, Color textMutedColor) {
    final text = _reqController.text.trim();
    final lower = text.toLowerCase();

    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final tokenEstimate = (text.length / 3.8).round();

    String domain = 'Enterprise Subsystem';
    Color domainColor = EnterpriseTheme.brandBlue;
    if (lower.contains('patient') || lower.contains('hospital') || lower.contains('health') || lower.contains('ehr') || lower.contains('fhir') || lower.contains('hipaa')) {
      domain = 'Digital Healthcare';
      domainColor = EnterpriseTheme.emerald;
    } else if (lower.contains('payment') || lower.contains('stripe') || lower.contains('bank') || lower.contains('fintech') || lower.contains('transaction') || lower.contains('ledger')) {
      domain = 'Fintech & Payments';
      domainColor = EnterpriseTheme.purple;
    } else if (lower.contains('iot') || lower.contains('vehicle') || lower.contains('telemetry') || lower.contains('fleet') || lower.contains('mqtt') || lower.contains('sensor')) {
      domain = 'IoT & Telemetry';
      domainColor = EnterpriseTheme.amber;
    } else if (lower.contains('auth') || lower.contains('identity') || lower.contains('sso') || lower.contains('oauth') || lower.contains('jwt')) {
      domain = 'Identity & IAM';
      domainColor = EnterpriseTheme.indigo;
    }

    final dbs = ['PostgreSQL', 'MongoDB', 'Redis', 'TimescaleDB', 'MySQL', 'DynamoDB']
        .where((db) => lower.contains(db.toLowerCase()))
        .toList();

    final apis = ['FHIR', 'REST', 'GraphQL', 'gRPC', 'MQTT', 'Kafka', 'Stripe']
        .where((api) => lower.contains(api.toLowerCase()))
        .toList();

    final hasSecret = lower.contains('sk_') || lower.contains('akia') || lower.contains('secret') || lower.contains('password') || RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b').hasMatch(text);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _metaChip(
          icon: Icons.layers_outlined,
          label: 'Domain: $domain',
          color: domainColor,
          isDark: isDark,
        ),
        if (dbs.isNotEmpty)
          _metaChip(
            icon: Icons.storage_rounded,
            label: 'DB: ${dbs.join(', ')}',
            color: EnterpriseTheme.brandBlue,
            isDark: isDark,
          ),
        if (apis.isNotEmpty)
          _metaChip(
            icon: Icons.api_rounded,
            label: 'API: ${apis.join(', ')}',
            color: EnterpriseTheme.emerald,
            isDark: isDark,
          ),
        if (hasSecret)
          _metaChip(
            icon: Icons.lock_outline_rounded,
            label: 'High-Entropy Secret Vaulted',
            color: EnterpriseTheme.amber,
            isDark: isDark,
          ),
        _metaChip(
          icon: Icons.analytics_outlined,
          label: '$words words (~$tokenEstimate tokens)',
          color: textMutedColor,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _metaChip({required IconData icon, required String label, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ─── AI Engine Button ─────────────────────────────────────────────
  Widget _aiEngineButton(
    EnterpriseSDLCController controller,
    bool isDark,
    Color inputBg,
    Color borderColor,
    Color primaryAccent,
  ) {
    return Obx(() {
      final isCloud = controller.customApiKey.value.isNotEmpty || controller.useCloudLlm.value;
      return InkWell(
        onTap: () => _showAiEngineModal(context, controller, isDark),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCloud
                ? EnterpriseTheme.purple.withValues(alpha: 0.12)
                : primaryAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isCloud
                  ? EnterpriseTheme.purple.withValues(alpha: 0.4)
                  : primaryAccent.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCloud ? Icons.cloud_done_outlined : Icons.smart_toy_outlined,
                color: isCloud ? EnterpriseTheme.purple : primaryAccent,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                isCloud ? 'Cloud LLM' : 'Zero-Trust Engine',
                style: GoogleFonts.inter(
                  color: isCloud ? EnterpriseTheme.purple : primaryAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.settings_outlined,
                color: isCloud ? EnterpriseTheme.purple : primaryAccent,
                size: 11,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showAiEngineModal(BuildContext context, EnterpriseSDLCController controller, bool isDark) {
    final apiKeyController = TextEditingController(text: controller.customApiKey.value);
    showDialog(
      context: context,
      builder: (ctx) {
        final textColor = EnterpriseTheme.getTextPrimary(isDark);
        final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
        final inputBg = EnterpriseTheme.getInputBg(isDark);
        final borderColor = EnterpriseTheme.getCardBorder(isDark);
        final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF131B2B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor),
          ),
          title: Row(
            children: [
              Icon(Icons.psychology_outlined, color: primaryAccent, size: 20),
              const SizedBox(width: 10),
              Text(
                'AI Synthesis Engine Settings',
                style: GoogleFonts.inter(color: textColor, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chronos supports both autonomous air-gapped Zero-Trust semantic synthesis and live Cloud LLMs (OpenAI / Azure OpenAI).',
                  style: GoogleFonts.inter(color: textSecColor, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EnterpriseTheme.emerald.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: EnterpriseTheme.emerald.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: EnterpriseTheme.emerald, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Zero-Trust Local Engine Active: Ingests real input, extracts entities/protocols, and dynamically drafts BRD & C4 specs without sending data outside.',
                          style: GoogleFonts.inter(color: EnterpriseTheme.emerald, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cloud LLM API Key (Optional for Live GPT-4o)',
                  style: GoogleFonts.inter(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: apiKeyController,
                  obscureText: true,
                  style: GoogleFonts.jetBrainsMono(color: textColor, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'sk-... (leave blank to use Local Engine)',
                    hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 12),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryAccent)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'When provided, masked requests will route through Azure OpenAI / OpenAI GPT-4o.',
                  style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 11),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                apiKeyController.clear();
                controller.customApiKey.value = '';
                Navigator.of(ctx).pop();
                Get.snackbar('Engine Reset', 'Using Zero-Trust Autonomous Engine');
              },
              child: Text('Reset to Local', style: GoogleFonts.inter(color: textSecColor, fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () {
                controller.customApiKey.value = apiKeyController.text.trim();
                Navigator.of(ctx).pop();
                Get.snackbar(
                  'Settings Saved',
                  controller.customApiKey.value.isNotEmpty ? 'Cloud LLM Key configured' : 'Autonomous Zero-Trust Engine selected',
                  backgroundColor: primaryAccent.withValues(alpha: 0.9),
                  colorText: Colors.black,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save Settings', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
  Widget _configDropdown({
    required bool isDark,
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);
    final cardBgElevated = EnterpriseTheme.getCardBgElevated(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: textSecColor, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              dropdownColor: cardBgElevated,
              icon: Icon(Icons.expand_more_rounded, color: textSecColor, size: 18),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: primaryAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.inter(color: textColor, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Utility Widgets ─────────────────────────────────────────────
  Widget _outlinedAction(String label, IconData icon, Color accent, bool isDark, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.inter(color: accent, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoChip(IconData icon, String text, Color iconColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(color: textColor, fontSize: 11)),
      ],
    );
  }
}

// ─── Execute Button with hover glow ──────────────────────────────────
class _ExecuteButton extends StatefulWidget {
  final bool isDark;
  final bool isProcessing;
  final String projectKey;
  final VoidCallback? onTap;

  const _ExecuteButton({
    required this.isDark,
    required this.isProcessing,
    required this.projectKey,
    this.onTap,
  });

  @override
  State<_ExecuteButton> createState() => _ExecuteButtonState();
}

class _ExecuteButtonState extends State<_ExecuteButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 46,
          decoration: BoxDecoration(
            gradient: widget.isProcessing ? null : EnterpriseTheme.brandGradient,
            color: widget.isProcessing ? EnterpriseTheme.getSubtleBg(widget.isDark) : null,
            borderRadius: BorderRadius.circular(9),
            boxShadow: _isHovered && !widget.isProcessing
                ? [
                    BoxShadow(
                      color: EnterpriseTheme.brandBlue.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: EnterpriseTheme.brandBlue),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Executing pipeline...',
                        style: GoogleFonts.inter(
                          color: EnterpriseTheme.getTextSecondary(widget.isDark),
                          fontWeight: FontWeight.w600, fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Initiate Pipeline [${widget.projectKey}]',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
