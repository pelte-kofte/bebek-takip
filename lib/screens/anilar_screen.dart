import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';

class AnilarScreen extends StatefulWidget {
  const AnilarScreen({super.key});

  @override
  State<AnilarScreen> createState() => _AnilarScreenState();
}

class _AnilarScreenState extends State<AnilarScreen> {
  List<Map<String, dynamic>> _anilar = [];
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _notController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _anilariYukle();
  }

  void _anilariYukle() {
    setState(() {
      _anilar = VeriYonetici.getAnilar();
    });
  }

  void _aniEkleVeyaDuzenle({int? index}) {
    final duzenlemeMi = index != null;

    if (duzenlemeMi) {
      _baslikController.text = _anilar[index]['baslik'];
      _notController.text = _anilar[index]['not'];
    } else {
      _baslikController.clear();
      _notController.clear();
    }

    String emoji = duzenlemeMi ? _anilar[index]['emoji'] : '👶';
    DateTime tarih = duzenlemeMi ? _anilar[index]['tarih'] : DateTime.now();

    final emojiler = [
      '👶',
      '🎀',
      '🧸',
      '🍼',
      '👣',
      '💕',
      '🌟',
      '🎈',
      '🎂',
      '🚼',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(duzenlemeMi ? '📸 Anıyı Düzenle' : '📸 Yeni Anı'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // EMOJİ SEÇİMİ
                Wrap(
                  spacing: 8,
                  children: emojiler.map((e) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => emoji = e),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: emoji == e
                              ? Colors.pink.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // TARİH SEÇİMİ
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tarih,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => tarih = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_tarihFormatla(tarih)),
                ),
                const SizedBox(height: 16),

                // BAŞLIK
                TextField(
                  controller: _baslikController,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    hintText: 'İlk gülümseme...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // NOT
                TextField(
                  controller: _notController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Not',
                    hintText: 'Bu anı hakkında notlar...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_baslikController.text.isNotEmpty) {
                  final navigator = Navigator.of(context);
                  setState(() {
                    if (duzenlemeMi) {
                      _anilar[index] = {
                        'baslik': _baslikController.text,
                        'not': _notController.text,
                        'tarih': tarih,
                        'emoji': emoji,
                      };
                    } else {
                      _anilar.insert(0, {
                        'baslik': _baslikController.text,
                        'not': _notController.text,
                        'tarih': tarih,
                        'emoji': emoji,
                      });
                    }
                  });
                  await VeriYonetici.saveAnilar(_anilar);
                  navigator.pop();
                }
              },
              child: Text(duzenlemeMi ? 'Güncelle' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _aniSil(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anıyı Sil'),
        content: const Text('Bu anıyı silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              setState(() {
                _anilar.removeAt(index);
              });
              await VeriYonetici.saveAnilar(_anilar);
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _tarihFormatla(DateTime tarih) {
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
    return '${tarih.day} ${aylar[tarih.month - 1]} ${tarih.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 Anılar Defteri'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _anilar.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📷', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text(
                    'Henüz anı eklenmemiş',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bebeğinizin özel anlarını kaydedin',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _anilar.length,
              itemBuilder: (context, index) {
                final ani = _anilar[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              ani['emoji'],
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ani['baslik'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _tarihFormatla(ani['tarih']),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
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
                                  _aniEkleVeyaDuzenle(index: index);
                                } else if (value == 'sil') {
                                  _aniSil(index);
                                }
                              },
                            ),
                          ],
                        ),
                        if (ani['not'].isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(ani['not']),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _aniEkleVeyaDuzenle(),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Anı Ekle'),
      ),
    );
  }
}
