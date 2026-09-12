import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../models/workflow_model.dart';
import '../../theme/enterprise_theme.dart';

class Stage5CodeGenSbom extends StatefulWidget {
  const Stage5CodeGenSbom({Key? key}) : super(key: key);

  @override
  State<Stage5CodeGenSbom> createState() => _Stage5CodeGenSbomState();
}

class _Stage5CodeGenSbomState extends State<Stage5CodeGenSbom> {
  int _selectedCodeSnippetIndex = 0;

  final List<Map<String, String>> _snippets = [
    {
      'title': 'TypeScript Temporal Worker',
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
      'title': 'Python FastAPI DLP Gateway',
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
      'title': 'Kubernetes Zero-Trust Deployment',
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
      final wf = controller.activeWorkflow.value;
      if (wf == null) {
        return const Center(
          child: Text('No active workflow.', style: TextStyle(color: EnterpriseTheme.textMuted)),
        );
      }

      final sbom = wf.sbomItems;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: EnterpriseTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.terminal_outlined, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Stage 5: Automated Code Generation & SBOM Security Matrix',
                        style: TextStyle(
                          color: EnterpriseTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Post-approval automated code scaffolding, Software Bill of Materials (CycloneDX / SPDX), and vulnerability assessment.',
                        style: TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.setStage(SDLCStageType.auditTelemetry),
                  icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                  label: const Text('View Audit Telemetry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnterpriseTheme.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // Code Scaffolding Snippets Preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code, color: EnterpriseTheme.cyan, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Generated Zero-Trust Microservice Scaffolding',
                        style: TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      // Code tab buttons
                      ...List.generate(_snippets.length, (idx) {
                        final isSelected = _selectedCodeSnippetIndex == idx;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            onTap: () => setState(() => _selectedCodeSnippetIndex = idx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? EnterpriseTheme.cyan.withOpacity(0.15) : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.cardBorder,
                                ),
                              ),
                              child: Text(
                                _snippets[idx]['title']!,
                                style: TextStyle(
                                  color: isSelected ? EnterpriseTheme.cyan : EnterpriseTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: EnterpriseTheme.terminalDecoration(),
                    child: SelectableText(
                      _snippets[_selectedCodeSnippetIndex]['code']!,
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontFamily: 'Consolas',
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SBOM Vulnerability Assessment Table
            Container(
              padding: const EdgeInsets.all(20),
              decoration: EnterpriseTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security, color: EnterpriseTheme.cyan, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Software Bill of Materials (SBOM) & Static Security Scan',
                        style: TextStyle(color: EnterpriseTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: EnterpriseTheme.emerald.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('CycloneDX 1.5 Compliant', style: TextStyle(color: EnterpriseTheme.emerald, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: EnterpriseTheme.cardBorder, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(2.0),
                      1: FlexColumnWidth(1.0),
                      2: FlexColumnWidth(1.0),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.8),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFF0F172A)),
                        children: [
                          _tableHeader('Package Identifier'),
                          _tableHeader('Version'),
                          _tableHeader('License'),
                          _tableHeader('Vulnerability'),
                          _tableHeader('CVE / Remediation'),
                        ],
                      ),
                      ...sbom.map((item) {
                        final isVulnerable = item.vulnerabilitySeverity != 'None';

                        return TableRow(
                          decoration: const BoxDecoration(color: Color(0xFF161F30)),
                          children: [
                            _tableCell(
                              child: Text(
                                item.packageName,
                                style: const TextStyle(color: EnterpriseTheme.textPrimary, fontFamily: 'Consolas', fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                            _tableCell(
                              child: Text(item.version, style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11)),
                            ),
                            _tableCell(
                              child: Text(item.license, style: const TextStyle(color: EnterpriseTheme.textMuted, fontSize: 11)),
                            ),
                            _tableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isVulnerable ? EnterpriseTheme.amber.withOpacity(0.2) : EnterpriseTheme.emerald.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.vulnerabilitySeverity,
                                  style: TextStyle(
                                    color: isVulnerable ? EnterpriseTheme.amber : EnterpriseTheme.emerald,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            _tableCell(
                              child: isVulnerable
                                  ? Text(
                                      "${item.cveId} (Upgrade to ${item.fixVersion})",
                                      style: const TextStyle(color: EnterpriseTheme.amber, fontSize: 11),
                                    )
                                  : const Text(
                                      'PASS - 0 CVEs Detected',
                                      style: TextStyle(color: EnterpriseTheme.emerald, fontSize: 11),
                                    ),
                            ),
                          ],
                        );
                      }).toList(),
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

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(color: EnterpriseTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _tableCell({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: child,
    );
  }
}
