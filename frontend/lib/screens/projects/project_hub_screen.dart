import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_special_outlined, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enterprise Project Workspaces & Access Hub',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Configure enterprise projects, define strict Code Repository Access and Database Access governance, and launch scoped feature pipelines.',
                        style: TextStyle(color: textSecColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateProjectDialog(context, controller, isDark),
                  icon: const Icon(Icons.add_circle, size: 16, color: Colors.black),
                  label: const Text(
                    'Setup New Project',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? EnterpriseTheme.cyan : const Color(0xFF00C9DB),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top Status Overview
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    isDark: isDark,
                    title: 'ACTIVE PROJECTS',
                    value: '${projects.length} Workspaces',
                    subtitle: '100% Policy Guarded',
                    color: primaryAccent,
                    icon: Icons.domain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    isDark: isDark,
                    title: 'ACTIVE FEATURE PIPELINES',
                    value: '${projects.fold<int>(0, (sum, p) => sum + p.activePipelinesCount)} Running',
                    subtitle: 'Temporal State Machines',
                    color: EnterpriseTheme.emerald,
                    icon: Icons.hub_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    isDark: isDark,
                    title: 'CODE ACCESS GOVERNANCE',
                    value: 'mTLS + Signed Commits',
                    subtitle: 'GitHub / GitLab / Azure',
                    color: EnterpriseTheme.purple,
                    icon: Icons.code,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    isDark: isDark,
                    title: 'DATABASE ACCESS VAULT',
                    value: 'JIT Ephemeral TTL',
                    subtitle: 'Dynamic PII Tokenization',
                    color: EnterpriseTheme.amber,
                    icon: Icons.dns_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Section Title
            Text(
              'MANAGED PROJECT WORKSPACES',
              style: TextStyle(
                color: textSecColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 14),

            // Projects Grid
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 340,
                ),
                itemBuilder: (context, index) {
                  final prj = projects[index];
                  final isSelected = activePrj?.id == prj.id;

                  return _projectCard(context, controller, prj, isSelected, isDark);
                },
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _projectCard(
    BuildContext context,
    EnterpriseSDLCController controller,
    ProjectWorkspace prj,
    bool isSelected,
    bool isDark,
  ) {
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EnterpriseTheme.cardDecoration(
        isDark: isDark,
        borderColor: isSelected ? primaryAccent : borderColor,
        glow: isSelected,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Key + Name + Active Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? primaryAccent.withValues(alpha: 0.15) : inputBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isSelected ? primaryAccent : borderColor),
                ),
                child: Text(
                  prj.projectKey,
                  style: TextStyle(
                    color: isSelected ? primaryAccent : textColor,
                    fontFamily: 'Consolas',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  prj.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: EnterpriseTheme.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE WORKSPACE',
                    style: TextStyle(color: EnterpriseTheme.emerald, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            prj.description,
            style: TextStyle(color: textSecColor, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          Divider(color: borderColor, height: 20),

          // Code Access Policy Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.code, size: 16, color: primaryAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "CODE: ${prj.codeAccess.provider}",
                            style: TextStyle(color: primaryAccent, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: EnterpriseTheme.purple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              prj.codeAccess.accessScope.split(' ').first,
                              style: const TextStyle(color: EnterpriseTheme.purple, fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        prj.codeAccess.repoUrl,
                        style: TextStyle(color: textMutedColor, fontFamily: 'Consolas', fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // DB Access Policy Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.dns_outlined, size: 16, color: EnterpriseTheme.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "DB: ${prj.dbAccess.dbType.split(' ').first}",
                            style: const TextStyle(color: EnterpriseTheme.amber, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "JIT TTL: ${prj.dbAccess.jitTtlMinutes}m",
                            style: const TextStyle(color: EnterpriseTheme.emerald, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        "${prj.dbAccess.host}:${prj.dbAccess.port}/${prj.dbAccess.databaseName}",
                        style: TextStyle(color: textMutedColor, fontFamily: 'Consolas', fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Footer Action Buttons
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 12, color: EnterpriseTheme.emerald),
                    const SizedBox(width: 4),
                    Text(
                      prj.complianceBaseline.split('+').first.trim(),
                      style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!isSelected)
                OutlinedButton(
                  onPressed: () => controller.selectProject(prj),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('Select Project', style: TextStyle(color: textColor, fontSize: 11)),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => controller.initiatePipelineForProject(prj),
                icon: const Icon(Icons.bolt, size: 14, color: Colors.black),
                label: const Text('Start Pipeline', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? EnterpriseTheme.cyan : const Color(0xFF00C9DB),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required bool isDark,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textMutedColor = EnterpriseTheme.getTextMuted(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.25)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textMutedColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
    final cardBg = EnterpriseTheme.getCardBg(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor),
            ),
            child: Container(
              width: 800,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.domain_add, color: primaryAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Register New Enterprise Project Workspace',
                          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: EnterpriseTheme.getTextMuted(isDark)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    Divider(color: borderColor, height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _dialogField(isDark: isDark, label: 'Project Name', controller: nameCtrl, hint: 'e.g. Identity & Access Broker'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _dialogField(isDark: isDark, label: 'Project Key', controller: keyCtrl, hint: 'e.g. IAM-CORE'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogField(isDark: isDark, label: 'Project Description', controller: descCtrl, hint: 'High-level business context & architecture mission', maxLines: 2),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _dialogDropdown(
                            isDark: isDark,
                            label: 'Deployment Environment',
                            value: selectedEnv,
                            items: [
                              'Staging Enclave (PCI-DSS 4.0)',
                              'GovCloud Health Enclave',
                              'Production GovCloud',
                              'Multi-Tenant Public Cloud',
                            ],
                            onChanged: (v) => setModalState(() => selectedEnv = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dialogDropdown(
                            isDark: isDark,
                            label: 'Security Tier',
                            value: selectedSecTier,
                            items: [
                              'Tier 1 (Mission Critical)',
                              'Tier 1 (HIPAA Restricted)',
                              'Tier 1 (Identity Root)',
                              'Tier 2 (Standard Enterprise)',
                            ],
                            onChanged: (v) => setModalState(() => selectedSecTier = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogDropdown(
                      isDark: isDark,
                      label: 'Compliance Baseline',
                      value: selectedCompliance,
                      items: [
                        'SOC2 Type II + PCI-DSS 4.0',
                        'HIPAA Security Rule + HITRUST',
                        'FedRAMP High + ISO 27001',
                        'GDPR & CCPA Standard',
                      ],
                      onChanged: (v) => setModalState(() => selectedCompliance = v!),
                    ),
                    const SizedBox(height: 20),
                    Text('SOURCE CODE ACCESS GOVERNANCE', style: TextStyle(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      isDark: isDark,
                      label: 'Git Provider',
                      value: selectedGitProvider,
                      items: ['GitHub Enterprise', 'GitLab Security Tier', 'Azure DevOps', 'Bitbucket Data Center'],
                      onChanged: (v) => setModalState(() => selectedGitProvider = v!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(flex: 3, child: _dialogField(isDark: isDark, label: 'Repository URL', controller: repoUrlCtrl, hint: 'https://github.com/org/repo.git')),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: _dialogField(isDark: isDark, label: 'Default Branch', controller: branchCtrl, hint: 'main')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogDropdown(
                      isDark: isDark,
                      label: 'Repository Access Scope',
                      value: selectedAccessScope,
                      items: [
                        'Read-Only (Static Analysis)',
                        'PR Scaffolding (Automated PR Creation)',
                        'Full Write (Direct Branch Commit - Strict MFA)',
                      ],
                      onChanged: (v) => setModalState(() => selectedAccessScope = v!),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('Enforce Cryptographically Signed Commits (GPG/SSH)', style: TextStyle(color: textColor, fontSize: 12)),
                      value: enforceSigned,
                      activeThumbColor: primaryAccent,
                      onChanged: (v) => setModalState(() => enforceSigned = v),
                    ),
                    SwitchListTile(
                      title: Text('Enforce Pre-Commit Secret Scanning Hook', style: TextStyle(color: textColor, fontSize: 12)),
                      value: secretScan,
                      activeThumbColor: primaryAccent,
                      onChanged: (v) => setModalState(() => secretScan = v),
                    ),
                    const SizedBox(height: 20),
                    const Text('DATABASE ACCESS GOVERNANCE', style: TextStyle(color: EnterpriseTheme.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      isDark: isDark,
                      label: 'Target Database Engine',
                      value: selectedDbType,
                      items: [
                        'PostgreSQL (ACID Cluster)',
                        'MongoDB (Encrypted Cluster)',
                        'Redis Cluster (In-Memory)',
                        'Snowflake Data Warehouse',
                        'MySQL Enterprise',
                      ],
                      onChanged: (v) => setModalState(() => selectedDbType = v!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(flex: 3, child: _dialogField(isDark: isDark, label: 'Host IP / Hostname', controller: dbHostCtrl, hint: '10.240.1.12')),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: _dialogField(isDark: isDark, label: 'Port', controller: dbPortCtrl, hint: '5432')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogField(isDark: isDark, label: 'Database Name', controller: dbNameCtrl, hint: 'enterprise_core_db'),
                    const SizedBox(height: 12),
                    _dialogDropdown(
                      isDark: isDark,
                      label: 'Access Privilege Level',
                      value: selectedDbPrivilege,
                      items: [
                        'Read-Only (Audit / Query)',
                        'Read-Write (Zero-Trust Tokenized)',
                        'DDL Migrations (Schema Admin Approval)',
                      ],
                      onChanged: (v) => setModalState(() => selectedDbPrivilege = v!),
                    ),
                    const SizedBox(height: 12),
                    _dialogDropdown(
                      isDark: isDark,
                      label: 'Just-In-Time (JIT) Credential Rotation TTL',
                      value: '$selectedJitTtl Minutes',
                      items: ['15 Minutes', '60 Minutes', '480 Minutes'],
                      onChanged: (v) => setModalState(() => selectedJitTtl = int.parse(v!.split(' ').first)),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('Enforce Dynamic Column-Level PII Masking on Query', style: TextStyle(color: textColor, fontSize: 12)),
                      value: dynamicMask,
                      activeThumbColor: primaryAccent,
                      onChanged: (v) => setModalState(() => dynamicMask = v),
                    ),
                    Divider(color: borderColor, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel', style: TextStyle(color: EnterpriseTheme.getTextMuted(isDark))),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (nameCtrl.text.trim().isEmpty || keyCtrl.text.trim().isEmpty) {
                              Get.snackbar('Input Error', 'Please enter Project Name and Key.', backgroundColor: Colors.red, colorText: Colors.white);
                              return;
                            }
                            controller.createNewProject(
                              name: nameCtrl.text.trim(),
                              projectKey: keyCtrl.text.trim(),
                              description: descCtrl.text.trim().isEmpty ? 'Enterprise project workspace.' : descCtrl.text.trim(),
                              environment: selectedEnv,
                              securityTier: selectedSecTier,
                              complianceBaseline: selectedCompliance,
                              codeAccess: CodeAccessConfig(
                                provider: selectedGitProvider,
                                repoUrl: repoUrlCtrl.text.trim().isEmpty ? 'https://github.com/org/repo.git' : repoUrlCtrl.text.trim(),
                                defaultBranch: branchCtrl.text.trim().isEmpty ? 'main' : branchCtrl.text.trim(),
                                branchRule: 'feature/${keyCtrl.text.trim().toLowerCase()}-*',
                                accessScope: selectedAccessScope,
                                enforceSignedCommits: enforceSigned,
                                preCommitSecretScan: secretScan,
                              ),
                              dbAccess: DbAccessConfig(
                                dbType: selectedDbType,
                                host: dbHostCtrl.text.trim().isEmpty ? '10.240.1.12' : dbHostCtrl.text.trim(),
                                port: int.tryParse(dbPortCtrl.text.trim()) ?? 5432,
                                databaseName: dbNameCtrl.text.trim().isEmpty ? 'enterprise_db' : dbNameCtrl.text.trim(),
                                privilegeLevel: selectedDbPrivilege,
                                jitTtlMinutes: selectedJitTtl,
                                enableDynamicMasking: dynamicMask,
                                isVaulted: true,
                              ),
                            );
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.check, size: 16, color: Colors.black),
                          label: const Text('Create Project Workspace', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? EnterpriseTheme.cyan : const Color(0xFF00C9DB),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _dialogField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSecColor, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: textColor, fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 12),
            filled: true,
            fillColor: inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
          ),
        ),
      ],
    );
  }

  Widget _dialogDropdown({
    required bool isDark,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final textColor = EnterpriseTheme.getTextPrimary(isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);
    final cardBgElevated = EnterpriseTheme.getCardBgElevated(isDark);
    final borderColor = EnterpriseTheme.getCardBorder(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSecColor, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              dropdownColor: cardBgElevated,
              icon: Icon(Icons.arrow_drop_down, color: textSecColor),
              style: TextStyle(color: textColor, fontSize: 12),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
