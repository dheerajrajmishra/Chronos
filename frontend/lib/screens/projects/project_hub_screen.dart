import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
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
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Page Header ──────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(gradient: EnterpriseTheme.brandGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Projects & Access Hub', style: GoogleFonts.inter(color: textColor, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text('Configure projects, define code & database governance, and launch scoped pipelines.', style: GoogleFonts.inter(color: textSecColor, fontSize: 13)),
                    ],
                  ),
                ),
                _ActionButton(
                  label: 'New Project',
                  icon: Icons.add_rounded,
                  isDark: isDark,
                  onTap: () => _showCreateProjectDialog(context, controller, isDark),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Metrics ──────────────────────────────────
            Row(
              children: [
                Expanded(child: _metricCard(isDark: isDark, title: 'PROJECTS', value: '${projects.length}', subtitle: 'Policy guarded', color: primaryAccent, icon: Icons.folder_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _metricCard(isDark: isDark, title: 'PIPELINES', value: '${projects.fold<int>(0, (sum, p) => sum + p.activePipelinesCount)}', subtitle: 'Active', color: EnterpriseTheme.emerald, icon: Icons.hub_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _metricCard(isDark: isDark, title: 'CODE ACCESS', value: 'mTLS', subtitle: 'Signed commits', color: EnterpriseTheme.purple, icon: Icons.code_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _metricCard(isDark: isDark, title: 'DB ACCESS', value: 'JIT TTL', subtitle: 'PII tokenization', color: EnterpriseTheme.amber, icon: Icons.dns_outlined)),
              ],
            ),

            const SizedBox(height: 28),

            // ─── Section Label ────────────────────────────
            Text('WORKSPACES', style: GoogleFonts.inter(color: textMutedColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            const SizedBox(height: 14),

            // ─── Projects Grid ────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 2 : 1,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 320,
                ),
                itemBuilder: (context, index) {
                  final prj = projects[index];
                  final isSelected = activePrj?.id == prj.id;
                  return _ProjectCard(
                    controller: controller,
                    prj: prj,
                    isSelected: isSelected,
                    isDark: isDark,
                  );
                },
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _metricCard({required bool isDark, required String title, required String value, required String subtitle, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.1 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 20, fontWeight: FontWeight.w700)),
                Text(subtitle, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, EnterpriseSDLCController controller, bool isDark) {
    final nameCtrl = TextEditingController();
    final keyCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final repoUrlCtrl = TextEditingController();
    final branchCtrl = TextEditingController(text: 'main');
    final dbHostCtrl = TextEditingController(text: '10.240.1.12');
    final dbPortCtrl = TextEditingController(text: '5432');
    final dbNameCtrl = TextEditingController(text: 'enterprise_core_db');

    String selectedEnv = 'Staging Enclave (PCI-DSS 4.0)';
    String selectedSecTier = 'Tier 1 (Mission Critical)';
    String selectedCompliance = 'SOC2 Type II + PCI-DSS 4.0';
    String selectedGitProvider = 'GitHub Enterprise';
    String selectedAccessScope = 'PR Scaffolding (Automated PR Creation)';
    bool enforceSigned = true;
    bool secretScan = true;
    String selectedDbType = 'PostgreSQL (ACID Cluster)';
    String selectedDbPrivilege = 'Read-Write (Zero-Trust Tokenized)';
    int selectedJitTtl = 60;
    bool dynamicMask = true;

    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final cardBg = EnterpriseTheme.getCardBg(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: borderColor)),
            child: Container(
              width: 780,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(gradient: EnterpriseTheme.brandGradient, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text('Create Project Workspace', style: GoogleFonts.inter(color: textColor, fontSize: 17, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.close_rounded, color: EnterpriseTheme.getTextMuted(isDark), size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: borderColor, height: 28),

                    // Project basics
                    Row(
                      children: [
                        Expanded(flex: 3, child: _dialogField(isDark: isDark, label: 'Project Name', controller: nameCtrl, hint: 'e.g. Identity & Access Broker')),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: _dialogField(isDark: isDark, label: 'Key', controller: keyCtrl, hint: 'IAM-CORE')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogField(isDark: isDark, label: 'Description', controller: descCtrl, hint: 'High-level business context', maxLines: 2),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _dialogDropdown(isDark: isDark, label: 'Environment', value: selectedEnv, items: ['Staging Enclave (PCI-DSS 4.0)', 'GovCloud Health Enclave', 'Production GovCloud', 'Multi-Tenant Public Cloud'], onChanged: (v) => setModalState(() => selectedEnv = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _dialogDropdown(isDark: isDark, label: 'Security Tier', value: selectedSecTier, items: ['Tier 1 (Mission Critical)', 'Tier 1 (HIPAA Restricted)', 'Tier 1 (Identity Root)', 'Tier 2 (Standard Enterprise)'], onChanged: (v) => setModalState(() => selectedSecTier = v!))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogDropdown(isDark: isDark, label: 'Compliance', value: selectedCompliance, items: ['SOC2 Type II + PCI-DSS 4.0', 'HIPAA Security Rule + HITRUST', 'FedRAMP High + ISO 27001', 'GDPR & CCPA Standard'], onChanged: (v) => setModalState(() => selectedCompliance = v!)),

                    const SizedBox(height: 20),
                    Text('CODE ACCESS', style: GoogleFonts.inter(color: primaryAccent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    _dialogDropdown(isDark: isDark, label: 'Git Provider', value: selectedGitProvider, items: ['GitHub Enterprise', 'GitLab Security Tier', 'Azure DevOps', 'Bitbucket Data Center'], onChanged: (v) => setModalState(() => selectedGitProvider = v!)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(flex: 3, child: _dialogField(isDark: isDark, label: 'Repository URL', controller: repoUrlCtrl, hint: 'https://github.com/org/repo.git')),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: _dialogField(isDark: isDark, label: 'Branch', controller: branchCtrl, hint: 'main')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogDropdown(isDark: isDark, label: 'Access Scope', value: selectedAccessScope, items: ['Read-Only (Static Analysis)', 'PR Scaffolding (Automated PR Creation)', 'Full Write (Direct Branch Commit - Strict MFA)'], onChanged: (v) => setModalState(() => selectedAccessScope = v!)),
                    const SizedBox(height: 12),
                    _toggle(isDark: isDark, label: 'Enforce Signed Commits (GPG/SSH)', value: enforceSigned, onChanged: (v) => setModalState(() => enforceSigned = v), accent: primaryAccent),
                    _toggle(isDark: isDark, label: 'Pre-Commit Secret Scanning', value: secretScan, onChanged: (v) => setModalState(() => secretScan = v), accent: primaryAccent),

                    const SizedBox(height: 20),
                    Text('DATABASE ACCESS', style: GoogleFonts.inter(color: EnterpriseTheme.amber, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    _dialogDropdown(isDark: isDark, label: 'Database Engine', value: selectedDbType, items: ['PostgreSQL (ACID Cluster)', 'MongoDB (Encrypted Cluster)', 'Redis Cluster (In-Memory)', 'Snowflake Data Warehouse', 'MySQL Enterprise'], onChanged: (v) => setModalState(() => selectedDbType = v!)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(flex: 3, child: _dialogField(isDark: isDark, label: 'Host', controller: dbHostCtrl, hint: '10.240.1.12')),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: _dialogField(isDark: isDark, label: 'Port', controller: dbPortCtrl, hint: '5432')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogField(isDark: isDark, label: 'Database Name', controller: dbNameCtrl, hint: 'enterprise_core_db'),
                    const SizedBox(height: 12),
                    _dialogDropdown(isDark: isDark, label: 'Privilege', value: selectedDbPrivilege, items: ['Read-Only (Audit / Query)', 'Read-Write (Zero-Trust Tokenized)', 'DDL Migrations (Schema Admin Approval)'], onChanged: (v) => setModalState(() => selectedDbPrivilege = v!)),
                    const SizedBox(height: 12),
                    _dialogDropdown(isDark: isDark, label: 'JIT TTL', value: '$selectedJitTtl Minutes', items: ['15 Minutes', '60 Minutes', '480 Minutes'], onChanged: (v) => setModalState(() => selectedJitTtl = int.parse(v!.split(' ').first))),
                    const SizedBox(height: 12),
                    _toggle(isDark: isDark, label: 'Dynamic Column-Level PII Masking', value: dynamicMask, onChanged: (v) => setModalState(() => dynamicMask = v), accent: EnterpriseTheme.amber),

                    Divider(color: borderColor, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel', style: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (nameCtrl.text.trim().isEmpty || keyCtrl.text.trim().isEmpty) {
                                Get.snackbar('Missing Fields', 'Enter Project Name and Key.', backgroundColor: EnterpriseTheme.rose, colorText: Colors.white, borderRadius: 8);
                                return;
                              }
                              controller.createNewProject(
                                name: nameCtrl.text.trim(),
                                projectKey: keyCtrl.text.trim(),
                                description: descCtrl.text.trim().isEmpty ? 'Enterprise project workspace.' : descCtrl.text.trim(),
                                environment: selectedEnv,
                                securityTier: selectedSecTier,
                                complianceBaseline: selectedCompliance,
                                codeAccess: CodeAccessConfig(provider: selectedGitProvider, repoUrl: repoUrlCtrl.text.trim().isEmpty ? 'https://github.com/org/repo.git' : repoUrlCtrl.text.trim(), defaultBranch: branchCtrl.text.trim().isEmpty ? 'main' : branchCtrl.text.trim(), branchRule: 'feature/${keyCtrl.text.trim().toLowerCase()}-*', accessScope: selectedAccessScope, enforceSignedCommits: enforceSigned, preCommitSecretScan: secretScan),
                                dbAccess: DbAccessConfig(dbType: selectedDbType, host: dbHostCtrl.text.trim().isEmpty ? '10.240.1.12' : dbHostCtrl.text.trim(), port: int.tryParse(dbPortCtrl.text.trim()) ?? 5432, databaseName: dbNameCtrl.text.trim().isEmpty ? 'enterprise_db' : dbNameCtrl.text.trim(), privilegeLevel: selectedDbPrivilege, jitTtlMinutes: selectedJitTtl, enableDynamicMasking: dynamicMask, isVaulted: true),
                              );
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(gradient: EnterpriseTheme.brandGradient, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('Create Workspace', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  Widget _dialogField({required bool isDark, required String label, required TextEditingController controller, required String hint, int maxLines = 1}) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: textSecColor, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: textColor, fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 12),
            filled: true,
            fillColor: inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: EnterpriseTheme.getPrimaryAccent(isDark), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _dialogDropdown({required bool isDark, required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);
    final cardBgElevated = EnterpriseTheme.getCardBgElevated(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: textSecColor, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              dropdownColor: cardBgElevated,
              icon: Icon(Icons.expand_more_rounded, color: textSecColor, size: 18),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: GoogleFonts.inter(color: textColor, fontSize: 12)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggle({required bool isDark, required String label, required bool value, required ValueChanged<bool> onChanged, required Color accent}) {
    return SwitchListTile(
      title: Text(label, style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 12)),
      value: value,
      activeColor: accent,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: onChanged,
    );
  }
}

// ─── Project Card with hover ────────────────────────────────────────
class _ProjectCard extends StatefulWidget {
  final EnterpriseSDLCController controller;
  final ProjectWorkspace prj;
  final bool isSelected;
  final bool isDark;

  const _ProjectCard({required this.controller, required this.prj, required this.isSelected, required this.isDark});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final prj = widget.prj;
    final isSelected = widget.isSelected;
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: EnterpriseTheme.getCardBg(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryAccent.withValues(alpha: 0.6) : borderColor, width: isSelected ? 1.5 : 1.0),
          boxShadow: _isHovered
              ? [BoxShadow(color: (isSelected ? primaryAccent : Colors.black).withValues(alpha: isDark ? 0.2 : 0.08), blurRadius: 16, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryAccent.withValues(alpha: 0.12) : inputBg,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: isSelected ? primaryAccent.withValues(alpha: 0.4) : borderColor),
                  ),
                  child: Text(prj.projectKey, style: GoogleFonts.jetBrainsMono(color: isSelected ? primaryAccent : textColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(prj.name, style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: EnterpriseTheme.emerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('ACTIVE', style: GoogleFonts.inter(color: EnterpriseTheme.emerald, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(prj.description, style: GoogleFonts.inter(color: textSecColor, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),

            Divider(color: borderColor, height: 18),

            // Code access
            _accessRow(
              icon: Icons.code_rounded,
              iconColor: primaryAccent,
              title: prj.codeAccess.provider,
              subtitle: prj.codeAccess.repoUrl,
              badge: prj.codeAccess.accessScope.split(' ').first,
              badgeColor: EnterpriseTheme.purple,
              isDark: isDark,
              textMutedColor: textMutedColor,
            ),
            const SizedBox(height: 8),
            // DB access
            _accessRow(
              icon: Icons.dns_outlined,
              iconColor: EnterpriseTheme.amber,
              title: prj.dbAccess.dbType.split(' ').first,
              subtitle: "${prj.dbAccess.host}:${prj.dbAccess.port}/${prj.dbAccess.databaseName}",
              badge: 'JIT ${prj.dbAccess.jitTtlMinutes}m',
              badgeColor: EnterpriseTheme.emerald,
              isDark: isDark,
              textMutedColor: textMutedColor,
            ),

            const Spacer(),

            // Footer
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: EnterpriseTheme.getSubtleBg(isDark), borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 11, color: EnterpriseTheme.emerald),
                      const SizedBox(width: 4),
                      Text(prj.complianceBaseline.split('+').first.trim(), style: GoogleFonts.inter(color: textColor, fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Spacer(),
                if (!isSelected)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.controller.selectProject(prj),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor)),
                        child: Text('Select', style: GoogleFonts.inter(color: textColor, fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.controller.initiatePipelineForProject(prj),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(gradient: EnterpriseTheme.brandGradient, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('Pipeline', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _accessRow({required IconData icon, required Color iconColor, required String title, required String subtitle, required String badge, required Color badgeColor, required bool isDark, required Color textMutedColor}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getInputBg(isDark),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: GoogleFonts.inter(color: iconColor, fontSize: 10, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: badgeColor.withValues(alpha: isDark ? 0.12 : 0.08), borderRadius: BorderRadius.circular(3)),
                      child: Text(badge, style: GoogleFonts.inter(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Text(subtitle, style: GoogleFonts.jetBrainsMono(color: textMutedColor, fontSize: 10), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Button with hover ───────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _ActionButton({required this.label, required this.icon, required this.onTap, required this.isDark});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: EnterpriseTheme.brandGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [BoxShadow(color: EnterpriseTheme.brandBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(widget.label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
