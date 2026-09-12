import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApprovalGateScreen extends StatelessWidget {
  const ApprovalGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Gate')),
      body: ListView.builder(
        itemCount: 1, // Mock 1 pending item
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pending BRD Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Generated Document Content (Unmasked) will appear here...'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.snackbar('Rejected', 'BRD Rejected');
                        },
                        child: const Text('Reject', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Get.snackbar('Approved', 'BRD Approved, proceeding to next phase');
                          Get.back();
                        },
                        child: const Text('Approve'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
