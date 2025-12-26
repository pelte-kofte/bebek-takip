import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';

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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    if (tomorrow.isBefore(DateTime.now()) ||
        _isSameDay(tomorrow, DateTime.now())) {
      setState(() {
        _selectedDate = tomorrow;
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  String _formatDate(DateTime date) {
    final aylar = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final gunler = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    if (_isToday(date)) {
      return 'Bugün, ${date.day} ${aylar[date.month - 1]}';
    }
    return '${gunler[date.weekday - 1]}, ${date.day} ${aylar[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFCE4EC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          '📋 Aktiviteler',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // TARİH SEÇİCİ
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
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
                                    _formatDate(_selectedDate),
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
                                  ? Colors.grey.shade300
                                  : const Color(0xFFE91E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // TAB BAR
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
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

              // TAB VIEWS
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
    return list.where((item) {
      final itemDate = item[dateKey] as DateTime;
      return _isSameDay(itemDate, _selectedDate);
    }).toList();
  }

  Widget _buildMamaList() {
    final tumKayitlar = VeriYonetici.getMamaKayitlari();
    final kayitlar = _filterByDate(tumKayitlar, 'tarih');

    // Günlük toplam
    final toplamMl = kayitlar.fold(0, (sum, k) => sum + (k['miktar'] as int));

    if (kayitlar.isEmpty) {
      return _buildEmptyState('🍼', 'Bu tarihte mama kaydı yok');
    }

    return Column(
      children: [
        // Günlük özet
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
              Text(
                'Toplam: $toplamMl ml',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${kayitlar.length} kayıt)',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final tarih = kayit['tarih'] as DateTime;
              final emoji = kayit['tur'] == 'Anne Sütü'
                  ? '🤱'
                  : kayit['tur'] == 'Formül'
                  ? '🍼'
                  : '🥛';
              return _buildListItem(
                emoji: emoji,
                title: '${kayit['miktar']} ml',
                subtitle: kayit['tur'],
                time: _formatTime(tarih),
                color: const Color(0xFFE91E63),
                onDelete: () => _deleteMama(tumKayitlar.indexOf(kayit)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKakaList() {
    final tumKayitlar = VeriYonetici.getKakaKayitlari();
    final kayitlar = _filterByDate(tumKayitlar, 'tarih');

    if (kayitlar.isEmpty) {
      return _buildEmptyState('👶', 'Bu tarihte bez kaydı yok');
    }

    // Sayılar
    final islak = kayitlar.where((k) => k['tur'] == 'Islak').length;
    final kirli = kayitlar.where((k) => k['tur'] == 'Kirli').length;
    final ikisi = kayitlar.where((k) => k['tur'] == 'İkisi de').length;

    return Column(
      children: [
        // Günlük özet
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
              _buildBezSummary('💧', islak, 'Islak'),
              _buildBezSummary('💩', kirli, 'Kirli'),
              _buildBezSummary('💧💩', ikisi, 'İkisi'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final tarih = kayit['tarih'] as DateTime;
              String emoji = kayit['tur'] == 'Islak'
                  ? '💧'
                  : kayit['tur'] == 'Kirli'
                  ? '💩'
                  : '💧💩';
              return _buildListItem(
                emoji: emoji,
                title: kayit['tur'],
                subtitle: 'Bez değişimi',
                time: _formatTime(tarih),
                color: const Color(0xFF9C27B0),
                onDelete: () => _deleteKaka(tumKayitlar.indexOf(kayit)),
              );
            },
          ),
        ),
      ],
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

  Widget _buildUykuList() {
    final tumKayitlar = VeriYonetici.getUykuKayitlari();
    final kayitlar = _filterByDate(tumKayitlar, 'bitis');

    if (kayitlar.isEmpty) {
      return _buildEmptyState('😴', 'Bu tarihte uyku kaydı yok');
    }

    // Toplam uyku
    final toplamDakika = kayitlar.fold(
      0,
      (sum, k) => sum + (k['sure'] as Duration).inMinutes,
    );
    final saat = toplamDakika ~/ 60;
    final dakika = toplamDakika % 60;

    return Column(
      children: [
        // Günlük özet
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
                'Toplam: $saat sa $dakika dk',
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
              return _buildListItem(
                emoji: '😴',
                title: _formatDuration(sure),
                subtitle: '${_formatTime(baslangic)} - ${_formatTime(bitis)}',
                time: '',
                color: const Color(0xFF3F51B5),
                onDelete: () => _deleteUyku(tumKayitlar.indexOf(kayit)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnilarList() {
    final tumAnilar = VeriYonetici.getAnilar();
    final anilar = _filterByDate(tumAnilar, 'tarih');

    if (anilar.isEmpty) {
      return _buildEmptyState('📸', 'Bu tarihte anı yok');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: anilar.length,
      itemBuilder: (context, index) {
        final ani = anilar[index];
        return _buildListItem(
          emoji: ani['emoji'],
          title: ani['baslik'],
          subtitle: ani['not'].isNotEmpty ? ani['not'] : 'Not yok',
          time: '',
          color: const Color(0xFFFF9800),
          onDelete: () => _deleteAni(tumAnilar.indexOf(ani)),
        );
      },
    );
  }

  Widget _buildEmptyState(String emoji, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _selectDate,
            child: const Text('Başka tarih seç'),
          ),
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
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (time.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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
                    fontSize: 14,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(onDelete),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🗑️ Sil'),
        content: const Text('Bu kaydı silmek istiyor musun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '$hours sa $minutes dk';
    return '$minutes dk';
  }

  void _deleteMama(int index) async {
    final kayitlar = VeriYonetici.getMamaKayitlari();
    kayitlar.removeAt(index);
    await VeriYonetici.saveMamaKayitlari(kayitlar);
    setState(() {});
  }

  void _deleteKaka(int index) async {
    final kayitlar = VeriYonetici.getKakaKayitlari();
    kayitlar.removeAt(index);
    await VeriYonetici.saveKakaKayitlari(kayitlar);
    setState(() {});
  }

  void _deleteUyku(int index) async {
    final kayitlar = VeriYonetici.getUykuKayitlari();
    kayitlar.removeAt(index);
    await VeriYonetici.saveUykuKayitlari(kayitlar);
    setState(() {});
  }

  void _deleteAni(int index) async {
    final anilar = VeriYonetici.getAnilar();
    anilar.removeAt(index);
    await VeriYonetici.saveAnilar(anilar);
    setState(() {});
  }
}
