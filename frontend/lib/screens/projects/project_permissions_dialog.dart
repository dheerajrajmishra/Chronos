import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/sdlc_models.dart';
import '../../models/tenant_model.dart';
import '../../theme/enterprise_theme.dart';
import '../../services/api_service.dart';

class ProjectPermissionsDialog extends StatefulWidget {
  final Project project;
  final bool isDark;

  const ProjectPermissionsDialog({super.key, required this.project, required this.isDark});

  @override
  State<ProjectPermissionsDialog> createState() => _ProjectPermissionsDialogState();
}

class _ProjectPermissionsDialogState extends State<ProjectPermissionsDialog> {
  bool _isLoading = true;
  List<ProjectUser> _users = [];
  List<TenantUser> _availableUsers = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      final users = await ApiService.getProjectUsers(widget.project.id);
      
      // Also load available users for the dropdown
      List<TenantUser> available = [];
      try {
        available = await ApiService.getProjectAvailableUsers(widget.project.id);
      } catch (e) {
        print('Error loading available users: $e');
      }

      setState(() {
        _users = users;
        _availableUsers = available;
        _error = '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRole(int userId, String role) async {
    try {
      await ApiService.updateProjectUserRole(widget.project.id, userId, role);
      await _loadUsers();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _removeUser(int userId) async {
    try {
      await ApiService.removeProjectUser(widget.project.id, userId);
      await _loadUsers();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _showAddUserDialog() {
    final emailController = TextEditingController();
    String selectedRole = 'viewer';
    String? selectedUserId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: EnterpriseTheme.getSurface(widget.isDark),
              title: Text('Add User to Workspace', style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(widget.isDark))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Note: You can only add users that are already members of this Tenant.', 
                    style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(widget.isDark), fontSize: 12)),
                  const SizedBox(height: 16),
                  if (_availableUsers.isEmpty)
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(widget.isDark)),
                      decoration: InputDecoration(
                        labelText: 'User Email or ID',
                        hintText: 'e.g. user@company.com or 4',
                        hintStyle: TextStyle(color: EnterpriseTheme.getTextMuted(widget.isDark), fontSize: 12),
                        labelStyle: TextStyle(color: EnterpriseTheme.getTextSecondary(widget.isDark)),
                        filled: true,
                        fillColor: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedUserId,
                      hint: Text('Select a user', style: TextStyle(color: EnterpriseTheme.getTextMuted(widget.isDark))),
                      dropdownColor: EnterpriseTheme.getSurface(widget.isDark),
                      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(widget.isDark)),
                      items: _availableUsers.map((u) {
                        return DropdownMenuItem(
                          value: u.id.toString(),
                          child: Text('${u.email} ${u.name.isNotEmpty ? '(${u.name})' : ''}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedUserId = val;
                            emailController.text = val;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Tenant User',
                        labelStyle: TextStyle(color: EnterpriseTheme.getTextSecondary(widget.isDark)),
                        filled: true,
                        fillColor: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    dropdownColor: EnterpriseTheme.getSurface(widget.isDark),
                    style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(widget.isDark)),
                    items: ['viewer', 'contributor'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(color: EnterpriseTheme.getTextSecondary(widget.isDark)),
                      filled: true,
                      fillColor: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: EnterpriseTheme.getTextSecondary(widget.isDark))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final input = emailController.text.trim();
                    if (input.isNotEmpty) {
                      Navigator.pop(ctx);
                      try {
                        final id = int.tryParse(input);
                        if (id != null) {
                          await ApiService.addProjectUser(widget.project.id, userId: id, role: selectedRole);
                        } else {
                          await ApiService.addProjectUser(widget.project.id, email: input, role: selectedRole);
                        }
                        _loadUsers();
                      } catch (e) {
                        setState(() => _error = 'Failed to add user: $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: EnterpriseTheme.brandBlue),
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = EnterpriseTheme.getSurface(widget.isDark);
    final textColor = EnterpriseTheme.getTextPrimary(widget.isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(widget.isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Workspace Permissions', style: GoogleFonts.outfit(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close, color: textSecColor),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Manage who has access to ${widget.project.name}.', style: GoogleFonts.inter(color: textSecColor)),
            const SizedBox(height: 24),

            if (_error.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: EnterpriseTheme.rose.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(_error, style: TextStyle(color: EnterpriseTheme.rose)),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                  label: const Text('Add User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnterpriseTheme.brandBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_users.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('No explicit users found (Admins have access automatically)', style: TextStyle(color: textSecColor))),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: widget.isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _users.length,
                  separatorBuilder: (ctx, i) => Divider(height: 1, color: widget.isDark ? Colors.white10 : Colors.black12),
                  itemBuilder: (context, index) {
                    final u = _users[index];
                    return ListTile(
                      title: Text(u.name.isEmpty ? u.email : u.name, style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600)),
                      subtitle: Text(u.email, style: TextStyle(color: textSecColor, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: u.role,
                            dropdownColor: bgColor,
                            style: GoogleFonts.inter(color: textColor, fontSize: 13),
                            underline: const SizedBox(),
                            items: ['viewer', 'contributor'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                            onChanged: (val) {
                              if (val != null && val != u.role) _updateRole(u.userId, val);
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: EnterpriseTheme.rose, size: 18),
                            onPressed: () => _removeUser(u.userId),
                            tooltip: 'Remove from Workspace',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
