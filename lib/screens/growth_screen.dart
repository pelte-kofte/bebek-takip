import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import '../widgets/nilico_motion.dart';
import 'add_growth_screen.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  List<Map<String, dynamic>> _records = [];
  int _selectedTab = 0;
  int _chartMetric = 0;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = _sortRecordsByMeasurementDateDesc(
        VeriYonetici.getBoyKiloKayitlari(),
      );
    });
  }

  List<Map<String, dynamic>> _sortRecordsByMeasurementDateDesc(
    List<Map<String, dynamic>> records,
  ) {
    final sorted = List<Map<String, dynamic>>.from(records);
    sorted.sort((a, b) {
      final aDate = a['tarih'] as DateTime?;
      final bDate = b['tarih'] as DateTime?;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  String _localeName(BuildContext context) =>
      Localizations.localeOf(context).toString();

  String _formatDate(BuildContext context, DateTime date) {
    return intl.DateFormat.yMMMMd(_localeName(context)).format(date);
  }

  String _formatMonthLabel(BuildContext context, DateTime date) {
    return intl.DateFormat.MMM(_localeName(context)).format(date);
  }

  String _formatNumber(BuildContext context, num value) {
    return intl.NumberFormat.decimalPatternDigits(
      locale: _localeName(context),
      decimalDigits: 1,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return DecorativeBackground(
      preset: BackgroundPreset.growth,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark, l10n),
              _buildTabBar(isDark, l10n),
              Expanded(
                child: _records.isEmpty
                    ? _buildEmptyState(l10n)
                    : _selectedTab == 0
                    ? _buildRecordsList(isDark, l10n)
                    : _buildChartView(isDark, l10n),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              buildNilicoPageRoute<bool>(
                builder: (context) => AddGrowthScreen(onSaved: _loadRecords),
              ),
            );
            if (result == true) {
              _loadRecords();
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
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
          Text(l10n.growthTracking, style: AppTypography.h1(context)),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
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
                onTap: () {
                  if (_selectedTab != 0) {
                    NilicoHaptics.trigger(NilicoHapticType.selection);
                  }
                  setState(() => _selectedTab = 0);
                },
                child: AnimatedContainer(
                  duration: NilicoMotion.chipDuration,
                  curve: NilicoMotion.ease,
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
                          l10n.list,
                          style: AppTypography.compactTitle(context).copyWith(
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
                onTap: () {
                  if (_selectedTab != 1) {
                    NilicoHaptics.trigger(NilicoHapticType.selection);
                  }
                  setState(() => _selectedTab = 1);
                },
                child: AnimatedContainer(
                  duration: NilicoMotion.chipDuration,
                  curve: NilicoMotion.ease,
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
                          l10n.chart,
                          style: AppTypography.compactTitle(context).copyWith(
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

  Widget _buildEmptyState(AppLocalizations l10n) {
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
              l10n.noMeasurements,
              style: AppTypography.sheetTitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addMeasurements,
              style: AppTypography.bodySmall(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartEmptyState(Color subtitleColor, AppLocalizations l10n) {
    final remaining = 3 - _records.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 56,
              color: const Color(0xFFD4C4E8).withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.moreDataNeeded,
              style: AppTypography.sheetTitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addMoreMeasurements(remaining),
              style: AppTypography.bodySmall(
                context,
              ).copyWith(color: subtitleColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList(bool isDark, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        final date = record['tarih'] as DateTime;
        final height = (record['boy'] as num?) ?? 0;
        final weight = (record['kilo'] as num?) ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bgDarkCard.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
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
                      color: AppColors.primary.withValues(alpha: 0.035),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(context, date),
                style: AppTypography.compactTitle(
                  context,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMeasurementMetric(
                      isDark: isDark,
                      label: l10n.weight,
                      value: _formatNumber(context, weight),
                      unit: l10n.kilogramUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMeasurementMetric(
                      isDark: isDark,
                      label: l10n.height,
                      value: _formatNumber(context, height),
                      unit: l10n.centimeterUnit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeasurementMetric({
    required bool isDark,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.borderSoft.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.compactTitle(context).copyWith(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF9B8F88),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: AppTypography.compactTitle(context).copyWith(
                    fontSize: 18,
                    letterSpacing: -0.35,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF2D1A18),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppTypography.caption(context).copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF9B8F88),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartView(bool isDark, AppLocalizations l10n) {
    final cardColor = isDark
        ? AppColors.bgDarkCard.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.9);
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : const Color(0xFF2D1A18);
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF7A749E);

    if (_records.length < 3) {
      return _buildChartEmptyState(subtitleColor, l10n);
    }

    final sorted = List<Map<String, dynamic>>.from(_records)
      ..sort(
        (a, b) => (a['tarih'] as DateTime).compareTo(b['tarih'] as DateTime),
      );

    final heightData = <double>[];
    final weightData = <double>[];
    final labels = <String>[];

    for (final record in sorted) {
      final height = record['boy'];
      final weight = record['kilo'];
      if (height != null) {
        heightData.add((height as num).toDouble());
      }
      if (weight != null) {
        weightData.add((weight as num).toDouble());
      }
      labels.add(_formatMonthLabel(context, record['tarih'] as DateTime));
    }

    final activeData = _chartMetric == 0 ? heightData : weightData;
    final unit = _chartMetric == 0 ? l10n.centimeterUnit : l10n.kilogramUnit;
    final title = _chartMetric == 0
        ? '${l10n.height} (${l10n.centimeterUnit})'
        : '${l10n.weight} (${l10n.kilogramUnit})';
    final icon = _chartMetric == 0
        ? Icons.straighten
        : Icons.monitor_weight_outlined;
    const lineColor = Color(0xFFD4C4E8);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      child: Column(
        children: [
          _buildMetricToggle(isDark, l10n),
          const SizedBox(height: 16),
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
            localeName: _localeName(context),
            emptyChartHint: l10n.atLeast2Measurements,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricToggle(bool isDark, AppLocalizations l10n) {
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
              onTap: () {
                if (_chartMetric != 0) {
                  NilicoHaptics.trigger(NilicoHapticType.selection);
                }
                setState(() => _chartMetric = 0);
              },
              child: AnimatedContainer(
                duration: NilicoMotion.chipDuration,
                curve: NilicoMotion.ease,
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
                  child: AnimatedDefaultTextStyle(
                    duration: NilicoMotion.chipDuration,
                    curve: NilicoMotion.ease,
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _chartMetric == 0 ? lavender : inactiveTextColor,
                    ),
                    child: Text(l10n.height),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_chartMetric != 1) {
                  NilicoHaptics.trigger(NilicoHapticType.selection);
                }
                setState(() => _chartMetric = 1);
              },
              child: AnimatedContainer(
                duration: NilicoMotion.chipDuration,
                curve: NilicoMotion.ease,
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
                  child: AnimatedDefaultTextStyle(
                    duration: NilicoMotion.chipDuration,
                    curve: NilicoMotion.ease,
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _chartMetric == 1 ? lavender : inactiveTextColor,
                    ),
                    child: Text(l10n.weight),
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
    required String localeName,
    required String emptyChartHint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numberFormat = intl.NumberFormat.decimalPatternDigits(
      locale: localeName,
      decimalDigits: 1,
    );

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
                    color: AppColors.primary.withValues(alpha: 0.035),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  numberFormat.format(data.first),
                  style: AppTypography.dataValue(
                    context,
                  ).copyWith(color: textColor),
                ),
                const SizedBox(width: 5),
                Text(
                  unit,
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(color: subtitleColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              labels.first,
              style: AppTypography.caption(
                context,
              ).copyWith(fontSize: 13, color: subtitleColor),
            ),
            const SizedBox(height: 16),
            Text(
              emptyChartHint,
              style: AppTypography.caption(context).copyWith(
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
                  color: AppColors.primary.withValues(alpha: 0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                style: AppTypography.compactTitle(
                  context,
                ).copyWith(fontSize: 16, color: textColor),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    numberFormat.format(data.last),
                    style: AppTypography.compactTitle(
                      context,
                    ).copyWith(color: lineColor),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: lineColor.withValues(alpha: 0.82)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                gridColor: subtitleColor.withValues(alpha: 0.07),
                localeName: localeName,
                labelStyle: AppTypography.caption(
                  context,
                ).copyWith(fontSize: 10, color: subtitleColor),
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
  final Color gridColor;
  final String localeName;
  final TextStyle labelStyle;

  _GrowthChartPainter({
    required this.data,
    required this.labels,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
    required this.gridColor,
    required this.localeName,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      return;
    }

    const leftPad = 44.0;
    const bottomPad = 24.0;
    const topPad = 8.0;

    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad - topPad;
    final valueRange = maxValue - minValue;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final numberFormat = intl.NumberFormat.decimalPatternDigits(
      locale: localeName,
      decimalDigits: 1,
    );

    for (int i = 0; i <= 2; i++) {
      final y = topPad + chartH * (1 - i / 2);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      final val = minValue + valueRange * (i / 2);
      final tp = TextPainter(
        text: TextSpan(text: numberFormat.format(val), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelX = (leftPad - tp.width - 6).clamp(0.0, leftPad).toDouble();
      tp.paint(canvas, Offset(labelX, y - tp.height / 2));
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.07)
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

    fillPath.lineTo(leftPad + (data.length - 1) * stepX, topPad + chartH);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;

      if (isLast) {
        final glowPaint = Paint()
          ..color = lineColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(points[i], 10, glowPaint);
        canvas.drawCircle(points[i], 6, dotBorderPaint);
        canvas.drawCircle(points[i], 4.5, dotPaint);
      } else {
        canvas.drawCircle(points[i], 5, dotBorderPaint);
        canvas.drawCircle(points[i], 3.5, dotPaint);
      }

      final showLabel =
          i == 0 ||
          i == data.length - 1 ||
          (data.length > 4 && i == data.length ~/ 2);

      if (showLabel && i < labels.length) {
        final tp = TextPainter(
          text: TextSpan(text: labels[i], style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final labelX = (points[i].dx - tp.width / 2)
            .clamp(leftPad, size.width - tp.width)
            .toDouble();
        tp.paint(canvas, Offset(labelX, topPad + chartH + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.localeName != localeName ||
        oldDelegate.labelStyle != labelStyle;
  }
}
