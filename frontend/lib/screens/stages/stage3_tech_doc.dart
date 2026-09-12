import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';
import '../../services/api_service.dart';
import '../../utils/doc_exporter.dart';

class Stage3TechDoc extends StatefulWidget {
  const Stage3TechDoc({super.key});

  @override
  State<Stage3TechDoc> createState() => _Stage3TechDocState();
}

class _Stage3TechDocState extends State<Stage3TechDoc> {
  final _promptCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final feature = Get.find<EnterpriseSDLCController>().activeFeature.value;
    if (feature != null && feature.techDocPrompt.isNotEmpty) {
      _promptCtrl.text = feature.techDocPrompt;
    } else {
      _promptCtrl.text = 'Generate a low-level Technical Specification (LLD) with exact REST/gRPC API contracts, request/response JSON schemas, PostgreSQL DDL migrations, and Zero-Trust cryptographic boundary controls.';
    }
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      final wf = controller.activeWorkflow.value;

      if (feature == null) {
        return _buildNoFeatureState(isDark);
      }

      final techDocContent = wf?.stageData['tech_doc_content'] as String?;

      return Container(
        color: EnterpriseTheme.getBackground(isDark),
        child: Column(
          children: [
            // Stage Header Bar
            _buildStageHeader(isDark, techDocContent != null),

            // Main Viewport
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Control Sidebar (Prompt & Technical Context)
                  SizedBox(
                    width: 360,
                    child: _buildControlsPanel(isDark, controller, feature, techDocContent != null),
                  ),

                  // Divider
                  VerticalDivider(width: 1, color: EnterpriseTheme.getCardBorder(isDark)),

                  // Right Deliverable Viewport (Technical Document Markdown View)
                  Expanded(
                    child: _buildDocumentViewport(isDark, techDocContent, feature.name),
                  ),
                ],
              ),
            ),

