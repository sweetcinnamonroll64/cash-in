import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey       = GlobalKey<FormState>();
  final _userIdCtrl    = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _authService   = AuthService();

  bool _loading       = false;
  bool _obscurePass   = true;

  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _userIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = await _authService.login(
        _userIdCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (!mounted) return;

      if (user == null) {
        _showError('User ID atau password salah.');
      } else {
        Navigator.pushReplacementNamed(context, '/main',
            arguments: user.userId);
      }
    } catch (e) {
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.expenseColor, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppTheme.bgCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ── Header ──
              Center(
                child: AnimatedBuilder(
                  animation: _glow,
                  builder: (_, child) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.bgCard,
                      border: Border.all(color: AppTheme.primaryGreen, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(_glow.value),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 36,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Center(
                child: Column(
                  children: [
                    const Text(
                      'CASH-IN',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk ke akun Anda',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── Form ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor, width: 1),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Terminal-style label
                      _terminalLabel('USER_ID'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _userIdCtrl,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          color: AppTheme.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Masukkan user ID',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppTheme.textHint, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'User ID tidak boleh kosong' : null,
                      ),

                      const SizedBox(height: 20),

                      _terminalLabel('PASSWORD'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePass,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan password',
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
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Password tidak boleh kosong' : null,
                      ),

                      const SizedBox(height: 28),

                      // Login Button
                      ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text('MASUK'),
                      ),

                      const SizedBox(height: 12),

                      // Register Button
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('DAFTAR AKUN BARU'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  '// Cash-in v1.0.0',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 11,
                    color: AppTheme.textHint.withOpacity(0.5),
                    letterSpacing: 1,
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
