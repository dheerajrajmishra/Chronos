import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';
import '../../models/workflow_model.dart';

class Stage5Uat extends StatefulWidget {
  const Stage5Uat({super.key});

  @override
  State<Stage5Uat> createState() => _Stage5UatState();
}

class _Stage5UatState extends State<Stage5Uat> {
  final _bugCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      final wf = controller.activeWorkflow.value;
      
      if (feature == null) return const Center(child: Text("No Feature Selected"));
      
      final uatContent = wf?.stageData['uat_content'] as String?;
      
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stage 5: User Acceptance Testing (UAT)', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
            const SizedBox(height: 24),
            
            if (uatContent == null) ...[
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    controller.isProcessing.value = true;
                    await Future.delayed(const Duration(seconds: 2));
                    await controller.updateWorkflowStage(5, 'uat_testing', {
                      'uat_content': "UAT Environment Provisioned.\nLink: https://uat.enterprise.internal/feature/${feature.id}\nStatus: Awaiting business user sign-off.",
                    });
                    controller.isProcessing.value = false;
                  },
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Provision UAT Environment'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24), textStyle: const TextStyle(fontSize: 18)),
                ),
              )
            ] else ...[
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EnterpriseTheme.getSurface(isDark),
                    border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(uatContent, style: TextStyle(color: EnterpriseTheme.getTextPrimary(isDark), height: 1.5)),
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
                        labelText: 'Log UAT Bug',
                        labelStyle: TextStyle(color: EnterpriseTheme.getTextSecondary(isDark)),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_bugCtrl.text.isNotEmpty) {
                        controller.logTerminal("UAT Bug Logged: ${_bugCtrl.text}. Reverting to Code Stage.", level: "UAT");
                        controller.updateWorkflowStage(3, 'uat_bug_fixing', {
                          'code_content': null, // Clear code to regenerate
                          'test_content': null, // Clear tests
                          'uat_content': null, // Clear UAT
                          'uat_bug_report': _bugCtrl.text,
                        });
                        controller.setStage(SDLCStageType.stage3Code);
                      }
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Log Bug & Cycle Back to Code'),
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
                      controller.updateWorkflowStage(6, 'uat_passed', {});
                      controller.setStage(SDLCStageType.stage6Deploy);
                    },
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Mark UAT Passed & Proceed to Deploy'),
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
