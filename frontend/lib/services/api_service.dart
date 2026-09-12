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
      }),
    );
    if (response.statusCode == 200) {
      return Feature.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update feature');
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
}
