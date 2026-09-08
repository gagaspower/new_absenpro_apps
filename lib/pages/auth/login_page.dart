import 'package:absenpro/pages/dashboard_page.dart';
import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absenpro/pages/face_profile/face_profile_register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  // Errors are tracked here instead of via TextFormField's built-in
  // errorText, so they can be rendered OUTSIDE the bordered field box
  // instead of stretching it from within.
  String? _usernameError;
  String? _passwordError;

  // ── Palette: brand teal, deepened slightly for AA text contrast,
  // paired with a soft mint background so it stays gentle, not clinical.
  static const Color primaryTeal = Color(0xFF0E9AA3); // was 0xFF2FC7CF
  static const Color deepTeal = Color(0xFF0B7A82);
  static const Color softMint = Color(0xFFF3FAFA);
  static const Color fieldFill = Color(0xFFF5F7F8);
  static const Color fieldBorder = Color(0xFFE3E8EA);
  static const Color textPrimary = Color(0xFF102A2C);
  static const Color textSecondary = Color(0xFF5C6B6D);
  static const Color errorRed = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softMint,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 56),
                      _buildBrandMark(),
                      const SizedBox(height: 28),

                      // Judul
                      const Text(
                        'Selamat datang!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subjudul
                      const Text(
                        'Masukkan username dan password\nuntuk melanjutkan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Input Username
                      _buildInputField(
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        label: 'Username',
                        hintText: 'Masukkan username',
                        icon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        errorText: _usernameError,
                        onChanged: (_) {
                          if (_usernameError != null) {
                            setState(() => _usernameError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // Input Password
                      _buildInputField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        label: 'Password',
                        hintText: 'Masukkan password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        errorText: _passwordError,
                        onChanged: (_) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: hubungkan ke alur lupa password.
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            foregroundColor: deepTeal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                          ),
                          child: const Text(
                            'Lupa password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tombol Masuk
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                disabledBackgroundColor:
                                    primaryTeal.withOpacity(0.6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: primaryTeal.withOpacity(0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ).copyWith(
                                elevation: MaterialStateProperty.resolveWith(
                                  (states) =>
                                      states.contains(MaterialState.disabled)
                                          ? 0
                                          : 2,
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        key: ValueKey('loading'),
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Masuk',
                                        key: ValueKey('label'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),
                      const Text(
                        'Hubungi admin jika mengalami kendala login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandMark() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: primaryTeal.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.fingerprint_rounded,
          color: deepTeal,
          size: 34,
          semanticLabel: 'Logo AbsenPro',
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData icon,
    String? errorText,
    ValueChanged<String>? onChanged,
    bool isPassword = false,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  hasError ? errorRed : (isFocused ? primaryTeal : fieldBorder),
              width: hasError || isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color:
                          (hasError ? errorRed : primaryTeal).withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          // TextFormField with a fixed-height, single-purpose decoration —
          // no `errorText` is ever passed here, so the InputDecorator never
          // reserves extra internal space and this box can't stretch.
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword ? _obscurePassword : false,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15, color: textPrimary),
            cursorColor: primaryTeal,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              prefixIcon: Icon(
                icon,
                color: hasError
                    ? errorRed
                    : (isFocused ? primaryTeal : Colors.black38),
                size: 20,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black38,
                        size: 20,
                      ),
                      tooltip: _obscurePassword
                          ? 'Tampilkan password'
                          : 'Sembunyikan password',
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
        // Error message lives outside the bordered box entirely, so it
        // adds space BELOW the field instead of stretching it from inside.
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 14,
                          color: errorRed,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          errorText,
                          style: const TextStyle(
                            color: errorRed,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _usernameError = username.isEmpty ? 'Username wajib diisi' : null;
      _passwordError = password.isEmpty ? 'Password wajib diisi' : null;
    });

    if (_usernameError != null || _passwordError != null) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      username: username,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      final hasFaceProfile = authProvider.user?.employee?.faceProfile != null;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => hasFaceProfile
              ? const DashboardPage()
              : const FaceProfileRegisterPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: errorRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(authProvider.errorMessage ?? 'Login gagal'),
        ),
      );
    }
  }
}
