import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';

class MamaScreen extends StatefulWidget {
  const MamaScreen({super.key});

  @override
  State<MamaScreen> createState() => _MamaScreenState();
}

class _MamaScreenState extends State<MamaScreen> {
  List<Map<String, dynamic>> _kayitlar = [];

  @override
  void initState() {
    super.initState();
    _kayitlariYukle();
  }

  void _kayitlariYukle() {
    setState(() {
      _kayitlar = VeriYonetici.getMamaKayitlari();
    });
  }

  void _kayitEkleVeyaDuzenle({int? index}) {
    final duzenlemeMi = index != null;
    int miktar = duzenlemeMi ? _kayitlar[index]['miktar'] : 100;
    String tur = duzenlemeMi ? _kayitlar[index]['tur'] : 'Anne Sütü';
    DateTime tarih = duzenlemeMi ? _kayitlar[index]['tarih'] : DateTime.now();
    TimeOfDay saat = TimeOfDay(hour: tarih.hour, minute: tarih.minute);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                duzenlemeMi ? '✏️ Kaydı Düzenle' : '🍼 Mama Kaydı Ekle',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              const SizedBox(height: 24),

              // MİKTAR
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade50, Colors.purple.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircleButton(
                      icon: Icons.remove,
                      onTap: () => setModalState(
                        () => miktar = (miktar - 10).clamp(0, 500),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      children: [
                        Text(
                          '$miktar',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                        const Text(
                          'ml',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    _buildCircleButton(
                      icon: Icons.add,
                      onTap: () => setModalState(
                        () => miktar = (miktar + 10).clamp(0, 500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // TÜR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Anne Sütü', 'Formül', 'Karışık'].map((t) {
                  final selected = tur == t;
                  return GestureDetector(
                    onTap: () => setModalState(() => tur = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFE91E63)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                  color: Color(0x66E91E63),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        t == 'Anne Sütü'
                            ? '🤱 Anne Sütü'
                            : t == 'Formül'
                            ? '🍼 Formül'
                            : '🥛 Karışık',
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // SAAT SEÇİMİ
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: saat,
                  );
                  if (picked != null) {
                    setModalState(() => saat = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE91E63),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFE91E63)),
                      const SizedBox(width: 12),
                      Text(
                        '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // KAYDET BUTONU
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final yeniTarih = DateTime(
                      tarih.year,
                      tarih.month,
                      tarih.day,
                      saat.hour,
                      saat.minute,
                    );

                    setState(() {
                      if (duzenlemeMi) {
                        _kayitlar[index] = {
                          'tarih': yeniTarih,
                          'miktar': miktar,
                          'tur': tur,
                        };
                      } else {
                        _kayitlar.insert(0, {
                          'tarih': yeniTarih,
                          'miktar': miktar,
                          'tur': tur,
                        });
                      }
                    });
                    await VeriYonetici.saveMamaKayitlari(_kayitlar);
                    navigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    duzenlemeMi ? '✓ Güncelle' : '✓ Kaydet',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFE91E63),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x66E91E63),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _kayitSil(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🗑️', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Text('Kaydı Sil'),
          ],
        ),
        content: const Text('Bu kaydı silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              setState(() {
                _kayitlar.removeAt(index);
              });
              await VeriYonetici.saveMamaKayitlari(_kayitlar);
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x1AE91E63), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33E91E63),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text('🍼', style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mama Takibi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                        Text(
                          'Beslenme kayıtları',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // GÜNLÜK ÖZET
              if (_kayitlar.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66E91E63),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOzet('Bugün', '${_bugunToplam()} ml', Icons.today),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildOzet(
                        'Kayıt',
                        '${_kayitlar.length}',
                        Icons.list_alt,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // LİSTE
              Expanded(
                child: _kayitlar.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '🍼',
                                style: TextStyle(fontSize: 64),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Henüz kayıt yok',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '+ butonuna basarak ilk kaydı ekle',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _kayitlar.length,
                        itemBuilder: (context, index) {
                          final kayit = _kayitlar[index];
                          final tarih = kayit['tarih'] as DateTime;
                          final emoji = kayit['tur'] == 'Anne Sütü'
                              ? '🤱'
                              : kayit['tur'] == 'Formül'
                              ? '🍼'
                              : '🥛';

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
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              title: Text(
                                '${kayit['miktar']} ml',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                              subtitle: Text(
                                kayit['tur'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.grey,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'duzenle',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Color(0xFFE91E63),
                                            ),
                                            SizedBox(width: 12),
                                            Text('Düzenle'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'sil',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Sil',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'duzenle') {
                                        _kayitEkleVeyaDuzenle(index: index);
                                      } else if (value == 'sil') {
                                        _kayitSil(index);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _kayitEkleVeyaDuzenle(),
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Mama Ekle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOzet(String baslik, String deger, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          deger,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          baslik,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  int _bugunToplam() {
    final bugun = DateTime.now();
    return _kayitlar
        .where((k) {
          final t = k['tarih'] as DateTime;
          return t.day == bugun.day &&
              t.month == bugun.month &&
              t.year == bugun.year;
        })
        .fold(0, (sum, k) => sum + (k['miktar'] as int));
  }
}
