import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/workflow_model.dart';

class EnterpriseSDLCController extends GetxController {
  // Navigation & Role State
  final Rx<SDLCStageType> currentStage = SDLCStageType.projectHub.obs;
  final RxString userRole = 'Principal Security Architect'.obs;
  final RxString environment = 'Zero-Trust Secure Enclave (PCI/SOC2)'.obs;
  final RxBool isSidebarCollapsed = false.obs;

  // AI Synthesis Engine State
  final RxString customApiKey = ''.obs;
  final RxBool useCloudLlm = false.obs;
  final RxString llmEngineStatus = 'Zero-Trust Autonomous Engine'.obs;

  // Theme Mode State (true = Dark Mode, false = Light Mode)
  final RxBool isDarkMode = true.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    logTerminal("Theme switched to: ${isDarkMode.value ? 'DARK MODE (High-Tech HUD)' : 'LIGHT MODE (Enterprise Clean)'}", level: "THEME");
    Get.snackbar(
      'Theme Mode Changed',
      isDarkMode.value ? 'Switched to Dark Cyberpunk HUD' : 'Switched to Enterprise Light Mode',
      backgroundColor: isDarkMode.value ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      colorText: isDarkMode.value ? Colors.white : const Color(0xFF0F172A),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  // Project Workspaces State
  final RxList<ProjectWorkspace> projectList = <ProjectWorkspace>[].obs;
  final Rxn<ProjectWorkspace> activeProject = Rxn<ProjectWorkspace>();

  // Active Workflow State
  final Rxn<WorkflowExecution> activeWorkflow = Rxn<WorkflowExecution>();
  final RxList<WorkflowExecution> workflowHistory = <WorkflowExecution>[].obs;
  final RxBool isProcessing = false.obs;

  // Audio / STT Simulation
  final RxBool isRecordingAudio = false.obs;
  final RxDouble audioLevel = 0.0.obs;
  final RxString liveTranscript = ''.obs;
  Timer? _audioTimer;

  // Live Terminal Logs
  final RxList<String> liveTerminalLogs = <String>[].obs;

  // System Infrastructure Telemetry
  final RxMap<String, dynamic> telemetry = <String, dynamic>{
    'gatewayStatus': 'ONLINE',
    'gatewayLatencyMs': 18,
    'temporalStatus': 'CONNECTED',
    'temporalTaskQueue': 'sdlc-queue',
    'redisStatus': 'ACTIVE',
    'redisTokensCount': 142,
    'postgresStatus': 'HEALTHY',
    'llmEngine': 'Azure OpenAI GPT-4o',
    'zeroTrustScore': '99.4%',
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _initSampleProjects();
    _startTelemetryLoop();
  }

  void _initSampleProjects() {
    final prj1 = ProjectWorkspace(
      id: 'PRJ-FINTECH',
      name: 'Fintech Core Payments Gateway',
      projectKey: 'PAY-CORE',
      description: 'Zero-trust payment authorization, card tokenization engine, and ledger reconciliation microservice.',
      environment: 'Staging Enclave (PCI-DSS 4.0)',
      securityTier: 'Tier 1 (Mission Critical)',
      complianceBaseline: 'SOC2 Type II + PCI-DSS 4.0',
      activePipelinesCount: 2,
      codeAccess: CodeAccessConfig(
        provider: 'GitHub Enterprise',
        repoUrl: 'https://github.com/enterprise-org/payments-core.git',
        defaultBranch: 'main',
        branchRule: 'feature/payment-*',
        accessScope: 'PR Scaffolding (Automated PR Creation)',
        enforceSignedCommits: true,
        preCommitSecretScan: true,
      ),
      dbAccess: DbAccessConfig(
        dbType: 'PostgreSQL (ACID Cluster)',
        host: '10.240.1.12',
        port: 5432,
        databaseName: 'fintech_core_db',
        privilegeLevel: 'Read-Write (Zero-Trust Tokenized)',
        jitTtlMinutes: 60,
        enableDynamicMasking: true,
        isVaulted: true,
      ),
    );

    final prj2 = ProjectWorkspace(
      id: 'PRJ-HEALTHCARE',
      name: 'Healthcare FHIR Patient Ingestion',
      projectKey: 'HL7-FHIR',
      description: 'HIPAA-compliant EHR ingest broker with de-identification and clinical trial data sanitization.',
      environment: 'GovCloud Health Enclave',
      securityTier: 'Tier 1 (HIPAA Restricted)',
      complianceBaseline: 'HIPAA Security Rule + HITRUST',
      activePipelinesCount: 1,
      codeAccess: CodeAccessConfig(
        provider: 'GitLab Security Tier',
        repoUrl: 'https://gitlab.enterprise.internal/health/fhir-broker.git',
        defaultBranch: 'release/v3',
        branchRule: 'feature/fhir-*',
        accessScope: 'PR Scaffolding (Automated PR Creation)',
        enforceSignedCommits: true,
        preCommitSecretScan: true,
      ),
      dbAccess: DbAccessConfig(
        dbType: 'MongoDB (Encrypted Cluster)',
        host: '10.180.4.55',
        port: 27017,
        databaseName: 'patient_ehr_vault',
        privilegeLevel: 'Read-Only (Audit / Query)',
        jitTtlMinutes: 15,
        enableDynamicMasking: true,
        isVaulted: true,
      ),
    );

    final prj3 = ProjectWorkspace(
      id: 'PRJ-AUTH-SSO',
      name: 'Enterprise Zero-Trust Identity Mesh',
      projectKey: 'IAM-MESH',
      description: 'OIDC/OAuth2 token broker with biometric passkey authentication and Redis ephemeral session vault.',
      environment: 'Production GovCloud',
      securityTier: 'Tier 1 (Identity Root)',
      complianceBaseline: 'FedRAMP High + ISO 27001',
      activePipelinesCount: 0,
      codeAccess: CodeAccessConfig(
        provider: 'Azure DevOps',
        repoUrl: 'https://dev.azure.com/enterprise-cloud/iam-mesh.git',
        defaultBranch: 'main',
        branchRule: 'feature/iam-*',
        accessScope: 'Read-Only (Static Analysis)',
        enforceSignedCommits: true,
        preCommitSecretScan: true,
      ),
      dbAccess: DbAccessConfig(
        dbType: 'Redis Cluster (In-Memory)',
        host: '10.100.8.99',
        port: 6379,
        databaseName: 'session_vault_db',
        privilegeLevel: 'Read-Write (Zero-Trust Tokenized)',
        jitTtlMinutes: 480,
        enableDynamicMasking: true,
        isVaulted: true,
      ),
    );

    projectList.addAll([prj1, prj2, prj3]);
    activeProject.value = prj1;

    _initSampleWorkflow(prj1);
  }

  void selectProject(ProjectWorkspace project) {
    activeProject.value = project;
    logTerminal("Active Project Workspace switched to: [${project.projectKey}] ${project.name}", level: "PROJECT");
    Get.snackbar(
      'Active Workspace Switched',
      'Now working inside [${project.projectKey}] ${project.name}',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  void createNewProject({
    required String name,
    required String projectKey,
    required String description,
    required String environment,
    required String securityTier,
    required String complianceBaseline,
    required CodeAccessConfig codeAccess,
    required DbAccessConfig dbAccess,
  }) {
    final prj = ProjectWorkspace(
      id: "PRJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      name: name,
      projectKey: projectKey.toUpperCase(),
      description: description,
      environment: environment,
      securityTier: securityTier,
      complianceBaseline: complianceBaseline,
      codeAccess: codeAccess,
      dbAccess: dbAccess,
      activePipelinesCount: 0,
    );

    projectList.insert(0, prj);
    activeProject.value = prj;
    logTerminal("Created new Project Workspace: [${prj.projectKey}] ${prj.name}", level: "PROJECT");
    logTerminal("Code Access: ${codeAccess.provider} (${codeAccess.accessScope}) | DB: ${dbAccess.dbType} on ${dbAccess.host}", level: "ACCESS_AUDIT");

    Get.snackbar(
      'Project Created Successfully',
      'Project ${prj.name} initialized with Code & DB Access policies.',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  void initiatePipelineForProject(ProjectWorkspace project) {
    selectProject(project);
    setStage(SDLCStageType.specStudio);
    logTerminal("Initiating new feature pipeline for project: ${project.name}", level: "PIPELINE");
  }

  void _startTelemetryLoop() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      final random = Random();
      telemetry['gatewayLatencyMs'] = 14 + random.nextInt(12);
      telemetry['redisTokensCount'] = (telemetry['redisTokensCount'] as int) + random.nextInt(3) - 1;
      telemetry.refresh();
    });
  }

  void logTerminal(String message, {String level = 'INFO'}) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}";
    final logLine = "[$timeStr] [$level] $message";
    liveTerminalLogs.insert(0, logLine);
    if (liveTerminalLogs.length > 200) {
      liveTerminalLogs.removeLast();
    }
  }

