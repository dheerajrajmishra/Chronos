import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';

class Stage3Code extends StatefulWidget {
  const Stage3Code({super.key});

  @override
  State<Stage3Code> createState() => _Stage3CodeState();
}

class _Stage3CodeState extends State<Stage3Code> {
  final _branchCtrl = TextEditingController(text: 'feature/impl-zero-trust');

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      final wf = controller.activeWorkflow.value;
      
      if (feature == null) return const Center(child: Text("No Feature Selected"));
      
      final codeContent = wf?.stageData['code_content'] as String?;
      
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stage 3: Code Generation', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
            const SizedBox(height: 24),
            
            if (codeContent == null) ...[
              TextField(
                controller: _branchCtrl,
                style: TextStyle(color: EnterpriseTheme.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Target Branch Name',
                  labelStyle: TextStyle(color: EnterpriseTheme.getTextSecondary(isDark)),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    controller.isProcessing.value = true;
                    await Future.delayed(const Duration(seconds: 3));
                    await controller.updateWorkflowStage(3, 'coding', {
                      'code_content': "// Auto-generated implementation for branch ${_branchCtrl.text}\n\nexport class ZeroTrustWrapper {\n  constructor(private db: DbClient) {}\n\n  async query(sql: string) {\n    const masked = await applyPIIMasking(sql);\n    return this.db.execute(masked);\n  }\n}\n",
                      'branch_name': _branchCtrl.text
                    });
                    controller.logTerminal("Code written and committed to branch: ${_branchCtrl.text}", level: "GIT");
                    controller.isProcessing.value = false;
                  },
                  icon: const Icon(Icons.code),
                  label: const Text('Generate Code in Branch'),
                ),
              )
            ] else ...[
              Text('Committed to: ${wf?.stageData['branch_name']}', style: TextStyle(color: EnterpriseTheme.emerald, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(codeContent, style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', height: 1.5)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.updateWorkflowStage(4, 'code_ready', {});
                      controller.setStage(SDLCStageType.stage4Test);
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Proceed to Test Automation'),
                  ),
                ],
              )
            ]
          ],
        ),
      );
    });
  }
}
