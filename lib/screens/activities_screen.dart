import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../models/ikonlar.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    if (_isToday(date))
      return '${Dil.bugun}, ${date.day} ${Dil.aylar[date.month - 1]}';
    return '${date.day} ${Dil.aylar[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF121212)]
                : [const Color(0xFFFCE4EC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black26
                                : const Color(0x1A000000),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _previousDay,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63).withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Color(0xFFE91E63),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDateHeader(_selectedDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _isToday(_selectedDate)
                                ? null
                                : _nextDay,
                            icon: Icon(
                              Icons.chevron_right,
                              color: _isToday(_selectedDate)
                                  ? Colors.grey.shade400
                                  : const Color(0xFFE91E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : const Color(0x1A000000),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark
                      ? Colors.grey.shade400
                      : Colors.grey,
                  indicator: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: '🍼'),
                    Tab(text: '👶'),
                    Tab(text: '😴'),
                    Tab(text: '📸'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMamaList(),
                    _buildKakaList(),
                    _buildUykuList(),
                    _buildAnilarList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

    if (kayitlar.isEmpty)
      return _buildEmptyState('🍼', '${Dil.kayitYok}', isDark);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🍼', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              if (toplamDakika > 0)
                Text(
                  '${Dil.emzirme}: $toplamDakika ${Dil.dk}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (toplamDakika > 0 && toplamMl > 0)
                const Text(' • ', style: TextStyle(color: Colors.white70)),
              if (toplamMl > 0)
                Text(
                  '${Dil.biberon}: $toplamMl ml',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                '(${kayitlar.length} ${Dil.kayit})',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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

              String emoji;
              String title;
              String subtitle;

              if (tur == 'Anne Sütü') {
                emoji = '🤱';
                title = Dil.emzirme;
                subtitle =
                    'Sol ${sol}${Dil.dk} • Sağ ${sag}${Dil.dk} (${Dil.toplam}: ${sol + sag}${Dil.dk})';
              } else {
                emoji = tur == 'Formül' ? '🍼' : '🥛';
                title = '$miktar ml';
                subtitle = tur == 'Formül' ? Dil.formula : Dil.biberonAnneSutu;
              }

              return _buildListItem(
                emoji: emoji,
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

    if (kayitlar.isEmpty)
      return _buildEmptyState(
        Ikonlar.diaperClean(size: 48),
        Dil.kayitYok,
        isDark,
      );

    final islak = kayitlar.where((k) => k['tur'] == Dil.islak).length;
    final kirli = kayitlar.where((k) => k['tur'] == Dil.kirli).length;
    final ikisi = kayitlar.where((k) => k['tur'] == Dil.ikisiBirden).length;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBezSummaryWithIcon(
                Ikonlar.diaperWet(size: 24),
                islak,
                Dil.islak,
              ),
              _buildBezSummaryWithIcon(
                Ikonlar.diaperDirty(size: 24),
                kirli,
                Dil.kirli,
              ),
              _buildBezSummaryWithIcon(
                Ikonlar.diaperClean(size: 24),
                ikisi,
                Dil.ikisiBirden,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final tarih = kayit['tarih'] as DateTime;
              final originalIndex = tumKayitlar.indexOf(kayit);
              Widget icon = _getBezIkon(kayit['tur'] ?? '', 24);
              return _buildListItemWithIcon(
                icon: icon,
                title: kayit['tur'],
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

  Widget _getBezIkon(String tur, double size) {
    if (tur == Dil.islak) {
      return Ikonlar.diaperWet(size: size);
    } else if (tur == Dil.kirli) {
      return Ikonlar.diaperDirty(size: size);
    } else {
      return Ikonlar.diaperClean(size: size);
    }
  }

  Widget _buildBezSummaryWithIcon(Widget icon, int count, String label) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildListItemWithIcon({
    required Widget icon,
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: icon),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: subtitleColor, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time, style: TextStyle(color: subtitleColor, fontSize: 12)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: Icon(Icons.edit, size: 18, color: subtitleColor),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete, size: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUykuList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final tumKayitlar = VeriYonetici.getUykuKayitlari();
    final kayitlar = _filterByDate(tumKayitlar, 'bitis');

    if (kayitlar.isEmpty) return _buildEmptyState('😴', Dil.kayitYok, isDark);

    final toplamDakika = kayitlar.fold(
      0,
      (sum, k) => sum + (k['sure'] as Duration).inMinutes,
    );
    final saat = toplamDakika ~/ 60;
    final dakika = toplamDakika % 60;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF1A237E)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😴', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                '${Dil.toplam}: $saat ${Dil.sa} $dakika ${Dil.dk}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
                emoji: '😴',
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

  Widget _buildAnilarList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final tumAnilar = VeriYonetici.getAnilar();
    final anilar = _filterByDate(tumAnilar, 'tarih');

    if (anilar.isEmpty) return _buildEmptyState('📸', Dil.kayitYok, isDark);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: anilar.length,
      itemBuilder: (context, index) {
        final ani = anilar[index];
        final originalIndex = tumAnilar.indexOf(ani);
        return _buildListItem(
          emoji: ani['emoji'],
          title: ani['baslik'],
          subtitle: ani['not'].isNotEmpty ? ani['not'] : 'Not yok',
          time: '',
          color: const Color(0xFFFF9800),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          onEdit: () => _editAni(originalIndex, ani),
          onDelete: () => _deleteAni(originalIndex),
        );
      },
    );
  }

  Widget _buildEmptyState(dynamic iconOrEmoji, String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: iconOrEmoji is String
                ? Text(iconOrEmoji, style: const TextStyle(fontSize: 48))
                : iconOrEmoji,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _selectDate, child: Text(Dil.baskaTarihSec)),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String emoji,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: subtitleColor, fontSize: 13),
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
                  color: color.withAlpha(25),
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
              icon: Icon(Icons.edit, color: color, size: 20),
              onPressed: onEdit,
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

  Widget _buildBezSummary(String emoji, int count, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // EDIT FUNCTIONS
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

                  // TÜR SEÇİMİ
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.pink.shade900.withAlpha(50)
                            : Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildMemeRow(
                            Dil.solMeme,
                            '👈',
                            solDakika,
                            (v) => setModalState(() => solDakika = v),
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildMemeRow(
                            Dil.sagMeme,
                            '👉',
                            sagDakika,
                            (v) => setModalState(() => sagDakika = v),
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '⏱️ ${Dil.toplam}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${solDakika + sagDakika} ${Dil.dakika}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE91E63),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (tur == 'Formül' || tur == 'Biberon Anne Sütü') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.pink.shade900.withAlpha(50)
                            : Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCircleButton(
                            Icons.remove,
                            () => setModalState(
                              () => miktar = (miktar - 10).clamp(0, 500),
                            ),
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
                            () => setModalState(
                              () => miktar = (miktar + 10).clamp(0, 500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  _buildTimeSelector(
                    saat,
                    (s) => setModalState(() => saat = s),
                    ctx,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
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
                  ),
                ],
              ),
            ),
          );
        },
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
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 12),
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
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final kayitlar = VeriYonetici.getKakaKayitlari();
                      kayitlar[index] = {'tarih': kayit['tarih'], 'tur': tur};
                      await VeriYonetici.saveKakaKayitlari(kayitlar);
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
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
                ),
              ],
            ),
          );
        },
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
          color: isSelected ? color.withAlpha(50) : color.withAlpha(25),
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
                    Column(
                      children: [
                        Text(
                          Dil.baslangic,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: baslangicSaat,
                            );
                            if (picked != null)
                              setModalState(() => baslangicSaat = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${baslangicSaat.hour.toString().padLeft(2, '0')}:${baslangicSaat.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    Column(
                      children: [
                        Text(
                          Dil.bitis,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: bitisSaat,
                            );
                            if (picked != null)
                              setModalState(() => bitisSaat = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${bitisSaat.hour.toString().padLeft(2, '0')}:${bitisSaat.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
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
                      if (yeniBitis.isBefore(yeniBaslangic))
                        yeniBitis = yeniBitis.add(const Duration(days: 1));
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
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
                ),
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

  void _editAni(int index, Map<String, dynamic> ani) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baslikController = TextEditingController(text: ani['baslik']);
    final notController = TextEditingController(text: ani['not']);
    String emoji = ani['emoji'];

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
                    '✏️ ${Dil.aniDuzenle}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: ['👶', '🎀', '🧸', '🍼', '👣', '💕', '🌟', '🎈']
                        .map((e) {
                          return GestureDetector(
                            onTap: () => setModalState(() => emoji = e),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: emoji == e
                                    ? Colors.orange.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: baslikController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: Dil.baslik,
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notController,
                    maxLines: 3,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: Dil.not,
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (baslikController.text.isNotEmpty) {
                          final anilar = VeriYonetici.getAnilar();
                          anilar[index] = {
                            'baslik': baslikController.text,
                            'not': notController.text,
                            'tarih': ani['tarih'],
                            'emoji': emoji,
                          };
                          await VeriYonetici.saveAnilar(anilar);
                          Navigator.pop(ctx);
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteAni(int index) async {
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      final anilar = VeriYonetici.getAnilar();
      anilar.removeAt(index);
      await VeriYonetici.saveAnilar(anilar);
      setState(() {});
    }
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
