import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showGrowthChart = true; // true = grafik, false = liste

  @override
  Widget build(BuildContext context) {
    final mamaKayitlari = VeriYonetici.getMamaKayitlari();
    final kakaKayitlari = VeriYonetici.getKakaKayitlari();
    final uykuKayitlari = VeriYonetici.getUykuKayitlari();
    final boyKiloKayitlari = VeriYonetici.getBoyKiloKayitlari();

    final timeline = _buildTimeline(
      mamaKayitlari,
      kakaKayitlari,
      uykuKayitlari,
    );

    // Boy/Kilo değişim hesapla
    Map<String, dynamic>? sonOlcum;
    Map<String, dynamic>? oncekiOlcum;
    if (boyKiloKayitlari.isNotEmpty) {
      sonOlcum = boyKiloKayitlari.first;
      if (boyKiloKayitlari.length > 1) {
        oncekiOlcum = boyKiloKayitlari[1];
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER - Bebek Profili
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👶', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bebeğim',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Row(
                          children: [
                            if (sonOlcum != null) ...[
                              Text(
                                '${sonOlcum['boy']} cm • ${sonOlcum['kilo']} kg',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ] else
                              const Text(
                                '6 ay 12 gün',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ),

              // LAST ACTIONS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Last actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildLastActionCard(
                      icon: '🍼',
                      title: 'Last Fed',
                      value: mamaKayitlari.isNotEmpty
                          ? _timeAgo(mamaKayitlari.first['tarih'])
                          : '-',
                      subtitle: mamaKayitlari.isNotEmpty
                          ? '${mamaKayitlari.first['tur']}'
                          : '',
                      detail: mamaKayitlari.isNotEmpty
                          ? '${mamaKayitlari.first['miktar']} ml'
                          : '',
                      color: const Color(0xFFFFE0B2),
                    ),
                    _buildLastActionCard(
                      icon: '😴',
                      title: 'Awake',
                      value: uykuKayitlari.isNotEmpty
                          ? _timeAgo(uykuKayitlari.first['bitis'])
                          : '-',
                      subtitle: 'Today',
                      detail: uykuKayitlari.isNotEmpty
                          ? _formatDuration(uykuKayitlari.first['sure'])
                          : '',
                      color: const Color(0xFFE1BEE7),
                    ),
                    _buildLastActionCard(
                      icon: '👶',
                      title: 'Changed',
                      value: kakaKayitlari.isNotEmpty
                          ? _timeAgo(kakaKayitlari.first['tarih'])
                          : '-',
                      subtitle: 'Type',
                      detail: kakaKayitlari.isNotEmpty
                          ? kakaKayitlari.first['tur']
                          : '',
                      color: const Color(0xFFB3E5FC),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // TIMELINE HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'All',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // TIMELINE LIST
              if (timeline.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Text('📝', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'Henüz kayıt yok',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '+ butonuna basarak ekle',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
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
                  itemBuilder: (context, index) {
                    final item = timeline[index];
                    return _buildTimelineItem(item);
                  },
                ),
              const SizedBox(height: 24),

              // GROWTH SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📊 Büyüme Takibi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    // Grafik/Liste Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showGrowthChart = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _showGrowthChart
                                    ? const Color(0xFF4CAF50)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.show_chart,
                                size: 18,
                                color: _showGrowthChart
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showGrowthChart = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: !_showGrowthChart
                                    ? const Color(0xFF4CAF50)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.list,
                                size: 18,
                                color: !_showGrowthChart
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // GROWTH CONTENT
              if (boyKiloKayitlari.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Text('📏', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'Henüz ölçüm yok',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '+ butonundan ölçüm ekle',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_showGrowthChart)
                _buildGrowthChart(boyKiloKayitlari)
              else
                _buildGrowthList(boyKiloKayitlari),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthChart(List<Map<String, dynamic>> kayitlar) {
    // Son 6 ölçümü al ve ters çevir (eski->yeni)
    final son6 = kayitlar.take(6).toList().reversed.toList();

    if (son6.isEmpty) return const SizedBox();

    // Max değerleri bul
    double maxBoy = 0;
    double maxKilo = 0;
    for (var k in son6) {
      if ((k['boy'] as num) > maxBoy) maxBoy = (k['boy'] as num).toDouble();
      if ((k['kilo'] as num) > maxKilo) maxKilo = (k['kilo'] as num).toDouble();
    }
    maxBoy = maxBoy * 1.1;
    maxKilo = maxKilo * 1.1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Boy Grafiği
          const Row(
            children: [
              Icon(Icons.straighten, color: Color(0xFF4CAF50), size: 18),
              SizedBox(width: 8),
              Text(
                'Boy (cm)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _ChartPainter(
                data: son6.map((k) => (k['boy'] as num).toDouble()).toList(),
                maxValue: maxBoy,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kilo Grafiği
          const Row(
            children: [
              Icon(Icons.monitor_weight, color: Color(0xFF2196F3), size: 18),
              SizedBox(width: 8),
              Text(
                'Kilo (kg)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _ChartPainter(
                data: son6.map((k) => (k['kilo'] as num).toDouble()).toList(),
                maxValue: maxKilo,
                color: const Color(0xFF2196F3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tarih etiketleri
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: son6.map((k) {
              final tarih = k['tarih'] as DateTime;
              return Text(
                '${tarih.day}/${tarih.month}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthList(List<Map<String, dynamic>> kayitlar) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kayitlar.length > 10 ? 10 : kayitlar.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final kayit = kayitlar[index];
          final tarih = kayit['tarih'] as DateTime;
          final boy = kayit['boy'];
          final kilo = kayit['kilo'];
          final bas = kayit['basCevresi'];

          // Önceki kayıtla karşılaştır
          String boyDegisim = '';
          String kiloDegisim = '';
          if (index < kayitlar.length - 1) {
            final onceki = kayitlar[index + 1];
            final boyFark = (boy as num) - (onceki['boy'] as num);
            final kiloFark = (kilo as num) - (onceki['kilo'] as num);
            if (boyFark != 0)
              boyDegisim = boyFark > 0
                  ? '+${boyFark.toStringAsFixed(1)}'
                  : boyFark.toStringAsFixed(1);
            if (kiloFark != 0)
              kiloDegisim = kiloFark > 0
                  ? '+${kiloFark.toStringAsFixed(1)}'
                  : kiloFark.toStringAsFixed(1);
          }

          return ListTile(
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('📏', style: TextStyle(fontSize: 20)),
              ),
            ),
            title: Row(
              children: [
                Text(
                  '${tarih.day}/${tarih.month}/${tarih.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                _buildMiniStat(
                  '📏',
                  '$boy cm',
                  boyDegisim,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 16),
                _buildMiniStat(
                  '⚖️',
                  '$kilo kg',
                  kiloDegisim,
                  const Color(0xFF2196F3),
                ),
                if (bas != null && bas > 0) ...[
                  const SizedBox(width: 16),
                  _buildMiniStat('🧒', '$bas cm', '', const Color(0xFFFF9800)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(
    String emoji,
    String value,
    String change,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (change.isNotEmpty) ...[
          const SizedBox(width: 2),
          Text(
            change,
            style: TextStyle(
              fontSize: 10,
              color: change.startsWith('+') ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLastActionCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required String detail,
    required Color color,
  }) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final time = item['time'] as String;

    Color lineColor;
    String emoji;
    String title;
    String subtitle;

    switch (type) {
      case 'mama':
        lineColor = const Color(0xFFFF9800);
        emoji = '🍼';
        title = 'Feed';
        subtitle = '${item['tur']} • ${item['miktar']} ml';
        break;
      case 'kaka':
        lineColor = const Color(0xFF03A9F4);
        emoji = '👶';
        title = 'Diaper';
        subtitle = item['tur'];
        break;
      case 'uyku':
        lineColor = const Color(0xFF9C27B0);
        emoji = '😴';
        title = 'Sleep';
        subtitle = 'Time slept: ${item['sure']}';
        break;
      default:
        lineColor = Colors.grey;
        emoji = '📝';
        title = 'Activity';
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
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: lineColor.withAlpha(50),
                  shape: BoxShape.circle,
                  border: Border.all(color: lineColor, width: 2),
                ),
              ),
              Container(width: 2, height: 50, color: Colors.grey.shade200),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(color: lineColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildTimeline(
    List<Map<String, dynamic>> mama,
    List<Map<String, dynamic>> kaka,
    List<Map<String, dynamic>> uyku,
  ) {
    final List<Map<String, dynamic>> timeline = [];

    for (var k in mama) {
      timeline.add({
        'type': 'mama',
        'tarih': k['tarih'],
        'time': _formatTime(k['tarih']),
        'miktar': k['miktar'],
        'tur': k['tur'],
      });
    }

    for (var k in kaka) {
      timeline.add({
        'type': 'kaka',
        'tarih': k['tarih'],
        'time': _formatTime(k['tarih']),
        'tur': k['tur'],
      });
    }

    for (var k in uyku) {
      timeline.add({
        'type': 'uyku',
        'tarih': k['bitis'],
        'time': _formatTime(k['bitis']),
        'sure': _formatDuration(k['sure']),
      });
    }

    timeline.sort(
      (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime),
    );
    return timeline;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)
      return '${diff.inHours}h ${diff.inMinutes % 60}m ago';
    return '${diff.inDays}d ago';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

// Basit çizgi grafik çizici
class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final Color color;

  _ChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1).clamp(1, 100);

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

      // Nokta çiz
      canvas.drawCircle(Offset(x, y), 5, dotPaint);

      // Değer yazısı
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].toStringAsFixed(1),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 18));
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
