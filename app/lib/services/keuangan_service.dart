import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/keuangan_model.dart';

class KeuanganService {
  final _db = Supabase.instance.client;

  // ── Insert ───────────────────────────────────────────────
  Future<KeuanganModel> insert(KeuanganModel data) async {
    final response = await _db
        .from('table_keuangan')
        .insert(data.toMap())
        .select()
        .single();
    return KeuanganModel.fromMap(response);
  }

  // ── Get All (with date filter) ───────────────────────────
  Future<List<KeuanganModel>> getByDateRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromStr = from.toIso8601String().split('T')[0];
    final toStr   = to.toIso8601String().split('T')[0];

    final response = await _db
        .from('table_keuangan')
        .select()
        .eq('user_id', userId)
        .gte('tanggal', fromStr)
        .lte('tanggal', toStr)
        .order('tanggal', ascending: true);

    return (response as List)
        .map((e) => KeuanganModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── Summary (total pemasukan & pengeluaran) ──────────────
  Future<Map<String, int>> getSummary({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await getByDateRange(userId: userId, from: from, to: to);

    int totalPemasukan  = 0;
    int totalPengeluaran = 0;

    for (final item in data) {
      if (item.isPemasukan) {
        totalPemasukan += item.nominal;
      } else {
        totalPengeluaran += item.nominal;
      }
    }

    return {
      'pemasukan':   totalPemasukan,
      'pengeluaran': totalPengeluaran,
      'saldo':       totalPemasukan - totalPengeluaran,
    };
  }

  // ── Delete ───────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _db.from('table_keuangan').delete().eq('id', id);
  }
}
