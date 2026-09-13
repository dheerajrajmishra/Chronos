import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'enterprise_sdlc_controller.dart';

class AuthController extends GetxController {
  final RxBool isAuthenticated = false.obs;
  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;
  final RxString token = ''.obs;

  final String baseUrl = 'http://localhost:4000/api'; // Or env variable

  @override
  void onInit() {
    super.onInit();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final storedUser = prefs.getString('auth_user');

    if (storedToken != null && storedToken.isNotEmpty && storedUser != null) {
      token.value = storedToken;
      currentUser.value = jsonDecode(storedUser);
      isAuthenticated.value = true;
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
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('auth_user', jsonEncode(data['user']));
        
        token.value = data['token'];
        currentUser.value = data['user'];
        isAuthenticated.value = true;
        
        return true;
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    
    token.value = '';
    currentUser.clear();
    isAuthenticated.value = false;
    
    Get.offAllNamed('/login');
  }
}
