import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _userIdCtrl   = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _authService  = AuthService();

  bool _loading     = false;
  bool _obscurePass = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _authService.register(
        userId:   _userIdCtrl.text.trim(),
        password: _passwordCtrl.text,
        email:    _emailCtrl.text.trim().isEmpty
                    ? null
                    : _emailCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: AppTheme.incomeColor, size: 18),
              SizedBox(width: 8),
              Text('Akun berhasil dibuat! Silakan login.'),
            ],
          ),
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.expenseColor, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text(
          'DAFTAR AKUN',
          style: TextStyle(fontFamily: 'RobotoMono', letterSpacing: 3),
        ),
        backgroundColor: AppTheme.bgSecondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.primaryGreen, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Buat akun baru untuk mulai mencatat keuangan Anda.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Form container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _terminalLabel('USER_ID *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _userIdCtrl,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          color: AppTheme.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Buat user ID unik',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppTheme.textHint, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'User ID tidak boleh kosong';
                          }
                          if (v.trim().length < 3) {
                            return 'User ID minimal 3 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _terminalLabel('PASSWORD *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePass,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buat password',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.textHint, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textHint,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (v.length < 4) {
                            return 'Password minimal 4 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _terminalLabel('EMAIL (opsional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          color: AppTheme.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'contoh@email.com',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.textHint, size: 20),
                        ),
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(v)) {
                              return 'Format email tidak valid';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      ElevatedButton.icon(
                        onPressed: _loading ? null : _register,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.save_outlined, size: 18),
                        label: const Text('SIMPAN & DAFTAR'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _terminalLabel(String text) {
    return Row(
      children: [
        Text(
          '> ',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 12,
            color: AppTheme.neonGreen.withOpacity(0.7),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 12,
            color: AppTheme.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
