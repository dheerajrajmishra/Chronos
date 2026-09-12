import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';

class Stage4Test extends StatefulWidget {
  const Stage4Test({super.key});

  @override
  State<Stage4Test> createState() => _Stage4TestState();
}

class _Stage4TestState extends State<Stage4Test> {
  final _bugCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      final wf = controller.activeWorkflow.value;
      
      if (feature == null) return const Center(child: Text("No Feature Selected"));
      
      final testContent = wf?.stageData['test_content'] as String?;
      
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stage 4: Test Automation', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
            const SizedBox(height: 24),
            
            if (testContent == null) ...[
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    controller.isProcessing.value = true;
                    await Future.delayed(const Duration(seconds: 2));
                    await controller.updateWorkflowStage(4, 'testing', {
                      'test_content': "Running Test Suite for ${feature.name}...\n\n[PASS] test_db_connection\n[PASS] test_pii_masking\n[PASS] test_rbac_auth\n\nAll automated tests passed successfully.",
                    });
                    controller.isProcessing.value = false;
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Generate & Run Test Scripts'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24), textStyle: const TextStyle(fontSize: 18)),
                ),
              )
            ] else ...[
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
                    child: Text(testContent, style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', height: 1.5)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bugCtrl,
                      style: TextStyle(color: EnterpriseTheme.getTextPrimary(isDark)),
                      decoration: InputDecoration(
                        labelText: 'Log Bug (If any)',
                        labelStyle: TextStyle(color: EnterpriseTheme.getTextSecondary(isDark)),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_bugCtrl.text.isNotEmpty) {
                        controller.logTerminal("Bug Logged: ${_bugCtrl.text}. Reverting to Design Stage.", level: "TEST");
                        controller.updateWorkflowStage(2, 'bug_fixing', {
                          'design_content': null, // Clear design to regenerate
                          'code_content': null, // Clear code
                          'test_content': null, // Clear tests
                          'bug_report': _bugCtrl.text,
                        });
                        controller.setStage(SDLCStageType.stage2Design);
                      }
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Log Bug & Cycle Back'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.updateWorkflowStage(5, 'tested', {});
                      controller.setStage(SDLCStageType.stage5Uat);
                    },
                    icon: const Icon(Icons.verified),
                    label: const Text('Approve Tests & Proceed to UAT'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
