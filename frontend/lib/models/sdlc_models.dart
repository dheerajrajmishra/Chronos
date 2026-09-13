class Project {
  final int id;
  final String name;
  final String description;
  final String? userRole;

  Project({required this.id, required this.name, required this.description, this.userRole});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      userRole: json['user_role'],
    );
  }
}

class ProjectUser {
  final int userId;
  final String email;
  final String name;
  final String role;

  ProjectUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  factory ProjectUser.fromJson(Map<String, dynamic> json) {
    return ProjectUser(
      userId: json['user_id'] is int ? json['user_id'] : (int.tryParse(json['user_id']?.toString() ?? '0') ?? 0),
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'viewer',
    );
  }
}

class Feature {
  final int id;
  final int projectId;
  final String name;
  final Map<String, dynamic> codeAccess;
  final Map<String, dynamic> dbAccess;
  final String baseRequirement;
  final String brdPrompt;
  final String designPrompt;
  final String codePrompt;
  final String testPrompt;
  final String techDocPrompt;
  final String unitTestPrompt;
  final String uatPrompt;
  final String deployPrompt;
  final String testCaseCreationPrompt;
  final String testAutomationPrompt;
  final String testingResultPrompt;
  final String memoryPrompt;
  final Map<String, dynamic> stagePrompts;
  final String memoryMd;

  Feature({
    required this.id,
    required this.projectId,
    required this.name,
    required this.codeAccess,
    required this.dbAccess,
    required this.baseRequirement,
    required this.brdPrompt,
    required this.designPrompt,
    required this.codePrompt,
    required this.testPrompt,
    this.techDocPrompt = '',
    this.unitTestPrompt = '',
    this.uatPrompt = '',
    this.deployPrompt = '',
    this.testCaseCreationPrompt = '',
    this.testAutomationPrompt = '',
    this.testingResultPrompt = '',
    this.memoryPrompt = '',
    this.stagePrompts = const {},
    required this.memoryMd,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      projectId: json['project_id'],
      name: json['name'],
      codeAccess: json['code_access'] ?? {},
      dbAccess: json['db_access'] ?? {},
      baseRequirement: json['base_requirement'] ?? '',
      brdPrompt: json['brd_prompt'] ?? '',
      designPrompt: json['design_prompt'] ?? '',
      codePrompt: json['code_prompt'] ?? '',
      testPrompt: json['test_prompt'] ?? '',
      techDocPrompt: json['tech_doc_prompt'] ?? '',
      unitTestPrompt: json['unit_test_prompt'] ?? '',
      uatPrompt: json['uat_prompt'] ?? '',
      deployPrompt: json['deploy_prompt'] ?? '',
      testCaseCreationPrompt: json['test_case_creation_prompt'] ?? '',
      testAutomationPrompt: json['test_automation_prompt'] ?? '',
      testingResultPrompt: json['testing_result_prompt'] ?? '',
      memoryPrompt: json['memory_prompt'] ?? json['stage_prompts']?['memoryPrompt'] ?? '',
      stagePrompts: json['stage_prompts'] is Map ? Map<String, dynamic>.from(json['stage_prompts']) : {},
      memoryMd: json['memory_md'] ?? '',
    );
  }
}

class WorkflowState {
  final int id;
  final int featureId;
  final int currentStage;
  final String status;
  final Map<String, dynamic> stageData;

  WorkflowState({
    required this.id,
    required this.featureId,
    required this.currentStage,
    required this.status,
    required this.stageData,
  });

  factory WorkflowState.fromJson(Map<String, dynamic> json) {
    return WorkflowState(
      id: json['id'],
      featureId: json['feature_id'],
      currentStage: json['current_stage'],
      status: json['status'],
      stageData: json['stage_data'] ?? {},
    );
  }
}
