import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Zero-Trust AI SDLC Platform', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed('/requirement-input'),
              child: const Text('New Requirement (Voice)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed('/approval-gate'),
              child: const Text('Pending Approvals'),
            ),
          ],
        ),
      ),
    );
  }
}
