import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';

class Stage6Deploy extends StatelessWidget {
  const Stage6Deploy({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final feature = controller.activeFeature.value;
      final wf = controller.activeWorkflow.value;
      
      if (feature == null) return const Center(child: Text("No Feature Selected"));
      
      final deployContent = wf?.stageData['deploy_content'] as String?;
      
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stage 6: Deployment & Artifacts', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: EnterpriseTheme.getTextPrimary(isDark))),
            const SizedBox(height: 24),
            
            if (deployContent == null) ...[
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    controller.isProcessing.value = true;
                    await Future.delayed(const Duration(seconds: 2));
                    await controller.updateWorkflowStage(6, 'deployed', {
                      'deploy_content': "Deployment Complete!\n\nArtifacts Generated:\n- Docker Image: registry.enterprise.internal/${feature.name}:latest\n- Helm Chart: v1.2.0\n- Terraform State Updated.\n\nLive URL: https://prod.enterprise.internal/api/${feature.name}",
                    });
                    controller.logTerminal("Feature successfully deployed to production.", level: "DEPLOY");
                    controller.isProcessing.value = false;
                  },
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Generate Deployment Artifacts & Deploy'),
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
                    child: Text(deployContent, style: TextStyle(color: EnterpriseTheme.getTextPrimary(isDark), height: 1.5)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.updateWorkflowStage(7, 'completed', {});
                      Get.snackbar("Workflow Complete", "The SDLC process for ${feature.name} has successfully concluded.", backgroundColor: Colors.green, colorText: Colors.white);
                    },
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark Workflow Complete'),
                    style: ElevatedButton.styleFrom(backgroundColor: EnterpriseTheme.getPrimaryAccent(isDark), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
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
