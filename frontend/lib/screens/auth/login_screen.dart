import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../controllers/auth_controller.dart';
import '../../controllers/enterprise_sdlc_controller.dart';
import '../../theme/enterprise_theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final EnterpriseSDLCController themeController = Get.find<EnterpriseSDLCController>();
  final TextEditingController orgController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;
  final RxBool isHoveringSignIn = false.obs;
  final RxBool isHoveringSSO = false.obs;
  final RxBool isHoveringGoogle = false.obs;

  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    orgController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final screenWidth = MediaQuery.of(context).size.width;
      final isWide = screenWidth > 900;

      return Scaffold(
        backgroundColor: EnterpriseTheme.getBackground(isDark),
        body: Stack(
          children: [
            // ─── Animated Background Gradient Orbs ─────────────
            _buildBackgroundOrbs(isDark),

            // ─── Main Content ──────────────────────────────────
            Row(
              children: [
                // ─── Left Panel: Brand Hero (only on wide screens) ──
                if (isWide) Expanded(flex: 5, child: _buildHeroPanel(isDark)),

                // ─── Right Panel: Login Form ───────────────────────
                isWide
                    ? SizedBox(width: 520, child: _buildLoginForm(isDark))
                    : Expanded(child: _buildLoginForm(isDark)),
              ],
            ),

            // ─── Theme Toggle (top-right) ──────────────────────
            Positioned(
              top: 16,
              right: 16,
              child: _buildThemeToggle(isDark),
            ),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  //  BACKGROUND ORBS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBackgroundOrbs(bool isDark) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        final offset = _floatController.value * 30;
        return Stack(
          children: [
            Positioned(
              top: -80 + offset,
              left: -120,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [EnterpriseTheme.brandBlue.withOpacity(0.08), Colors.transparent]
                        : [EnterpriseTheme.brandBlue.withOpacity(0.06), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100 + offset,
              right: -60,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [EnterpriseTheme.purple.withOpacity(0.06), Colors.transparent]
                        : [EnterpriseTheme.purple.withOpacity(0.04), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: MediaQuery.of(context).size.width * 0.3,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [EnterpriseTheme.emerald.withOpacity(0.04), Colors.transparent]
                        : [EnterpriseTheme.emerald.withOpacity(0.03), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HERO PANEL (Left Side)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeroPanel(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: EnterpriseTheme.getCardBorder(isDark),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Logo Mark
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          EnterpriseTheme.brandBlue,
                          Color.lerp(EnterpriseTheme.brandBlue, EnterpriseTheme.purple, _pulseController.value)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: EnterpriseTheme.brandBlue.withOpacity(0.3 * _pulseController.value),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Hero Title
              Text(
                'Chronos',
                style: GoogleFonts.inter(
                  color: EnterpriseTheme.getTextPrimary(isDark),
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [EnterpriseTheme.brandBlue, EnterpriseTheme.purple],
                ).createShader(bounds),
                child: Text(
                  'Zero-Trust SDLC Platform',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Enterprise-grade security pipeline for your\nsoftware development lifecycle.',
                style: GoogleFonts.inter(
                  color: EnterpriseTheme.getTextSecondary(isDark),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 48),

              // Feature Pills
              _buildFeaturePill(isDark, Icons.verified_user_outlined, 'Role-Based Access Control'),
              const SizedBox(height: 12),
              _buildFeaturePill(isDark, Icons.lan_outlined, 'Multi-Tenant Architecture'),
              const SizedBox(height: 12),
              _buildFeaturePill(isDark, Icons.lock_clock_outlined, 'IP Whitelisting & Audit Logs'),
              const SizedBox(height: 12),
              _buildFeaturePill(isDark, Icons.auto_awesome_outlined, 'AI-Powered SDLC Automation'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(bool isDark, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: EnterpriseTheme.brandBlue.withOpacity(isDark ? 0.1 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: EnterpriseTheme.getPrimaryAccent(isDark)),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            color: EnterpriseTheme.getTextSecondary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  THEME TOGGLE
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildThemeToggle(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => themeController.isDarkMode.value = !themeController.isDarkMode.value,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: EnterpriseTheme.getSurface(isDark).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EnterpriseTheme.getCardBorder(isDark)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: Tween(begin: 0.75, end: 1.0).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              size: 20,
              color: isDark ? EnterpriseTheme.amber : EnterpriseTheme.brandBlueDark,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  LOGIN FORM (Right Side)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildLoginForm(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header ─────────────────────────────────────────
            Text(
              'Welcome back',
              style: GoogleFonts.inter(
                color: EnterpriseTheme.getTextPrimary(isDark),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to your organization workspace',
              style: GoogleFonts.inter(
                color: EnterpriseTheme.getTextMuted(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 36),

            // ─── SSO Buttons Row ────────────────────────────────
            Row(
              children: [
                Expanded(child: _buildSSOButton(isDark, 'SSO / SAML', Icons.shield_outlined, isHoveringSSO)),
                const SizedBox(width: 12),
                Expanded(child: _buildSSOButton(isDark, 'Google', Icons.g_mobiledata_rounded, isHoveringGoogle)),
              ],
            ),

            const SizedBox(height: 28),

            // ─── Divider ────────────────────────────────────────
            Row(
              children: [
                Expanded(child: Container(height: 1, color: EnterpriseTheme.getCardBorder(isDark))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or continue with email',
                    style: GoogleFonts.inter(
                      color: EnterpriseTheme.getTextMuted(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: EnterpriseTheme.getCardBorder(isDark))),
              ],
            ),

            const SizedBox(height: 28),

            // ─── Organization Field ─────────────────────────────
            _buildFieldLabel(isDark, 'Organization'),
            const SizedBox(height: 8),
            _buildTextField(
              isDark: isDark,
              controller: orgController,
              hint: 'e.g. acme-corp',
              prefixIcon: Icons.business_rounded,
            ),

            const SizedBox(height: 20),

            // ─── Email Field ────────────────────────────────────
            _buildFieldLabel(isDark, 'Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              isDark: isDark,
              controller: emailController,
              hint: 'you@company.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // ─── Password Field ─────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFieldLabel(isDark, 'Password'),
                GestureDetector(
                  onTap: () {
                    Get.snackbar('Reset Password', 'Password reset flow coming soon.',
                        backgroundColor: EnterpriseTheme.getCardBorder(isDark),
                        colorText: EnterpriseTheme.getTextPrimary(isDark));
                  },
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.inter(
                      color: EnterpriseTheme.getPrimaryAccent(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => _buildTextField(
                  isDark: isDark,
                  controller: passwordController,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: !showPassword.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: EnterpriseTheme.getTextMuted(isDark),
                    ),
                    onPressed: () => showPassword.value = !showPassword.value,
                  ),
                )),

            const SizedBox(height: 28),

            // ─── Sign In Button ─────────────────────────────────
            Obx(() => MouseRegion(
                  onEnter: (_) => isHoveringSignIn.value = true,
                  onExit: (_) => isHoveringSignIn.value = false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [EnterpriseTheme.brandBlue, Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: isHoveringSignIn.value
                          ? [
                              BoxShadow(
                                color: EnterpriseTheme.brandBlue.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            // ─── Footer ─────────────────────────────────────────
            Center(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: EnterpriseTheme.getTextMuted(isDark),
                    fontSize: 13,
                  ),
                  children: [
                    const TextSpan(text: 'By signing in, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: EnterpriseTheme.getPrimaryAccent(isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  REUSABLE COMPONENTS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFieldLabel(bool isDark, String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: EnterpriseTheme.getTextSecondary(isDark),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    final borderColor = EnterpriseTheme.getCardBorder(isDark);
    final focusBorder = EnterpriseTheme.getPrimaryAccent(isDark);

    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        color: EnterpriseTheme.getTextPrimary(isDark),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: EnterpriseTheme.getTextMuted(isDark).withOpacity(0.6),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(prefixIcon, size: 18, color: EnterpriseTheme.getTextMuted(isDark)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: EnterpriseTheme.getInputBg(isDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusBorder, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSSOButton(bool isDark, String label, IconData icon, RxBool isHovering) {
    return Obx(() => MouseRegion(
          onEnter: (_) => isHovering.value = true,
          onExit: (_) => isHovering.value = false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isHovering.value
                  ? EnterpriseTheme.getSubtleBg(isDark)
                  : EnterpriseTheme.getInputBg(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHovering.value
                    ? EnterpriseTheme.getTextMuted(isDark).withOpacity(0.4)
                    : EnterpriseTheme.getCardBorder(isDark),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.snackbar('SSO', '$label login is not yet configured for this organization.',
                      backgroundColor: EnterpriseTheme.getCardBorder(isDark),
                      colorText: EnterpriseTheme.getTextPrimary(isDark));
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20, color: EnterpriseTheme.getTextSecondary(isDark)),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          color: EnterpriseTheme.getTextPrimary(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SIGN IN HANDLER
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _handleSignIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Missing Fields',
        'Please enter your email and password.',
        backgroundColor: EnterpriseTheme.rose.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    isLoading.value = true;
    final success = await authController.login(
      emailController.text.trim(),
      passwordController.text,
      orgController.text.trim(),
    );
    isLoading.value = false;

    if (success) {
      final sdlcController = Get.find<EnterpriseSDLCController>();
      await sdlcController.fetchProjects();
      Get.offAllNamed('/dashboard');
    } else {
      Get.snackbar(
        'Authentication Failed',
        'Invalid credentials, IP blocked, or user not found.',
        backgroundColor: EnterpriseTheme.rose.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    }
  }
}
