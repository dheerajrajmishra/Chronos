import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage1SpecStudio extends StatefulWidget {
  const Stage1SpecStudio({Key? key}) : super(key: key);

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
      final prj = controller.activeProject.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage Title & Subtitle Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_outlined, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Stage 1: Requirements Ingestion & Spec Studio',
                        style: TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Zero-Trust natural language input with speech-to-text transcription and project-scoped governance parameters.',
                        style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => controller.setStage(SDLCStageType.projectHub),
                  icon: const Icon(Icons.swap_horiz, size: 16, color: EnterpriseTheme.cyan),
                  label: const Text('Switch Project', style: TextStyle(color: EnterpriseTheme.cyan, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: EnterpriseTheme.cyan),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Active Project Scope & Access Governance Banner
            if (prj != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: EnterpriseTheme.cyan.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: EnterpriseTheme.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shield, color: EnterpriseTheme.cyan, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "TARGET PROJECT: [${prj.projectKey}] ${prj.name}",
                                style: const TextStyle(
                                  color: EnterpriseTheme.cyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: EnterpriseTheme.emerald.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  prj.environment,
                                  style: const TextStyle(color: EnterpriseTheme.emerald, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 16,
                            runSpacing: 6,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.code, size: 14, color: EnterpriseTheme.purple),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Code Repo: ${prj.codeAccess.provider} (${prj.codeAccess.accessScope.split(' ').first})",
                                    style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.dns_outlined, size: 14, color: EnterpriseTheme.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Database: ${prj.dbAccess.dbType.split(' ').first} on ${prj.dbAccess.host} [JIT TTL: ${prj.dbAccess.jitTtlMinutes}m]",
                                    style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Main 2-Column Layout
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              final leftColumn = Container(
                padding: const EdgeInsets.all(20),
                decoration: EnterpriseTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note, color: EnterpriseTheme.cyan, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Requirement Specification (PRD / Feature Request)',
                          style: TextStyle(
                            color: EnterpriseTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Preset Scenario Chips
                        PopupMenuButton<String>(
                          tooltip: 'Load Sample Scenarios',
                          color: EnterpriseTheme.cardBgElevated,
                          onSelected: (val) {
                            _reqController.text = val;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: EnterpriseTheme.cardBorder),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.auto_stories, size: 14, color: EnterpriseTheme.cyan),
                                SizedBox(width: 6),
                                Text('Sample Scenarios', style: TextStyle(color: EnterpriseTheme.cyan, fontSize: 11)),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value:
                                  "Deploy a zero-trust payments gateway with Stripe API key sk_live_51N8e2A93jK198LmN04B2 and connect customer DB postgres://admin:SuperSecret99@10.0.4.12:5432/finance for user john.doe@enterprise.com with IP 192.168.1.104.",
                              child: Text('Fintech Gateway & DB Connector'),
                            ),
                            const PopupMenuItem(
                              value:
                                  "Build HIPAA-compliant FHIR Patient Ingestion API integrating AWS S3 bucket s3://health-records-private-prod with access key AKIAIOSFODNN7EXAMPLE and secret key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY.",
                              child: Text('Healthcare HIPAA Patient Records API'),
                            ),
                            const PopupMenuItem(
                              value:
                                  "Develop an automated microservices authentication broker connecting Okta tenant dev-99482.okta.com with client secret sec_99ab21cd88ef and Redis cluster 10.128.0.45:6379.",
                              child: Text('Enterprise SSO & Auth Broker'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Audio Voice STT Simulation Bar
                    Obx(() {
                      final isRec = controller.isRecordingAudio.value;
                      final level = controller.audioLevel.value;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isRec ? const Color(0xFF1E1020) : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isRec ? EnterpriseTheme.rose : EnterpriseTheme.cardBorder,
                            width: isRec ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => controller.toggleAudioRecording(_reqController),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isRec ? EnterpriseTheme.rose : const Color(0xFF1E293B),
                                  shape: BoxShape.circle,
                                  boxShadow: isRec
                                      ? [
                                          BoxShadow(
                                            color: EnterpriseTheme.rose.withValues(alpha: 0.5),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  isRec ? Icons.stop : Icons.mic,
                                  color: isRec ? Colors.white : EnterpriseTheme.rose,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isRec ? 'STREAMING AZURE SPEECH-TO-TEXT...' : 'Zero-Trust Audio Ingestion',
                                        style: TextStyle(
                                          color: isRec ? EnterpriseTheme.rose : EnterpriseTheme.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isRec) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: EnterpriseTheme.rose,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (isRec)
                                    LinearProgressIndicator(
                                      value: level,
                                      backgroundColor: const Color(0xFF2D1B28),
                                      color: EnterpriseTheme.rose,
                                      minHeight: 4,
                                    )
                                  else
                                    const Text(
                                      'Click microphone to dictate requirement via encrypted voice stream.',
                                      style: TextStyle(color: EnterpriseTheme.textMuted, fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 14),

                    // Text Specification Input Area
                    TextField(
                      controller: _reqController,
                      maxLines: 8,
                      style: const TextStyle(
                        color: EnterpriseTheme.textPrimary,
                        fontSize: 13,
                        height: 1.5,
                        fontFamily: 'Consolas',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter feature requirements, database connections, API keys, or architectures...',
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: EnterpriseTheme.cardBorder),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notice Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: EnterpriseTheme.cyan.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: EnterpriseTheme.cyan.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_outlined, color: EnterpriseTheme.cyan, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Zero-Trust Enforcement: Any API keys, IP addresses, database passwords, or PII entered will be intercepted and replaced with deterministic cryptographic tokens at Stage 2 before leaving the security enclave.',
                              style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final rightColumn = Container(
                padding: const EdgeInsets.all(20),
                decoration: EnterpriseTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tune, color: EnterpriseTheme.cyan, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Pipeline Governance Configuration',
                          style: TextStyle(
                            color: EnterpriseTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _dropdownOption(
                      label: 'Compliance Framework Target',
                      icon: Icons.verified_user_outlined,
                      value: _selectedCompliance,
                      items: [
                        'SOC2 Type II + PCI-DSS 4.0',
                        'HIPAA Security & Privacy Rule',
                        'ISO/IEC 27001:2022 ISMS',
                        'FedRAMP High Baseline (GovCloud)',
                        'GDPR / CCPA Data Privacy',
                      ],
                      onChanged: (val) => setState(() => _selectedCompliance = val!),
                    ),

                    const SizedBox(height: 14),

                    _dropdownOption(
                      label: 'Architecture Pattern Blueprint',
                      icon: Icons.account_tree_outlined,
                      value: _selectedArchitecture,
                      items: [
                        'Event-Driven Microservices',
                        'Zero-Trust Service Mesh (mTLS)',
                        'Serverless Event Sourcing',
                        'Layered Hexagonal Architecture',
                        'High-Throughput CQRS Pipeline',
                      ],
                      onChanged: (val) => setState(() => _selectedArchitecture = val!),
                    ),

                    const SizedBox(height: 14),

                    _dropdownOption(
                      label: 'Target Cloud Enclave',
                      icon: Icons.cloud_outlined,
                      value: _selectedCloud,
                      items: [
                        'Microsoft Azure (Zero-Trust VPC)',
                        'AWS GovCloud (Air-Gapped VPC)',
                        'Google Cloud Platform (Confidential VMs)',
                        'On-Premises Kubernetes Private Cluster',
                      ],
                      onChanged: (val) => setState(() => _selectedCloud = val!),
                    ),

                    const SizedBox(height: 14),

                    _dropdownOption(
                      label: 'AI Reasoning Model Engine',
                      icon: Icons.smart_toy_outlined,
                      value: _selectedLlm,
                      items: [
                        'Azure OpenAI GPT-4o (PitchPerfect Engine)',
                        'Anthropic Claude 3.5 Sonnet (Enclave Hosted)',
                        'Google Gemini 1.5 Pro (Enterprise Vertex)',
                        'Local Llama-3 70B (Air-Gapped Private LLM)',
                      ],
                      onChanged: (val) => setState(() => _selectedLlm = val!),
                    ),

                    const SizedBox(height: 14),

                    _dropdownOption(
                      label: 'Data Sensitivity & Tokenization Policy',
                      icon: Icons.lock_outline,
                      value: _sensitivityMode,
                      items: [
                        'Strict Zero-Trust (Full NER Tokenization)',
                        'High Entropy Secret Masking Only',
                        'Selective PII Masking (HIPAA Strict)',
                      ],
                      onChanged: (val) => setState(() => _sensitivityMode = val!),
                    ),

                    const SizedBox(height: 24),

                    // Execute Primary Action Button
                    Obx(() {
                      final isBusy = controller.isProcessing.value;

                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isBusy
                              ? null
                              : () {
                                  controller.executePipeline(
                                    rawRequirement: _reqController.text,
                                    compliance: _selectedCompliance,
                                    architecture: _selectedArchitecture,
                                    cloudTarget: _selectedCloud,
                                    llmModel: _selectedLlm,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EnterpriseTheme.cyan,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 4,
                          ),
                          child: isBusy
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Executing Zero-Trust Pipeline...',
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bolt, color: Colors.black, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Initiate Pipeline in [${prj?.projectKey ?? 'DEFAULT'}]',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: leftColumn),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: rightColumn),
                  ],
                );
              } else {
                return Column(
                  children: [
                    leftColumn,
                    const SizedBox(height: 20),
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

  Widget _dropdownOption({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: EnterpriseTheme.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: EnterpriseTheme.cardBgElevated,
              icon: const Icon(Icons.arrow_drop_down, color: EnterpriseTheme.textSecondary),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: EnterpriseTheme.cyan),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12),
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
}
