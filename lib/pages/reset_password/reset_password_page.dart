import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:absenpro/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  static const Color primaryTeal = Color(0xFF2FC7CF);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validasi password: alphanumeric saja, minimal 6 karakter
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    // Cek hanya alphanumeric (a-z, A-Z, 0-9)
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumericRegex.hasMatch(value)) {
      return 'Password hanya boleh huruf dan angka (tanpa spasi/simbol)';
    }

    return null;
  }

  /// Cek apakah password & confirm password cocok
  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (value != _passwordController.text) {
      return 'Konfirmasi password tidak cocok';
    }

    return null;
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);

    final passwordError = _validatePassword(_passwordController.text);
    final confirmError =
        _validateConfirmPassword(_confirmPasswordController.text);

    if (passwordError != null) {
      setState(() => _errorMessage = passwordError);
      return;
    }

    if (confirmError != null) {
      setState(() => _errorMessage = confirmError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API untuk change password melalui AuthProvider
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.changePassword(
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        await showCustomAlert(
          context: context,
          title: 'Berhasil',
          message: 'Password berhasil diubah.',
          assetPath: 'assets/images/alert/check-mark.png',
          accentColor: const Color(0xFF4CAF7D),
        );

        if (!mounted) return;

        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _errorMessage = null;
          _obscurePassword = true;
          _obscureConfirmPassword = true;
        });
      } else {
        // Error message dari AuthProvider sudah diset, tampilkan kembali
        setState(
          () => _errorMessage =
              authProvider.errorMessage ?? 'Gagal mengubah password',
        );

        await showCustomAlert(
          context: context,
          title: 'Gagal',
          message: authProvider.errorMessage ?? 'Gagal mengubah password',
          assetPath: 'assets/images/alert/warning.png',
          accentColor: const Color(0xFFE0637A),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Error: ', '');
      setState(() => _errorMessage = message);
      await showCustomAlert(
        context: context,
        title: 'Gagal',
        message: message,
        assetPath: 'assets/images/alert/warning.png',
        accentColor: const Color(0xFFE0637A),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Deskripsi
                const Text(
                  'Masukkan password baru Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE0E4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFE0637A),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE0637A),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 20),

                // Input Password Baru
                _buildInputField(
                  controller: _passwordController,
                  hintText: 'Masukan Password Baru',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  label: 'Password Baru',
                ),
                const SizedBox(height: 16),

                // Input Konfirmasi Password
                _buildInputField(
                  controller: _confirmPasswordController,
                  hintText: 'Konfirmasi Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  label: 'Konfirmasi Password',
                ),
                const SizedBox(height: 32),

                // Informasi validasi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF0D2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Persyaratan Password:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC9A23B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildValidationItem(
                        'Minimal 6 karakter',
                        _passwordController.text.length >= 6,
                      ),
                      _buildValidationItem(
                        'Hanya huruf dan angka (tanpa spasi/simbol)',
                        RegExp(r'^[a-zA-Z0-9]*$')
                            .hasMatch(_passwordController.text),
                      ),
                      _buildValidationItem(
                        'Password cocok dengan konfirmasi',
                        _passwordController.text.isNotEmpty &&
                            _passwordController.text ==
                                _confirmPasswordController.text,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Simpan
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData icon,
    required bool isPassword,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: (_) => setState(() {}), // Trigger rebuild untuk validasi
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.black38, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black38,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isValid ? const Color(0xFF4CAF7D) : Colors.black26,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isValid ? const Color(0xFF4CAF7D) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
