import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage5CodeGenSbom extends StatefulWidget {
  const Stage5CodeGenSbom({super.key});

  @override
  State<Stage5CodeGenSbom> createState() => _Stage5CodeGenSbomState();
}

class _Stage5CodeGenSbomState extends State<Stage5CodeGenSbom> {
  int _selectedCodeSnippetIndex = 0;

  final List<Map<String, String>> _snippets = [
    {
      'title': 'Temporal Worker',
      'language': 'typescript',
      'code': """// Zero-Trust Temporal Activity Implementation
import { Context } from '@temporalio/activity';
import axios from 'axios';

export async function processZeroTrustTransaction(maskedPayload: string): Promise<string> {
  const workflowId = Context.current().info.workflowExecution.workflowId;
  
  // Call AI reasoning engine with masked tokens only
  const response = await axios.post('https://pitchperfectllmengine2.openai.azure.com/v1/chat', {
    model: 'gpt-4o',
    messages: [{ role: 'user', content: maskedPayload }],
  });
  
  return response.data.choices[0].message.content;
}""",
    },
    {
      'title': 'DLP Gateway',
      'language': 'python',
      'code': """# Presidio Zero-Trust Anonymizer Gateway
from fastapi import FastAPI
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine
import redis, uuid

app = FastAPI()
analyzer = AnalyzerEngine()
anonymizer = AnonymizerEngine()
redis_client = redis.Redis(host='redis', port=6379, db=0)

@app.post("/v1/vault/mask")
def mask_payload(workflow_id: str, text: str):
    results = analyzer.analyze(text=text, entities=["API_KEY", "CREDIT_CARD", "EMAIL_ADDRESS", "IP_ADDRESS"], language='en')
    # Deterministic tokenization into Redis Vault
    tokenized = anonymizer.anonymize(text=text, analyzer_results=results)
    return {"status": "VAULTED", "tokenized_text": tokenized.text}""",
    },
    {
      'title': 'K8s Deployment',
      'language': 'yaml',
      'code': """apiVersion: apps/v1
kind: Deployment
metadata:
  name: zero-trust-sdlc-worker
  namespace: zero-trust-prod
spec:
  replicas: 3
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - name: worker
        image: zero-trust-sdlc/worker:v2.4.0
        env:
        - name: TEMPORAL_ADDRESS
          value: "temporal.internal:7233"
        securityContext:
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false""",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final wf = controller.activeWorkflow.value;
      final textColor = EnterpriseTheme.getTextPrimary(isDark);
      final textSecColor = EnterpriseTheme.getTextSecondary(isDark);
      final textMutedColor = EnterpriseTheme.getTextMuted(isDark);
      final borderColor = EnterpriseTheme.getCardBorder(isDark);
      final primaryAccent = EnterpriseTheme.getPrimaryAccent(isDark);
      final inputBg = EnterpriseTheme.getInputBg(isDark);
      final cardBgElevated = EnterpriseTheme.getCardBgElevated(isDark);

      if (wf == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.terminal_outlined, size: 48, color: primaryAccent.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('No active workflow', style: GoogleFonts.inter(color: textMutedColor, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }

      final sbom = wf.sbomItems;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(gradient: EnterpriseTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.terminal_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code Gen & SBOM', style: GoogleFonts.inter(color: textColor, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text('Automated code scaffolding, SBOM (CycloneDX), and vulnerability assessment.', style: GoogleFonts.inter(color: textSecColor, fontSize: 13)),
                    ],
                  ),
                ),
                _gradientButton('View Audit', Icons.arrow_forward_rounded, () => controller.setStage(SDLCStageType.auditTelemetry)),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Code Snippets ────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code_rounded, color: primaryAccent, size: 18),
                      const SizedBox(width: 8),
                      Text('Generated Scaffolding', style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      ...List.generate(_snippets.length, (idx) {
                        final isSelected = _selectedCodeSnippetIndex == idx;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _CodeTab(
                            label: _snippets[idx]['title']!,
                            isSelected: isSelected,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedCodeSnippetIndex = idx),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: EnterpriseTheme.terminalDecoration(isDark: isDark),
                    child: SelectableText(
                      _snippets[_selectedCodeSnippetIndex]['code']!,
                      style: GoogleFonts.jetBrainsMono(
                        color: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1),
                        fontSize: 11.5,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── SBOM Table ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security_outlined, color: EnterpriseTheme.emerald, size: 18),
                      const SizedBox(width: 8),
                      Text('SBOM & Security Scan', style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      _pill('CycloneDX 1.5', EnterpriseTheme.emerald, isDark),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: borderColor, width: 1, borderRadius: BorderRadius.circular(8)),
                    columnWidths: const {
                      0: FlexColumnWidth(2.0),
                      1: FlexColumnWidth(1.0),
                      2: FlexColumnWidth(1.0),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.8),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: inputBg),
                        children: [_th('Package', isDark), _th('Version', isDark), _th('License', isDark), _th('Severity', isDark), _th('CVE / Fix', isDark)],
                      ),
                      ...sbom.map((item) {
                        final isVuln = item.vulnerabilitySeverity != 'None';
                        return TableRow(
                          decoration: BoxDecoration(color: cardBgElevated),
                          children: [
                            _td(child: Text(item.packageName, style: GoogleFonts.jetBrainsMono(color: textColor, fontSize: 11, fontWeight: FontWeight.w600))),
                            _td(child: Text(item.version, style: GoogleFonts.inter(color: textSecColor, fontSize: 11))),
                            _td(child: Text(item.license, style: GoogleFonts.inter(color: textMutedColor, fontSize: 11))),
                            _td(child: _pill(item.vulnerabilitySeverity, isVuln ? EnterpriseTheme.amber : EnterpriseTheme.emerald, isDark)),
                            _td(child: isVuln
                                ? Text("${item.cveId} → ${item.fixVersion}", style: GoogleFonts.inter(color: EnterpriseTheme.amber, fontSize: 11))
                                : Text('PASS — 0 CVEs', style: GoogleFonts.inter(color: EnterpriseTheme.emerald, fontSize: 11))),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _th(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text, style: GoogleFonts.inter(color: EnterpriseTheme.getTextSecondary(isDark), fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _td({required Widget child}) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), child: child);
  }

  Widget _pill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.1 : 0.08), borderRadius: BorderRadius.circular(5)),
      child: Text(text, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _gradientButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(gradient: EnterpriseTheme.brandGradient, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Icon(icon, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  const _CodeTab({required this.label, required this.isSelected, required this.isDark, required this.onTap});

  @override
  State<_CodeTab> createState() => _CodeTabState();
}

class _CodeTabState extends State<_CodeTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryAccent = EnterpriseTheme.getPrimaryAccent(widget.isDark);
    final borderColor = EnterpriseTheme.getCardBorder(widget.isDark);
    final textSecColor = EnterpriseTheme.getTextSecondary(widget.isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isSelected ? primaryAccent.withValues(alpha: widget.isDark ? 0.12 : 0.08) : (_isHovered ? EnterpriseTheme.getSubtleBg(widget.isDark) : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: widget.isSelected ? primaryAccent.withValues(alpha: 0.5) : borderColor),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(color: widget.isSelected ? primaryAccent : textSecColor, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
