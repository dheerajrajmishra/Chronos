enum SDLCStageType {
  projectHub,
  stage0Setup,    // Feature setup
  stage1Brd,      // BRD
  stage2Design,   // Design Document
  stage3TechDoc,  // Technical Document
  stage4Code,     // Code
  stage5TestCaseCreation, // Test Case Creation
  stage6TestAutomation,   // Test Case Automation Script
  stage7TestingResult,    // Testing and Result
  stage8Deploy,   // Deployment
  settings,       // Global Settings & Prompt Configuration
  tenantAdmin,    // System Admin: Tenant Management
  userManagement, // Org Admin: User & Permission Management
}

enum EntityCategory {
  apiKey,
  ipAddress,
  creditCard,
  email,
  person,
  internalHost,
  dbPassword,
  jwtToken,
}

class CodeAccessConfig {
  final String provider; // GitHub, GitLab, Bitbucket, Azure DevOps
  final String repoUrl;
  final String defaultBranch;
  final String branchRule; // feature/*, main, release/*
  final String accessScope; // Read-Only (Audit), PR Scaffolding, Direct Commit
  final bool enforceSignedCommits;
  final bool preCommitSecretScan;

  CodeAccessConfig({
    this.provider = 'GitHub Enterprise',
    this.repoUrl = 'https://github.com/enterprise-org/payments-core.git',
    this.defaultBranch = 'main',
    this.branchRule = 'feature/zero-trust-*',
    this.accessScope = 'PR Scaffolding (Automated PR Creation)',
    this.enforceSignedCommits = true,
    this.preCommitSecretScan = true,
  });

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'repoUrl': repoUrl,
        'defaultBranch': defaultBranch,
        'branchRule': branchRule,
        'accessScope': accessScope,
        'enforceSignedCommits': enforceSignedCommits,
        'preCommitSecretScan': preCommitSecretScan,
      };
}

class DbAccessConfig {
  final String dbType; // PostgreSQL, Redis, MongoDB, Snowflake, MySQL
  final String host;
  final int port;
  final String databaseName;
  final String privilegeLevel; // Read-Only Query, Read-Write DML, DDL Migrations
  final int jitTtlMinutes; // 15 min, 60 min, 480 min
  final bool enableDynamicMasking;
  final bool isVaulted;

  DbAccessConfig({
    this.dbType = 'PostgreSQL (ACID Cluster)',
    this.host = '10.240.1.12',
    this.port = 5432,
    this.databaseName = 'fintech_core_db',
    this.privilegeLevel = 'Read-Write (Zero-Trust Tokenized)',
    this.jitTtlMinutes = 60,
    this.enableDynamicMasking = true,
    this.isVaulted = true,
  });

  Map<String, dynamic> toJson() => {
        'dbType': dbType,
        'host': host,
        'port': port,
        'databaseName': databaseName,
        'privilegeLevel': privilegeLevel,
        'jitTtlMinutes': jitTtlMinutes,
        'enableDynamicMasking': enableDynamicMasking,
        'isVaulted': isVaulted,
      };
}

class ProjectWorkspace {
  final String id;
  String name;
  String projectKey; // e.g. PRJ-PAY
  String description;
  String environment; // Dev Sandbox, Staging VPC, Production GovCloud
  String securityTier; // Tier 1 (Mission Critical), Tier 2 (Standard)
  String complianceBaseline; // SOC2, HIPAA, PCI-DSS
  CodeAccessConfig codeAccess;
  DbAccessConfig dbAccess;
  int activePipelinesCount;
  DateTime createdAt;

  ProjectWorkspace({
    required this.id,
    required this.name,
    required this.projectKey,
    required this.description,
    this.environment = 'Staging Enclave (PCI/SOC2)',
    this.securityTier = 'Tier 1 (Mission Critical)',
    this.complianceBaseline = 'SOC2 Type II + PCI-DSS 4.0',
    CodeAccessConfig? codeAccess,
    DbAccessConfig? dbAccess,
    this.activePipelinesCount = 1,
    DateTime? createdAt,
  })  : codeAccess = codeAccess ?? CodeAccessConfig(),
        dbAccess = dbAccess ?? DbAccessConfig(),
        createdAt = createdAt ?? DateTime.now();
}

class VaultToken {
  final String id;
  final String entityType;
  final String originalValue;
  final String maskedToken;
  final double confidence;
  final double entropy;
  bool isRevealed;
  final DateTime detectedAt;

