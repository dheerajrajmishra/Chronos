import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/sdlc_models.dart';
import '../../theme/enterprise_theme.dart';

class ProjectHubScreen extends StatelessWidget {
  const ProjectHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final projects = controller.projectList;
      final activePrj = controller.activeProject.value;
      final features = controller.activeProjectFeatures;
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);

      return Container(
        color: EnterpriseTheme.getBackground(isDark),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => EnterpriseTheme.brandGradient.createShader(bounds),
                        child: Text(
                          'Projects & Workspaces',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your secure enclaves and automated SDLC pipelines.',
                        style: GoogleFonts.inter(color: textSecColor, fontSize: 15),
                      ),
                    ],
                  ),
                  _buildGradientButton(
                    onPressed: () => _showCreateProjectDialog(context, controller, isDark),
                    icon: Icons.add_circle_outline,
                    label: 'New Project',
                    isDark: isDark,
                  )
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Projects Section
              Row(
                children: [
                  Icon(Icons.folder_copy_outlined, color: textSecColor, size: 20),
                  const SizedBox(width: 8),
                  Text('ACTIVE PROJECTS', style: GoogleFonts.inter(color: textSecColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 16),
              
              if (projects.isEmpty)
                _buildEmptyState('No projects found.', 'Get started by creating a new secure workspace.', Icons.folder_off_outlined, isDark)
              else
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: projects.map((p) => _ModernProjectCard(project: p, activeProject: activePrj, controller: controller, isDark: isDark)).toList(),
                ),

              const SizedBox(height: 32),

              // Features Section (only if project selected)
              if (activePrj != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hub_outlined, color: EnterpriseTheme.emerald, size: 20),
                        const SizedBox(width: 8),
                        Text('FEATURES IN ${activePrj.name.toUpperCase()}', style: GoogleFonts.inter(color: textSecColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                      ],
                    ),
                    _buildGradientButton(
                      onPressed: () => _showCreateFeatureDialog(context, controller, activePrj, isDark),
                      icon: Icons.rocket_launch_outlined,
                      label: 'New Feature',
                      isDark: isDark,
                      gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                if (features.isEmpty)
                  _buildEmptyState('No features defined.', 'Create a feature to kick off a zero-trust SDLC workflow.', Icons.auto_awesome_mosaic_outlined, isDark)
                else
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: features.map((f) => _ModernFeatureCard(feature: f, controller: controller, isDark: isDark)).toList(),
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildGradientButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isDark, Gradient? gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? EnterpriseTheme.brandGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? EnterpriseTheme.getPrimaryAccent(isDark)).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Modern Glassmorphism Dialog
  void _showCreateProjectDialog(BuildContext context, EnterpriseSDLCController controller, bool isDark) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getSurface(isDark).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: EnterpriseTheme.getCardBorder(isDark).withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: EnterpriseTheme.getPrimaryAccent(isDark).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.dashboard_customize_rounded, color: EnterpriseTheme.getPrimaryAccent(isDark)),
                      ),
                      const SizedBox(width: 16),
                      Text('Create Workspace', style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildInputField('Project Name', nameCtrl, isDark, Icons.title),
                  const SizedBox(height: 20),
                  _buildInputField('Description', descCtrl, isDark, Icons.description, maxLines: 3),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(foregroundColor: EnterpriseTheme.getTextSecondary(isDark), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      _buildGradientButton(
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty) {
                            controller.createProject(nameCtrl.text, descCtrl.text);
                            Get.back();
                          }
                        },
                        icon: Icons.check,
                        label: 'Create Project',
                        isDark: isDark,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateFeatureDialog(BuildContext context, EnterpriseSDLCController controller, Project activePrj, bool isDark) {

    final nameCtrl = TextEditingController();
    final codeRepoCtrl = TextEditingController(text: 'https://github.com/my-org/repo.git');
    final dbUrlCtrl = TextEditingController(text: 'postgres://user:pass@localhost:5432/db');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getSurface(isDark).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: EnterpriseTheme.getCardBorder(isDark).withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40)],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: EnterpriseTheme.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.rocket_launch, color: EnterpriseTheme.purple),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Define Feature', style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('Target Workspace: ${activePrj.name}', style: GoogleFonts.inter(color: EnterpriseTheme.purple, fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildInputField('Feature Name', nameCtrl, isDark, Icons.label_outline),
                    const SizedBox(height: 20),
                    _buildInputField('Code Access (Git Repo URL)', codeRepoCtrl, isDark, Icons.code),
                    const SizedBox(height: 20),
                    _buildInputField('Database Access URL', dbUrlCtrl, isDark, Icons.dns_outlined),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(foregroundColor: EnterpriseTheme.getTextSecondary(isDark), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        _buildGradientButton(
                          onPressed: () {
                            if (nameCtrl.text.isNotEmpty) {
                              controller.createFeature(
                                projectId: activePrj.id,
                                name: nameCtrl.text,
                                codeAccess: {'repoUrl': codeRepoCtrl.text},
                                dbAccess: {'url': dbUrlCtrl.text},
                                baseRequirement: '',
                                brdPrompt: '',
                              );
                              Get.back();
                            }
                          },
                          icon: Icons.play_arrow_rounded,
                          label: 'Initialize Workflow',
                          isDark: isDark,
                          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isDark, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark)),
        prefixIcon: maxLines == 1 ? Icon(icon, color: EnterpriseTheme.getTextMuted(isDark), size: 18) : null,
        filled: true,
        fillColor: EnterpriseTheme.getInputBg(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark)),
        ),
      ),
    );
  }
}

