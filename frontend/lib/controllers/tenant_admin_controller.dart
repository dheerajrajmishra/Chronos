import 'package:get/get.dart';
import '../models/tenant_model.dart';
import '../services/api_service.dart';

/// Controller for system-admin-level tenant management
class TenantAdminController extends GetxController {
  final RxList<Tenant> tenants = <Tenant>[].obs;
  final Rxn<Tenant> selectedTenant = Rxn<Tenant>();
  final RxList<TenantUser> selectedTenantUsers = <TenantUser>[].obs;
  final RxList<IpWhitelist> selectedTenantIps = <IpWhitelist>[].obs;
  final Rxn<AdminStats> stats = Rxn<AdminStats>();
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  List<Tenant> get filteredTenants {
    if (searchQuery.value.isEmpty) return tenants;
    final q = searchQuery.value.toLowerCase();
    return tenants.where((t) => 
      t.name.toLowerCase().contains(q) || 
      t.slug.toLowerCase().contains(q) ||
      t.plan.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> loadTenants() async {
    try {
      isLoading.value = true;
      final list = await ApiService.getTenants();
      tenants.value = list;
    } catch (e) {
      print('Failed to load tenants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      stats.value = await ApiService.getAdminStats();
    } catch (e) {
      print('Failed to load stats: $e');
    }
  }

  Future<bool> createTenant({
    required String name,
    String? slug,
    String plan = 'free',
    int maxUsers = 10,
    String? adminEmail,
    String? adminPassword,
    String? adminName,
  }) async {
    try {
      final tenant = await ApiService.createTenant(
        name: name,
        slug: slug,
        plan: plan,
        maxUsers: maxUsers,
        adminEmail: adminEmail,
        adminPassword: adminPassword,
        adminName: adminName,
      );
      tenants.insert(0, tenant);
      await loadStats();
      return true;
    } catch (e) {
      print('Failed to create tenant: $e');
      return false;
    }
  }

  Future<bool> updateTenant(int id, {
    String? name,
    String? slug,
    String? status,
    String? plan,
    int? maxUsers,
  }) async {
    try {
      final updated = await ApiService.updateTenant(id,
        name: name, slug: slug, status: status, plan: plan, maxUsers: maxUsers,
      );
      final idx = tenants.indexWhere((t) => t.id == id);
      if (idx != -1) {
        tenants[idx] = updated;
      }
      return true;
    } catch (e) {
      print('Failed to update tenant: $e');
      return false;
    }
  }

  Future<bool> suspendTenant(int id) async {
    try {
      final success = await ApiService.suspendTenant(id);
      if (success) {
        await loadTenants();
        await loadStats();
      }
      return success;
    } catch (e) {
      print('Failed to suspend tenant: $e');
      return false;
    }
  }

  Future<bool> deleteTenant(int id) async {
    try {
      final success = await ApiService.deleteTenant(id);
      if (success) {
        tenants.removeWhere((t) => t.id == id);
        if (selectedTenant.value?.id == id) {
          selectedTenant.value = null;
        }
        await loadStats();
      }
      return success;
    } catch (e) {
      print('Failed to delete tenant: $e');
      return false;
    }
  }

  Future<void> selectTenant(Tenant tenant) async {
    selectedTenant.value = tenant;
    await loadTenantUsers(tenant.id);
    await loadTenantIps(tenant.id);
  }

  Future<void> loadTenantUsers(int tenantId) async {
    try {
      selectedTenantUsers.value = await ApiService.getTenantUsers(tenantId);
    } catch (e) {
      print('Failed to load tenant users: $e');
    }
  }

  Future<bool> addUserToTenant(int tenantId, {
    required String email,
    String? password,
    String? name,
    String role = 'viewer',
  }) async {
    try {
      final success = await ApiService.addTenantUser(tenantId,
        email: email, password: password, name: name, role: role,
      );
      if (success) {
        await loadTenantUsers(tenantId);
        await loadTenants(); // refresh user counts
      }
      return success;
    } catch (e) {
      print('Failed to add user to tenant: $e');
      return false;
    }
  }

  Future<bool> removeUserFromTenant(int tenantId, int userId) async {
    try {
      final success = await ApiService.removeTenantUser(tenantId, userId);
      if (success) {
        await loadTenantUsers(tenantId);
        await loadTenants();
      }
      return success;
    } catch (e) {
      print('Failed to remove user: $e');
      return false;
    }
  }

  Future<void> loadTenantIps(int tenantId) async {
    try {
      selectedTenantIps.value = await ApiService.getTenantIps(tenantId);
    } catch (e) {
      print('Failed to load tenant IPs: $e');
    }
  }

  Future<bool> addTenantIp(int tenantId, String ipCidr, String description) async {
    try {
      await ApiService.addTenantIp(tenantId, ipCidr, description);
      await loadTenantIps(tenantId);
      return true;
    } catch (e) {
      print('Failed to add tenant IP: $e');
      return false;
    }
  }

  Future<bool> removeTenantIp(int tenantId, int ipId) async {
    try {
      await ApiService.removeTenantIp(tenantId, ipId);
      await loadTenantIps(tenantId);
      return true;
    } catch (e) {
      print('Failed to remove tenant IP: $e');
      return false;
    }
  }
}
