import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class ProjectHubScreen extends StatelessWidget {
  const ProjectHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final projects = controller.projectList;
      final activePrj = controller.activeProject.value;

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
                    children: const [
                      Text(
                        'Enterprise Project Workspaces & Access Hub',
                        style: TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Configure enterprise projects, define strict Code Repository Access and Database Access governance, and launch scoped feature pipelines.',
                        style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateProjectDialog(context, controller),
                  icon: const Icon(Icons.add_circle, size: 16, color: Colors.black),
                  label: const Text(
                    'Setup New Project',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnterpriseTheme.cyan,
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
                    title: 'ACTIVE PROJECTS',
                    value: '${projects.length} Workspaces',
                    subtitle: '100% Policy Guarded',
                    color: EnterpriseTheme.cyan,
                    icon: Icons.domain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
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
            const Text(
              'MANAGED PROJECT WORKSPACES',
              style: TextStyle(
                color: EnterpriseTheme.textSecondary,
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
                  mainAxisExtent: 320,
                ),
                itemBuilder: (context, index) {
                  final prj = projects[index];
                  final isSelected = activePrj?.id == prj.id;

                  return _projectCard(context, controller, prj, isSelected);
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
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EnterpriseTheme.cardDecoration(
        borderColor: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.cardBorder,
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
                  color: isSelected ? EnterpriseTheme.cyan.withValues(alpha: 0.15) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.cardBorder),
                ),
                child: Text(
                  prj.projectKey,
                  style: TextStyle(
                    color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.textPrimary,
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
                  style: const TextStyle(
                    color: EnterpriseTheme.textPrimary,
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
            style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Divider(color: EnterpriseTheme.cardBorder, height: 20),

          // Code Access Policy Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: EnterpriseTheme.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.code, size: 16, color: EnterpriseTheme.cyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "CODE: ${prj.codeAccess.provider}",
                            style: const TextStyle(color: EnterpriseTheme.cyan, fontSize: 10, fontWeight: FontWeight.bold),
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
                        style: const TextStyle(color: EnterpriseTheme.textMuted, fontFamily: 'Consolas', fontSize: 10),
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
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: EnterpriseTheme.cardBorder),
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
                        style: const TextStyle(color: EnterpriseTheme.textMuted, fontFamily: 'Consolas', fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Actions Row: Select Workspace / Launch Pipeline
          Row(
            children: [
              OutlinedButton(
                onPressed: () => controller.selectProject(prj),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(
                  isSelected ? 'Selected' : 'Select Workspace',
                  style: TextStyle(
                    color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.textPrimary,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.initiatePipelineForProject(prj),
                  icon: const Icon(Icons.bolt, size: 14, color: Colors.black),
                  label: const Text(
                    'Launch Pipeline',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnterpriseTheme.cyan,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, EnterpriseSDLCController controller) {
    final nameCtrl = TextEditingController(text: 'Enterprise Payments Core');
    final keyCtrl = TextEditingController(text: 'PAY-CORE');
    final descCtrl = TextEditingController(text: 'Zero-trust payment authorization engine with card tokenization vault.');
    final repoUrlCtrl = TextEditingController(text: 'https://github.com/enterprise-org/payments-core.git');
    final branchCtrl = TextEditingController(text: 'feature/payment-*');
    final dbHostCtrl = TextEditingController(text: '10.240.1.12');
    final dbPortCtrl = TextEditingController(text: '5432');
    final dbNameCtrl = TextEditingController(text: 'payments_prod_db');

    String selectedEnv = 'Staging Enclave (PCI-DSS 4.0)';
    String selectedTier = 'Tier 1 (Mission Critical)';
    String selectedCompliance = 'SOC2 Type II + PCI-DSS 4.0';
    String selectedGitProvider = 'GitHub Enterprise';
    String selectedCodeScope = 'PR Scaffolding (Automated PR Creation)';
    String selectedDbType = 'PostgreSQL (ACID Cluster)';
    String selectedDbPrivilege = 'Read-Write (Zero-Trust Tokenized)';
    int selectedJitTtl = 60;
    bool enforceSigned = true;
    bool secretScan = true;
    bool dynamicMask = true;

    int activeTab = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: EnterpriseTheme.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: EnterpriseTheme.cardBorder, width: 1.5),
            ),
            child: Container(
              width: 720,
              height: 600,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: EnterpriseTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.domain_add, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Setup New Enterprise Project Workspace',
                              style: TextStyle(
                                color: EnterpriseTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Define identity, code repository permissions, and zero-trust database access.',
                              style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: EnterpriseTheme.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Configuration Tabs
                  Row(
                    children: [
                      _tabHeader('1. General Information', 0, activeTab, (i) => setDialogState(() => activeTab = i)),
                      const SizedBox(width: 10),
                      _tabHeader('2. Code Repository Access', 1, activeTab, (i) => setDialogState(() => activeTab = i)),
                      const SizedBox(width: 10),
                      _tabHeader('3. Database Access Governance', 2, activeTab, (i) => setDialogState(() => activeTab = i)),
                    ],
                  ),

                  const Divider(color: EnterpriseTheme.cardBorder, height: 24),

                  // Tab Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: activeTab == 0
                          ? _buildGeneralTab(
                              nameCtrl, keyCtrl, descCtrl, selectedEnv, selectedTier, selectedCompliance,
                              (env) => setDialogState(() => selectedEnv = env),
                              (tier) => setDialogState(() => selectedTier = tier),
                              (comp) => setDialogState(() => selectedCompliance = comp),
                            )
                          : activeTab == 1
                              ? _buildCodeAccessTab(
                                  repoUrlCtrl, branchCtrl, selectedGitProvider, selectedCodeScope, enforceSigned, secretScan,
                                  (prov) => setDialogState(() => selectedGitProvider = prov),
                                  (scope) => setDialogState(() => selectedCodeScope = scope),
                                  (sign) => setDialogState(() => enforceSigned = sign),
                                  (scan) => setDialogState(() => secretScan = scan),
                                )
                              : _buildDbAccessTab(
                                  dbHostCtrl, dbPortCtrl, dbNameCtrl, selectedDbType, selectedDbPrivilege, selectedJitTtl, dynamicMask,
                                  (db) => setDialogState(() => selectedDbType = db),
                                  (priv) => setDialogState(() => selectedDbPrivilege = priv),
                                  (ttl) => setDialogState(() => selectedJitTtl = ttl),
                                  (mask) => setDialogState(() => dynamicMask = mask),
                                ),
                    ),
                  ),

                  const Divider(color: EnterpriseTheme.cardBorder, height: 24),

                  // Footer Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: EnterpriseTheme.textMuted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.createNewProject(
                            name: nameCtrl.text,
                            projectKey: keyCtrl.text,
                            description: descCtrl.text,
                            environment: selectedEnv,
                            securityTier: selectedTier,
                            complianceBaseline: selectedCompliance,
                            codeAccess: CodeAccessConfig(
                              provider: selectedGitProvider,
                              repoUrl: repoUrlCtrl.text,
                              branchRule: branchCtrl.text,
                              accessScope: selectedCodeScope,
                              enforceSignedCommits: enforceSigned,
                              preCommitSecretScan: secretScan,
                            ),
                            dbAccess: DbAccessConfig(
                              dbType: selectedDbType,
                              host: dbHostCtrl.text,
                              port: int.tryParse(dbPortCtrl.text) ?? 5432,
                              databaseName: dbNameCtrl.text,
                              privilegeLevel: selectedDbPrivilege,
                              jitTtlMinutes: selectedJitTtl,
                              enableDynamicMasking: dynamicMask,
                              isVaulted: true,
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.check, size: 16, color: Colors.black),
                        label: const Text(
                          'Save Project & Initialize Policies',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EnterpriseTheme.cyan,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _tabHeader(String title, int index, int current, ValueChanged<int> onSelect) {
    final isSelected = index == current;
    return InkWell(
      onTap: () => onSelect(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? EnterpriseTheme.cyan.withValues(alpha: 0.15) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.cardBorder),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab(
    TextEditingController nameCtrl,
    TextEditingController keyCtrl,
    TextEditingController descCtrl,
    String env,
    String tier,
    String compliance,
    ValueChanged<String> onEnvChanged,
    ValueChanged<String> onTierChanged,
    ValueChanged<String> onCompChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _dialogField(label: 'Project Name', controller: nameCtrl, hint: 'e.g. Fintech Payments Core'),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _dialogField(label: 'Project Key', controller: keyCtrl, hint: 'PAY-CORE'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _dialogField(label: 'Description', controller: descCtrl, hint: 'Summary of project scope and architecture'),
        const SizedBox(height: 12),
        _dialogDropdown(
          label: 'Deployment Environment',
          value: env,
          items: [
            'Dev Sandbox',
            'Staging Enclave (PCI-DSS 4.0)',
            'Production GovCloud Health Enclave',
            'Air-Gapped Private VPC',
          ],
          onChanged: (v) => onEnvChanged(v!),
        ),
        const SizedBox(height: 12),
        _dialogDropdown(
          label: 'Security Tier',
          value: tier,
          items: [
            'Tier 1 (Mission Critical)',
            'Tier 2 (Enterprise Standard)',
            'Tier 3 (Internal Non-Sensitive)',
          ],
          onChanged: (v) => onTierChanged(v!),
        ),
        const SizedBox(height: 12),
        _dialogDropdown(
          label: 'Compliance Baseline',
          value: compliance,
          items: [
            'SOC2 Type II + PCI-DSS 4.0',
            'HIPAA Security Rule + HITRUST',
            'FedRAMP High + ISO 27001',
            'GDPR / CCPA Data Privacy',
          ],
          onChanged: (v) => onCompChanged(v!),
        ),
      ],
    );
  }

  Widget _buildCodeAccessTab(
    TextEditingController repoUrlCtrl,
    TextEditingController branchCtrl,
    String provider,
    String scope,
    bool enforceSigned,
    bool secretScan,
    ValueChanged<String> onProvChanged,
    ValueChanged<String> onScopeChanged,
    ValueChanged<bool> onSignChanged,
    ValueChanged<bool> onScanChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dialogDropdown(
          label: 'Git Source Code Provider',
          value: provider,
          items: [
            'GitHub Enterprise',
            'GitLab Security Tier',
            'Azure DevOps',
            'Bitbucket Data Center',
          ],
          onChanged: (v) => onProvChanged(v!),
        ),
        const SizedBox(height: 12),
        _dialogField(label: 'Repository URL (mTLS Authenticated)', controller: repoUrlCtrl, hint: 'https://github.com/org/repo.git'),
        const SizedBox(height: 12),
        _dialogField(label: 'Target Feature Branch Pattern', controller: branchCtrl, hint: 'feature/payment-*'),
        const SizedBox(height: 12),
        _dialogDropdown(
          label: 'Code Access Permission Scope',
          value: scope,
          items: [
            'Read-Only (Static Analysis & SBOM)',
            'PR Scaffolding (Automated PR Creation)',
            'Direct Commit (Restricted Signoff)',
          ],
          onChanged: (v) => onScopeChanged(v!),
        ),
        const SizedBox(height: 14),
        SwitchListTile(
          title: const Text('Enforce Cryptographically Signed Commits (GPG/SSH)', style: TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12)),
          value: enforceSigned,
          activeColor: EnterpriseTheme.cyan,
          onChanged: onSignChanged,
        ),
        SwitchListTile(
          title: const Text('Enforce Pre-Commit Secret Scanning Hook', style: TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12)),
          value: secretScan,
          activeColor: EnterpriseTheme.cyan,
          onChanged: onScanChanged,
        ),
      ],
    );
  }

  Widget _buildDbAccessTab(
    TextEditingController hostCtrl,
    TextEditingController portCtrl,
    TextEditingController nameCtrl,
    String dbType,
    String privilege,
    int jitTtl,
    bool dynamicMask,
    ValueChanged<String> onDbChanged,
    ValueChanged<String> onPrivChanged,
    ValueChanged<int> onTtlChanged,
    ValueChanged<bool> onMaskChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dialogDropdown(
          label: 'Target Database Engine',
          value: dbType,
          items: [
            'PostgreSQL (ACID Cluster)',
            'MongoDB (Encrypted Cluster)',
            'Redis Cluster (In-Memory)',
            'Snowflake Data Warehouse',
            'MySQL Enterprise',
          ],
          onChanged: (v) => onDbChanged(v!),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(flex: 3, child: _dialogField(label: 'Database Host / Cluster IP', controller: hostCtrl, hint: '10.240.1.12')),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: _dialogField(label: 'Port', controller: portCtrl, hint: '5432')),
          ],
        ),
        const SizedBox(height: 12),
        _dialogField(label: 'Database / Schema Name', controller: nameCtrl, hint: 'payments_prod_db'),
        const SizedBox(height: 12),
        _dialogDropdown(
          label: 'Access Privilege Level',
          value: privilege,
          items: [
            'Read-Only (Audit / Query)',
            'Read-Write (Zero-Trust Tokenized)',
            'DDL Migrations (Schema Admin Approval)',
          ],
          onChanged: (v) => onPrivChanged(v!),
        ),
        const SizedBox(height: 12),
        _dialogDropdown(
          label: 'Just-In-Time (JIT) Credential Rotation TTL',
          value: '$jitTtl Minutes',
          items: ['15 Minutes', '60 Minutes', '480 Minutes'],
          onChanged: (v) => onTtlChanged(int.parse(v!.split(' ').first)),
        ),
        const SizedBox(height: 14),
        SwitchListTile(
          title: const Text('Enforce Dynamic Column-Level PII Masking on Query', style: TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12)),
          value: dynamicMask,
          activeColor: EnterpriseTheme.cyan,
          onChanged: onMaskChanged,
        ),
      ],
    );
  }

  Widget _dialogField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFF0F172A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: EnterpriseTheme.cardBorder)),
          ),
        ),
      ],
    );
  }

  Widget _dialogDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: EnterpriseTheme.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: EnterpriseTheme.cardBgElevated,
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 12)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EnterpriseTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: EnterpriseTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
