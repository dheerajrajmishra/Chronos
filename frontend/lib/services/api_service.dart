import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sdlc_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:4000/api';

  static Future<List<Project>> getProjects() async {
    final response = await http.get(Uri.parse('$baseUrl/projects'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Project.fromJson(json)).toList();
    }
    throw Exception('Failed to load projects');
  }

  static Future<Project> createProject(String name, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'description': description}),
    );
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create project');
  }

  static Future<List<Feature>> getFeatures(int projectId) async {
    final response = await http.get(Uri.parse('$baseUrl/projects/$projectId/features'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Feature.fromJson(json)).toList();
    }
    throw Exception('Failed to load features');
  }

  static Future<Feature> createFeature({
    required int projectId,
    required String name,
    required Map<String, dynamic> codeAccess,
    required Map<String, dynamic> dbAccess,
    required String baseRequirement,
    required String brdPrompt,
    required String designPrompt,
    required String codePrompt,
    required String testPrompt,
    required String memoryMd,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects/$projectId/features'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'code_access': codeAccess,
        'db_access': dbAccess,
        'base_requirement': baseRequirement,
        'brd_prompt': brdPrompt,
        'design_prompt': designPrompt,
        'code_prompt': codePrompt,
        'test_prompt': testPrompt,
        'memory_md': memoryMd,
      }),
    );
    if (response.statusCode == 200) {
      return Feature.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create feature');
  }

  static Future<Feature> updateFeature(int featureId, {
    required String name,
    required Map<String, dynamic> codeAccess,
    required Map<String, dynamic> dbAccess,
    required String baseRequirement,
    required String brdPrompt,
    required String designPrompt,
    required String codePrompt,
    required String testPrompt,
    required String memoryMd,
    String? memoryPrompt,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/features/$featureId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'code_access': codeAccess,
        'db_access': dbAccess,
        'base_requirement': baseRequirement,
        'brd_prompt': brdPrompt,
        'design_prompt': designPrompt,
        'code_prompt': codePrompt,
        'test_prompt': testPrompt,
        'memory_md': memoryMd,
        if (memoryPrompt != null) 'memory_prompt': memoryPrompt,
      }),
    );
    if (response.statusCode == 200) {
      return Feature.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update feature');
  }

  static Future<Feature> updateFeaturePrompts(
    int featureId, {
    String? brdPrompt,
    String? designPrompt,
    String? techDocPrompt,
    String? codePrompt,
    String? testCaseCreationPrompt,
    String? testAutomationPrompt,
    String? testingResultPrompt,
    String? deployPrompt,
    String? memoryPrompt,
    Map<String, dynamic>? stagePrompts,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/features/$featureId/prompts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (brdPrompt != null) 'brd_prompt': brdPrompt,
        if (designPrompt != null) 'design_prompt': designPrompt,
        if (techDocPrompt != null) 'tech_doc_prompt': techDocPrompt,
        if (codePrompt != null) 'code_prompt': codePrompt,
        if (testCaseCreationPrompt != null) 'test_case_creation_prompt': testCaseCreationPrompt,
        if (testAutomationPrompt != null) 'test_automation_prompt': testAutomationPrompt,
        if (testingResultPrompt != null) 'testing_result_prompt': testingResultPrompt,
        if (deployPrompt != null) 'deploy_prompt': deployPrompt,
        if (memoryPrompt != null) 'memory_prompt': memoryPrompt,
        if (stagePrompts != null) 'stage_prompts': stagePrompts,
      }),
    );
    if (response.statusCode == 200) {
      return Feature.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update feature prompts: ${response.statusCode}');
  }

  static Future<WorkflowState> getWorkflowState(int featureId) async {
    final response = await http.get(Uri.parse('$baseUrl/features/$featureId/workflow'));
    if (response.statusCode == 200) {
      return WorkflowState.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load workflow state');
  }

  static Future<WorkflowState> updateWorkflowStage(
      int featureId, int currentStage, String status, Map<String, dynamic> stageData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/features/$featureId/workflow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'current_stage': currentStage,
        'status': status,
        'stage_data': stageData,
      }),
    );
    if (response.statusCode == 200) {
      return WorkflowState.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update workflow state');
  }

  static Future<Map<String, dynamic>> applyCodeToBranch(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/repository/apply-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to apply code to branch: ${response.statusCode} - ${response.body}');
  }

  static Future<Map<String, dynamic>> generateDeliverables(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/agents/synthesize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to generate deliverables: ${response.body}');
  }

  static Future<Map<String, dynamic>> generateMemory(
    String projectId,
    String repoUrl,
    String branch, {
    String? memoryPrompt,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/repository/generate-memory'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'projectId': projectId,
        'repoUrl': repoUrl,
        'branch': branch,
        if (memoryPrompt != null && memoryPrompt.isNotEmpty) 'memoryPrompt': memoryPrompt,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to generate repository memory: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getGlobalSettings() async {
    final response = await http.get(Uri.parse('$baseUrl/settings'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load global settings: ${response.statusCode}');
  }

  static Future<bool> saveGlobalSettings({Map<String, dynamic>? theme, Map<String, dynamic>? defaultPrompts}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/settings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (theme != null) 'theme': theme,
        if (defaultPrompts != null) 'defaultPrompts': defaultPrompts,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> resetDefaultPrompts() async {
    final response = await http.post(
      Uri.parse('$baseUrl/settings/reset-prompts'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to reset default prompts: ${response.statusCode}');
  }
}
