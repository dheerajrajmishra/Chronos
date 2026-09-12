import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequirementInputScreen extends StatelessWidget {
  const RequirementInputScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Requirement Input')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Describe your requirement:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Azure STT Transcript will appear here...', style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.mic, size: 40, color: Colors.red),
                  onPressed: () {
                    // Start Azure STT
                    Get.snackbar('Recording', 'Azure STT Started');
                  },
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Submit workflow
                    Get.snackbar('Submitted', 'Workflow started');
                    Get.toNamed('/dashboard');
                  },
                  child: const Text('Submit to AI Agent'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