  VaultToken({
    required this.id,
    required this.entityType,
    required this.originalValue,
    required this.maskedToken,
    this.confidence = 0.98,
    this.entropy = 4.75,
    this.isRevealed = false,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  factory VaultToken.fromJson(Map<String, dynamic> json) {
    return VaultToken(
      id: json['id'] ?? '',
      entityType: json['entityType'] ?? 'PII',
      originalValue: json['originalValue'] ?? '',
      maskedToken: json['maskedToken'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.98,
      entropy: (json['entropy'] as num?)?.toDouble() ?? 4.5,
      isRevealed: json['isRevealed'] ?? false,
      detectedAt: json['detectedAt'] != null ? DateTime.parse(json['detectedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType,
        'originalValue': originalValue,
        'maskedToken': maskedToken,
        'confidence': confidence,
        'entropy': entropy,
        'isRevealed': isRevealed,
        'detectedAt': detectedAt.toIso8601String(),
      };
}

class AgentDeliverable {
  final String agentName;
  final String agentRole;
  final String iconName;
  final String summary;
  final String markdownContent;
  final List<String> tags;

  AgentDeliverable({
    required this.agentName,
    required this.agentRole,
    required this.iconName,
    required this.summary,
    required this.markdownContent,
    this.tags = const [],
  });
}

class SbomItem {
  final String packageName;
  final String version;
  final String license;
  final String vulnerabilitySeverity; // None, Low, Medium, High, Critical
  final String? cveId;
  final String? fixVersion;

  SbomItem({
    required this.packageName,
    required this.version,
    required this.license,
    this.vulnerabilitySeverity = 'None',
    this.cveId,
    this.fixVersion,
  });
}

class AuditEvent {
  final String id;
  final DateTime timestamp;
  final String actor;
  final String role;
  final String action;
  final String stage;
  final String sha256Hash;
  final String status; // SUCCESS, WARNING, BLOCKED

  AuditEvent({
    required this.id,
    required this.timestamp,
    required this.actor,
    required this.role,
    required this.action,
    required this.stage,
    required this.sha256Hash,
    this.status = 'SUCCESS',
  });
}

class WorkflowExecution {
  final String id;
  String projectId;
  String projectName;
  String title;
  String rawRequirement;
  String maskedRequirement;
  String complianceStandard; // SOC2, HIPAA, PCI-DSS, GDPR, ISO27001
  String architecturePattern; // Microservices, Event-Driven, Serverless
  String cloudTarget; // Azure, AWS, GCP
  String llmModel; // Azure GPT-4o, Claude 3.5, Gemini 1.5 Pro
  CodeAccessConfig codeAccess;
  DbAccessConfig dbAccess;
  SDLCStageType currentStage;
  String status; // RUNNING, WAITING_APPROVAL, APPROVED, REJECTED, COMPLETED
  DateTime createdAt;
  bool isApproved;
  String? approvalComment;
  String? approvedBy;
  List<VaultToken> tokens;
  List<String> liveLogs;
  List<AgentDeliverable> deliverables;
  List<SbomItem> sbomItems;
  List<AuditEvent> auditHistory;

  WorkflowExecution({
    required this.id,
    this.projectId = 'PRJ-FINTECH',
    this.projectName = 'Fintech Core Payments Gateway',
    required this.title,
    required this.rawRequirement,
    this.maskedRequirement = '',
    this.complianceStandard = 'SOC2 Type II + HIPAA',
    this.architecturePattern = 'Event-Driven Microservices',
    this.cloudTarget = 'Microsoft Azure (Zero-Trust VPC)',
    this.llmModel = 'Azure OpenAI GPT-4o (PitchPerfect Engine)',
    CodeAccessConfig? codeAccess,
    DbAccessConfig? dbAccess,
    this.currentStage = SDLCStageType.stage1Brd,
    this.status = 'DRAFT',
    DateTime? createdAt,
    this.isApproved = false,
    this.approvalComment,
    this.approvedBy,
    List<VaultToken>? tokens,
    List<String>? liveLogs,
    List<AgentDeliverable>? deliverables,
    List<SbomItem>? sbomItems,
    List<AuditEvent>? auditHistory,
  })  : codeAccess = codeAccess ?? CodeAccessConfig(),
        dbAccess = dbAccess ?? DbAccessConfig(),
        createdAt = createdAt ?? DateTime.now(),
        tokens = tokens ?? [],
        liveLogs = liveLogs ?? [],
        deliverables = deliverables ?? [],
        sbomItems = sbomItems ?? [],
        auditHistory = auditHistory ?? [];
}

class CodeModuleInfo {
  final String name;
  final String directory;
  final int filesCount;
  final String tech;
  final List<String> keyFiles;

  CodeModuleInfo({
    required this.name,
    required this.directory,
    required this.filesCount,
    required this.tech,
    required this.keyFiles,
  });

  factory CodeModuleInfo.fromJson(Map<String, dynamic> json) {
    return CodeModuleInfo(
      name: json['name'] ?? '',
      directory: json['directory'] ?? '',
      filesCount: json['filesCount'] ?? 0,
      tech: json['tech'] ?? '',
      keyFiles: List<String>.from(json['keyFiles'] ?? []),
    );
  }
}

class CodebaseGraph {
  final String projectId;
  final String repoPath;
  final String repoUrl;
  final String branch;
  final DateTime lastSyncedAt;
  final int filesCount;
  final int totalSizeBytes;
  final List<String> techStack;
  final List<CodeModuleInfo> modules;
  final String graphDigest;
  final bool isFromCache;
  final String summaryMarkdown;

  CodebaseGraph({
    required this.projectId,
    required this.repoPath,
    required this.repoUrl,
    required this.branch,
    required this.lastSyncedAt,
    required this.filesCount,
    required this.totalSizeBytes,
    required this.techStack,
    required this.modules,
    required this.graphDigest,
    required this.isFromCache,
    required this.summaryMarkdown,
  });

  factory CodebaseGraph.fromJson(Map<String, dynamic> json) {
    return CodebaseGraph(
      projectId: json['projectId'] ?? '',
      repoPath: json['repoPath'] ?? '',
      repoUrl: json['repoUrl'] ?? '',
      branch: json['branch'] ?? 'main',
      lastSyncedAt: DateTime.tryParse(json['lastSyncedAt'] ?? '') ?? DateTime.now(),
      filesCount: json['filesCount'] ?? 0,
      totalSizeBytes: json['totalSizeBytes'] ?? 0,
      techStack: List<String>.from(json['techStack'] ?? []),
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((m) => CodeModuleInfo.fromJson(m as Map<String, dynamic>))
          .toList(),
      graphDigest: json['graphDigest'] ?? '',
      isFromCache: json['isFromCache'] ?? false,
      summaryMarkdown: json['summaryMarkdown'] ?? '',
    );
  }
}
