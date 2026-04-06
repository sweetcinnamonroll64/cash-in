class KeuanganModel {
  final String? id;
  final String userId;
  final String tipe; // 'pemasukan' | 'pengeluaran'
  final String keterangan;
  final int nominal;
  final DateTime tanggal;
  final DateTime? createdAt;

  const KeuanganModel({
    this.id,
    required this.userId,
    required this.tipe,
    required this.keterangan,
    required this.nominal,
    required this.tanggal,
    this.createdAt,
  });

  bool get isPemasukan => tipe == 'pemasukan';

  factory KeuanganModel.fromMap(Map<String, dynamic> map) {
    return KeuanganModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      tipe: map['tipe'] as String,
      keterangan: map['keterangan'] as String,
      nominal: (map['nominal'] as num).toInt(),
      tanggal: DateTime.parse(map['tanggal'] as String),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id':    userId,
      'tipe':       tipe,
      'keterangan': keterangan,
      'nominal':    nominal,
      'tanggal':    tanggal.toIso8601String().split('T')[0],
    };
  }
}
