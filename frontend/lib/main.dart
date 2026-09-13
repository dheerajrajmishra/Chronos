import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/enterprise_sdlc_controller.dart';
import 'controllers/auth_controller.dart';
import 'screens/enterprise_portal_screen.dart';
import 'screens/auth/login_screen.dart';
import 'theme/enterprise_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
  Get.put(EnterpriseSDLCController());
  runApp(const ZeroTrustApp());
}

class ZeroTrustApp extends StatelessWidget {
  const ZeroTrustApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnterpriseSDLCController>();
    final authController = Get.find<AuthController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'Chronos',
        debugShowCheckedModeBanner: false,
        theme: EnterpriseTheme.lightTheme,
        darkTheme: EnterpriseTheme.darkTheme,
        themeMode: controller.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: authController.isAuthenticated.value ? '/portal' : '/login',
        getPages: [
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/portal', page: () => const EnterprisePortalScreen()),
          GetPage(name: '/dashboard', page: () => const EnterprisePortalScreen()),
        ],
      );
    });
  }
}
