import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/user_management_controller.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/tenant_model.dart';
import '../../theme/enterprise_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late final UserManagementController _userCtrl;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userCtrl = Get.find<UserManagementController>();
    _userCtrl.loadUsers();
    _userCtrl.loadRoles();
  }

  @override
  Widget build(BuildContext context) {
    final sdlcCtrl = Get.find<EnterpriseSDLCController>();
    final authCtrl = Get.find<AuthController>();

    return Obx(() {
      final isDark = sdlcCtrl.isDarkMode.value;
      final bg = EnterpriseTheme.getBackground(isDark);
      final surface = EnterpriseTheme.getSurface(isDark);
      final border = EnterpriseTheme.getCardBorder(isDark);
      final text = EnterpriseTheme.getTextPrimary(isDark);
      final textSec = EnterpriseTheme.getTextSecondary(isDark);
      final textMuted = EnterpriseTheme.getTextMuted(isDark);
      final primary = EnterpriseTheme.getPrimaryAccent(isDark);

      return Container(
        color: bg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF059669).withValues(alpha: 0.15), const Color(0xFF059669).withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.manage_accounts_rounded, size: 28, color: Color(0xFF059669)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Management',
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: text)),
                        const SizedBox(height: 4),
                        Text('Manage users, roles, and permissions for ${authCtrl.currentTenantName}',
                          style: GoogleFonts.inter(fontSize: 13, color: textSec)),
                      ],
                    ),
                  ),
                  _buildAddUserButton(isDark, primary, text, surface, border, textSec),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Stats Row
              _buildQuickStats(isDark, surface, border, text, textMuted),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => _userCtrl.searchQuery.value = v,
                  style: GoogleFonts.inter(fontSize: 13, color: text),
                  decoration: InputDecoration(
                    hintText: 'Search users by name, email, or role...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: textMuted),
                    prefixIcon: Icon(Icons.search_rounded, size: 18, color: textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // User Cards Grid
              _buildUserGrid(isDark, surface, border, text, textSec, textMuted, primary),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickStats(bool isDark, Color surface, Color border, Color text, Color textMuted) {
    return Obx(() {
      final users = _userCtrl.users;
      final activeCount = users.where((u) => u.isActive).length;
      final adminCount = users.where((u) => u.role == 'org_admin').length;
      final editorCount = users.where((u) => u.role == 'editor').length;
      final viewerCount = users.where((u) => u.role == 'viewer').length;

      return Row(
        children: [
          _quickStat('Total Users', '${users.length}', Icons.people_rounded, const Color(0xFF2563EB), surface, border, text, textMuted),
          _quickStat('Active', '$activeCount', Icons.check_circle_rounded, const Color(0xFF059669), surface, border, text, textMuted),
          _quickStat('Admins', '$adminCount', Icons.admin_panel_settings_rounded, const Color(0xFFD97706), surface, border, text, textMuted),
          _quickStat('Editors', '$editorCount', Icons.edit_rounded, const Color(0xFF7C3AED), surface, border, text, textMuted),
          _quickStat('Viewers', '$viewerCount', Icons.visibility_rounded, const Color(0xFF6B7280), surface, border, text, textMuted),
        ],
      );
    });
  }

  Widget _quickStat(String label, String value, IconData icon, Color color, Color surface, Color border, Color text, Color textMuted) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: text)),
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrid(bool isDark, Color surface, Color border, Color text, Color textSec, Color textMuted, Color primary) {
    return Obx(() {
      final users = _userCtrl.filteredUsers;
      final isLoading = _userCtrl.isLoading.value;

      if (isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: CircularProgressIndicator(color: primary),
          ),
        );
      }

      if (users.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              children: [
                Icon(Icons.person_off_rounded, size: 56, color: textMuted.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No users found', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textMuted)),
                const SizedBox(height: 6),
                Text('Add users to get started', style: GoogleFonts.inter(fontSize: 13, color: textMuted.withValues(alpha: 0.6))),
              ],
            ),
          ),
        );
      }

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: users.map((u) => _buildUserCard(u, isDark, surface, border, text, textSec, textMuted, primary)).toList(),
      );
    });
  }

  Widget _buildUserCard(TenantUser user, bool isDark, Color surface, Color border, Color text, Color textSec, Color textMuted, Color primary) {
    final isActive = user.isActive;
    final roleColor = _getRoleColor(user.role);
    final authCtrl = Get.find<AuthController>();
    final isSelf = user.id == (authCtrl.currentUser['id'] ?? -1);

    return Container(
      width: 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? border : const Color(0xFFDC2626).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Status
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: roleColor.withValues(alpha: 0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : user.email[0].toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: roleColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name.isNotEmpty ? user.name : user.email.split('@')[0],
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: text),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelf) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('YOU', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: primary)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(user.email, style: GoogleFonts.inter(fontSize: 11, color: textMuted), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Status dot
              Tooltip(
                message: isActive ? 'Active' : 'Inactive',
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isActive ? const Color(0xFF059669) : const Color(0xFFDC2626)).withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Role Badge + Last Login
          Row(
            children: [
              _roleBadge(user.role, roleColor),
              const Spacer(),
              if (user.lastLogin != null)
                Text('Last login: ${_formatDate(user.lastLogin!)}',
                  style: GoogleFonts.inter(fontSize: 9, color: textMuted)),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          if (!isSelf) ...[
            Divider(color: border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _actionChip('Edit Role', Icons.edit_rounded, primary, () => _showEditRoleDialog(user, isDark, primary, text, surface, border, textSec)),
                const SizedBox(width: 8),
                _actionChip('Permissions', Icons.security_rounded, const Color(0xFF7C3AED), () => _showPermissionsDialog(user, isDark, text, surface, border, textSec)),
                const Spacer(),
                // Toggle active
                Tooltip(
                  message: isActive ? 'Deactivate' : 'Activate',
                  child: InkWell(
                    onTap: () => _userCtrl.toggleUserStatus(user.id, !isActive),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                        size: 18,
                        color: isActive ? const Color(0xFFDC2626).withValues(alpha: 0.6) : const Color(0xFF059669),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Remove
                Tooltip(
                  message: 'Remove from organization',
                  child: InkWell(
                    onTap: () => _confirmRemoveUser(user, isDark, text, surface, textSec),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.person_remove_rounded, size: 18, color: const Color(0xFFDC2626).withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _roleBadge(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(role.replaceAll('_', ' ').toUpperCase(),
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _actionChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'org_admin': return const Color(0xFFD97706);
      case 'editor': return const Color(0xFF2563EB);
      case 'system_admin': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  Widget _buildAddUserButton(bool isDark, Color primary, Color text, Color surface, Color border, Color textSec) {
    return ElevatedButton.icon(
      onPressed: () => _showAddUserDialog(isDark, primary, text, surface, border, textSec),
      icon: const Icon(Icons.person_add_rounded, size: 18),
      label: Text('Add User', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  void _showAddUserDialog(bool isDark, Color primary, Color text, Color surface, Color border, Color textSec) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String role = 'viewer';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.person_add_rounded, color: Color(0xFF059669), size: 24),
              const SizedBox(width: 10),
              Text('Add New User', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: text)),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogLabel('Full Name', textSec),
                _dialogInput(nameCtrl, 'Jane Doe', isDark, border, text),
                const SizedBox(height: 14),
                _dialogLabel('Email Address *', textSec),
                _dialogInput(emailCtrl, 'jane@company.com', isDark, border, text),
                const SizedBox(height: 14),
                _dialogLabel('Password *', textSec),
                _dialogInput(passCtrl, '••••••••', isDark, border, text, obscure: true),
                const SizedBox(height: 14),
                _dialogLabel('Role', textSec),
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1D25) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: role,
                      isExpanded: true,
                      dropdownColor: surface,
                      style: GoogleFonts.inter(fontSize: 13, color: text),
                      items: [
                        DropdownMenuItem(value: 'viewer', child: Row(children: [
                          Icon(Icons.visibility_rounded, size: 16, color: _getRoleColor('viewer')),
                          const SizedBox(width: 8),
                          const Text('Viewer — Read-only access'),
                        ])),
                        DropdownMenuItem(value: 'editor', child: Row(children: [
                          Icon(Icons.edit_rounded, size: 16, color: _getRoleColor('editor')),
                          const SizedBox(width: 8),
                          const Text('Editor — Create & edit projects'),
                        ])),
                        DropdownMenuItem(value: 'org_admin', child: Row(children: [
                          Icon(Icons.admin_panel_settings_rounded, size: 16, color: _getRoleColor('org_admin')),
                          const SizedBox(width: 8),
                          const Text('Org Admin — Full organization access'),
                        ])),
                      ],
                      onChanged: (v) => setDialogState(() => role = v!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: textSec)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) return;
                final success = await _userCtrl.createUser(
                  email: emailCtrl.text.trim(),
                  password: passCtrl.text,
                  name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                  role: role,
                );
                if (success) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Add User', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  void _showEditRoleDialog(TenantUser user, bool isDark, Color primary, Color text, Color surface, Color border, Color textSec) {
    String role = user.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Role — ${user.name.isNotEmpty ? user.name : user.email}',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ['viewer', 'editor', 'org_admin'].map((r) {
                final isSelected = role == r;
                final color = _getRoleColor(r);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setDialogState(() => role = r),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? color.withValues(alpha: 0.3) : border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            size: 18, color: isSelected ? color : textSec,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.replaceAll('_', ' ').toUpperCase(),
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                                Text(_getRoleDescription(r),
                                  style: GoogleFonts.inter(fontSize: 10, color: textSec)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: textSec)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _userCtrl.updateUserRole(user.id, role);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Save Role', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  void _showPermissionsDialog(TenantUser user, bool isDark, Color text, Color surface, Color border, Color textSec) {
    // Start with existing user overrides
    final overrides = Map<String, dynamic>.from(user.permissions);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.security_rounded, color: Color(0xFF7C3AED), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Permissions — ${user.name.isNotEmpty ? user.name : user.email}',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: text),
                  overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: textSec),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Overrides apply on top of the "${user.role}" role defaults. Toggle to grant/revoke specific permissions.',
                          style: GoogleFonts.inter(fontSize: 11, color: textSec),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: Permissions.allPermissions.map((perm) {
                      final key = perm['key']!;
                      final label = perm['label']!;
                      final desc = perm['desc']!;
                      // Skip system admin-only permissions for non-system-admins
                      if (['manage_tenants', 'manage_all_users', 'view_all_tenants'].contains(key)) {
                        return const SizedBox.shrink();
                      }
                      final hasOverride = overrides.containsKey(key);
                      final isEnabled = hasOverride ? overrides[key] == true : false;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          title: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: text)),
                          subtitle: Text(desc, style: GoogleFonts.inter(fontSize: 10, color: textSec)),
                          value: isEnabled,
                          activeColor: const Color(0xFF7C3AED),
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                overrides[key] = true;
                              } else {
                                overrides.remove(key);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: textSec)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _userCtrl.updateUserPermissions(user.id, overrides);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Save Permissions', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  void _confirmRemoveUser(TenantUser user, bool isDark, Color text, Color surface, Color textSec) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove User', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
        content: Text(
          'Are you sure you want to remove "${user.name.isNotEmpty ? user.name : user.email}" from this organization? They will lose access to all projects and features.',
          style: GoogleFonts.inter(fontSize: 13, color: textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: textSec)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _userCtrl.removeUser(user.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('Remove', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'org_admin': return 'Full organization access. Manages users, projects, and settings.';
      case 'editor': return 'Can create, edit projects and features. Run SDLC pipeline.';
      case 'viewer': return 'Read-only access to projects and features.';
      default: return '';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _dialogLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _dialogInput(TextEditingController controller, String hint, bool isDark, Color border, Color text, {bool obscure = false}) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D25) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.inter(fontSize: 13, color: text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 13, color: text.withValues(alpha: 0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
