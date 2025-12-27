import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showGrowthChart = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final mamaKayitlari = VeriYonetici.getMamaKayitlari();
    final kakaKayitlari = VeriYonetici.getKakaKayitlari();
    final uykuKayitlari = VeriYonetici.getUykuKayitlari();
    final boyKiloKayitlari = VeriYonetici.getBoyKiloKayitlari();

    final timeline = _buildTimeline(mamaKayitlari, kakaKayitlari, uykuKayitlari);

    Map<String, dynamic>? sonOlcum;
    if (boyKiloKayitlari.isNotEmpty) {
      sonOlcum = boyKiloKayitlari.first;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF121212)]
                : [const Color(0xFFFCE4EC), const Color(0xFFF8F8F8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.pink.shade900 : Colors.pink.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('👶', style: TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bebeğim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                          if (sonOlcum != null)
                            Text('${sonOlcum['boy']} cm • ${sonOlcum['kilo']} kg', style: TextStyle(fontSize: 12, color: subtitleColor))
                          else
                            Text('6 ay 12 gün', style: TextStyle(fontSize: 14, color: subtitleColor)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.pink.shade900 : Colors.pink.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none, color: Color(0xFFE91E63)),
                      ),
                    ],
                  ),
                ),

                // SON AKTİVİTELER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(Dil.sonAktiviteler, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildLastActionCard(
                        '🍼', Dil.sonBeslenme,
                        mamaKayitlari.isNotEmpty ? _timeAgo(mamaKayitlari.first['tarih']) : '-',
                        _getMamaDetail(mamaKayitlari.isNotEmpty ? mamaKayitlari.first : null),
                        const Color(0xFFFFE0B2), cardColor, textColor, subtitleColor,
                      ),
                      _buildLastActionCard(
                        '😴', Dil.sonUyku,
                        uykuKayitlari.isNotEmpty ? _timeAgo(uykuKayitlari.first['bitis']) : '-',
                        uykuKayitlari.isNotEmpty ? _formatDuration(uykuKayitlari.first['sure']) : '',
                        const Color(0xFFE1BEE7), cardColor, textColor, subtitleColor,
                      ),
                      _buildLastActionCard(
                        '👶', Dil.sonBezDegisimi,
                        kakaKayitlari.isNotEmpty ? _timeAgo(kakaKayitlari.first['tarih']) : '-',
                        kakaKayitlari.isNotEmpty ? kakaKayitlari.first['tur'] : '',
                        const Color(0xFFB3E5FC), cardColor, textColor, subtitleColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ZAMAN ÇİZELGESİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Dil.zaman, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(Dil.son24Saat, style: TextStyle(fontSize: 12, color: textColor)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (timeline.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(Dil.henuzKayitYok, style: TextStyle(color: subtitleColor)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: timeline.length > 5 ? 5 : timeline.length,
                    itemBuilder: (context, index) => _buildTimelineItem(timeline[index], textColor, subtitleColor, isDark),
                  ),
                const SizedBox(height: 24),

                // BÜYÜME TAKİBİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📊 ${Dil.buyumeTakibi}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _showGrowthChart = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _showGrowthChart ? const Color(0xFF4CAF50) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.show_chart, size: 18, color: _showGrowthChart ? Colors.white : subtitleColor),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _showGrowthChart = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_showGrowthChart ? const Color(0xFF4CAF50) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.list, size: 18, color: !_showGrowthChart ? Colors.white : subtitleColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (boyKiloKayitlari.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('📏', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(Dil.henuzOlcumYok, style: TextStyle(color: subtitleColor)),
                        ],
                      ),
                    ),
                  )
                else if (_showGrowthChart)
                  _buildGrowthChart(boyKiloKayitlari, cardColor, textColor)
                else
                  _buildGrowthList(boyKiloKayitlari, cardColor, textColor, subtitleColor),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMamaDetail(Map<String, dynamic>? kayit) {
    if (kayit == null) return '';
    final tur = kayit['tur'] as String? ?? '';
    if (tur == 'Anne Sütü') {
      final sol = kayit['solDakika'] ?? 0;
      final sag = kayit['sagDakika'] ?? 0;
      return 'Sol ${sol}dk • Sağ ${sag}dk';
    } else {
      return '${kayit['miktar']} ml';
    }
  }

  Widget _buildLastActionCard(String icon, String title, String value, String detail, Color color, Color cardColor, Color textColor, Color subtitleColor) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 9, color: subtitleColor)),
                    Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(detail, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE91E63))),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, Color textColor, Color subtitleColor, bool isDark) {
    final type = item['type'] as String;
    final time = item['time'] as String;
    
    Color lineColor;
    String emoji;
    String title;
    String subtitle;
    
    switch (type) {
      case 'mama':
        lineColor = const Color(0xFFFF9800);
        final tur = item['tur'] as String? ?? '';
        final sol = item['solDakika'] ?? 0;
        final sag = item['sagDakika'] ?? 0;
        final miktar = item['miktar'] ?? 0;
        
        if (tur == 'Anne Sütü') {
          emoji = '🤱';
          title = Dil.emzirme;
          subtitle = 'Sol ${sol}dk • Sağ ${sag}dk';
        } else {
          emoji = tur == 'Formül' ? '🍼' : '🥛';
          title = tur;
          subtitle = '$miktar ml';
        }
        break;
      case 'kaka':
        lineColor = const Color(0xFF03A9F4);
        emoji = '👶';
        title = Dil.bezDegisimi;
        subtitle = item['tur'] ?? '';
        break;
      case 'uyku':
        lineColor = const Color(0xFF9C27B0);
        emoji = '😴';
        title = Dil.uyku;
        subtitle = item['sure'] ?? '';
        break;
      default:
        lineColor = Colors.grey;
        emoji = '📝';
        title = 'Aktivite';
        subtitle = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: lineColor.withAlpha(50),
                  shape: BoxShape.circle,
                  border: Border.all(color: lineColor, width: 2),
                ),
              ),
              Container(width: 2, height: 40, color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                      Text(subtitle, style: TextStyle(color: lineColor, fontSize: 12)),
                    ],
                  ),
                ),
                Text(time, style: TextStyle(color: subtitleColor, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(List<Map<String, dynamic>> kayitlar, Color cardColor, Color textColor) {
    final son6 = kayitlar.take(6).toList().reversed.toList();
    if (son6.isEmpty) return const SizedBox();

    double maxBoy = 0, maxKilo = 0;
    for (var k in son6) {
      if ((k['boy'] as num) > maxBoy) maxBoy = (k['boy'] as num).toDouble();
      if ((k['kilo'] as num) > maxKilo) maxKilo = (k['kilo'] as num).toDouble();
    }
    maxBoy *= 1.1;
    maxKilo *= 1.1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.straighten, color: Color(0xFF4CAF50), size: 18),
            const SizedBox(width: 8),
            Text('${Dil.boy} (cm)', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _ChartPainter(data: son6.map((k) => (k['boy'] as num).toDouble()).toList(), maxValue: maxBoy, color: const Color(0xFF4CAF50)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.monitor_weight, color: Color(0xFF2196F3), size: 18),
            const SizedBox(width: 8),
            Text('${Dil.kilo} (kg)', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _ChartPainter(data: son6.map((k) => (k['kilo'] as num).toDouble()).toList(), maxValue: maxKilo, color: const Color(0xFF2196F3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthList(List<Map<String, dynamic>> kayitlar, Color cardColor, Color textColor, Color subtitleColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kayitlar.length > 5 ? 5 : kayitlar.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: subtitleColor.withAlpha(50)),
        itemBuilder: (context, index) {
          final k = kayitlar[index];
          final tarih = k['tarih'] as DateTime;
          return ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.green.withAlpha(25), borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('📏', style: TextStyle(fontSize: 18))),
            ),
            title: Text('${tarih.day} ${Dil.aylar[tarih.month - 1]} ${tarih.year}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            subtitle: Text('${Dil.boy}: ${k['boy']} cm • ${Dil.kilo}: ${k['kilo']} kg', style: TextStyle(color: subtitleColor, fontSize: 12)),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _buildTimeline(List<Map<String, dynamic>> mama, List<Map<String, dynamic>> kaka, List<Map<String, dynamic>> uyku) {
    final List<Map<String, dynamic>> timeline = [];
    final son24Saat = DateTime.now().subtract(const Duration(hours: 24));
    
    for (var k in mama) {
      final tarih = k['tarih'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({
          'type': 'mama',
          'tarih': tarih,
          'time': _formatTime(tarih),
          'miktar': k['miktar'] ?? 0,
          'tur': k['tur'] ?? '',
          'solDakika': k['solDakika'] ?? 0,
          'sagDakika': k['sagDakika'] ?? 0,
        });
      }
    }
    for (var k in kaka) {
      final tarih = k['tarih'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({'type': 'kaka', 'tarih': tarih, 'time': _formatTime(tarih), 'tur': k['tur']});
      }
    }
    for (var k in uyku) {
      final tarih = k['bitis'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({'type': 'uyku', 'tarih': tarih, 'time': _formatTime(tarih), 'sure': _formatDuration(k['sure'])});
      }
    }
    
    timeline.sort((a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime));
    return timeline;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return Dil.azOnce;
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${Dil.dakikaOnce}';
    if (diff.inHours < 24) return '${diff.inHours} ${Dil.saatOnce}';
    return '${diff.inDays} ${Dil.gunOnce}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '$hours ${Dil.sa} $minutes ${Dil.dk}';
    return '$minutes ${Dil.dk}';
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final Color color;

  _ChartPainter({required this.data, required this.maxValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..color = color.withAlpha(30)..style = PaintingStyle.fill;
    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final stepX = data.length > 1 ? size.width / (data.length - 1) : size.width;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}