import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../models/ikonlar.dart';

enum ActivityType { mama, bez, uyku }

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  DateTime _selectedDate = DateTime.now();
  ActivityType _activeType = ActivityType.mama;

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _previousDay() => setState(
    () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
  );

  void _nextDay() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    if (tomorrow.isBefore(DateTime.now()) ||
        _isSameDay(tomorrow, DateTime.now())) {
      setState(() => _selectedDate = tomorrow);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());

  String _formatDateHeader(DateTime date) {
    if (_isToday(date)) {
      return '${Dil.bugun}, ${date.day} ${Dil.aylar[date.month - 1]}';
    }
    return '${date.day} ${Dil.aylar[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Scaffold(
      body: Stack(
        children: [
          // 1. ARKA PLAN RENK
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFFFBF5),
            ),
          ),

          // 2. DEKORATİF ARKA PLAN LAYER (köşelerde, çok hafif)
          if (!isDark)
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    // Lavender blob - sol üst köşe
                    Positioned(
                      top: -50,
                      left: -100,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFE5E0F7,
                          ).withValues(alpha: 0.03),
                        ),
                      ),
                    ),
                    // Peach blob - sağ üst köşe
                    Positioned(
                      top: -30,
                      right: -80,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFFFB4A2,
                          ).withValues(alpha: 0.03),
                        ),
                      ),
                    ),
                    // Lavender blob - sağ alt köşe
                    Positioned(
                      bottom: -60,
                      right: -70,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFE5E0F7,
                          ).withValues(alpha: 0.03),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. ANA İÇERİK (Stack'in üstünde)
          SafeArea(
            child: Column(
              children: [
                // Header (fixed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '📋 ${Dil.aktiviteler}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tarih Seçici
                      _buildDateSelector(isDark),
                    ],
                  ),
                ),

                // Hero Icons - Main Touch Targets
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildActivitySegment(
                          'assets/icons/illustration/bottle2.png',
                          ActivityType.mama,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActivitySegment(
                          'assets/icons/illustration/diaper_clean.png',
                          ActivityType.bez,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActivitySegment(
                          'assets/icons/illustration/sleeping_moon2.png',
                          ActivityType.uyku,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Status Banner
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFB4A2).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFB4A2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Son aktivite takibi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1d0e0c),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // İçerik (scrollable, Expanded ile kalan alanı doldurur)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildActiveContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    final cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFBF5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black12
                : const Color(0xFFE5E0F7).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousDay,
            icon: const Icon(Icons.chevron_left, color: Color(0xFFFFB4A2)),
          ),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFFFFB4A2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateHeader(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFB4A2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _isToday(_selectedDate) ? null : _nextDay,
            icon: Icon(
              Icons.chevron_right,
              color: _isToday(_selectedDate)
                  ? Colors.grey.shade400
                  : const Color(0xFFFFB4A2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySegment(String iconPath, ActivityType type) {
    final isActive = _activeType == type;

    return GestureDetector(
      onTap: () => setState(() => _activeType = type),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main circular button - HERO SIZE
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE5E0F7), // SOLID lavender
              border: isActive
                  ? Border.all(
                      color: const Color(0xFFFFB4A2),
                      width: 3,
                    )
                  : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFB4A2).withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 84,
                height: 84,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Label
          Text(
            type == ActivityType.mama
                ? 'MAMA'
                : type == ActivityType.bez
                    ? 'BEZ'
                    : 'UYKU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.5,
              color: isActive
                  ? const Color(0xFF1d0e0c)
                  : const Color(0xFF1d0e0c).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContent() {
    // Her widget'a unique key ver ki AnimatedSwitcher farkı anlasın
    switch (_activeType) {
      case ActivityType.mama:
        return KeyedSubtree(
          key: const ValueKey('mama'),
          child: _buildMamaList(),
        );
      case ActivityType.bez:
        return KeyedSubtree(
          key: const ValueKey('bez'),
          child: _buildKakaList(),
        );
      case ActivityType.uyku:
        return KeyedSubtree(
          key: const ValueKey('uyku'),
          child: _buildUykuList(),
        );
    }
  }

  List<Map<String, dynamic>> _filterByDate(
    List<Map<String, dynamic>> list,
    String dateKey,
  ) {
    return list
        .where((item) => _isSameDay(item[dateKey] as DateTime, _selectedDate))
        .toList();
  }

  Widget _buildMamaList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final tumKayitlar = VeriYonetici.getMamaKayitlari();
    final kayitlar = _filterByDate(tumKayitlar, 'tarih');

    int toplamMl = 0;
    int toplamDakika = 0;
    for (var k in kayitlar) {
      toplamMl += (k['miktar'] ?? 0) as int;
      toplamDakika +=
          ((k['solDakika'] ?? 0) as int) + ((k['sagDakika'] ?? 0) as int);
    }

    if (kayitlar.isEmpty) {
      return _buildEmptyState(
        'assets/icons/illustration/bottle2.png',
        'İlk mama zamanı geldi mi?',
        'Bebeğinizin beslenmesini takip edin',
        isDark,
      );
    }

    return Column(
      children: [
        // Section Header - ÖZET
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ÖZET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),
        // Özet kartı
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFB4A2).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Image.asset(
                  'assets/icons/illustration/bottle2.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (toplamDakika > 0)
                      Text(
                        '${Dil.emzirme}: $toplamDakika ${Dil.dk}',
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (toplamDakika > 0 && toplamMl > 0)
                      const Text(
                        '•',
                        style: TextStyle(color: Color(0xFF888888)),
                      ),
                    if (toplamMl > 0)
                      Text(
                        '${Dil.biberon}: $toplamMl ml',
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      '(${kayitlar.length} ${Dil.kayit})',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Header - SON AKTİVİTELER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Text(
                'SON AKTİVİTELER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final tarih = kayit['tarih'] as DateTime;
              final originalIndex = tumKayitlar.indexOf(kayit);
              final tur = kayit['tur'] as String? ?? '';
              final sol = kayit['solDakika'] ?? 0;
              final sag = kayit['sagDakika'] ?? 0;
              final miktar = kayit['miktar'] ?? 0;

              String title;
              String subtitle;

              if (tur == 'Anne Sütü') {
                title = Dil.emzirme;
                subtitle =
                    'Sol $sol${Dil.dk} • Sağ $sag${Dil.dk} (${Dil.toplam}: ${sol + sag}${Dil.dk})';
              } else {
                title = '$miktar ml';
                subtitle = tur == 'Formül' ? Dil.formula : Dil.biberonAnneSutu;
              }

              return _buildListItem(
                iconPath: 'assets/icons/illustration/bottle2.png',
                title: title,
                subtitle: subtitle,
                time: _formatTime(tarih),
                color: const Color(0xFFE91E63),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onEdit: () => _editMama(originalIndex, kayit),
                onDelete: () => _deleteMama(originalIndex),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKakaList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final tumKayitlar = VeriYonetici.getKakaKayitlari();
    final kayitlar = _filterByDate(tumKayitlar, 'tarih');

    if (kayitlar.isEmpty) {
      return _buildEmptyState(
        'assets/icons/illustration/diaper_clean.png',
        'Bez değiştirme zamanı!',
        'Hijyen takibini burada yapın',
        isDark,
      );
    }

    final islak = kayitlar.where((k) => k['tur'] == Dil.islak).length;
    final kirli = kayitlar.where((k) => k['tur'] == Dil.kirli).length;
    final ikisi = kayitlar.where((k) => k['tur'] == Dil.ikisiBirden).length;

    return Column(
      children: [
        // Section Header - ÖZET
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ÖZET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),
        // Özet kartı
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E0F7).withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBezSummary(
                'assets/icons/illustration/diaper_wet.png',
                islak,
                Dil.islak,
              ),
              _buildBezSummary(
                'assets/icons/illustration/diaper_dirty.png',
                kirli,
                Dil.kirli,
              ),
              _buildBezSummary(
                'assets/icons/illustration/diaper_clean.png',
                ikisi,
                Dil.ikisiBirden,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Header - SON AKTİVİTELER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Text(
                'SON AKTİVİTELER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final tarih = kayit['tarih'] as DateTime;
              final originalIndex = tumKayitlar.indexOf(kayit);
              final tur = kayit['tur'] ?? '';

              String iconPath = 'assets/icons/illustration/diaper_clean.png';
              if (tur == Dil.islak) {
                iconPath = 'assets/icons/illustration/diaper_wet.png';
              } else if (tur == Dil.kirli) {
                iconPath = 'assets/icons/illustration/diaper_dirty.png';
              }

              return _buildListItem(
                iconPath: iconPath,
                title: tur,
                subtitle: Dil.bezDegisimi,
                time: _formatTime(tarih),
                color: const Color(0xFF9C27B0),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onEdit: () => _editKaka(originalIndex, kayit),
                onDelete: () => _deleteKaka(originalIndex),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUykuList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final tumKayitlar = VeriYonetici.getUykuKayitlari();
    final kayitlar = _filterByDate(tumKayitlar, 'bitis');

    if (kayitlar.isEmpty) {
      return _buildEmptyState(
        'assets/icons/illustration/sleeping_moon2.png',
        'Tatlı rüyalar...',
        'Uyku düzenini buradan izleyin',
        isDark,
      );
    }

    final toplamDakika = kayitlar.fold(
      0,
      (sum, k) => sum + (k['sure'] as Duration).inMinutes,
    );
    final saat = toplamDakika ~/ 60;
    final dakika = toplamDakika % 60;

    return Column(
      children: [
        // Section Header - ÖZET
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ÖZET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),
        // Özet kartı
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E0F7).withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Image.asset(
                  'assets/icons/illustration/sleeping_moon2.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${Dil.toplam}: $saat ${Dil.sa} $dakika ${Dil.dk}',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Header - SON AKTİVİTELER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Text(
                'SON AKTİVİTELER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final baslangic = kayit['baslangic'] as DateTime;
              final bitis = kayit['bitis'] as DateTime;
              final sure = kayit['sure'] as Duration;
              final originalIndex = tumKayitlar.indexOf(kayit);

              return _buildListItem(
                iconPath: 'assets/icons/illustration/sleeping_moon2.png',
                title: _formatDuration(sure),
                subtitle: '${_formatTime(baslangic)} - ${_formatTime(bitis)}',
                time: '',
                color: const Color(0xFF3F51B5),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onEdit: () => _editUyku(originalIndex, kayit),
                onDelete: () => _deleteUyku(originalIndex),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBezSummary(String iconPath, int count, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E0F7).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Image.asset(
            iconPath,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    String iconPath,
    String title,
    String subtitle,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : const Color(0xFFFFFBF5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(iconPath, width: 56, height: 56),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF4A4458),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF8A8494),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFB4A2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB4A2).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          Dil.baskaTarihSec,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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

  Widget _buildListItem({
    required String iconPath,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5E0F7).withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onEdit,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFFFFBF5), // solid warm cream
            border: Border.all(
              color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Image.asset(
              iconPath,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: subtitleColor, fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (time.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  // ============ EDIT & DELETE FUNCTIONS ============

  void _editMama(int index, Map<String, dynamic> kayit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String tur = kayit['tur'] ?? 'Anne Sütü';
    int solDakika = kayit['solDakika'] ?? 0;
    int sagDakika = kayit['sagDakika'] ?? 0;
    int miktar = kayit['miktar'] ?? 100;
    DateTime tarih = kayit['tarih'];
    TimeOfDay saat = TimeOfDay(hour: tarih.hour, minute: tarih.minute);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '✏️ ${Dil.beslenmeDuzenle}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTurButton(
                        '🤱',
                        Dil.emzirme,
                        'Anne Sütü',
                        tur,
                        (t) => setModalState(() => tur = t),
                      ),
                      _buildTurButton(
                        '🍼',
                        Dil.formula,
                        'Formül',
                        tur,
                        (t) => setModalState(() => tur = t),
                      ),
                      _buildTurButton(
                        '🥛',
                        Dil.biberon,
                        'Biberon Anne Sütü',
                        tur,
                        (t) => setModalState(() => tur = t),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (tur == 'Anne Sütü') ...[
                    _buildMemeEditor(solDakika, sagDakika, (s, sa) {
                      setModalState(() {
                        solDakika = s;
                        sagDakika = sa;
                      });
                    }, isDark),
                  ],
                  if (tur == 'Formül' || tur == 'Biberon Anne Sütü') ...[
                    _buildMiktarEditor(
                      miktar,
                      (m) => setModalState(() => miktar = m),
                      isDark,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildTimeSelector(
                    saat,
                    (s) => setModalState(() => saat = s),
                    ctx,
                  ),
                  const SizedBox(height: 24),
                  _buildSaveButton(() async {
                    final yeniTarih = DateTime(
                      tarih.year,
                      tarih.month,
                      tarih.day,
                      saat.hour,
                      saat.minute,
                    );
                    final kayitlar = VeriYonetici.getMamaKayitlari();
                    if (tur == 'Anne Sütü') {
                      kayitlar[index] = {
                        'tarih': yeniTarih,
                        'tur': 'Anne Sütü',
                        'solDakika': solDakika,
                        'sagDakika': sagDakika,
                        'miktar': 0,
                      };
                    } else {
                      kayitlar[index] = {
                        'tarih': yeniTarih,
                        'tur': tur,
                        'miktar': miktar,
                        'solDakika': 0,
                        'sagDakika': 0,
                      };
                    }
                    await VeriYonetici.saveMamaKayitlari(kayitlar);
                    Navigator.pop(ctx);
                    setState(() {});
                  }, const Color(0xFFE91E63)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteMama(int index) async {
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      final kayitlar = VeriYonetici.getMamaKayitlari();
      kayitlar.removeAt(index);
      await VeriYonetici.saveMamaKayitlari(kayitlar);
      setState(() {});
    }
  }

  void _editKaka(int index, Map<String, dynamic> kayit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String tur = kayit['tur'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✏️ ${Dil.bez} ${Dil.duzenle}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _bezEditOption(
                      '💧',
                      Dil.islak,
                      Colors.blue,
                      tur,
                      (t) => setModalState(() => tur = t),
                    ),
                    _bezEditOption(
                      '💩',
                      Dil.kirli,
                      Colors.brown,
                      tur,
                      (t) => setModalState(() => tur = t),
                    ),
                    _bezEditOption(
                      '💧💩',
                      Dil.ikisiBirden,
                      Colors.purple,
                      tur,
                      (t) => setModalState(() => tur = t),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSaveButton(() async {
                  final kayitlar = VeriYonetici.getKakaKayitlari();
                  kayitlar[index] = {'tarih': kayit['tarih'], 'tur': tur};
                  await VeriYonetici.saveKakaKayitlari(kayitlar);
                  Navigator.pop(ctx);
                  setState(() {});
                }, const Color(0xFF9C27B0)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _deleteKaka(int index) async {
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      final kayitlar = VeriYonetici.getKakaKayitlari();
      kayitlar.removeAt(index);
      await VeriYonetici.saveKakaKayitlari(kayitlar);
      setState(() {});
    }
  }

  void _editUyku(int index, Map<String, dynamic> kayit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime baslangic = kayit['baslangic'];
    DateTime bitis = kayit['bitis'];
    TimeOfDay baslangicSaat = TimeOfDay(
      hour: baslangic.hour,
      minute: baslangic.minute,
    );
    TimeOfDay bitisSaat = TimeOfDay(hour: bitis.hour, minute: bitis.minute);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✏️ ${Dil.uykuDuzenle}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeColumn(
                      Dil.baslangic,
                      baslangicSaat,
                      (picked) {
                        setModalState(() => baslangicSaat = picked);
                      },
                      ctx,
                      isDark,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    _buildTimeColumn(
                      Dil.bitis,
                      bitisSaat,
                      (picked) {
                        setModalState(() => bitisSaat = picked);
                      },
                      ctx,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSaveButton(() async {
                  final yeniBaslangic = DateTime(
                    baslangic.year,
                    baslangic.month,
                    baslangic.day,
                    baslangicSaat.hour,
                    baslangicSaat.minute,
                  );
                  var yeniBitis = DateTime(
                    bitis.year,
                    bitis.month,
                    bitis.day,
                    bitisSaat.hour,
                    bitisSaat.minute,
                  );
                  if (yeniBitis.isBefore(yeniBaslangic)) {
                    yeniBitis = yeniBitis.add(const Duration(days: 1));
                  }
                  final sure = yeniBitis.difference(yeniBaslangic);
                  final kayitlar = VeriYonetici.getUykuKayitlari();
                  kayitlar[index] = {
                    'baslangic': yeniBaslangic,
                    'bitis': yeniBitis,
                    'sure': sure,
                  };
                  await VeriYonetici.saveUykuKayitlari(kayitlar);
                  Navigator.pop(ctx);
                  setState(() {});
                }, const Color(0xFF3F51B5)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _deleteUyku(int index) async {
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      final kayitlar = VeriYonetici.getUykuKayitlari();
      kayitlar.removeAt(index);
      await VeriYonetici.saveUykuKayitlari(kayitlar);
      setState(() {});
    }
  }

  // ============ HELPER WIDGETS ============

  Widget _buildTurButton(
    String emoji,
    String label,
    String value,
    String selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemeEditor(
    int sol,
    int sag,
    Function(int, int) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.pink.shade900.withValues(alpha: 0.3)
            : Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMemeRow('Sol', '👈', sol, (v) => onChanged(v, sag), isDark),
          const SizedBox(height: 16),
          _buildMemeRow('Sağ', '👉', sag, (v) => onChanged(sol, v), isDark),
        ],
      ),
    );
  }

  Widget _buildMemeRow(
    String label,
    String emoji,
    int dakika,
    Function(int) onChanged,
    bool isDark,
  ) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        _buildCircleButton(
          Icons.remove,
          () => onChanged((dakika - 1).clamp(0, 60)),
        ),
        const SizedBox(width: 12),
        Text(
          '$dakika ${Dil.dk}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        const SizedBox(width: 12),
        _buildCircleButton(
          Icons.add,
          () => onChanged((dakika + 1).clamp(0, 60)),
        ),
      ],
    );
  }

  Widget _buildMiktarEditor(int miktar, Function(int) onChanged, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.pink.shade900.withValues(alpha: 0.3)
            : Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircleButton(
            Icons.remove,
            () => onChanged((miktar - 10).clamp(0, 500)),
          ),
          const SizedBox(width: 24),
          Text(
            '$miktar ml',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(width: 24),
          _buildCircleButton(
            Icons.add,
            () => onChanged((miktar + 10).clamp(0, 500)),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFE91E63),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTimeSelector(
    TimeOfDay saat,
    Function(TimeOfDay) onChanged,
    BuildContext ctx,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: ctx, initialTime: saat);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE91E63), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, color: Color(0xFFE91E63)),
            const SizedBox(width: 8),
            Text(
              '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(
    String label,
    TimeOfDay saat,
    Function(TimeOfDay) onChanged,
    BuildContext ctx,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: ctx,
              initialTime: saat,
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          '✓ ${Dil.guncelle}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _bezEditOption(
    String emoji,
    String label,
    Color color,
    String selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🗑️ ${Dil.sil}',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          Dil.silmekIstiyor,
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Dil.iptal),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(Dil.sil, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  String _formatDuration(Duration d) => d.inHours > 0
      ? '${d.inHours} ${Dil.sa} ${d.inMinutes % 60} ${Dil.dk}'
      : '${d.inMinutes} ${Dil.dk}';
}
