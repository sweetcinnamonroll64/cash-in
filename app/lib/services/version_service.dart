import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class VersionService {
  static Future<bool> hasInternet() async {
    final results = await Connectivity().checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    // Double-check with real request
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Returns map with keys: 'hasUpdate', 'latestVersion', 'downloadUrl', 'changelog'
  /// Returns null if check fails (don't block user on version check failure)
  static Future<Map<String, dynamic>?> checkVersion(String currentVersion) async {
    final url = dotenv.env['VERSION_CHECK_URL'];
    if (url == null || url.isEmpty) return null;

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final latestVersion = data['version'] as String? ?? currentVersion;
      final downloadUrl   = data['download_url'] as String? ?? '';
      final changelog     = data['changelog'] as String? ?? '';

      final hasUpdate = _isNewerVersion(latestVersion, currentVersion);

      return {
        'hasUpdate':      hasUpdate,
        'latestVersion':  latestVersion,
        'downloadUrl':    downloadUrl,
        'changelog':      changelog,
      };
    } catch (_) {
      return null;
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    final latestParts  = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}
