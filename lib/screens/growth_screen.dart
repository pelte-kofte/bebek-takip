import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import 'add_growth_screen.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  List<Map<String, dynamic>> _records = [];
  int _selectedTab = 0; // 0 = Liste, 1 = Grafik
  int _chartMetric = 0; // 0 = Boy (height), 1 = Kilo (weight)

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = VeriYonetici.getBoyKiloKayitlari();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecorativeBackground(
      preset: BackgroundPreset.growth,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              _buildTabBar(isDark),
              Expanded(
                child: _records.isEmpty
                    ? _buildEmptyState(isDark)
                    : _selectedTab == 0
                        ? _buildRecordsList(isDark)
                        : _buildChartView(isDark),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddGrowthScreen(onSaved: _loadRecords),
              ),
            );
            _loadRecords();
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.primary.withValues(alpha: 0.1),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.primary,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            Dil.buyumeTakibi,
            style: AppTypography.h1(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;
    final activeColor = const Color(0xFFFFB4A2);
    final inactiveTextColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF7A749E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.6)
              : const Color(0xFFE5E0F7).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0 ? cardColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _selectedTab == 0
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.list_rounded,
                          size: 18,
                          color: _selectedTab == 0
                              ? activeColor
                              : inactiveTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Liste',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 0
                                ? activeColor
                                : inactiveTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1 ? cardColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _selectedTab == 1
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 18,
                          color: _selectedTab == 1
                              ? activeColor
                              : inactiveTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Grafik',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 1
                                ? activeColor
                                : inactiveTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.straighten,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henuz olcum yok',
              style: AppTypography.h3(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Boy ve kilo olcumlerini ekleyin',
              style: AppTypography.bodySmall(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        final tarih = record['tarih'] as DateTime;
        final boy = record['boy'];
        final kilo = record['kilo'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bgDarkCard.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.primary.withValues(alpha: 0.05),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: AppColors.accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tarih.day} ${Dil.aylar[tarih.month - 1]} ${tarih.year}',
                      style: AppTypography.h3(context).copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Dil.boy}: $boy cm  •  ${Dil.kilo}: $kilo kg',
                      style: AppTypography.caption(context).copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF866F65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartView(bool isDark) {
    final cardColor = isDark
        ? AppColors.bgDarkCard.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.9);
    final textColor = isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18);
    final subtitleColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF7A749E);

    // Sort records by date ascending for charts
    final sorted = List<Map<String, dynamic>>.from(_records)
      ..sort((a, b) => (a['tarih'] as DateTime).compareTo(b['tarih'] as DateTime));

    final boyData = <double>[];
    final kiloData = <double>[];
    final labels = <String>[];

    for (final r in sorted) {
      final boy = r['boy'];
      final kilo = r['kilo'];
      if (boy != null) boyData.add((boy as num).toDouble());
      if (kilo != null) kiloData.add((kilo as num).toDouble());
      final t = r['tarih'] as DateTime;
      labels.add('${t.day}/${t.month}');
    }

    final activeData = _chartMetric == 0 ? boyData : kiloData;
    final unit = _chartMetric == 0 ? 'cm' : 'kg';
    final title = _chartMetric == 0 ? '${Dil.boy} (cm)' : '${Dil.kilo} (kg)';
    final icon = _chartMetric == 0 ? Icons.straighten : Icons.monitor_weight_outlined;
    const lineColor = Color(0xFFD4C4E8); // lavender

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      child: Column(
        children: [
          // Metric toggle
          _buildMetricToggle(isDark),
          const SizedBox(height: 16),

          // Chart card
          _buildChartCard(
            cardColor: cardColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            title: title,
            icon: icon,
            lineColor: lineColor,
            data: activeData,
            labels: labels,
            unit: unit,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricToggle(bool isDark) {
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;
    const lavender = Color(0xFFD4C4E8);
    final inactiveTextColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF7A749E);

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withValues(alpha: 0.6)
            : const Color(0xFFE5E0F7).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _chartMetric = 0),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _chartMetric == 0 ? cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _chartMetric == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    Dil.boy,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _chartMetric == 0 ? lavender : inactiveTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _chartMetric = 1),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _chartMetric == 1 ? cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _chartMetric == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    Dil.kilo,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _chartMetric == 1 ? lavender : inactiveTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required String title,
    required IconData icon,
    required Color lineColor,
    required List<double> data,
    required List<String> labels,
    required String unit,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Single-record: show a value card instead of a chart
    if (data.length == 1) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.primary.withValues(alpha: 0.05),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: lineColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: lineColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              '${data.first.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels.first,
              style: TextStyle(fontSize: 13, color: subtitleColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Grafik icin en az 2 olcum gerekli',
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final chartMin = range > 0 ? minVal - range * 0.15 : minVal * 0.9;
    final chartMax = range > 0 ? maxVal + range * 0.15 : maxVal * 1.1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.primary.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: lineColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              // Latest value
              Text(
                '${data.last.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: lineColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _GrowthChartPainter(
                data: data,
                labels: labels,
                minValue: chartMin,
                maxValue: chartMax,
                lineColor: lineColor,
                labelColor: subtitleColor,
                gridColor: subtitleColor.withValues(alpha: 0.1),
                unit: unit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double minValue;
  final double maxValue;
  final Color lineColor;
  final Color labelColor;
  final Color gridColor;
  final String unit;

  _GrowthChartPainter({
    required this.data,
    required this.labels,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
    required this.labelColor,
    required this.gridColor,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const leftPad = 44.0;
    const bottomPad = 24.0;
    const topPad = 8.0;

    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad - topPad;
    final valueRange = maxValue - minValue;

    // Grid lines (3 horizontal)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: labelColor,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i <= 2; i++) {
      final y = topPad + chartH * (1 - i / 2);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Y-axis label
      final val = minValue + valueRange * (i / 2);
      final tp = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(1), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 6, y - tp.height / 2));
    }

    // Plot data
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(leftPad, topPad, chartW, chartH))
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final stepX = data.length > 1 ? chartW / (data.length - 1) : chartW;
    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = leftPad + i * stepX;
      final normalised = valueRange > 0
          ? (data[i] - minValue) / valueRange
          : 0.5;
      final y = topPad + chartH * (1 - normalised);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, topPad + chartH);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close fill path
    fillPath.lineTo(leftPad + (data.length - 1) * stepX, topPad + chartH);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw dots and x-axis labels
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, dotBorderPaint);
      canvas.drawCircle(points[i], 3.5, dotPaint);

      // X-axis labels (show a subset if too many)
      if (data.length <= 8 || i % ((data.length / 6).ceil()) == 0 || i == data.length - 1) {
        if (i < labels.length) {
          final tp = TextPainter(
            text: TextSpan(text: labels[i], style: labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(points[i].dx - tp.width / 2, topPad + chartH + 6),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue;
  }
}