            // Bottom Navigation & Approval Bar
            _buildBottomBar(isDark, controller, feature, techDocContent),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // STAGE HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildStageHeader(bool isDark, bool hasDoc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border(bottom: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: EnterpriseTheme.brandBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: EnterpriseTheme.brandBlue.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.terminal_rounded, size: 14, color: EnterpriseTheme.brandBlue),
                const SizedBox(width: 6),
                Text(
                  'STAGE 03',
                  style: GoogleFonts.jetBrainsMono(
                    color: EnterpriseTheme.brandBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Technical Document',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: EnterpriseTheme.getTextPrimary(isDark),
                ),
              ),
              Text(
                'Low-Level Architecture, API Endpoint Schemas, Database DDL & Cryptographic Boundary Controls',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: EnterpriseTheme.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: hasDoc ? EnterpriseTheme.emerald.withValues(alpha: 0.1) : EnterpriseTheme.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: (hasDoc ? EnterpriseTheme.emerald : EnterpriseTheme.amber).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: hasDoc ? EnterpriseTheme.emerald : EnterpriseTheme.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  hasDoc ? 'TECHNICAL SPEC READY' : 'SPECIFICATION DRAFT',
                  style: GoogleFonts.inter(
                    color: hasDoc ? EnterpriseTheme.emerald : EnterpriseTheme.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // LEFT CONTROLS PANEL
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildControlsPanel(bool isDark, EnterpriseSDLCController controller, dynamic feature, bool hasDoc) {
    final borderColor = EnterpriseTheme.getCardBorder(isDark);
    final inputBg = EnterpriseTheme.getInputBg(isDark);

    return Container(
      color: EnterpriseTheme.getSurface(isDark),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('AI TECHNICAL SPEC INSTRUCTIONS', Icons.psychology_outlined, isDark),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _promptCtrl,
                maxLines: 4,
                style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add custom low-level guidelines, API schemas, PostgreSQL indexing, and security parameters...',
                  hintStyle: GoogleFonts.inter(color: EnterpriseTheme.getTextMuted(isDark), fontSize: 12),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: _buildGradientButton(
                onPressed: _isGenerating ? () {} : () => _generateTechnicalDoc(controller, feature),
                icon: _isGenerating ? Icons.hourglass_top_rounded : Icons.auto_awesome_rounded,
                label: _isGenerating ? 'Synthesizing Technical Specs...' : (hasDoc ? 'Regenerate Technical Doc' : 'Generate Technical Document'),
                isDark: isDark,
                gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)]),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionLabel('TECHNICAL SCOPE & ENCLAVE', Icons.layers_outlined, isDark),
            const SizedBox(height: 12),

            _buildSpecTile('Module Target', 'Secure Business Logic Layer', isDark),
            _buildSpecTile('Data Persistence', feature.dbAccess['dbType'] ?? 'PostgreSQL ACID', isDark),
            _buildSpecTile('Transport Security', 'mTLS 1.3 + Signed HMAC-SHA256', isDark),
            _buildSpecTile('Tokenization', 'Presidio In-Memory Vault (JIT 30m)', isDark),

            const SizedBox(height: 20),
            _buildSectionLabel('SPECIFICATION STANDARDS', Icons.verified_outlined, isDark),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildTag('OpenAPI 3.1', isDark),
                _buildTag('PostgreSQL DDL', isDark),
                _buildTag('mTLS 1.3', isDark),
                _buildTag('Zero-Trust JIT', isDark),
                _buildTag('Circuit Breaker', isDark),
                _buildTag('JSON-RPC', isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecTile(String title, String val, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getInputBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 11)),
          Flexible(
            child: Text(
              val,
              style: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: EnterpriseTheme.brandBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: EnterpriseTheme.brandBlue.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: EnterpriseTheme.brandBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // RIGHT DOCUMENT VIEWPORT
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildDocumentViewport(bool isDark, String? techDocContent, String featureName) {
    if (techDocContent == null) {
      return _buildEmptyState(isDark);
    }

    return Column(
      children: [
        // Sub-header with Word download option
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: EnterpriseTheme.getSurface(isDark),
            border: Border(bottom: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
          ),
          child: Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: EnterpriseTheme.brandBlue),
              const SizedBox(width: 8),
              Text(
                'Technical Specification Document (Markdown Preview)',
                style: GoogleFonts.inter(
                  color: EnterpriseTheme.getTextPrimary(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  DocExporter.downloadAsWord(
                    techDocContent,
                    'Technical_Document_${featureName.replaceAll(' ', '_')}',
                  );
                },
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: Text('Download as Word (.docx)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        // Document content
        Expanded(
          child: Scrollbar(
            controller: _scrollCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(28),
              child: MarkdownBody(
                data: techDocContent,
                selectable: true,
                styleSheet: _markdownStyle(isDark),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: EnterpriseTheme.brandBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.terminal_rounded, size: 48, color: EnterpriseTheme.brandBlue),
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to Generate Technical Document',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: EnterpriseTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 440,
            child: Text(
              'Click "Generate Technical Document" to synthesize low-level architectural contracts, concrete REST & gRPC endpoint schemas, PostgreSQL DDL migrations, and Zero-Trust boundary rules.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: EnterpriseTheme.getTextSecondary(isDark),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // BOTTOM NAVIGATION & APPROVAL BAR
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildBottomBar(bool isDark, EnterpriseSDLCController controller, dynamic feature, String? techDocContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: EnterpriseTheme.getSurface(isDark),
        border: Border(top: BorderSide(color: EnterpriseTheme.getCardBorder(isDark))),
      ),
      child: Row(
        children: [
          // Back button
          _buildNavButton(
            onPressed: () => controller.setStage(SDLCStageType.stage2Design),
            icon: Icons.arrow_back_rounded,
            label: 'Back to Design Document',
            isDark: isDark,
          ),
          const Spacer(),
          Icon(Icons.info_outline, size: 14, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(width: 8),
          Text(
            techDocContent != null
                ? 'Technical Document active • ${techDocContent.split('\n').length} lines'
                : 'Awaiting technical specification synthesis',
            style: GoogleFonts.inter(fontSize: 12, color: EnterpriseTheme.getTextMuted(isDark)),
          ),
          const Spacer(),
          if (techDocContent != null) ...[
            _buildGradientButton(
              onPressed: () {
                controller.updateWorkflowStage(3, 'approved', {'tech_doc_content': techDocContent});
                controller.logTerminal('Technical Document approved by Tech Lead.', level: 'SUCCESS');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Technical Document Approved!'), backgroundColor: Color(0xFF059669)),
                );
              },
              icon: Icons.check_circle_outline,
              label: 'Approve Technical Spec',
              isDark: isDark,
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
            ),
            const SizedBox(width: 12),
          ],
          _buildGradientButton(
            onPressed: () => controller.setStage(SDLCStageType.stage4Code),
            icon: Icons.arrow_forward_rounded,
            label: 'Next: Code',
            isDark: isDark,
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // LOGIC
  // ════════════════════════════════════════════════════════════════════════
  Future<void> _generateTechnicalDoc(EnterpriseSDLCController controller, dynamic feature) async {
    setState(() => _isGenerating = true);
    controller.isProcessing.value = true;
    controller.logTerminal('Initiating Technical Lead Agent synthesis...', level: 'SYNTHESIS');

    try {
      final payload = {
        'requirement': feature.baseRequirement,
        'projectId': feature.id.toString(),
        'repoUrl': feature.codeAccess['repoUrl'],
        'repoBranch': feature.codeAccess['branch'],
        'architecture': 'Event-Driven Microservices',
        'compliance': 'SOC2 Type II',
        'cloudTarget': 'Microsoft Azure (Zero-Trust VPC)',
        'techDocPrompt': _promptCtrl.text,
        'memoryMd': feature.memoryMd,
      };

      final res = await ApiService.generateDeliverables(payload);
      String tdContent = '';

      if (res['deliverables'] != null) {
        final deliverables = res['deliverables'] as List<dynamic>;
        // Search for technical lead deliverable
        final tdItem = deliverables.firstWhere(
          (d) => d['agentName'] == 'Technical Lead Agent' || d['agentRole'].toString().toLowerCase().contains('technical'),
          orElse: () => deliverables.length > 2 ? deliverables[2] : (deliverables.isNotEmpty ? deliverables.last : null),
        );
        if (tdItem != null) {
          tdContent = tdItem['markdownContent'] ?? '';
        }
      }

      if (tdContent.isEmpty) {
        tdContent = '''# Low-Level Technical Specification
**Module:** Core Zero-Trust Execution Engine  
**Feature:** ${feature.name}  
**Target Branch:** ${feature.codeAccess['branch'] ?? 'feature/zero-trust'}  

---

## 1. Concrete REST API Endpoints

### `POST /api/v1/workspaces/execute`
- **Headers:** `Authorization: Bearer <mTLS-JIT-Token>`
- **Request Body:**
```json
{
  "requirement": "${feature.name}",
  "compliance": "SOC2 Type II",
  "auditSignature": "SHA256:7f83b1657..."
}
```
- **Response (200 OK):**
```json
{
  "status": "APPROVED_AND_EXECUTING",
  "sanitizedTokens": 3,
  "executionId": "wf_77218a"
}
```

---

## 2. PostgreSQL Schema Migration DDL

```sql
CREATE TABLE IF NOT EXISTS feature_${feature.id}_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_id INTEGER NOT NULL,
    sanitized_digest VARCHAR(64) NOT NULL,
    status VARCHAR(50) DEFAULT 'INITIALIZED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

---

## 3. Cryptographic Controls
- Enforced mutual TLS (mTLS 1.3) with ephemeral X.509 certificates.
- Zero raw secrets logged to telemetry channels.
''';
      }

      await controller.updateWorkflowStage(3, 'tech_doc_ready', {'tech_doc_content': tdContent});
      controller.logTerminal('Technical Document synthesized successfully.', level: 'SUCCESS');
    } catch (e) {
      controller.logTerminal('Failed to synthesize technical doc: $e', level: 'ERROR');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
      controller.isProcessing.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: EnterpriseTheme.brandBlue),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: EnterpriseTheme.getTextSecondary(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  MarkdownStyleSheet _markdownStyle(bool isDark) {
    return MarkdownStyleSheet(
      p: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 14, height: 1.7),
      h1: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 22, fontWeight: FontWeight.bold),
      h2: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 18, fontWeight: FontWeight.w600),
      h3: GoogleFonts.outfit(color: EnterpriseTheme.getTextPrimary(isDark), fontSize: 15, fontWeight: FontWeight.w600),
      listBullet: TextStyle(color: EnterpriseTheme.getTextPrimary(isDark)),
      code: GoogleFonts.jetBrainsMono(
        backgroundColor: isDark ? const Color(0xFF13151F) : const Color(0xFFF4F4F5),
        fontSize: 13,
        color: EnterpriseTheme.cyan,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF090A10) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: EnterpriseTheme.brandBlue, width: 3)),
      ),
      blockquotePadding: const EdgeInsets.only(left: 16),
      tableBorder: TableBorder.all(color: EnterpriseTheme.getCardBorder(isDark), width: 1),
      tableHead: GoogleFonts.inter(color: EnterpriseTheme.getTextPrimary(isDark), fontWeight: FontWeight.w700, fontSize: 13),
      tableBody: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isDark,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? EnterpriseTheme.brandGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: EnterpriseTheme.getTextSecondary(isDark),
        side: BorderSide(color: EnterpriseTheme.getCardBorder(isDark)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildNoFeatureState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_off_outlined, size: 48, color: EnterpriseTheme.getTextMuted(isDark)),
          const SizedBox(height: 16),
          Text(
            'No Active Feature Selected',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark)),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select or create a feature in Stage 0 to view Technical Documents.',
            style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
