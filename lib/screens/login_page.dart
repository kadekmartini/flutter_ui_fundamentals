
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'register_page.dart';
import 'responsive_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

    return null;
  }

  String _authErrorMessage(String message) {
    final error = message.toLowerCase();

    if (error.contains('invalid login credentials')) {
      return 'Email atau kata sandi yang kamu masukkan salah.';
    }

    if (error.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Silakan periksa kotak masuk email.';
    }

    if (error.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Silakan coba kembali nanti.';
    }

    if (error.contains('network')) {
      return 'Koneksi internet bermasalah. Periksa koneksi lalu coba lagi.';
    }

    return 'Gagal masuk. Periksa kembali email dan kata sandi kamu.';
  }

  Future<void> _login() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.session == null) {
        _showMessage(
          'Login belum berhasil. Silakan periksa kembali akun kamu.',
          isError: true,
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ResponsiveShell(),
        ),
        (route) => false,
      );
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

  Future<void> _openRegisterPage() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ResponsiveShell(),
        ),
        (route) => false,
      );
    } else if (result == false) {
      _showMessage(
        'Akun berhasil dibuat. Silakan masuk setelah mengonfirmasi email jika diperlukan.',
      );
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
            Icons.school_rounded,
            color: Colors.white,
            size: 43,
          ),
        ),
        const SizedBox(height: 27),
        const Text(
          'Selamat Datang Kembali!',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Masuk ke akun kamu untuk melanjutkan aktivitas pembelajaran dan mengelola kursus.',
          style: TextStyle(
            fontSize: 13,
            height: 1.7,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
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
              'Masuk ke Akun',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Masukkan email dan kata sandi yang sudah terdaftar.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
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
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              autofillHints: const [
                AutofillHints.password,
              ],
              onFieldSubmitted: (_) {
                _login();
              },
              decoration: _inputDecoration(
                label: 'Kata Sandi',
                hint: 'Masukkan kata sandi',
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
            const SizedBox(height: 27),
            SizedBox(
              height: 53,
              child: FilledButton(
                onPressed: _isLoading ? null : _login,
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
                          Icon(Icons.login_rounded),
                          SizedBox(width: 10),
                          Text(
                            'Masuk',
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

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(
          child: Text(
            'Belum memiliki akun?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF718096),
            ),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _openRegisterPage,
          child: const Text(
            'Daftar Sekarang',
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 23,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 29),
                  _buildLoginForm(),
                  const SizedBox(height: 19),
                  _buildRegisterLink(),
                  const SizedBox(height: 24),
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
