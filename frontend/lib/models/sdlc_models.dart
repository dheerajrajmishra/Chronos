class Project {
  final int id;
  final String name;
  final String description;

  Project({required this.id, required this.name, required this.description});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
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

  Feature({
    required this.id,
    required this.projectId,
    required this.name,
    required this.codeAccess,
    required this.dbAccess,
    required this.baseRequirement,
    required this.brdPrompt,
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
