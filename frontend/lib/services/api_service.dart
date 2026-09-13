import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/sdlc_models.dart';
import '../models/tenant_model.dart';
import '../controllers/auth_controller.dart';


class ApiService {
  static const String baseUrl = 'http://localhost:4000/api';

  static Map<String, String> _getHeaders() {
    final token = Get.isRegistered<AuthController>() ? Get.find<AuthController>().token.value : '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─── LLM CONFIG ──────────────────────────────────────

  static Future<Map<String, dynamic>> getLlmConfig() async {
    final response = await http.get(Uri.parse('$baseUrl/settings/llm-config'), headers: _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  static Future<bool> saveLlmConfig(Map<String, dynamic> config) async {
    final response = await http.post(
      Uri.parse('$baseUrl/settings/llm-config'),
      headers: _getHeaders(),
      body: jsonEncode(config),
    );
    return response.statusCode == 200;
  }

  // ─── PROJECTS ──────────────────────────────────────

  static Future<List<Project>> getProjects() async {
    final response = await http.get(Uri.parse('$baseUrl/projects'), headers: _getHeaders());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Project.fromJson(json)).toList();
    }
    throw Exception('Failed to load projects');
  }
  static Future<Project> createProject(String name, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: _getHeaders(),
      body: jsonEncode({'name': name, 'description': description}),
    );
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to create project');
  }

  static Future<Project> updateProject(int id, String name, String description) async {
    final response = await http.put(
      Uri.parse('$baseUrl/projects/$id'),
      headers: _getHeaders(),
      body: jsonEncode({'name': name, 'description': description}),
    );
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update project');
  }

  static Future<bool> deleteProject(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$id'),
      headers: _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // ─── FEATURES ──────────────────────────────────────

  static Future<List<Feature>> getFeatures(int projectId) async {
    final response = await http.get(Uri.parse('$baseUrl/projects/$projectId/features'), headers: _getHeaders());
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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

  static Future<void> deleteFeature(int featureId) async {
    final response = await http.delete(Uri.parse('$baseUrl/features/$featureId'), headers: _getHeaders());
    if (response.statusCode != 200) {
      throw Exception('Failed to delete feature');
    }
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
      headers: _getHeaders(),
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

  // ─── WORKFLOWS ──────────────────────────────────────

  static Future<WorkflowState> getWorkflowState(int featureId) async {
    final response = await http.get(Uri.parse('$baseUrl/features/$featureId/workflow'), headers: _getHeaders());
    if (response.statusCode == 200) {
      return WorkflowState.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load workflow state');
  }

  static Future<WorkflowState> updateWorkflowStage(
      int featureId, int currentStage, String status, Map<String, dynamic> stageData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/features/$featureId/workflow'),
      headers: _getHeaders(),
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

  // ─── REPOSITORY ──────────────────────────────────────

  static Future<Map<String, dynamic>> applyCodeToBranch(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/repository/apply-code'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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

  // ─── SETTINGS ──────────────────────────────────────

  static Future<Map<String, dynamic>> getGlobalSettings() async {
    final response = await http.get(Uri.parse('$baseUrl/settings'), headers: _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load global settings: ${response.statusCode}');
  }

  static Future<bool> saveGlobalSettings({Map<String, dynamic>? theme, Map<String, dynamic>? defaultPrompts}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/settings'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to reset default prompts: ${response.statusCode}');
  }

  // ═══════════════════════════════════════════════════════
  // ─── TENANT ADMIN API (System Admin only) ────────────
  // ═══════════════════════════════════════════════════════

  static Future<List<Tenant>> getTenants() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/tenants'), headers: _getHeaders());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Tenant.fromJson(json)).toList();
    }
    throw Exception('Failed to load tenants: ${response.statusCode}');
  }

  static Future<Tenant> createTenant({
    required String name,
    String? slug,
    String plan = 'free',
    int maxUsers = 10,
    String? adminEmail,
    String? adminPassword,
    String? adminName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/tenants'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        if (slug != null) 'slug': slug,
        'plan': plan,
        'max_users': maxUsers,
        if (adminEmail != null) 'admin_email': adminEmail,
        if (adminPassword != null) 'admin_password': adminPassword,
        if (adminName != null) 'admin_name': adminName,
      }),
    );
    if (response.statusCode == 200) {
      return Tenant.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create tenant: ${response.body}');
  }

  static Future<Tenant> updateTenant(int id, {
    String? name,
    String? slug,
    String? status,
    String? plan,
    int? maxUsers,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/tenants/$id'),
      headers: _getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (slug != null) 'slug': slug,
        if (status != null) 'status': status,
        if (plan != null) 'plan': plan,
        if (maxUsers != null) 'max_users': maxUsers,
      }),
    );
    if (response.statusCode == 200) {
      return Tenant.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update tenant: ${response.statusCode}');
  }

  static Future<bool> suspendTenant(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/tenants/$id'),
      headers: _getHeaders(),
    );
    return response.statusCode == 200;
  }

  static Future<List<TenantUser>> getTenantUsers(int tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/tenants/$tenantId/users'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => TenantUser.fromJson(json)).toList();
    }
    throw Exception('Failed to load tenant users: ${response.statusCode}');
  }

  static Future<bool> addTenantUser(int tenantId, {
    required String email,
    String? password,
    String? name,
    String role = 'viewer',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/tenants/$tenantId/users'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        if (password != null) 'password': password,
        if (name != null) 'name': name,
        'role': role,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> removeTenantUser(int tenantId, int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/tenants/$tenantId/users/$userId'),
      headers: _getHeaders(),
    );
    return response.statusCode == 200;
  }

  static Future<AdminStats> getAdminStats() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/stats'), headers: _getHeaders());
    if (response.statusCode == 200) {
      return AdminStats.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load admin stats: ${response.statusCode}');
  }

  // ═══════════════════════════════════════════════════════
  // ─── USER MANAGEMENT API (Org Admin within tenant) ───
  // ═══════════════════════════════════════════════════════

  static Future<List<TenantUser>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/saas/users'), headers: _getHeaders());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => TenantUser.fromJson(json)).toList();
    }
    throw Exception('Failed to load users: ${response.statusCode}');
  }

  static Future<bool> createUser({
    required String email,
    required String password,
    String? name,
    String role = 'viewer',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saas/users'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        if (name != null) 'name': name,
        'role': role,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateUserRole(int userId, String role, {String? name}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/saas/users/$userId'),
      headers: _getHeaders(),
      body: jsonEncode({
        'role': role,
        if (name != null) 'name': name,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateUserPermissions(int userId, Map<String, dynamic> permissions) async {
    final response = await http.put(
      Uri.parse('$baseUrl/saas/users/$userId/permissions'),
      headers: _getHeaders(),
      body: jsonEncode({'permissions': permissions}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateUserStatus(int userId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/saas/users/$userId/status'),
      headers: _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> removeUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/saas/users/$userId'),
      headers: _getHeaders(),
    );
    return response.statusCode == 200;
  }

  static Future<List<RoleDefinition>> getRoles() async {
    final response = await http.get(Uri.parse('$baseUrl/saas/roles'), headers: _getHeaders());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => RoleDefinition.fromJson(json)).toList();
    }
    throw Exception('Failed to load roles: ${response.statusCode}');
  }
}
