import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/enterprise_sdlc_controller.dart';
import 'screens/enterprise_portal_screen.dart';
import 'theme/enterprise_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(EnterpriseSDLCController());
  runApp(const ZeroTrustApp());
}

class ZeroTrustApp extends StatelessWidget {
  const ZeroTrustApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Zero-Trust AI SDLC Enterprise Portal',
      debugShowCheckedModeBanner: false,
      theme: EnterpriseTheme.darkTheme,
      initialRoute: '/portal',
      getPages: [
        GetPage(name: '/portal', page: () => const EnterprisePortalScreen()),
        GetPage(name: '/dashboard', page: () => const EnterprisePortalScreen()),
      ],
    );
  }
}
