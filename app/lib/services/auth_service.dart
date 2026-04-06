import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const _sessionKey = 'cash_in_user_id';
  final _db = Supabase.instance.client;

  // ── Login ────────────────────────────────────────────────
  Future<UserModel?> login(String userId, String password) async {
    final response = await _db
        .from('table_user_id')
        .select()
        .eq('user_id', userId)
        .eq('password', password)
        .maybeSingle();

    if (response == null) return null;

    final user = UserModel.fromMap(response);
    await _saveSession(user.userId);
    return user;
  }

  // ── Register ─────────────────────────────────────────────
  Future<UserModel> register({
    required String userId,
    required String password,
    String? email,
  }) async {
    // Cek apakah user_id sudah ada
    final existing = await _db
        .from('table_user_id')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      throw Exception('User ID sudah digunakan. Pilih yang lain.');
    }

    final newUser = UserModel(
      userId: userId,
      password: password,
      email: email,
    );

    final response = await _db
        .from('table_user_id')
        .insert(newUser.toMap())
        .select()
        .single();

    return UserModel.fromMap(response);
  }

  // ── Session ──────────────────────────────────────────────
  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
