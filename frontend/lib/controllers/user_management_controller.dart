import 'package:get/get.dart';
import '../models/tenant_model.dart';
import '../services/api_service.dart';

/// Controller for org-admin-level user management within the current tenant
class UserManagementController extends GetxController {
  final RxList<TenantUser> users = <TenantUser>[].obs;
  final RxList<RoleDefinition> roles = <RoleDefinition>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  List<TenantUser> get filteredUsers {
    if (searchQuery.value.isEmpty) return users;
    final q = searchQuery.value.toLowerCase();
    return users.where((u) =>
      u.email.toLowerCase().contains(q) ||
      u.name.toLowerCase().contains(q) ||
      u.role.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      users.value = await ApiService.getUsers();
    } catch (e) {
      print('Failed to load users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRoles() async {
    try {
      roles.value = await ApiService.getRoles();
    } catch (e) {
      print('Failed to load roles: $e');
    }
  }

  Future<bool> createUser({
    required String email,
    required String password,
    String? name,
    String role = 'viewer',
  }) async {
    try {
      final success = await ApiService.createUser(
        email: email, password: password, name: name, role: role,
      );
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to create user: $e');
      return false;
    }
  }

  Future<bool> updateUserRole(int userId, String role, {String? name}) async {
    try {
      final success = await ApiService.updateUserRole(userId, role, name: name);
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to update user role: $e');
      return false;
    }
  }

  Future<bool> updateUserPermissions(int userId, Map<String, dynamic> permissions) async {
    try {
      final success = await ApiService.updateUserPermissions(userId, permissions);
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to update permissions: $e');
      return false;
    }
  }

  Future<bool> toggleUserStatus(int userId, bool activate) async {
    try {
      final success = await ApiService.updateUserStatus(userId, activate ? 'active' : 'inactive');
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to toggle user status: $e');
      return false;
    }
  }

  Future<bool> removeUser(int userId) async {
    try {
      final success = await ApiService.removeUser(userId);
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to remove user: $e');
      return false;
    }
  }
}
