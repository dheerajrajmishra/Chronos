import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tenant_model.dart';
import 'enterprise_sdlc_controller.dart';

class AuthController extends GetxController {
  final RxBool isAuthenticated = false.obs;
  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;
  final RxString token = ''.obs;
  final RxList<TenantInfo> availableTenants = <TenantInfo>[].obs;

  final String baseUrl = 'http://localhost:4000/api';

  // Computed properties for role checks
  bool get isSystemAdmin => currentUser['is_system_admin'] == true;
  bool get isOrgAdmin => currentUser['role'] == 'org_admin' || isSystemAdmin;
  String get currentRole => currentUser['role'] ?? 'viewer';
  int get currentTenantId => currentUser['tenant_id'] ?? 1;
  String get currentTenantName => currentUser['tenant_name'] ?? 'Unknown';
  String get currentTenantSlug {
    final tenant = availableTenants.firstWhereOrNull((t) => t.tenantId == currentTenantId);
    return tenant?.tenantSlug.isNotEmpty == true ? tenant!.tenantSlug : 'portal';
  }
  String get currentUserName => currentUser['name'] ?? currentUser['email'] ?? 'User';
  Map<String, dynamic> get currentPermissions => 
    currentUser['permissions'] is Map ? Map<String, dynamic>.from(currentUser['permissions']) : {};
  
  bool hasPermission(String permission) {
    if (isSystemAdmin) return true;
    final perms = currentPermissions;
    return perms[permission] == true;
  }

  @override
  void onInit() {
    super.onInit();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final storedUser = prefs.getString('auth_user');
    final storedTenants = prefs.getString('auth_tenants');

    if (storedToken != null && storedToken.isNotEmpty && storedUser != null) {
      token.value = storedToken;
      currentUser.value = jsonDecode(storedUser);
      isAuthenticated.value = true;

      if (storedTenants != null) {
        final List tenantList = jsonDecode(storedTenants);
        availableTenants.value = tenantList.map((t) => TenantInfo.fromJson(t)).toList();
      }

      if (Get.isRegistered<EnterpriseSDLCController>()) {
        Get.find<EnterpriseSDLCController>().fetchProjects();
      }
    }
  }

  Future<bool> login(String email, String password, [String orgId = '']) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'password': password,
          if (orgId.isNotEmpty) 'orgId': orgId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthState(data);
        return true;
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthState(data);
        return true;
      }
    } catch (e) {
      print('Register Error: $e');
    }
    return false;
  }

  Future<bool> switchTenant(int tenantId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/switch-tenant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.value}',
        },
        body: jsonEncode({'tenant_id': tenantId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthState(data);
        
        // Reload projects for new tenant context
        if (Get.isRegistered<EnterpriseSDLCController>()) {
          final sdlcCtrl = Get.find<EnterpriseSDLCController>();
          sdlcCtrl.clearSession();
          await sdlcCtrl.fetchProjects();
        }
        return true;
      }
    } catch (e) {
      print('Switch Tenant Error: $e');
    }
    return false;
  }

  Future<void> _saveAuthState(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('auth_token', data['token']);
    await prefs.setString('auth_user', jsonEncode(data['user']));
    
    token.value = data['token'];
    currentUser.value = Map<String, dynamic>.from(data['user']);
    isAuthenticated.value = true;

    if (data['tenants'] != null) {
      final List tenantList = data['tenants'];
      availableTenants.value = tenantList.map((t) => TenantInfo.fromJson(t)).toList();
      await prefs.setString('auth_tenants', jsonEncode(data['tenants']));
    }
  }

  Future<void> logout() async {
    if (Get.isRegistered<EnterpriseSDLCController>()) {
      Get.find<EnterpriseSDLCController>().clearSession();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    await prefs.remove('auth_tenants');
    
    token.value = '';
    currentUser.clear();
    availableTenants.clear();
    isAuthenticated.value = false;
    
    Get.offAllNamed('/login');
  }
}
