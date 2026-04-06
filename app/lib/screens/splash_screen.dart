import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/version_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _pulse;
  late Animation<double> _fade;

  String _status = 'Memulai...';

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _runChecks();
  }

  Future<void> _runChecks() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // 1. Cek internet
    _setStatus('Mengecek koneksi internet...');
    final hasNet = await VersionService.hasInternet();

    if (!mounted) return;

    if (!hasNet) {
      _showNoInternetDialog();
      return;
    }

    // 2. Cek versi
    _setStatus('Mengecek versi aplikasi...');
    const currentVersion = '1.0.0';
    final versionInfo = await VersionService.checkVersion(currentVersion);

    if (!mounted) return;

    if (versionInfo != null && versionInfo['hasUpdate'] == true) {
      _showUpdateDialog(
        latestVersion: versionInfo['latestVersion'] as String,
        downloadUrl: versionInfo['downloadUrl'] as String,
        changelog: versionInfo['changelog'] as String,
      );
      return;
    }

    // 3. Cek session login
    _setStatus('Memeriksa sesi...');
    final authService = AuthService();
    final savedUserId = await authService.getSavedUserId();

    if (!mounted) return;

    if (savedUserId != null) {
      Navigator.pushReplacementNamed(context, '/main',
          arguments: savedUserId);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _setStatus(String message) {
    if (mounted) setState(() => _status = message);
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.expenseColor, width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: AppTheme.expenseColor, size: 24),
            const SizedBox(width: 10),
            const Text('Tidak Ada Internet',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Cash-in memerlukan koneksi internet untuk sinkronisasi data. '
          'Pastikan perangkat Anda terhubung ke internet, lalu coba lagi.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _runChecks();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog({
    required String latestVersion,
    required String downloadUrl,
    required String changelog,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.primaryGreen, width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.system_update_rounded,
                color: AppTheme.primaryGreen, size: 24),
            const SizedBox(width: 10),
            const Text('Update Tersedia',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versi terbaru: v$latestVersion',
                style: const TextStyle(color: AppTheme.neonGreen,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (changelog.isNotEmpty) ...[
              Text(changelog,
                  style: const TextStyle(color: AppTheme.textSecondary,
                      fontSize: 13)),
              const SizedBox(height: 8),
            ],
            const Text(
              'Unduh versi terbaru untuk mendapatkan fitur dan perbaikan terkini.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(downloadUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Download', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo pulse
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.bgCard,
                    border: Border.all(color: AppTheme.primaryGreen, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 52,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // App name
              const Text(
                'CASH-IN',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manajemen Keuangan Pribadi',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  color: AppTheme.textHint,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),
              // Loading indicator
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  color: AppTheme.textHint,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
