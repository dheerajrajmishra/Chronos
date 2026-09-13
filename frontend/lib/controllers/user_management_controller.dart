import 'package:get/get.dart';
import '../models/tenant_model.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

/// Controller for org-admin-level user management within the current tenant
class UserManagementController extends GetxController {
  final RxList<TenantUser> users = <TenantUser>[].obs;
  final RxList<RoleDefinition> roles = <RoleDefinition>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final RxList<Tenant> tenants = <Tenant>[].obs;
  final Rx<int?> selectedTenantId = Rx<int?>(null);

  @override
  void onInit() {
    super.onInit();
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.isSystemAdmin) {
      loadTenants();
    }
  }

  List<TenantUser> get filteredUsers {
    if (searchQuery.value.isEmpty) return users;
    final q = searchQuery.value.toLowerCase();
    return users.where((u) =>
      u.email.toLowerCase().contains(q) ||
      u.name.toLowerCase().contains(q) ||
      u.role.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> loadTenants() async {
    try {
      final fetchedTenants = await ApiService.getTenants();
      if (selectedTenantId.value == null) {
        final authCtrl = Get.find<AuthController>();
        selectedTenantId.value = authCtrl.currentTenantId;
      }
      tenants.value = fetchedTenants;
    } catch (e) {
      print('Failed to load tenants: $e');
    }
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final authCtrl = Get.find<AuthController>();
      
      if (authCtrl.isSystemAdmin && tenants.isEmpty) {
        await loadTenants();
      }

      final targetTenantId = selectedTenantId.value ?? authCtrl.currentTenantId;
      if (authCtrl.isSystemAdmin && targetTenantId != null) {
        users.value = await ApiService.getTenantUsers(targetTenantId);
      } else {
        users.value = await ApiService.getUsers();
      }
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
    int? tenantId,
  }) async {
    try {
      bool success;
      final authCtrl = Get.find<AuthController>();
      final targetTenantId = tenantId ?? selectedTenantId.value ?? authCtrl.currentTenantId;
      if (authCtrl.isSystemAdmin && targetTenantId != null) {
        success = await ApiService.addTenantUser(targetTenantId, email: email, password: password, name: name, role: role);
      } else {
        success = await ApiService.createUser(
          email: email, password: password, name: name, role: role,
        );
      }
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to create user: $e');
      return false;
    }
  }

  Future<bool> updateUserRole(int userId, String role, {String? name}) async {
    try {
      bool success;
      final authCtrl = Get.find<AuthController>();
      final targetTenantId = selectedTenantId.value ?? authCtrl.currentTenantId;
      if (authCtrl.isSystemAdmin && targetTenantId != null) {
        success = await ApiService.updateTenantUser(targetTenantId, userId, role: role);
      } else {
        success = await ApiService.updateUserRole(userId, role, name: name);
      }
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to update user role: $e');
      return false;
    }
  }

  Future<bool> updateUserPermissions(int userId, Map<String, dynamic> permissions) async {
    try {
      bool success;
      final authCtrl = Get.find<AuthController>();
      final targetTenantId = selectedTenantId.value ?? authCtrl.currentTenantId;
      if (authCtrl.isSystemAdmin && targetTenantId != null) {
        success = await ApiService.updateTenantUser(targetTenantId, userId, permissions: permissions);
      } else {
        success = await ApiService.updateUserPermissions(userId, permissions);
      }
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to update permissions: $e');
      return false;
    }
  }

  Future<bool> toggleUserStatus(int userId, bool activate) async {
    try {
      bool success;
      final authCtrl = Get.find<AuthController>();
      final targetTenantId = selectedTenantId.value ?? authCtrl.currentTenantId;
      if (authCtrl.isSystemAdmin && targetTenantId != null) {
        success = await ApiService.updateTenantUser(targetTenantId, userId, status: activate ? 'active' : 'inactive');
      } else {
        success = await ApiService.updateUserStatus(userId, activate ? 'active' : 'inactive');
      }
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to toggle user status: $e');
      return false;
    }
  }

  Future<bool> removeUser(int userId) async {
    try {
      bool success;
      final authCtrl = Get.find<AuthController>();
      final targetTenantId = selectedTenantId.value ?? authCtrl.currentTenantId;
      if (authCtrl.isSystemAdmin && targetTenantId != null) {
        success = await ApiService.removeTenantUser(targetTenantId, userId);
      } else {
        success = await ApiService.removeUser(userId);
      }
      if (success) await loadUsers();
      return success;
    } catch (e) {
      print('Failed to remove user: $e');
      return false;
    }
  }
}
