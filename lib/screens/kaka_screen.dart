import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';

class KakaScreen extends StatefulWidget {
  const KakaScreen({super.key});

  @override
  State<KakaScreen> createState() => _KakaScreenState();
}

class _KakaScreenState extends State<KakaScreen> {
  List<Map<String, dynamic>> _kayitlar = [];

  @override
  void initState() {
    super.initState();
    _kayitlariYukle();
  }

  void _kayitlariYukle() {
    setState(() {
      _kayitlar = VeriYonetici.getKakaKayitlari();
    });
  }

  void _kayitEkle(String tur) async {
    setState(() {
      _kayitlar.insert(0, {'tarih': DateTime.now(), 'tur': tur});
    });
    await VeriYonetici.saveKakaKayitlari(_kayitlar);
  }

  void _kayitDuzenle(int index) {
    String tur = _kayitlar[index]['tur'];
    DateTime tarih = _kayitlar[index]['tarih'];
    TimeOfDay saat = TimeOfDay(hour: tarih.hour, minute: tarih.minute);

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kaydı Düzenle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // TÜR SEÇİMİ
              Wrap(
                spacing: 8,
                children: ['Islak', 'Kirli', 'İkisi de'].map((t) {
                  return ChoiceChip(
                    label: Text(t),
                    selected: tur == t,
                    onSelected: (selected) => setModalState(() => tur = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // SAAT SEÇİMİ
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: saat,
                  );
                  if (picked != null) {
                    setModalState(() => saat = picked);
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(
                  '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              // GÜNCELLE BUTONU
              ElevatedButton(
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
                    _kayitlar[index] = {'tarih': yeniTarih, 'tur': tur};
                  });
                  await VeriYonetici.saveKakaKayitlari(_kayitlar);
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
              await VeriYonetici.saveKakaKayitlari(_kayitlar);
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👶 Bez Takibi'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BezButonu(
                  emoji: '💧',
                  label: 'Islak',
                  renk: Colors.blue.shade100,
                  onTap: () => _kayitEkle('Islak'),
                ),
                _BezButonu(
                  emoji: '💩',
                  label: 'Kirli',
                  renk: Colors.brown.shade100,
                  onTap: () => _kayitEkle('Kirli'),
                ),
                _BezButonu(
                  emoji: '💧💩',
                  label: 'İkisi de',
                  renk: Colors.purple.shade100,
                  onTap: () => _kayitEkle('İkisi de'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _kayitlar.isEmpty
                ? const Center(
                    child: Text(
                      'Henüz kayıt yok\nYukarıdaki butonlara bas',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _kayitlar.length,
                    itemBuilder: (context, index) {
                      final kayit = _kayitlar[index];
                      final tarih = kayit['tarih'] as DateTime;
                      String emoji = kayit['tur'] == 'Islak'
                          ? '💧'
                          : kayit['tur'] == 'Kirli'
                          ? '💩'
                          : '💧💩';
                      return ListTile(
                        leading: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(kayit['tur']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}',
                            ),
                            PopupMenuButton(
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
                          ],
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

class _BezButonu extends StatelessWidget {
  final String emoji;
  final String label;
  final Color renk;
  final VoidCallback onTap;

  const _BezButonu({
    required this.emoji,
    required this.label,
    required this.renk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: renk,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
