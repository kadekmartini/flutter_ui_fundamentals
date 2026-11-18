
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email wajib diisi';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Masukkan alamat email yang valid';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }

    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }

    if (value != _passwordController.text) {
      return 'Konfirmasi kata sandi tidak sama';
    }

    return null;
  }

  String _authErrorMessage(String message) {
    final error = message.toLowerCase();

    if (error.contains('already registered') ||
        error.contains('user already registered') ||
        error.contains('already exists')) {
      return 'Email ini sudah terdaftar. Silakan gunakan email lain.';
    }

    if (error.contains('password')) {
      return 'Kata sandi tidak memenuhi ketentuan. Periksa kembali kata sandi kamu.';
    }

    if (error.contains('email')) {
      return 'Alamat email tidak dapat digunakan. Periksa kembali email kamu.';
    }

    if (error.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Silakan coba kembali nanti.';
    }

    return 'Pendaftaran gagal. Periksa koneksi internet dan coba lagi.';
  }

  Future<void> _register() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.instance.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final hasSession = response.session != null;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Icon(
              Icons.check_circle_outline_rounded,
              color: primaryColor,
              size: 49,
            ),
            title: const Text(
              'Pendaftaran Berhasil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              hasSession
                  ? 'Akun berhasil dibuat dan kamu sudah masuk. Silakan lanjutkan ke aplikasi.'
                  : 'Akun berhasil dibuat. Silakan periksa email untuk melakukan konfirmasi jika diminta, kemudian masuk menggunakan akun kamu.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF718096),
                height: 1.6,
                fontSize: 13,
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lanjutkan'),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop<bool>(hasSession);
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        _authErrorMessage(error.message),
        isError: true,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Terjadi kesalahan. Periksa koneksi internet dan coba lagi.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE1E9F2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1976D2),
                Color(0xFF1255A0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(23),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Buat Akun Baru',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Daftarkan akun kamu untuk mulai mengakses dan mengelola kursus.',
          style: TextStyle(
            fontSize: 13,
            height: 1.7,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Lengkapi informasi berikut untuk membuat akun.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              enabled: !_isLoading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.username,
              ],
              decoration: _inputDecoration(
                label: 'Alamat Email',
                hint: 'nama@email.com',
                icon: Icons.email_outlined,
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 19),
            TextFormField(
              controller: _passwordController,
              enabled: !_isLoading,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.newPassword,
              ],
              decoration: _inputDecoration(
                label: 'Kata Sandi',
                hint: 'Minimal 6 karakter',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  tooltip: _isPasswordVisible
                      ? 'Sembunyikan kata sandi'
                      : 'Tampilkan kata sandi',
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 19),
            TextFormField(
              controller: _confirmPasswordController,
              enabled: !_isLoading,
              obscureText: !_isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              autofillHints: const [
                AutofillHints.newPassword,
              ],
              onFieldSubmitted: (_) {
                _register();
              },
              decoration: _inputDecoration(
                label: 'Konfirmasi Kata Sandi',
                hint: 'Masukkan ulang kata sandi',
                icon: Icons.lock_reset_outlined,
                suffixIcon: IconButton(
                  tooltip: _isConfirmPasswordVisible
                      ? 'Sembunyikan kata sandi'
                      : 'Tampilkan kata sandi',
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 27),
            SizedBox(
              height: 53,
              child: FilledButton(
                onPressed: _isLoading ? null : _register,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blueGrey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_alt_1_rounded),
                          SizedBox(width: 10),
                          Text(
                            'Daftar Akun',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(
          child: Text(
            'Sudah memiliki akun?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF718096),
            ),
          ),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text(
            'Masuk',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pendaftaran Akun',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 23,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 27),
                  _buildRegisterForm(),
                  const SizedBox(height: 19),
                  _buildLoginLink(),
                  const SizedBox(height: 22),
                  const Text(
                    'APLIKASI MANAJEMEN KURSUS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9AA8B8),
                      fontSize: 10,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
