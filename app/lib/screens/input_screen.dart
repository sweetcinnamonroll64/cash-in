import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/keuangan_model.dart';
import '../services/keuangan_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class InputScreen extends StatefulWidget {
  final String userId;
  const InputScreen({super.key, required this.userId});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with SingleTickerProviderStateMixin {
  final _formKey       = GlobalKey<FormState>();
  final _keteranganCtrl = TextEditingController();
  final _nominalCtrl    = TextEditingController();
  final _service        = KeuanganService();

  String    _tipe     = 'pemasukan';
  DateTime  _tanggal  = DateTime.now();
  bool      _loading  = false;

  late AnimationController _successCtrl;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _keteranganCtrl.dispose();
    _nominalCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  String _formatNominal(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final number = int.parse(digits);
    return NumberFormat('#,###', 'id_ID').format(number);
  }

  int _parseNominal() {
    final raw = _nominalCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return raw.isEmpty ? 0 : int.parse(raw);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryGreen,
            onPrimary: Colors.black,
            surface: AppTheme.bgCard,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nominal = _parseNominal();
    if (nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _service.insert(KeuanganModel(
        userId:     widget.userId,
        tipe:       _tipe,
        keterangan: _keteranganCtrl.text.trim(),
        nominal:    nominal,
        tanggal:    _tanggal,
      ));

      // Reset form
      _formKey.currentState!.reset();
      _keteranganCtrl.clear();
      _nominalCtrl.clear();
      setState(() {
        _tipe    = 'pemasukan';
        _tanggal = DateTime.now();
      });

      if (!mounted) return;
      _showSuccessSnackbar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: AppTheme.bgCard,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.incomeColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'Data berhasil disimpan!',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.bgCard,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      color: AppTheme.primaryGreen, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INPUT DATA KEUANGAN',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Catat transaksi keuangan Anda',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Form
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
                  // ── Tipe Keuangan ──
                  _fieldLabel('TIPE KEUANGAN', Icons.swap_vert_rounded),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _tipeButton(
                          label: 'PEMASUKAN',
                          value: 'pemasukan',
                          icon: Icons.arrow_downward_rounded,
                          color: AppTheme.incomeColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _tipeButton(
                          label: 'PENGELUARAN',
                          value: 'pengeluaran',
                          icon: Icons.arrow_upward_rounded,
                          color: AppTheme.expenseColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.borderColor),
                  const SizedBox(height: 20),

                  // ── Keterangan ──
                  _fieldLabel('KETERANGAN', Icons.notes_rounded),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _keteranganCtrl,
                    maxLines: 3,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Gaji bulanan, Bayar listrik...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Keterangan tidak boleh kosong'
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // ── Nominal ──
                  _fieldLabel('NOMINAL (Rp)', Icons.attach_money_rounded),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nominalCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0',
                      prefixText: 'Rp  ',
                      prefixStyle: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _RupiahInputFormatter(),
                    ],
                    validator: (v) {
                      final nominal = _parseNominal();
                      if (nominal <= 0) return 'Nominal harus lebih dari 0';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Tanggal ──
                  _fieldLabel('TANGGAL TRANSAKSI', Icons.calendar_today_rounded),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgInput,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_rounded,
                              color: AppTheme.primaryGreen, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            Formatters.date(_tanggal),
                            style: const TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.expand_more,
                              color: AppTheme.textHint, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Submit ──
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tipe == 'pemasukan'
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                    ),
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(
                      _loading ? 'MENYIMPAN...' : 'SIMPAN DATA',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _tipeButton({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _tipe == value;
    return GestureDetector(
      onTap: () => setState(() => _tipe = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppTheme.textHint, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppTheme.textHint,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// Custom input formatter untuk format Rupiah
class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final number = int.parse(digits);
    final formatted = NumberFormat('#,###', 'id_ID').format(number);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
