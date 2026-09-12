import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/workflow_model.dart';

class EnterpriseSDLCController extends GetxController {
  // Navigation & Role State
  final Rx<SDLCStageType> currentStage = SDLCStageType.projectHub.obs;
  final RxString userRole = 'Principal Security Architect'.obs;
  final RxString environment = 'Zero-Trust Secure Enclave (PCI/SOC2)'.obs;
  final RxBool isSidebarCollapsed = false.obs;

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
    logTerminal("Agent [Business Analyst] generated BRD with target schema constraints.", level: "AGENT_BA");
    logTerminal("Agent [Solutions Architect] generated C4 models for repo: ${codeAccess.repoUrl}.", level: "AGENT_ARCH");
    logTerminal("Agent [CyberSec Ops] verified STRIDE controls for ${dbAccess.dbType} on ${dbAccess.host}.", level: "AGENT_SEC");

    newWf.deliverables = _generateSampleDeliverables(rawRequirement, masked, architecture);
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

  List<AgentDeliverable> _generateSampleDeliverables(String raw, String masked, String pattern) {
    return [
      AgentDeliverable(
        agentName: "Business Analyst Agent",
        agentRole: "Requirement Synthesis & User Story Extraction",
        iconName: "assignment",
        summary: "Detailed 8-part BRD with acceptance criteria, non-functional requirements, and user journeys.",
        markdownContent: """
# Business Requirements Document (BRD)
**Workflow Reference:** `BRD-ZERO-TRUST-2026-v2`  
**Classification:** RESTRICTED // ZERO-TRUST COMPLIANT  

## 1. Executive Summary
This document specifies the enterprise functional requirements for the requested subsystem:
> **Sanitized Requirement Context:**
> $masked

## 2. Target Objectives & Key Results (OKRs)
- **Zero-Data Leakage:** Enforce 100% cryptographic tokenization on all incoming credentials and PII prior to multi-model LLM invocation.
- **Latency Budget:** P99 end-to-end response time under 180ms across all authenticated endpoints.
- **Compliance Certification:** Full compliance with SOC2 Type II, HIPAA Security Rule, and PCI-DSS 4.0.

## 3. Epics & User Stories
### Epic 1: Secure Credential & PII Vaulting
- **US-1.1:** As an API consumer, all inbound requests containing secrets must be stripped and substituted with cryptographically secure tokens before reaching upstream reasoning models.
- **US-1.2:** As a Security Auditor, all unmasking operations must leave an immutable, non-repudiable audit trace with actor ID and SHA-256 payload digest.
""",
        tags: ["BRD", "User Stories", "Acceptance Criteria", "OKRs"],
      ),
      AgentDeliverable(
        agentName: "Solutions Architect Agent",
        agentRole: "C4 Architecture, Data Schemas & API Specifications",
        iconName: "architecture",
        summary: "C4 container architecture, OpenAPI 3.1 specification, and PostgreSQL ACID schema definitions.",
        markdownContent: """
# System Architecture Specification
**Pattern:** $pattern  
**Target Infrastructure:** Zero-Trust VPC Enclave  

## 1. C4 Container Architecture
```mermaid
graph LR
    Client["Client / Portal Web"] --> Gateway["Zero-Trust Gateway (FastAPI)"]
    Gateway --> Vault[("Redis Token Vault")]
    Gateway --> Temporal["Temporal Orchestrator"]
    Temporal --> Worker["Worker Activities (Node/Go)"]
    Worker --> LLM["Azure OpenAI GPT-4o (Masked)"]
    Worker --> DB[("PostgreSQL DB (Unmasked)")]
```

## 2. API Contract Specification (OpenAPI 3.1)
```yaml
openapi: 3.1.0
info:
  title: Zero-Trust SDLC Gateway API
  version: 2.4.0
paths:
  /v1/vault/mask:
    post:
      summary: Tokenize payload into Redis Vault
```
""",
        tags: ["C4 Model", "OpenAPI 3.1", "Schema", "PostgreSQL"],
      ),
      AgentDeliverable(
        agentName: "CyberSec Ops Agent",
        agentRole: "STRIDE Threat Modeling & OWASP Mitigation Matrix",
        iconName: "security",
        summary: "STRIDE matrix, automated attack surface analysis, and Zero-Trust defense-in-depth controls.",
        markdownContent: """
# STRIDE Threat Model & Security Posture
**Risk Rating:** LOW (Residual Risk Managed)  
**Security Boundary:** Air-Gapped Zero-Trust Enclave  

## 1. STRIDE Analysis
| Threat Category | Potential Vector | Zero-Trust Mitigation Control | Status |
| :--- | :--- | :--- | :--- |
| **Spoofing** | Rogue caller impersonating Temporal Worker | mTLS with automated rotating X.509 certs | **MITIGATED** |
| **Tampering** | In-transit payload manipulation | SHA-256 HMAC digest verification | **MITIGATED** |
| **Repudiation** | Denying approval action at gate | Dual-signature immutable audit log | **MITIGATED** |
| **Info Disclosure** | Raw API keys sent to LLM provider | Presidio regex + NER tokenization vault | **ELIMINATED** |
""",
        tags: ["STRIDE", "OWASP", "mTLS", "Defense-in-Depth"],
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
      deliverables: _generateSampleDeliverables(raw, masked, "Event-Driven Microservices"),
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
