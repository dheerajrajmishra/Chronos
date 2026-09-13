/// Represents a tenant/organization in the SaaS platform
class Tenant {
  final int id;
  final String name;
  final String slug;
  final String status; // active, suspended
  final String plan; // free, pro, enterprise
  final int maxUsers;
  final int userCount;
  final int projectCount;
  final String createdAt;

  Tenant({
    required this.id,
    required this.name,
    this.slug = '',
    this.status = 'active',
    this.plan = 'free',
    this.maxUsers = 10,
    this.userCount = 0,
    this.projectCount = 0,
    this.createdAt = '',
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      status: json['status'] ?? 'active',
      plan: json['plan'] ?? 'free',
      maxUsers: json['max_users'] ?? 10,
      userCount: int.tryParse('${json['user_count'] ?? 0}') ?? 0,
      projectCount: int.tryParse('${json['project_count'] ?? 0}') ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

/// A user's membership within a tenant
class TenantUser {
  final int id;
  final String email;
  final String name;
  final String role;
  final String userStatus;
  final String membershipStatus;
  final Map<String, dynamic> permissions;
  final String? lastLogin;
  final String createdAt;

  TenantUser({
    required this.id,
    required this.email,
    this.name = '',
    this.role = 'viewer',
    this.userStatus = 'active',
    this.membershipStatus = 'active',
    this.permissions = const {},
    this.lastLogin,
    this.createdAt = '',
  });

  factory TenantUser.fromJson(Map<String, dynamic> json) {
    return TenantUser(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'viewer',
      userStatus: json['user_status'] ?? 'active',
      membershipStatus: json['membership_status'] ?? 'active',
      permissions: json['permissions'] is Map ? Map<String, dynamic>.from(json['permissions']) : {},
      lastLogin: json['last_login'],
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isActive => membershipStatus == 'active' && userStatus == 'active';
}

/// Tenant info returned in login/switch-tenant responses
class TenantInfo {
  final int tenantId;
  final String tenantName;
  final String tenantSlug;
  final String role;
  final String plan;

  TenantInfo({
    required this.tenantId,
    required this.tenantName,
    this.tenantSlug = '',
    this.role = 'viewer',
    this.plan = 'free',
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      tenantId: json['tenant_id'],
      tenantName: json['tenant_name'] ?? '',
      tenantSlug: json['tenant_slug'] ?? '',
      role: json['role'] ?? 'viewer',
      plan: json['plan'] ?? 'free',
    );
  }
}

/// Platform-wide stats (system admin)
class AdminStats {
  final int totalTenants;
  final int totalUsers;
  final int totalProjects;
  final int activeMemberships;

  AdminStats({
    this.totalTenants = 0,
    this.totalUsers = 0,
    this.totalProjects = 0,
    this.activeMemberships = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalTenants: json['total_tenants'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalProjects: json['total_projects'] ?? 0,
      activeMemberships: json['active_memberships'] ?? 0,
    );
  }
}

/// Available role with permissions
class RoleDefinition {
  final String role;
  final String label;
  final String description;
  final Map<String, dynamic> permissions;

  RoleDefinition({
    required this.role,
    required this.label,
    this.description = '',
    this.permissions = const {},
  });

  factory RoleDefinition.fromJson(Map<String, dynamic> json) {
    return RoleDefinition(
      role: json['role'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      permissions: json['permissions'] is Map ? Map<String, dynamic>.from(json['permissions']) : {},
    );
  }
}

/// Predefined permission keys
class Permissions {
  static const String manageTenants = 'manage_tenants';
  static const String manageAllUsers = 'manage_all_users';
  static const String viewAllTenants = 'view_all_tenants';
  static const String manageUsers = 'manage_users';
  static const String manageProjects = 'manage_projects';
  static const String manageFeatures = 'manage_features';
  static const String manageSettings = 'manage_settings';
  static const String viewProjects = 'view_projects';
  static const String viewFeatures = 'view_features';
  static const String generateDeliverables = 'generate_deliverables';
  static const String manageWorkflows = 'manage_workflows';
  static const String viewAuditLogs = 'view_audit_logs';

  static const List<Map<String, String>> allPermissions = [
    {'key': 'manage_tenants', 'label': 'Manage Tenants', 'desc': 'Create, update, suspend tenants'},
    {'key': 'manage_all_users', 'label': 'Manage All Users', 'desc': 'Manage users across all tenants'},
    {'key': 'view_all_tenants', 'label': 'View All Tenants', 'desc': 'View all tenant details'},
    {'key': 'manage_users', 'label': 'Manage Users', 'desc': 'Add, remove, and update users in the organization'},
    {'key': 'manage_projects', 'label': 'Manage Projects', 'desc': 'Create, edit, and delete projects'},
    {'key': 'manage_features', 'label': 'Manage Features', 'desc': 'Create, edit, and delete features'},
    {'key': 'manage_settings', 'label': 'Manage Settings', 'desc': 'Update LLM config, prompts, and theme'},
    {'key': 'view_projects', 'label': 'View Projects', 'desc': 'View projects and their details'},
    {'key': 'view_features', 'label': 'View Features', 'desc': 'View features and pipeline stages'},
    {'key': 'generate_deliverables', 'label': 'Generate Deliverables', 'desc': 'Run the AI pipeline to generate BRD, design, code, etc.'},
    {'key': 'manage_workflows', 'label': 'Manage Workflows', 'desc': 'Advance, approve, or reject pipeline stages'},
    {'key': 'view_audit_logs', 'label': 'View Audit Logs', 'desc': 'View admin action history'},
  ];
}

class IpWhitelist {
  final int id;
  final int tenantId;
  final String ipCidr;
  final String description;
  final String createdAt;

  IpWhitelist({
    required this.id,
    required this.tenantId,
    required this.ipCidr,
    required this.description,
    required this.createdAt,
  });

  factory IpWhitelist.fromJson(Map<String, dynamic> json) {
    return IpWhitelist(
      id: json['id'],
      tenantId: json['tenant_id'],
      ipCidr: json['ip_cidr'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
