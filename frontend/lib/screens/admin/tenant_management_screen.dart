import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/tenant_admin_controller.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/tenant_model.dart';
import '../../theme/enterprise_theme.dart';

class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  late final TenantAdminController _tenantCtrl;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tenantCtrl = Get.find<TenantAdminController>();
    _tenantCtrl.loadTenants();
    _tenantCtrl.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final sdlcCtrl = Get.find<EnterpriseSDLCController>();

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
                        colors: [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.domain_rounded, size: 28, color: primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tenant Management',
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: text)),
                        const SizedBox(height: 4),
                        Text('Manage organizations, users, and platform configuration',
                          style: GoogleFonts.inter(fontSize: 13, color: textSec)),
                      ],
                    ),
                  ),
                  _buildCreateTenantButton(isDark, primary, text, surface, border, textSec),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsRow(isDark, surface, border, text, textSec, textMuted, primary),
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
                  onChanged: (v) => _tenantCtrl.searchQuery.value = v,
                  style: GoogleFonts.inter(fontSize: 13, color: text),
                  decoration: InputDecoration(
                    hintText: 'Search tenants by name, slug, or plan...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: textMuted),
                    prefixIcon: Icon(Icons.search_rounded, size: 18, color: textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tenant Table
              _buildTenantTable(isDark, surface, border, text, textSec, textMuted, primary),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatsRow(bool isDark, Color surface, Color border, Color text, Color textSec, Color textMuted, Color primary) {
    return Obx(() {
      final s = _tenantCtrl.stats.value;
      final statItems = [
        _StatItem('Total Tenants', '${s?.totalTenants ?? 0}', Icons.domain_rounded, const Color(0xFF2563EB)),
        _StatItem('Active Users', '${s?.totalUsers ?? 0}', Icons.people_rounded, const Color(0xFF059669)),
        _StatItem('Total Projects', '${s?.totalProjects ?? 0}', Icons.folder_rounded, const Color(0xFF7C3AED)),
        _StatItem('Active Memberships', '${s?.activeMemberships ?? 0}', Icons.badge_rounded, const Color(0xFFD97706)),
      ];

      return Row(
        children: statItems.map((item) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 22, color: item.color),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.value,
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: text)),
                      const SizedBox(height: 2),
                      Text(item.label,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildTenantTable(bool isDark, Color surface, Color border, Color text, Color textSec, Color textMuted, Color primary) {
    return Obx(() {
      final tenants = _tenantCtrl.filteredTenants;
      final isLoading = _tenantCtrl.isLoading.value;

      if (isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: CircularProgressIndicator(color: primary),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1D25) : const Color(0xFFF8F9FB),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  _tableHeader('Organization', 3, textMuted),
                  _tableHeader('Slug', 2, textMuted),
                  _tableHeader('Plan', 1, textMuted),
                  _tableHeader('Users', 1, textMuted),
                  _tableHeader('Projects', 1, textMuted),
                  _tableHeader('Status', 1, textMuted),
                  _tableHeader('Actions', 2, textMuted),
                ],
              ),
            ),
            // Table Rows
            if (tenants.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.domain_disabled_rounded, size: 48, color: textMuted.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('No tenants found', style: GoogleFonts.inter(fontSize: 14, color: textMuted)),
                  ],
                ),
              )
            else
              ...tenants.map((t) => _buildTenantRow(t, isDark, border, text, textSec, textMuted, primary)),
          ],
        ),
      );
    });
  }

  Widget _tableHeader(String label, int flex, Color color) {
    return Expanded(
      flex: flex,
      child: Text(label,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _buildTenantRow(Tenant t, bool isDark, Color border, Color text, Color textSec, Color textMuted, Color primary) {
    final isActive = t.status == 'active';
    final statusColor = isActive ? const Color(0xFF059669) : const Color(0xFFDC2626);

    final surface = EnterpriseTheme.getSurface(isDark);

    return InkWell(
      onTap: () => _showTenantDetail(t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border.withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            // Name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(t.name,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: text),
                      overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            // Slug
            Expanded(
              flex: 2,
              child: Text(t.slug.isNotEmpty ? t.slug : '—',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: textMuted)),
            ),
            // Plan
            Expanded(
              flex: 1,
              child: _planBadge(t.plan),
            ),
            // Users
            Expanded(
              flex: 1,
              child: Text('${t.userCount} / ${t.maxUsers}',
                style: GoogleFonts.inter(fontSize: 12, color: textSec)),
            ),
            // Projects
            Expanded(
              flex: 1,
              child: Text('${t.projectCount}',
                style: GoogleFonts.inter(fontSize: 12, color: textSec)),
            ),
            // Status
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t.status.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                ),
              ),
            ),
            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _iconAction(Icons.edit_rounded, 'Edit', () => _showEditTenantDialog(t, isDark, primary, text, surface, border, textSec), primary),
                  _iconAction(Icons.people_rounded, 'Users', () => _showTenantDetail(t), primary),
                  _iconAction(Icons.security_rounded, 'IP Whitelist', () => _showTenantIpsDialog(t), primary),
                  if (t.id != 1)
                    _iconAction(
                      isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                      isActive ? 'Suspend' : 'Reactivate',
                      () => _toggleTenantStatus(t),
                      isActive ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    ),
                  if (t.id != 1)
                    _iconAction(Icons.delete_forever_rounded, 'Delete permanently', () => _confirmDeleteTenant(t), const Color(0xFFDC2626)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planBadge(String plan) {
    Color color;
    switch (plan.toLowerCase()) {
      case 'enterprise': color = const Color(0xFF7C3AED); break;
      case 'pro': color = const Color(0xFF2563EB); break;
      default: color = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(plan.toUpperCase(),
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _iconAction(IconData icon, String tooltip, VoidCallback onTap, Color color) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
        ),
      ),
    );
  }

  Widget _buildCreateTenantButton(bool isDark, Color primary, Color text, Color surface, Color border, Color textSec) {
    return ElevatedButton.icon(
      onPressed: () => _showCreateTenantDialog(isDark, primary, text, surface, border, textSec),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text('New Tenant', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  void _showCreateTenantDialog(bool isDark, Color primary, Color text, Color surface, Color border, Color textSec) {
    final nameCtrl = TextEditingController();
    final slugCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final adminNameCtrl = TextEditingController();
    String plan = 'free';
    int maxUsers = 10;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.domain_add_rounded, color: primary, size: 24),
              const SizedBox(width: 10),
              Text('Create New Tenant', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: text)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogLabel('Organization Name *', textSec),
                  _dialogInput(nameCtrl, 'e.g., Acme Corporation', isDark, border, text),
                  const SizedBox(height: 14),
                  _dialogLabel('URL Slug', textSec),
                  _dialogInput(slugCtrl, 'e.g., acme-corp (auto-generated if empty)', isDark, border, text),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogLabel('Plan', textSec),
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
                                  value: plan,
                                  isExpanded: true,
                                  dropdownColor: surface,
                                  style: GoogleFonts.inter(fontSize: 13, color: text),
                                  items: ['free', 'pro', 'enterprise'].map((p) =>
                                    DropdownMenuItem(value: p, child: Text(p.toUpperCase()))
                                  ).toList(),
                                  onChanged: (v) => setDialogState(() => plan = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogLabel('Max Users', textSec),
                            _dialogInput(
                              TextEditingController(text: '$maxUsers'),
                              '10',
                              isDark, border, text,
                              keyboardType: TextInputType.number,
                              onChanged: (v) => maxUsers = int.tryParse(v) ?? 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: border),
                  const SizedBox(height: 8),
                  Text('Initial Admin User (Optional)',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: text)),
                  const SizedBox(height: 12),
                  _dialogLabel('Admin Name', textSec),
                  _dialogInput(adminNameCtrl, 'Jane Doe', isDark, border, text),
                  const SizedBox(height: 14),
                  _dialogLabel('Admin Email', textSec),
                  _dialogInput(emailCtrl, 'admin@acme.com', isDark, border, text),
                  const SizedBox(height: 14),
                  _dialogLabel('Admin Password', textSec),
                  _dialogInput(passCtrl, '••••••••', isDark, border, text, obscure: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: textSec)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final success = await _tenantCtrl.createTenant(
                  name: nameCtrl.text.trim(),
                  slug: slugCtrl.text.trim().isNotEmpty ? slugCtrl.text.trim() : null,
                  plan: plan,
                  maxUsers: maxUsers,
                  adminEmail: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                  adminPassword: passCtrl.text.isNotEmpty ? passCtrl.text : null,
                  adminName: adminNameCtrl.text.trim().isNotEmpty ? adminNameCtrl.text.trim() : null,
                );
                if (success) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Create Tenant', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  void _showEditTenantDialog(Tenant t, bool isDark, Color primary, Color text, Color surface, Color border, Color textSec) {
    final nameCtrl = TextEditingController(text: t.name);
    final slugCtrl = TextEditingController(text: t.slug);
    String plan = t.plan;
    int maxUsers = t.maxUsers;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit_rounded, color: primary, size: 24),
              const SizedBox(width: 10),
              Text('Edit Tenant', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: text)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogLabel('Organization Name *', textSec),
                  _dialogInput(nameCtrl, 'e.g., Acme Corporation', isDark, border, text),
                  const SizedBox(height: 14),
                  _dialogLabel('URL Slug', textSec),
                  _dialogInput(slugCtrl, 'e.g., acme-corp', isDark, border, text),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogLabel('Plan', textSec),
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
                                  value: plan,
                                  isExpanded: true,
                                  dropdownColor: surface,
                                  style: GoogleFonts.inter(fontSize: 13, color: text),
                                  items: ['free', 'pro', 'enterprise'].map((p) =>
                                    DropdownMenuItem(value: p, child: Text(p.toUpperCase()))
                                  ).toList(),
                                  onChanged: (v) => setDialogState(() => plan = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogLabel('Max Users', textSec),
                            _dialogInput(
                              TextEditingController(text: '$maxUsers'),
                              '10',
                              isDark, border, text,
                              keyboardType: TextInputType.number,
                              onChanged: (v) => maxUsers = int.tryParse(v) ?? 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: textSec)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final success = await _tenantCtrl.updateTenant(
                  t.id,
                  name: nameCtrl.text.trim(),
                  slug: slugCtrl.text.trim().isNotEmpty ? slugCtrl.text.trim() : null,
                  plan: plan,
                  maxUsers: maxUsers,
                );
                if (success) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  void _showTenantDetail(Tenant t) {
    _tenantCtrl.selectTenant(t);
    final sdlcCtrl = Get.find<EnterpriseSDLCController>();
    final isDark = sdlcCtrl.isDarkMode.value;
    final surface = EnterpriseTheme.getSurface(isDark);
    final border = EnterpriseTheme.getCardBorder(isDark);
    final text = EnterpriseTheme.getTextPrimary(isDark);
    final textSec = EnterpriseTheme.getTextSecondary(isDark);
    final textMuted = EnterpriseTheme.getTextMuted(isDark);
    final primary = EnterpriseTheme.getPrimaryAccent(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.people_rounded, color: primary, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${t.name} — Users',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: text),
                overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              icon: Icon(Icons.person_add_rounded, color: primary, size: 20),
              onPressed: () => _showAddUserToTenantDialog(ctx, t.id, isDark, primary, text, surface, border, textSec),
              tooltip: 'Add User',
            ),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Obx(() {
            final users = _tenantCtrl.selectedTenantUsers;
            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_off_rounded, size: 48, color: textMuted.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No users in this tenant', style: GoogleFonts.inter(fontSize: 14, color: textMuted)),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(color: border, height: 1),
              itemBuilder: (_, i) {
                final u = users[i];
                final isActive = u.isActive;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primary.withValues(alpha: 0.1),
                    child: Text(u.email.isNotEmpty ? u.email[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: primary)),
                  ),
                  title: Text(u.name.isNotEmpty ? u.name : u.email,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: text)),
                  subtitle: Text(u.email,
                    style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _roleBadge(u.role, primary),
                      const SizedBox(width: 8),
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, size: 18, color: const Color(0xFFDC2626).withValues(alpha: 0.7)),
                        onPressed: () {
                          _tenantCtrl.removeUserFromTenant(t.id, u.id);
                        },
                        tooltip: 'Remove from tenant',
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.inter(color: textSec)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTenant(Tenant t) {
    final sdlcCtrl = Get.find<EnterpriseSDLCController>();
    final isDark = sdlcCtrl.isDarkMode.value;
    final surface = EnterpriseTheme.getSurface(isDark);
    final text = EnterpriseTheme.getTextPrimary(isDark);
    final textMuted = EnterpriseTheme.getTextMuted(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Text('Delete Tenant', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: text)),
          ],
        ),
        content: Text('Are you sure you want to permanently delete "${t.name}"? This will delete all associated users, projects, features, and settings. This action cannot be undone.', style: GoogleFonts.inter(color: textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _tenantCtrl.deleteTenant(t.id);
              if (success && mounted) {
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTenantIpsDialog(Tenant t) {
    _tenantCtrl.selectTenant(t);
    final sdlcCtrl = Get.find<EnterpriseSDLCController>();
    final isDark = sdlcCtrl.isDarkMode.value;
    final surface = EnterpriseTheme.getSurface(isDark);
    final border = EnterpriseTheme.getCardBorder(isDark);
    final text = EnterpriseTheme.getTextPrimary(isDark);
    final textSec = EnterpriseTheme.getTextSecondary(isDark);
    final textMuted = EnterpriseTheme.getTextMuted(isDark);
    final primary = EnterpriseTheme.getPrimaryAccent(isDark);

    final ipCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.security_rounded, color: primary, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${t.name} — IP Whitelist',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: text),
                overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _dialogInput(ipCtrl, 'IP CIDR (e.g. 192.168.1.1/32)', isDark, border, text),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: _dialogInput(descCtrl, 'Description', isDark, border, text),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (ipCtrl.text.trim().isEmpty) return;
                      final success = await _tenantCtrl.addTenantIp(t.id, ipCtrl.text.trim(), descCtrl.text.trim());
                      if (success) {
                        ipCtrl.clear();
                        descCtrl.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.add_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: border),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  final ips = _tenantCtrl.selectedTenantIps;
                  if (ips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 48, color: textMuted.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('No IP whitelists configured.', style: GoogleFonts.inter(fontSize: 14, color: textMuted)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: ips.length,
                    separatorBuilder: (_, __) => Divider(color: border, height: 1),
                    itemBuilder: (_, i) {
                      final ip = ips[i];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.router_rounded, size: 18, color: primary),
                        ),
                        title: Text(ip.ipCidr,
                          style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: text)),
                        subtitle: Text(ip.description.isNotEmpty ? ip.description : 'No description',
                          style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline_rounded, size: 18, color: const Color(0xFFDC2626).withValues(alpha: 0.7)),
                          onPressed: () {
                            _tenantCtrl.removeTenantIp(t.id, ip.id);
                          },
                          tooltip: 'Remove IP',
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.inter(color: textSec)),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(String role, Color primary) {
    Color color;
    switch (role) {
      case 'org_admin': color = const Color(0xFFD97706); break;
      case 'editor': color = const Color(0xFF2563EB); break;
      case 'system_admin': color = const Color(0xFFDC2626); break;
      default: color = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(role.replaceAll('_', ' ').toUpperCase(),
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }

  void _showAddUserToTenantDialog(BuildContext parentCtx, int tenantId, bool isDark, Color primary, Color text, Color surface, Color border, Color textSec) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String role = 'viewer';

    showDialog(
      context: parentCtx,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add User to Tenant', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogLabel('Name', textSec),
                _dialogInput(nameCtrl, 'John Doe', isDark, border, text),
                const SizedBox(height: 12),
                _dialogLabel('Email *', textSec),
                _dialogInput(emailCtrl, 'user@example.com', isDark, border, text),
                const SizedBox(height: 12),
                _dialogLabel('Password (for new users)', textSec),
                _dialogInput(passCtrl, '••••••••', isDark, border, text, obscure: true),
                const SizedBox(height: 12),
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
                      items: ['viewer', 'editor', 'org_admin'].map((r) =>
                        DropdownMenuItem(value: r, child: Text(r.replaceAll('_', ' ').toUpperCase()))
                      ).toList(),
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
                if (emailCtrl.text.trim().isEmpty) return;
                final success = await _tenantCtrl.addUserToTenant(tenantId,
                  email: emailCtrl.text.trim(),
                  password: passCtrl.text.isNotEmpty ? passCtrl.text : null,
                  name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                  role: role,
                );
                if (success) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
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

  void _toggleTenantStatus(Tenant t) async {
    if (t.status == 'active') {
      await _tenantCtrl.suspendTenant(t.id);
    } else {
      await _tenantCtrl.updateTenant(t.id, status: 'active');
      await _tenantCtrl.loadTenants();
    }
  }

  Widget _dialogLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _dialogInput(TextEditingController controller, String hint, bool isDark, Color border, Color text, {
    bool obscure = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
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
        keyboardType: keyboardType,
        onChanged: onChanged,
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

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
