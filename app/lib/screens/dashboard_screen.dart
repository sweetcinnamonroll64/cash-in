import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/keuangan_model.dart';
import '../services/keuangan_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = KeuanganService();

  DateTime _from = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _to = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
  );

  List<KeuanganModel> _data    = [];
  Map<String, int> _summary   = {'pemasukan': 0, 'pengeluaran': 0, 'saldo': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getByDateRange(
        userId: widget.userId,
        from: _from,
        to: _to,
      );
      final summary = await _service.getSummary(
        userId: widget.userId,
        from: _from,
        to: _to,
      );
      setState(() {
        _data    = data;
        _summary = summary;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _from, end: _to),
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

    if (range != null) {
      setState(() {
        _from = range.start;
        _to   = range.end;
      });
      _loadData();
    }
  }

  // Build chart spots from data
  List<FlSpot> _buildSpots(String tipe) {
    if (_data.isEmpty) return [const FlSpot(0, 0)];

    final Map<String, int> daily = {};
    for (final item in _data) {
      if (item.tipe != tipe) continue;
      final key = item.tanggal.toIso8601String().split('T')[0];
      daily[key] = (daily[key] ?? 0) + item.nominal;
    }

    final sorted = daily.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final start = _from.millisecondsSinceEpoch.toDouble();

    return sorted.map((e) {
      final dt = DateTime.parse(e.key);
      final x  = (dt.difference(_from).inDays).toDouble();
      final y  = e.value / 1000; // dalam ribuan
      return FlSpot(x, y);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryGreen,
      backgroundColor: AppTheme.bgCard,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date Filter ──
            _buildDateFilter(),
            const SizedBox(height: 16),

            // ── Summary Cards ──
            _buildSummaryCards(),
            const SizedBox(height: 20),

            // ── Chart ──
            _buildChartSection(),
            const SizedBox(height: 20),

            // ── Transaction List ──
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppTheme.primaryGreen, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${Formatters.date(_from)}  →  ${Formatters.date(_to)}',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.expand_more,
                color: AppTheme.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            label: 'PEMASUKAN',
            value: _summary['pemasukan'] ?? 0,
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.incomeColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: 'PENGELUARAN',
            value: _summary['pengeluaran'] ?? 0,
            icon: Icons.arrow_upward_rounded,
            color: AppTheme.expenseColor,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 9,
                  color: color,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Formatters.rupiah(value),
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final pemasukanSpots   = _buildSpots('pemasukan');
    final pengeluaranSpots = _buildSpots('pengeluaran');
    final totalDays = _to.difference(_from).inDays.toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GRAFIK KEUANGAN',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              Row(
                children: [
                  _legendDot(AppTheme.incomeColor, 'Masuk'),
                  const SizedBox(width: 12),
                  _legendDot(AppTheme.expenseColor, 'Keluar'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen))
                : _data.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada data',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                            color: AppTheme.textHint.withOpacity(0.5),
                          ),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: totalDays > 0 ? totalDays : 30,
                          minY: 0,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: AppTheme.borderColor,
                              strokeWidth: 0.8,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 48,
                                getTitlesWidget: (v, _) => Text(
                                  '${v.toInt()}K',
                                  style: const TextStyle(
                                    fontFamily: 'RobotoMono',
                                    fontSize: 10,
                                    color: AppTheme.textHint,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            // Pemasukan (green)
                            LineChartBarData(
                              spots: pemasukanSpots,
                              isCurved: true,
                              color: AppTheme.incomeColor,
                              barWidth: 2.5,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.incomeColor.withOpacity(0.08),
                              ),
                            ),
                            // Pengeluaran (red)
                            LineChartBarData(
                              spots: pengeluaranSpots,
                              isCurved: true,
                              color: AppTheme.expenseColor,
                              barWidth: 2.5,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.expenseColor.withOpacity(0.06),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (spots) => spots.map((s) {
                                final isIncome = s.barIndex == 0;
                                return LineTooltipItem(
                                  'Rp ${(s.y * 1000).toInt()}',
                                  TextStyle(
                                    color: isIncome
                                        ? AppTheme.incomeColor
                                        : AppTheme.expenseColor,
                                    fontFamily: 'RobotoMono',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RIWAYAT TRANSAKSI',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 2,
              ),
            ),
            if (!_loading)
              Text(
                '${_data.length} transaksi',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 10,
                  color: AppTheme.textHint,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (_loading)
          const Center(child: CircularProgressIndicator(
              color: AppTheme.primaryGreen))
        else if (_data.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 40,
                      color: AppTheme.textHint.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada transaksi\npada periode ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: AppTheme.textHint.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.reversed.take(30).length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = _data.reversed.toList()[i];
              final isPemasukan = item.isPemasukan;
              return _buildTransactionItem(item, isPemasukan);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionItem(KeuanganModel item, bool isPemasukan) {
    final color = isPemasukan ? AppTheme.incomeColor : AppTheme.expenseColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPemasukan
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.keterangan,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.date(item.tanggal),
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 10,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPemasukan ? '+' : '-'} ${Formatters.rupiah(item.nominal)}',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
