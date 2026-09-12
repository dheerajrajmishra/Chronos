import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../services/api_service.dart';
import '../../models/workflow_model.dart';

class Stage0FeatureSetup extends StatefulWidget {
  const Stage0FeatureSetup({super.key});

  @override
  State<Stage0FeatureSetup> createState() => _Stage0FeatureSetupState();
}

class _Stage0FeatureSetupState extends State<Stage0FeatureSetup> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _codeRepoCtrl = TextEditingController();
  final _gitBranchCtrl = TextEditingController();
  final _dbUrlCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();
  final _memoryCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isSyncing = false;
  String _syncStatus = 'idle'; // idle, syncing, success, error

  @override
  void initState() {
    super.initState();
    final controller = Get.find<EnterpriseSDLCController>();
    final feature = controller.activeFeature.value;
    if (feature != null) {
      _nameCtrl.text = feature.name;
      _codeRepoCtrl.text = feature.codeAccess['repoUrl'] ?? '';
      _gitBranchCtrl.text = feature.codeAccess['branch'] ?? '';
      _dbUrlCtrl.text = feature.dbAccess['url'] ?? '';
      _reqCtrl.text = feature.baseRequirement;
      _promptCtrl.text = feature.brdPrompt;
      _memoryCtrl.text = feature.memoryMd;
      if (feature.memoryMd.isNotEmpty) {
        _syncStatus = 'success';
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeRepoCtrl.dispose();
    _gitBranchCtrl.dispose();
    _dbUrlCtrl.dispose();
    _reqCtrl.dispose();
    _promptCtrl.dispose();
    _memoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      
      if (feature == null) {
        return const Center(child: Text("No Feature Selected"));
      }
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────
            _buildHeader(isDark),
            const SizedBox(height: 28),
            
            // ─── Main Content: Two-column layout ─────────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ LEFT COLUMN: Configuration ═══
                  Expanded(
                    flex: 5,
                    child: _buildConfigColumn(isDark, controller, feature),
                  ),
                  const SizedBox(width: 24),
                  // ═══ RIGHT COLUMN: Repository Context ═══
                  Expanded(
                    flex: 5,
                    child: _buildContextColumn(isDark, controller, feature),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Bottom Action Bar ───────────────────────────────────
            _buildBottomBar(isDark, controller, feature),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Feature Setup', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
              const SizedBox(height: 4),
              Text('Configure your feature context, connect your repository, and prepare AI agents for the SDLC pipeline.',
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13, height: 1.4)),
            ],
          ),
        ),
        // Sync status badge
        _buildSyncStatusBadge(isDark),
      ],
    );
  }

  Widget _buildSyncStatusBadge(bool isDark) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;
    switch (_syncStatus) {
      case 'syncing':
        badgeColor = EnterpriseTheme.amber;
        badgeIcon = Icons.sync;
        badgeText = 'Syncing...';
        break;
      case 'success':
        badgeColor = EnterpriseTheme.emerald;
        badgeIcon = Icons.check_circle_outline;
        badgeText = 'Repo Connected';
        break;
      case 'error':
        badgeColor = EnterpriseTheme.rose;
        badgeIcon = Icons.error_outline;
        badgeText = 'Sync Failed';
        break;
      default:
        badgeColor = EnterpriseTheme.getTextMuted(isDark);
        badgeIcon = Icons.cloud_off_outlined;
        badgeText = 'Not Synced';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _syncStatus == 'syncing'
              ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: badgeColor))
              : Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(badgeText, style: GoogleFonts.inter(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // LEFT COLUMN – Configuration
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildConfigColumn(bool isDark, EnterpriseSDLCController controller, feature) {
    return Container(
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.04), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Feature Info
            _buildSectionLabel('FEATURE IDENTITY', Icons.label_outline, isDark),
            const SizedBox(height: 14),
            _buildInputField('Feature Name', _nameCtrl, isDark, Icons.label_outline, hint: 'e.g. Password Based Attachment'),
            const SizedBox(height: 24),

            // Section: Repository
            _buildSectionLabel('CODE REPOSITORY', Icons.code, isDark),
            const SizedBox(height: 14),
            _buildInputField('Git Repo URL', _codeRepoCtrl, isDark, Icons.link, hint: 'https://github.com/org/repo.git'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildInputField('Branch', _gitBranchCtrl, isDark, Icons.account_tree_outlined, hint: 'main'),
                ),
                const SizedBox(width: 12),
                _buildSyncButton(isDark, controller, feature),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Data Access
            _buildSectionLabel('DATA ACCESS', Icons.dns_outlined, isDark),
            const SizedBox(height: 14),
            _buildInputField('Database Connection URL', _dbUrlCtrl, isDark, Icons.dns_outlined, hint: 'postgresql://user:pass@host:5432/db'),
            const SizedBox(height: 24),

            // Section: Requirements
            _buildSectionLabel('REQUIREMENTS', Icons.description_outlined, isDark),
            const SizedBox(height: 14),
            _buildInputField('Base Requirements', _reqCtrl, isDark, Icons.format_quote, maxLines: 4, hint: 'Describe what this feature should do in plain English...'),
            const SizedBox(height: 14),
            _buildInputField('Custom BRD Prompt (Optional)', _promptCtrl, isDark, Icons.smart_toy_outlined, maxLines: 2, hint: 'e.g. Focus on HIPAA compliance, ignore mobile views...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton(bool isDark, EnterpriseSDLCController controller, feature) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: _isSyncing
            ? null
            : const LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
        color: _isSyncing ? EnterpriseTheme.getCardBgElevated(isDark) : null,
        borderRadius: BorderRadius.circular(10),
        boxShadow: _isSyncing
            ? []
            : [BoxShadow(color: const Color(0xFF059669).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSyncing ? null : () => _syncRepo(controller, feature),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isSyncing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.sync_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _isSyncing ? 'Syncing...' : 'Sync Repo',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _syncRepo(EnterpriseSDLCController controller, feature) async {
    if (_codeRepoCtrl.text.isEmpty) {
      controller.logTerminal("Please enter a Repo URL first.", level: "ERROR");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter a Git Repo URL first.'), backgroundColor: EnterpriseTheme.rose),
      );
      return;
    }
    setState(() { _isSyncing = true; _syncStatus = 'syncing'; });
    controller.logTerminal("Cloning repo and generating memory.md via LLM...", level: "INFO");
    try {
      final res = await ApiService.generateMemory(feature.projectId.toString(), _codeRepoCtrl.text, _gitBranchCtrl.text);
      _memoryCtrl.text = res['memoryMd'] ?? '';
      setState(() => _syncStatus = 'success');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Repository synced & memory.md generated!'), backgroundColor: Color(0xFF059669)),
        );
      }
    } catch (e) {
      setState(() => _syncStatus = 'error');
      controller.logTerminal("Failed to sync repository: $e", level: "ERROR");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Sync failed: $e'), backgroundColor: EnterpriseTheme.rose),
        );
      }
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // RIGHT COLUMN – Repository Context (memory.md)
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildContextColumn(bool isDark, EnterpriseSDLCController controller, feature) {
    final hasMemory = _memoryCtrl.text.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border.all(color: hasMemory ? EnterpriseTheme.emerald.withOpacity(0.4) : EnterpriseTheme.getCardBorder(isDark)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.04), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panel Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: hasMemory
                  ? EnterpriseTheme.emerald.withOpacity(isDark ? 0.08 : 0.05)
                  : EnterpriseTheme.getSubtleBg(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (hasMemory ? EnterpriseTheme.emerald : EnterpriseTheme.getTextMuted(isDark)).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasMemory ? Icons.memory_rounded : Icons.cloud_off_outlined,
                    size: 18,
                    color: hasMemory ? EnterpriseTheme.emerald : EnterpriseTheme.getTextMuted(isDark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Project Context', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: EnterpriseTheme.getTextPrimary(isDark))),
                      const SizedBox(height: 2),
                      Text(
                        hasMemory ? 'AI-generated from repository analysis' : 'Sync your repo or paste context manually',
                        style: GoogleFonts.inter(fontSize: 11, color: EnterpriseTheme.getTextMuted(isDark)),
                      ),
                    ],
                  ),
                ),
                if (hasMemory) ...[
                  _buildMiniAction(Icons.content_copy_rounded, 'Copy', isDark, () {
                    // No clipboard import needed for web
                  }),
                  const SizedBox(width: 4),
                  _buildMiniAction(Icons.delete_outline_rounded, 'Clear', isDark, () {
                    setState(() { _memoryCtrl.clear(); _syncStatus = 'idle'; });
                  }),
                ],
              ],
            ),
          ),

          // Body
          Expanded(
            child: hasMemory
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _memoryCtrl,
                      maxLines: null,
                      expands: true,
                      style: GoogleFonts.firaCode(
                        color: EnterpriseTheme.getTextPrimary(isDark),
                        fontSize: 12.5,
                        height: 1.7,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'memory.md content...',
                        hintStyle: GoogleFonts.firaCode(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 12.5),
                      ),
                    ),
                  )
                : _buildEmptyContextState(isDark, controller, feature),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction(IconData icon, String tooltip, bool isDark, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: EnterpriseTheme.getInputBg(isDark),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
          ),
          child: Icon(icon, size: 14, color: EnterpriseTheme.getTextSecondary(isDark)),
        ),
      ),
    );
  }

  Widget _buildEmptyContextState(bool isDark, EnterpriseSDLCController controller, feature) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: EnterpriseTheme.purple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.account_tree_outlined, size: 44, color: EnterpriseTheme.purple.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            Text('No Repository Context', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: EnterpriseTheme.getTextPrimary(isDark))),
            const SizedBox(height: 10),
            Text(
              'Click "Sync Repo" to clone your repository and let AI analyze your codebase to generate a project context file (memory.md).\n\nAlternatively, you can paste your own context below.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _syncRepo(controller, feature),
                  icon: const Icon(Icons.sync_rounded, size: 16),
                  label: Text('Sync from Repository', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EnterpriseTheme.emerald,
                    side: BorderSide(color: EnterpriseTheme.emerald.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Focus the memory text field for manual paste
                    setState(() {
                      _memoryCtrl.text = '# Project Context\n\n## Overview\nDescribe your project here...\n\n## Tech Stack\n- \n\n## Modules\n- \n';
                    });
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: Text('Write Manually', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
                    side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // BOTTOM ACTION BAR
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildBottomBar(bool isDark, EnterpriseSDLCController controller, feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.12 : 0.04), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          // Info chips
          _buildInfoChip(Icons.code, _codeRepoCtrl.text.isNotEmpty ? 'Repo linked' : 'No repo', _codeRepoCtrl.text.isNotEmpty, isDark),
          const SizedBox(width: 8),
          _buildInfoChip(Icons.memory, _memoryCtrl.text.isNotEmpty ? 'Context ready' : 'No context', _memoryCtrl.text.isNotEmpty, isDark),
          const SizedBox(width: 8),
          _buildInfoChip(Icons.description_outlined, _reqCtrl.text.isNotEmpty ? 'Requirements set' : 'No requirements', _reqCtrl.text.isNotEmpty, isDark),
          const Spacer(),
          // Save button
          _buildGradientButton(
            onPressed: _isSaving ? () {} : () async {
              setState(() => _isSaving = true);
              try {
                final updatedFeature = await ApiService.updateFeature(
                  feature.id,
                  name: _nameCtrl.text,
                  codeAccess: {'repoUrl': _codeRepoCtrl.text, 'branch': _gitBranchCtrl.text},
                  dbAccess: {'url': _dbUrlCtrl.text},
                  baseRequirement: _reqCtrl.text,
                  brdPrompt: _promptCtrl.text,
                  designPrompt: feature.designPrompt,
                  codePrompt: feature.codePrompt,
                  testPrompt: feature.testPrompt,
                  memoryMd: _memoryCtrl.text,
                );
                
                controller.activeFeature.value = updatedFeature;
                
                if (controller.activeProject.value?.id == updatedFeature.projectId) {
                  final index = controller.activeProjectFeatures.indexWhere((f) => f.id == updatedFeature.id);
                  if (index != -1) {
                    controller.activeProjectFeatures[index] = updatedFeature;
                  }
                }
                
                controller.logTerminal("Feature saved successfully.", level: "SUCCESS");
                controller.setStage(SDLCStageType.stage1Brd);
                
              } catch (e) {
                controller.logTerminal("Failed to save feature: $e", level: "ERROR");
              } finally {
                setState(() => _isSaving = false);
              }
            },
            icon: _isSaving ? Icons.hourglass_empty : Icons.arrow_forward_rounded,
            label: _isSaving ? 'Saving...' : 'Save & Proceed to BRD',
            isDark: isDark,
            gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isActive, bool isDark) {
    final color = isActive ? EnterpriseTheme.emerald : EnterpriseTheme.getTextMuted(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: EnterpriseTheme.getPrimaryAccent(isDark)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(
          color: EnterpriseTheme.getTextSecondary(isDark),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        )),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: EnterpriseTheme.getCardBorder(isDark), height: 1)),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, bool isDark, IconData icon, {int maxLines = 1, String? hint}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 13),
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.5), fontSize: 13),
        prefixIcon: maxLines == 1 ? Icon(icon, color: EnterpriseTheme.getTextMuted(isDark), size: 17) : null,
        filled: true,
        fillColor: EnterpriseTheme.getInputBg(isDark),
        contentPadding: EdgeInsets.symmetric(horizontal: maxLines > 1 ? 16 : 12, vertical: maxLines > 1 ? 16 : 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark), width: 1.5),
        ),
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
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