// ─── Modern Animated Cards ───────────────────────────────────────────────────

class _ModernProjectCard extends StatefulWidget {
  final Project project;
  final Project? activeProject;
  final EnterpriseSDLCController controller;
  final bool isDark;

  const _ModernProjectCard({required this.project, required this.activeProject, required this.controller, required this.isDark});

  @override
  State<_ModernProjectCard> createState() => _ModernProjectCardState();
}

class _ModernProjectCardState extends State<_ModernProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.activeProject?.id == widget.project.id;
    final primaryColor = EnterpriseTheme.getPrimaryAccent(widget.isDark);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.controller.selectProject(widget.project),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? primaryColor.withOpacity(0.05) 
                : (_isHovered ? EnterpriseTheme.getSubtleBg(widget.isDark) : EnterpriseTheme.getSurface(widget.isDark)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : (_isHovered ? primaryColor.withOpacity(0.5) : EnterpriseTheme.getCardBorder(widget.isDark)),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: _isHovered ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6))] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.15) : EnterpriseTheme.getSubtleBg(widget.isDark),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.folder_shared_outlined, color: isSelected ? primaryColor : EnterpriseTheme.getTextSecondary(widget.isDark), size: 16),
                  ),
                  Row(
                    children: [
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: Text('ACTIVE', style: GoogleFonts.inter(color: primaryColor, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 16, color: EnterpriseTheme.getTextSecondary(widget.isDark)),
                        padding: EdgeInsets.zero,
                        tooltip: 'Options',
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showEditProjectDialog(context, widget.controller, widget.project, widget.isDark);
                          } else if (val == 'delete') {
                            _showDeleteProjectDialog(context, widget.controller, widget.project, widget.isDark);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [Icon(Icons.edit_outlined, size: 18), const SizedBox(width: 8), const Text('Edit')]),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [Icon(Icons.delete_outline, size: 18, color: EnterpriseTheme.rose), const SizedBox(width: 8), Text('Delete', style: TextStyle(color: EnterpriseTheme.rose))]),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.project.name, 
                style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(widget.isDark), fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.project.description.isEmpty ? 'No description' : widget.project.description,
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(widget.isDark), fontSize: 12, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.timeline_outlined, size: 12, color: EnterpriseTheme.getTextMuted(widget.isDark)),
                  const SizedBox(width: 4),
                  Text('PRJ-${widget.project.id}', style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(widget.isDark), fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, EnterpriseSDLCController controller, Project project, bool isDark) {
    final nameCtrl = TextEditingController(text: project.name);
    final descCtrl = TextEditingController(text: project.description);
    final primaryColor = EnterpriseTheme.getPrimaryAccent(isDark);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getSurface(isDark).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: EnterpriseTheme.getCardBorder(isDark).withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.edit_outlined, color: primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Text('Edit Workspace',
                          style: GoogleFonts.outfit(
                              color: EnterpriseTheme.getTextPrimary(isDark),
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildTextField('Project Name', nameCtrl, isDark, Icons.title),
                  const SizedBox(height: 20),
                  _buildTextField('Description', descCtrl, isDark, Icons.description, maxLines: 3),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty) {
                            controller.updateProject(project.id, nameCtrl.text, descCtrl.text);
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteProjectDialog(BuildContext context, EnterpriseSDLCController controller, Project project, bool isDark) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getSurface(isDark).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: EnterpriseTheme.rose.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: EnterpriseTheme.rose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48)),
                      ),
                      const SizedBox(width: 16),
                      Text('Delete Workspace',
                          style: GoogleFonts.outfit(
                              color: EnterpriseTheme.getTextPrimary(isDark),
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Are you sure you want to delete "${project.name}"? This will permanently remove all associated features and workflows. This action cannot be undone.',
                    style: GoogleFonts.inter(
                        color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.deleteProject(project.id);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, bool isDark, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: EnterpriseTheme.getTextMuted(isDark), size: 18),
            filled: true,
            fillColor: EnterpriseTheme.getSubtleBg(isDark),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark), width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _ModernFeatureCard extends StatefulWidget {
  final Feature feature;
  final EnterpriseSDLCController controller;
  final bool isDark;

  const _ModernFeatureCard({required this.feature, required this.controller, required this.isDark});

  @override
  State<_ModernFeatureCard> createState() => _ModernFeatureCardState();
}

class _ModernFeatureCardState extends State<_ModernFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.controller.selectFeature(widget.feature),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 240,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? EnterpriseTheme.getSubtleBg(widget.isDark) : EnterpriseTheme.getSurface(widget.isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? EnterpriseTheme.purple.withOpacity(0.5) : EnterpriseTheme.getCardBorder(widget.isDark),
            ),
            boxShadow: _isHovered ? [BoxShadow(color: EnterpriseTheme.purple.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: EnterpriseTheme.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.rocket_launch_outlined, color: EnterpriseTheme.purple, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.feature.name, style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(widget.isDark), fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 16, color: EnterpriseTheme.getTextSecondary(widget.isDark)),
                    padding: EdgeInsets.zero,
                    tooltip: 'Options',
                    onSelected: (val) {
                      if (val == 'edit') {
                        // _showEditFeatureDialog(context); // Optional: add an edit feature dialog here
                      } else if (val == 'delete') {
                        _showDeleteConfirmationDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [Icon(Icons.edit_outlined, size: 18), const SizedBox(width: 8), const Text('Edit')]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete_outline, size: 18, color: EnterpriseTheme.rose), const SizedBox(width: 8), Text('Delete', style: TextStyle(color: EnterpriseTheme.rose))]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EnterpriseTheme.getInputBg(widget.isDark).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REQUIREMENT', style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(widget.isDark), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(
                      widget.feature.baseRequirement.isEmpty ? 'No requirement specified' : widget.feature.baseRequirement,
                      style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(widget.isDark), fontSize: 11, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FTR-${widget.feature.id}', style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(widget.isDark), fontSize: 12, fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      Text('Open Workflow', style: GoogleFonts.inter(color: _isHovered ? EnterpriseTheme.purple : EnterpriseTheme.getTextSecondary(widget.isDark), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: _isHovered ? EnterpriseTheme.purple : EnterpriseTheme.getTextSecondary(widget.isDark)),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: EnterpriseTheme.getSurface(widget.isDark).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                      ),
                      const SizedBox(width: 16),
                      Text('Delete Feature', style: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(widget.isDark), fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Are you sure you want to delete "${widget.feature.name}"? This action cannot be undone and will permanently erase all associated workflows and data.',
                    style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(widget.isDark), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(foregroundColor: EnterpriseTheme.getTextSecondary(widget.isDark)),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.controller.deleteFeature(widget.feature.id);
                          Get.back();
                        },
                        icon: const Icon(Icons.delete_forever, size: 18),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