  void setStage(SDLCStageType stage) {
    currentStage.value = stage;
    logTerminal("Navigated to: ${stage.name.toUpperCase()}", level: "NAV");
  }

  void setUserRole(String role) {
    userRole.value = role;
    logTerminal("Security context switched to role: $role", level: "AUTH");
    Get.snackbar(
      'Role Context Updated',
      'Active identity: $role',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  void toggleAudioRecording(TextEditingController textController) {
    if (isRecordingAudio.value) {
      isRecordingAudio.value = false;
      _audioTimer?.cancel();
      logTerminal("Audio stream closed. Transcribing voice stream via Azure Speech API...", level: "STT");
      Get.snackbar(
        'Speech Transcribed',
        'Voice input successfully converted to structured requirement.',
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } else {
      isRecordingAudio.value = true;
      logTerminal("Microphone stream opened. Initializing Zero-Trust secure audio channel...", level: "STT");

      const samplePhases = [
        "Deploy a zero-trust payments gateway with Stripe API key sk_live_51N8e2A93jK198LmN04B2 and connect customer DB postgres://admin:SuperSecret99@10.0.4.12:5432/finance...",
        "Integrate customer onboarding API with identity verification for user john.doe@enterprise.com with SSN 482-99-0192 and IP 192.168.1.104...",
        "Build automated tokenized OAuth2 auth service connecting Redis cluster redis://10.240.0.8:6379 with JWT secret key secret_key_77a91bc.",
      ];

      final chosen = samplePhases[Random().nextInt(samplePhases.length)];
      int charIdx = 0;

      _audioTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
        if (!isRecordingAudio.value) {
          timer.cancel();
          return;
        }
        audioLevel.value = 0.2 + (Random().nextDouble() * 0.8);
        if (charIdx < chosen.length) {
          charIdx = min(chosen.length, charIdx + 3);
          final chunk = chosen.substring(0, charIdx);
          liveTranscript.value = chunk;
          textController.text = chunk;
        }
      });
    }
  }

  Future<void> executePipeline({
    required String rawRequirement,
    required String compliance,
    required String architecture,
    required String cloudTarget,
    required String llmModel,
    CodeAccessConfig? customCodeAccess,
    DbAccessConfig? customDbAccess,
  }) async {
    if (rawRequirement.trim().isEmpty) {
      Get.snackbar('Input Error', 'Please enter or record a requirement specification.',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    isProcessing.value = true;
    final prj = activeProject.value;
    final workflowId = "ZTSDLC-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

    final codeAccess = customCodeAccess ?? prj?.codeAccess ?? CodeAccessConfig();
    final dbAccess = customDbAccess ?? prj?.dbAccess ?? DbAccessConfig();

    logTerminal("=== INITIATING ZERO-TRUST FEATURE PIPELINE: $workflowId ===", level: "WORKFLOW");
    logTerminal("Project: [${prj?.projectKey ?? 'DEFAULT'}] ${prj?.name ?? 'Standalone'} | Compliance: $compliance", level: "CONFIG");
    logTerminal("Code Access Policy: ${codeAccess.provider} -> ${codeAccess.repoUrl} (${codeAccess.accessScope})", level: "ACCESS_CODE");
    logTerminal("Database Access Policy: ${dbAccess.dbType} -> ${dbAccess.host}:${dbAccess.port}/${dbAccess.databaseName} [JIT TTL: ${dbAccess.jitTtlMinutes}m]", level: "ACCESS_DB");

    final newWf = WorkflowExecution(
      id: workflowId,
      projectId: prj?.id ?? 'PRJ-DEFAULT',
      projectName: prj?.name ?? 'Enterprise SDLC Pipeline',
      title: "Feature Pipeline: ${rawRequirement.split(' ').take(5).join(' ')}...",
      rawRequirement: rawRequirement,
      complianceStandard: compliance,
      architecturePattern: architecture,
      cloudTarget: cloudTarget,
      llmModel: llmModel,
      codeAccess: codeAccess,
      dbAccess: dbAccess,
      currentStage: SDLCStageType.vaultInspector,
      status: "TOKENIZING",
    );

    activeWorkflow.value = newWf;
    currentStage.value = SDLCStageType.vaultInspector;

    // Simulate Step 1 & 2: Presidio Zero-Trust Gateway Tokenization
    await Future.delayed(const Duration(milliseconds: 1200));
    final tokens = _extractAndTokenize(rawRequirement);
    String masked = rawRequirement;
    for (var t in tokens) {
      masked = masked.replaceAll(t.originalValue, t.maskedToken);
    }
    newWf.tokens = tokens;
    newWf.maskedRequirement = masked;
    newWf.auditHistory.add(AuditEvent(
      id: "AUD-${Random().nextInt(999999)}",
      timestamp: DateTime.now(),
      actor: userRole.value,
      role: "Security Officer",
      action: "PRESIDIO_TOKENIZE_VAULT",
      stage: "Stage 2: Zero-Trust Gateway",
      sha256Hash: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      status: "SUCCESS",
    ));
    logTerminal("Tokenized ${tokens.length} high-entropy secrets and PII entities into Redis Vault.", level: "VAULT");
    activeWorkflow.refresh();

    // Step 3: Multi-Agent AI Synthesis
    await Future.delayed(const Duration(milliseconds: 1400));
    setStage(SDLCStageType.agentOrchestration);
    newWf.status = "SYNTHESIZING_AGENTS";
    logTerminal("Invoking Temporal Activities on task queue 'sdlc-queue'...", level: "TEMPORAL");
    logTerminal("Agent [Business Analyst] synthesizing BRD for: ${rawRequirement.split(' ').take(6).join(' ')}...", level: "AGENT_BA");
    logTerminal("Agent [Solutions Architect] generating C4 models for repo: ${codeAccess.repoUrl}.", level: "AGENT_ARCH");
    logTerminal("Agent [CyberSec Ops] verifying STRIDE controls for ${dbAccess.dbType} on ${dbAccess.host}.", level: "AGENT_SEC");

    newWf.deliverables = await _synthesizeDeliverables(
      rawRequirement: rawRequirement,
      maskedRequirement: masked,
      architecture: architecture,
      compliance: compliance,
      cloudTarget: cloudTarget,
      llmModel: llmModel,
    );
    newWf.currentStage = SDLCStageType.approvalGate;
    newWf.status = "WAITING_APPROVAL";

    newWf.auditHistory.add(AuditEvent(
      id: "AUD-${Random().nextInt(999999)}",
      timestamp: DateTime.now(),
      actor: "Temporal Worker (sdlc-queue)",
      role: "Agent Orchestrator",
      action: "MULTI_AGENT_SYNTHESIS_COMPLETE",
      stage: "Stage 3: Agent Orchestration",
      sha256Hash: "8f4803227a84e9f4414164b3297a303b21264f2244597d9ad9770b6f8d886039",
      status: "SUCCESS",
    ));

    newWf.sbomItems = _generateSbom();

    isProcessing.value = false;
    workflowHistory.insert(0, newWf);
    if (prj != null) {
      prj.activePipelinesCount++;
      projectList.refresh();
    }
    activeWorkflow.refresh();

    setStage(SDLCStageType.approvalGate);
    Get.snackbar(
      'Multi-Agent Synthesis Complete',
      'Feature pipeline ready for Stage 4 (Human-in-the-Loop Governance Gate).',
      backgroundColor: const Color(0xFF00F2FE).withValues(alpha: 0.9),
      colorText: const Color(0xFF0A0E17),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
    );
  }

  void submitApproval(bool approved, String comments) {
    if (activeWorkflow.value == null) return;
    final wf = activeWorkflow.value!;

    wf.isApproved = approved;
    wf.approvedBy = userRole.value;
    wf.approvalComment = comments.isNotEmpty
        ? comments
        : (approved ? "Approved with Zero-Trust compliance signoff." : "Rejected during architecture review.");
    wf.status = approved ? "APPROVED_READY_FOR_DEPLOY" : "REJECTED";

    final action = approved ? "GOVERNANCE_GATE_APPROVED" : "GOVERNANCE_GATE_REJECTED";
    logTerminal("Human Sign-off Signal sent to Temporal Workflow: ${approved ? 'SIGNAL: APPROVE' : 'SIGNAL: REJECT'}", level: "SIGNAL");
    logTerminal("Signed by: ${userRole.value} with SHA-256 validation.", level: "AUDIT");

    wf.auditHistory.add(AuditEvent(
      id: "AUD-${Random().nextInt(999999)}",
      timestamp: DateTime.now(),
      actor: userRole.value,
      role: userRole.value,
      action: action,
      stage: "Stage 4: Approval Gate",
      sha256Hash: "a45c7b82f0192e448b3014a005086d773412f9e42e1819d9b4c09d81d5bfa780",
      status: approved ? "SUCCESS" : "BLOCKED",
    ));

    activeWorkflow.refresh();

    if (approved) {
      setStage(SDLCStageType.codeGenSbom);
      Get.snackbar(
        'Workflow Approved',
        'Proceeding to Stage 5: Automated Code Scaffolding, SAST & SBOM verification.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } else {
      Get.snackbar(
        'Workflow Rejected',
        'Workflow halted at gate per security policy.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  void toggleTokenReveal(VaultToken token) {
    token.isRevealed = !token.isRevealed;
    logTerminal("Vault access: Token ${token.maskedToken} reveal toggled to ${token.isRevealed ? 'VISIBLE' : 'MASKED'} by ${userRole.value}", level: "VAULT_AUDIT");
    activeWorkflow.refresh();
  }

  List<VaultToken> _extractAndTokenize(String text) {
    final List<VaultToken> result = [];
    final random = Random();

    // API Key regex / pattern
    final apiKeyRegex = RegExp(r'(sk_live_[a-zA-Z0-9_-]+|key_[a-zA-Z0-9_-]+|AIza[0-9A-Za-z-_]{35})');
    for (final match in apiKeyRegex.allMatches(text)) {
      final val = match.group(0)!;
      final hex = (random.nextInt(0xFFFFFF) + 0x100000).toRadixString(16).toUpperCase();
      result.add(VaultToken(
        id: "TKN-$hex",
        entityType: "API_KEY",
        originalValue: val,
        maskedToken: "<API_KEY_$hex>",
        confidence: 0.99,
        entropy: 5.82,
      ));
    }

    // IP Address
    final ipRegex = RegExp(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b');
    for (final match in ipRegex.allMatches(text)) {
      final val = match.group(0)!;
      final hex = (random.nextInt(0xFFFFFF) + 0x100000).toRadixString(16).toUpperCase();
      result.add(VaultToken(
        id: "TKN-$hex",
        entityType: "IP_ADDRESS",
        originalValue: val,
        maskedToken: "<IP_ADDRESS_$hex>",
        confidence: 0.97,
        entropy: 3.41,
      ));
    }

    // Email Address
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    for (final match in emailRegex.allMatches(text)) {
      final val = match.group(0)!;
      final hex = (random.nextInt(0xFFFFFF) + 0x100000).toRadixString(16).toUpperCase();
      result.add(VaultToken(
        id: "TKN-$hex",
        entityType: "EMAIL_ADDRESS",
        originalValue: val,
        maskedToken: "<EMAIL_ADDRESS_$hex>",
        confidence: 0.98,
        entropy: 4.15,
      ));
    }

    // Passwords / Connection Strings
    final dbPassRegex = RegExp(r'(postgres:\/\/[a-zA-Z0-9]+:)([a-zA-Z0-9!@#$%^&*]+)(@)');
    for (final match in dbPassRegex.allMatches(text)) {
      final val = match.group(2)!;
      final hex = (random.nextInt(0xFFFFFF) + 0x100000).toRadixString(16).toUpperCase();
      result.add(VaultToken(
        id: "TKN-$hex",
        entityType: "DB_CREDENTIALS",
        originalValue: val,
        maskedToken: "<DB_PASSWORD_$hex>",
        confidence: 0.99,
        entropy: 5.95,
      ));
    }

    if (result.isEmpty) {
      result.addAll([
        VaultToken(
          id: "TKN-A749E1",
          entityType: "API_KEY",
          originalValue: "sk_live_94f8b2c41890a8e7",
          maskedToken: "<API_KEY_A749E1>",
          confidence: 0.99,
          entropy: 5.64,
        ),
        VaultToken(
          id: "TKN-C301D8",
          entityType: "INTERNAL_HOST",
          originalValue: "10.240.1.84:5432",
          maskedToken: "<INTERNAL_HOST_C301D8>",
          confidence: 0.96,
          entropy: 3.82,
        ),
        VaultToken(
          id: "TKN-E994B2",
          entityType: "EMAIL_ADDRESS",
          originalValue: "lead.dev@enterprise-internal.org",
          maskedToken: "<EMAIL_ADDRESS_E994B2>",
          confidence: 0.98,
          entropy: 4.31,
        ),
      ]);
    }

    return result;
  }

  Future<List<AgentDeliverable>> _synthesizeDeliverables({
    required String rawRequirement,
    required String maskedRequirement,
    required String architecture,
    required String compliance,
    required String cloudTarget,
    required String llmModel,
  }) async {
    // 1. Try backend server synthesis endpoint
    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/api/agents/synthesize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requirement': rawRequirement,
          'maskedRequirement': maskedRequirement,
          'architecture': architecture,
          'compliance': compliance,
          'cloudTarget': cloudTarget,
          'llmModel': llmModel,
          'apiKey': customApiKey.value.trim().isNotEmpty ? customApiKey.value.trim() : null,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> dels = data['deliverables'] ?? [];
        if (dels.isNotEmpty) {
          final isCloud = data['usedCloudLlm'] == true;
          logTerminal(
            isCloud
                ? "Dispatched to Cloud LLM ($llmModel). Synthesis completed with live reasoning."
                : "Zero-Trust Autonomous Synthesizer generated domain-specific deliverables.",
            level: isCloud ? "CLOUD_LLM" : "AGENT_BA",
          );
          return dels.map((d) => AgentDeliverable(
            agentName: d['agentName'] ?? 'Agent',
            agentRole: d['agentRole'] ?? '',
            iconName: d['iconName'] ?? 'assignment',
            summary: d['summary'] ?? '',
            markdownContent: d['markdownContent'] ?? '',
            tags: List<String>.from(d['tags'] ?? []),
          )).toList();
        }
      }
    } catch (e) {
      logTerminal("Backend synthesis bridge notice: using client-side Zero-Trust synthesis engine ($e).", level: "LOCAL_ENGINE");
    }

    // 2. Resilient In-Browser Zero-Trust Synthesizer
    return _generateDynamicDeliverables(
      raw: rawRequirement,
      masked: maskedRequirement,
      architecture: architecture,
      compliance: compliance,
      cloudTarget: cloudTarget,
    );
  }

  List<AgentDeliverable> _generateDynamicDeliverables({
    required String raw,
    required String masked,
    required String architecture,
    String compliance = "SOC2 Type II & Zero-Trust NIST 800-207",
    String cloudTarget = "Microsoft Azure (Zero-Trust VPC)",
  }) {
    final lower = raw.toLowerCase();

    // Domain & Actor Extraction
    String domain = "Enterprise Cloud Subsystem";
    List<String> actors = ["Platform Engineer", "API Consumer", "Security Officer", "Auditor"];
    List<String> keywords = ["confidential computing", "mTLS 1.3", "least-privilege access"];

    if (lower.contains('patient') || lower.contains('hospital') || lower.contains('health') || lower.contains('ehr') || lower.contains('fhir') || lower.contains('hipaa')) {
      domain = "Digital Healthcare & Clinical Informatics";
      actors = ["Attending Physician", "Clinical Data Officer", "HIPAA Compliance Auditor", "EMR Integration Service"];
      keywords = ["ePHI confidentiality", "HL7 FHIR REST API", "immutable clinical audit", "patient consent verification"];
    } else if (lower.contains('payment') || lower.contains('stripe') || lower.contains('bank') || lower.contains('fintech') || lower.contains('transaction') || lower.contains('ledger') || lower.contains('kyc')) {
      domain = "Fintech & High-Assurance Financial Services";
      actors = ["Risk Officer", "Payment Settlement Engine", "PCI-DSS Auditor", "Merchant API Client"];
      keywords = ["zero-loss ledger", "idempotent transactions", "tokenized PAN/CVV", "anti-fraud AML verification"];
    } else if (lower.contains('iot') || lower.contains('vehicle') || lower.contains('telemetry') || lower.contains('fleet') || lower.contains('mqtt') || lower.contains('sensor')) {
      domain = "Edge IoT & High-Throughput Telemetry Logistics";
      actors = ["Edge Device Gateway", "Fleet Operations Manager", "Site Reliability Engineer", "Anomaly Detection Worker"];
      keywords = ["time-series compression", "sub-50ms ingestion", "mTLS hardware security", "out-of-order packet reassembly"];
    } else if (lower.contains('auth') || lower.contains('identity') || lower.contains('sso') || lower.contains('oauth') || lower.contains('saml') || lower.contains('jwt') || lower.contains('iam')) {
      domain = "Enterprise Identity & Zero-Trust Access Management";
      actors = ["Identity Provider (IdP)", "Directory Administrator", "Security Operations Center (SOC)", "Federated Client"];
      keywords = ["JIT credential issuance", "short-lived token lifetimes", "least-privilege RBAC/ABAC", "FIDO2 WebAuthn"];
    } else if (lower.contains('commerce') || lower.contains('order') || lower.contains('cart') || lower.contains('inventory') || lower.contains('catalog')) {
      domain = "Omnichannel Enterprise E-Commerce & Supply Chain";
      actors = ["Inventory Controller", "Order Processing Pipeline", "Fulfillment Partner Service", "Customer Experience Portal"];
      keywords = ["distributed ACID reservations", "eventual consistency sync", "real-time stock reconciliation", "PCI checkout"];
    }

    // Technology extraction
    String detectedDb = "PostgreSQL 16 (Encrypted at rest via AES-256)";
    final dbMatches = ["TimescaleDB", "PostgreSQL", "MongoDB", "Redis", "MySQL", "DynamoDB", "Cassandra", "Oracle"]
        .where((db) => lower.contains(db.toLowerCase()))
        .toList();
    if (dbMatches.isNotEmpty) {
      detectedDb = dbMatches.join(', ');
    }

    String detectedApi = "mTLS REST / OpenAPI 3.1 & gRPC Streams";
    final apiMatches = ["FHIR", "REST", "GraphQL", "gRPC", "WebSocket", "MQTT", "Kafka", "Webhook", "Stripe"]
        .where((api) => lower.contains(api.toLowerCase()))
        .toList();
    if (apiMatches.isNotEmpty) {
      detectedApi = apiMatches.join(', ');
    }

    // Summary snippet
    final cleanSnippet = raw.replaceAll(RegExp(r'[\n\r]+'), ' ').trim();
    final summaryTitle = cleanSnippet.length > 80 ? '${cleanSnippet.substring(0, 80)}...' : cleanSnippet;
    final wfId = "BRD-${Random().nextInt(900000) + 100000}";

    final brdMarkdown = """
# Business Requirements Document (BRD)
**Workflow Reference:** `$wfId`  
**System Classification:** ${domain.toUpperCase()} // RESTRICTED ZERO-TRUST  
**Compliance Standard:** $compliance  
**Target Infrastructure:** $cloudTarget  
**Architecture Pattern:** $architecture  

---

## 1. Executive Summary & Problem Statement
This Business Requirements Document defines the functional, architectural, and governance contract for:
> **Sanitized Requirement Context:**
> $masked

### 1.1 Business Problem
The enterprise requires a resilient, zero-trust implementation for:  
**"$summaryTitle"**  
Existing operational workflows must transition to strict zero-data-leakage pipelines where all credentials, connection strings, and identifiable tokens are scrubbed prior to any reasoning or downstream storage.

### 1.2 Target Scope
Deploy an isolated subsystem within **$cloudTarget**, interfacing with **$detectedDb**, and communicating securely over **$detectedApi** under **$compliance** controls.

---

## 2. In-Scope vs. Out-of-Scope Capabilities

| Boundary Category | In-Scope Deliverables | Out-of-Scope Constraints |
| :--- | :--- | :--- |
| **Ingestion Security** | Real-time Presidio tokenization, Redis Vault storage, and SHA-256 HMAC payload signatures. | Direct exposure of raw unredacted credentials to reasoning models. |
| **Core Workflow** | Autonomous multi-agent synthesis, contract generation for $detectedApi, and ACID persistence in $detectedDb. | Unauthenticated API endpoints bypassing mTLS boundaries. |
| **Data Governance** | Just-In-Time (JIT) ephemeral database leasing (< 30 min TTL) and immutable audit log chaining. | Hardcoded static database passwords in deployment artifacts. |
| **Regulatory Gate** | Human-in-the-Loop governance sign-off prior to code generation and container dispatch. | Automated production deploy bypass without designated officer approval. |

---

## 3. Target Objectives & Key Results (OKRs)

- **OKR-1 (Zero-Trust Security):** Maintain **0% credential/PII leakage** to external reasoning models by verifying 100% token substitution at the Presidio DLP Gateway.
- **OKR-2 (Performance SLA):** Achieve an end-to-end ingestion and processing latency of **P95 < 220ms** across all authenticated $detectedApi endpoints.
- **OKR-3 (Audit Non-Repudiation):** Record 100% of pipeline events in an append-only audit ledger with SHA-256 digests.
- **OKR-4 (Compliance Baseline):** Meet all technical controls for **$compliance** with zero critical/high CVEs in the generated SBOM.

---

## 4. Epics & Detailed User Stories

### Epic 1: Zero-Trust Gateway & Payload Sanitization
- **US-1.1 (Payload Interception):** As an **${actors[0]}**, all incoming requests for *"$summaryTitle"* must be stripped of secrets before reaching any internal execution logic.
- **US-1.2 (Surrogate Token Substitution):** As a **Security Officer**, surrogate tokens must be deterministically mapped in Redis Vault so that downstream agents reason on realistic structures without seeing plaintext secrets.

### Epic 2: Core Domain Logic & Data Persistence
- **US-2.1 (Domain Workflow Execution):** As a **${actors[1]}**, the subsystem must execute core transactions against **$detectedDb** with strict transaction isolation.
- **US-2.2 (Protocol Communication):** As an **${actors[2]}**, all service communication must occur over **$detectedApi** with TLS 1.3 encryption and automated retry policies.

### Epic 3: Governance & Regulatory Compliance
- **US-3.1 (Pre-Flight Gate):** As a **${actors[3]}**, changes cannot progress to code generation without interactive dual-signature human sign-off.
- **US-3.2 (Audit Trail):** As a **Security Auditor**, every tokenization, unmasking, and deployment signal must produce an immutable audit event.

---

## 5. Acceptance Criteria (Gherkin Scenarios)

```gherkin
Scenario: Successful Zero-Trust Ingestion and Execution
  Given a validated client request matching "$summaryTitle"
  And the request contains sensitive tokens or credentials
  When the payload is received by the Zero-Trust DLP Gateway
  Then all credentials must be substituted with surrogate tokens
  And an entry must be persisted in the Redis Token Vault
  And the workflow state must transition to "SYNTHESIS_COMPLETE"

Scenario: Ephemeral Database Transaction
  Given an approved workflow execution for "$wfId"
  When the activity worker interacts with "$detectedDb"
  Then it must acquire an ephemeral JIT credential with TTL <= 30 minutes
  And all queries must execute over TLS 1.3 encrypted sockets
```

---

## 6. Non-Functional Requirements (NFRs)

1. **Availability:** 99.99% service uptime backed by Temporal durable state execution.
2. **Confidentiality:** Mutual TLS (mTLS) with rotating X.509 certificates.
3. **Data Protection:** ${keywords.join(', ')}.
4. **Disaster Recovery:** RPO = 0 seconds; RTO < 60 seconds.
""";

    final archMarkdown = """
# System Architecture Specification
**Architecture Pattern:** $architecture  
**Target Infrastructure:** $cloudTarget  
**System Classification:** $domain Architecture Blueprint  

---

## 1. C4 Container Architecture Diagram
```mermaid
graph TD
    Client["Client / Web Gateway"] -->|mTLS 1.3| ZTGateway["Zero-Trust DLP Gateway (Presidio)"]
    ZTGateway -->|Store Tokens| RedisVault[("Redis Token Vault (In-Memory)")]
    ZTGateway -->|Sanitized Workflow| Temporal["Temporal Durable Orchestrator"]
    Temporal -->|Task Queue: sdlc-queue| WorkerPool["Activity Workers Pool"]
    WorkerPool -->|Masked Payload| ReasoningEngine["Reasoning / CodeGen Engine"]
    WorkerPool -->|JIT Unmasked Conn| TargetDB[("$detectedDb")]
    WorkerPool -->|Audit Signals| AuditLog[("Immutable Audit Ledger")]
```

---

## 2. API Contract Specification ($detectedApi)
```yaml
openapi: 3.1.0
info:
  title: Zero-Trust Subsystem API
  version: 1.0.0
  description: Auto-synthesized contract for $summaryTitle
paths:
  /api/v1/subsystem/execute:
    post:
      summary: Execute sanitized business transaction
      security:
        - OAuth2Bearer: []
        - MutualTLS: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                workflowId: { type: string }
                payloadDigest: { type: string }
      responses:
        '200':
          description: Successful execution under zero-trust controls
```

---

## 3. Data Storage & Schema Design ($detectedDb)
```sql
-- Enterprise ACID schema definition for $domain
CREATE TABLE IF NOT EXISTS subsystem_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id VARCHAR(64) NOT NULL,
    domain VARCHAR(128) NOT NULL,
    payload_hash CHAR(64) NOT NULL,
    execution_status VARCHAR(32) DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_subsystem_workflow ON subsystem_records(workflow_id);
```
""";

    final secMarkdown = """
# STRIDE Threat Model & Security Posture
**Risk Rating:** LOW (Residual Risk Mitigated)  
**Security Boundary:** $cloudTarget Zero-Trust Enclave  
**Compliance Standard:** $compliance  

---

## 1. STRIDE Threat Analysis

| Threat Category | Potential Attack Vector | Zero-Trust Mitigation Control | Status |
| :--- | :--- | :--- | :--- |
| **Spoofing** | Rogue caller attempting to execute against $detectedApi | Strict mTLS with hardware-backed X.509 client certs | **MITIGATED** |
| **Tampering** | In-transit payload corruption or parameter injection | SHA-256 HMAC payload verification and signed envelopes | **MITIGATED** |
| **Repudiation** | Actor denies initiating or approving workflow execution | Immutable audit ledger with dual-signature approval trail | **MITIGATED** |
| **Information Disclosure** | Plaintext credential leak from input to reasoning engine | Presidio DLP Gateway + Redis Vault tokenization | **ELIMINATED** |
| **Denial of Service** | Volumetric abuse on ingestion gateway | Distributed Redis token-bucket rate limiting (10,000 req/min) | **MITIGATED** |
| **Elevation of Privilege** | Compromised worker accessing $detectedDb directly | Just-In-Time (JIT) ephemeral credentials (TTL <= 30m) | **MITIGATED** |

---

## 2. OWASP Top 10 & Zero-Trust Defense Matrix
- **A01: Broken Access Control**: Enforced through RBAC with least-privilege principles.
- **A02: Cryptographic Failures**: All data encrypted in transit (TLS 1.3) and at rest (AES-256-GCM).
- **A03: Injection Attacks**: Strict parameterized queries and prepared statements on **$detectedDb**.
""";

    return [
      AgentDeliverable(
        agentName: "Business Analyst Agent",
        agentRole: "Requirements Engineering & User Story Extraction",
        iconName: "assignment",
        summary: "Dynamic 8-part BRD synthesized for: $summaryTitle",
        markdownContent: brdMarkdown,
        tags: ["BRD", "User Stories", domain, compliance],
      ),
      AgentDeliverable(
        agentName: "Solutions Architect Agent",
        agentRole: "C4 Architecture, Data Schemas & API Specifications",
        iconName: "architecture",
        summary: "C4 Container Model & $detectedDb schema specification for $architecture",
        markdownContent: archMarkdown,
        tags: ["C4 Architecture", detectedApi, detectedDb, architecture],
      ),
      AgentDeliverable(
        agentName: "CyberSec Ops Agent",
        agentRole: "STRIDE Threat Modeling & OWASP Mitigation Matrix",
        iconName: "security",
        summary: "STRIDE matrix & zero-trust threat model addressing $detectedDb & $compliance",
        markdownContent: secMarkdown,
        tags: ["STRIDE", "OWASP", compliance, "Zero-Trust"],
      ),
    ];
  }

  List<SbomItem> _generateSbom() {
    return [
      SbomItem(packageName: "@temporalio/workflow", version: "1.23.0", license: "MIT", vulnerabilitySeverity: "None"),
      SbomItem(packageName: "@temporalio/client", version: "1.23.0", license: "MIT", vulnerabilitySeverity: "None"),
      SbomItem(packageName: "presidio-analyzer", version: "2.2.354", license: "MIT", vulnerabilitySeverity: "None"),
      SbomItem(packageName: "presidio-anonymizer", version: "2.2.354", license: "MIT", vulnerabilitySeverity: "None"),
      SbomItem(packageName: "fastapi", version: "0.115.0", license: "MIT", vulnerabilitySeverity: "None"),
      SbomItem(packageName: "redis-py", version: "5.0.8", license: "MIT", vulnerabilitySeverity: "None"),
      SbomItem(packageName: "pg", version: "8.13.0", license: "MIT", vulnerabilitySeverity: "Low", cveId: "CVE-2025-1102", fixVersion: "8.13.1"),
      SbomItem(packageName: "axios", version: "1.7.7", license: "MIT", vulnerabilitySeverity: "None"),
    ];
  }

  void _initSampleWorkflow(ProjectWorkspace prj) {
    const raw = "Deploy a zero-trust payments gateway with Stripe API key sk_live_51N8e2A93jK198LmN04B2 and connect customer DB postgres://admin:SuperSecret99@10.0.4.12:5432/finance for user john.doe@enterprise.com with IP 192.168.1.104.";
    final tokens = _extractAndTokenize(raw);
    String masked = raw;
    for (var t in tokens) {
      masked = masked.replaceAll(t.originalValue, t.maskedToken);
    }

    final wf = WorkflowExecution(
      id: "ZTSDLC-884912",
      projectId: prj.id,
      projectName: prj.name,
      title: "Fintech Real-Time Transaction Engine with Zero-Trust Gateway",
      rawRequirement: raw,
      maskedRequirement: masked,
      complianceStandard: prj.complianceBaseline,
      architecturePattern: "Event-Driven Microservices",
      cloudTarget: "Microsoft Azure (Zero-Trust VPC)",
      llmModel: "Azure OpenAI GPT-4o (PitchPerfect Engine)",
      codeAccess: prj.codeAccess,
      dbAccess: prj.dbAccess,
      currentStage: SDLCStageType.approvalGate,
      status: "WAITING_APPROVAL",
      tokens: tokens,
      deliverables: _generateDynamicDeliverables(
        raw: raw,
        masked: masked,
        architecture: "Event-Driven Microservices",
        compliance: prj.complianceBaseline,
        cloudTarget: "Microsoft Azure (Zero-Trust VPC)",
      ),
      sbomItems: _generateSbom(),
      auditHistory: [
        AuditEvent(
          id: "AUD-100293",
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
          actor: "Principal Security Architect",
          role: "Security Officer",
          action: "REQUIREMENTS_INGEST_STT",
          stage: "Stage 1: Spec Studio",
          sha256Hash: "3f821a9c80d44b912e731054a88f729e248b8941785f839818e9d938b812b910",
        ),
        AuditEvent(
          id: "AUD-100294",
          timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
          actor: "Presidio Engine v2.2",
          role: "DLP Gateway",
          action: "VAULT_TOKENIZE_REDACT",
          stage: "Stage 2: Zero-Trust Vault",
          sha256Hash: "8d9102830f9a21b3840192e40184b93818e928d9381029e81920b9381829e102",
        ),
        AuditEvent(
          id: "AUD-100295",
          timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
          actor: "Temporal Worker (sdlc-queue)",
          role: "Agent Orchestrator",
          action: "MULTI_AGENT_SYNTHESIS",
          stage: "Stage 3: Agent Orchestration",
          sha256Hash: "7c182938190e2918384910293847581928374829102938475819283746581920",
        ),
      ],
    );

    activeWorkflow.value = wf;
    workflowHistory.add(wf);

    logTerminal("Zero-Trust SDLC Enterprise Portal initialized.", level: "SYSTEM");
    logTerminal("Connected to Temporal cluster at localhost:7233 (Task Queue: sdlc-queue)", level: "TEMPORAL");
    logTerminal("Active Project: [${prj.projectKey}] ${prj.name}", level: "PROJECT");
  }
}
