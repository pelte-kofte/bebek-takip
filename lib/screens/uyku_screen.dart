import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';

class UykuScreen extends StatefulWidget {
  const UykuScreen({super.key});

  @override
  State<UykuScreen> createState() => _UykuScreenState();
}

class _UykuScreenState extends State<UykuScreen> {
  List<Map<String, dynamic>> _kayitlar = [];
  DateTime? _uykuBaslangic;
  bool _uyuyor = false;

  @override
  void initState() {
    super.initState();
    _kayitlariYukle();
  }

  void _kayitlariYukle() {
    setState(() {
      _kayitlar = VeriYonetici.getUykuKayitlari();
    });
  }

  void _uykuToggle() async {
    setState(() {
      if (_uyuyor) {
        final sure = DateTime.now().difference(_uykuBaslangic!);
        _kayitlar.insert(0, {
          'baslangic': _uykuBaslangic,
          'bitis': DateTime.now(),
          'sure': sure,
        });
        _uyuyor = false;
        _uykuBaslangic = null;
      } else {
        _uykuBaslangic = DateTime.now();
        _uyuyor = true;
      }
    });
    await VeriYonetici.saveUykuKayitlari(_kayitlar);
  }

  void _kayitDuzenle(int index) {
    DateTime baslangic = _kayitlar[index]['baslangic'];
    DateTime bitis = _kayitlar[index]['bitis'];
    TimeOfDay baslangicSaat = TimeOfDay(
      hour: baslangic.hour,
      minute: baslangic.minute,
    );
    TimeOfDay bitisSaat = TimeOfDay(hour: bitis.hour, minute: bitis.minute);

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Uyku Kaydını Düzenle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // BAŞLANGIÇ SAATİ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uyudu:', style: TextStyle(fontSize: 16)),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: baslangicSaat,
                      );
                      if (picked != null) {
                        setModalState(() => baslangicSaat = picked);
                      }
                    },
                    icon: const Icon(Icons.bedtime),
                    label: Text(
                      '${baslangicSaat.hour.toString().padLeft(2, '0')}:${baslangicSaat.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // BİTİŞ SAATİ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uyandı:', style: TextStyle(fontSize: 16)),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: bitisSaat,
                      );
                      if (picked != null) {
                        setModalState(() => bitisSaat = picked);
                      }
                    },
                    icon: const Icon(Icons.wb_sunny),
                    label: Text(
                      '${bitisSaat.hour.toString().padLeft(2, '0')}:${bitisSaat.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // GÜNCELLE BUTONU
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final yeniBaslangic = DateTime(
                    baslangic.year,
                    baslangic.month,
                    baslangic.day,
                    baslangicSaat.hour,
                    baslangicSaat.minute,
                  );
                  final yeniBitis = DateTime(
                    bitis.year,
                    bitis.month,
                    bitis.day,
                    bitisSaat.hour,
                    bitisSaat.minute,
                  );
                  final sure = yeniBitis.difference(yeniBaslangic);

                  setState(() {
                    _kayitlar[index] = {
                      'baslangic': yeniBaslangic,
                      'bitis': yeniBitis,
                      'sure': sure,
                    };
                  });
                  await VeriYonetici.saveUykuKayitlari(_kayitlar);
                  navigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Güncelle', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _kayitSil(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
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
              await VeriYonetici.saveUykuKayitlari(_kayitlar);
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _sureyiFormatla(Duration sure) {
    final saat = sure.inHours;
    final dakika = sure.inMinutes % 60;
    if (saat > 0) {
      return '$saat sa $dakika dk';
    }
    return '$dakika dk';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('😴 Uyku Takibi'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _uykuToggle,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _uyuyor
                    ? Colors.indigo.shade100
                    : Colors.orange.shade100,
                boxShadow: [
                  BoxShadow(
                    color: _uyuyor
                        ? Colors.indigo.shade200
                        : Colors.orange.shade200,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _uyuyor ? '😴' : '👶',
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _uyuyor ? 'Uyuyor...' : 'Uyanık',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _uyuyor ? 'Uyandırmak için dokun' : 'Uyutmak için dokun',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Uyku Geçmişi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _kayitlar.isEmpty
                ? const Center(
                    child: Text(
                      'Henüz uyku kaydı yok',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _kayitlar.length,
                    itemBuilder: (context, index) {
                      final kayit = _kayitlar[index];
                      final baslangic = kayit['baslangic'] as DateTime;
                      final bitis = kayit['bitis'] as DateTime;
                      final sure = kayit['sure'] as Duration;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: const Text(
                            '😴',
                            style: TextStyle(fontSize: 28),
                          ),
                          title: Text(_sureyiFormatla(sure)),
                          subtitle: Text(
                            '${baslangic.hour.toString().padLeft(2, '0')}:${baslangic.minute.toString().padLeft(2, '0')} - ${bitis.hour.toString().padLeft(2, '0')}:${bitis.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'duzenle',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Düzenle'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'sil',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Sil',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'duzenle') {
                                _kayitDuzenle(index);
                              } else if (value == 'sil') {
                                _kayitSil(index);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
