import 'package:flutter/material.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  final List<Map<String, dynamic>> _milestones = [
    {
      'emoji': '😊',
      'title': 'İlk Gülümseme',
      'ay': 2,
      'tamamlandi': false,
      'tarih': '15 Oca 2025',
    },
    {
      'emoji': '🎒',
      'title': 'Başını Tutma',
      'ay': 3,
      'tamamlandi': false,
      'tarih': '20 Şub 2025',
    },
    {
      'emoji': '🔄',
      'title': 'Dönme',
      'ay': 4,
      'tamamlandi': false,
      'tarih': '10 Mar 2025',
    },
    {
      'emoji': '🪑',
      'title': 'Desteksiz Oturma',
      'ay': 6,
      'tamamlandi': false,
      'tarih': null,
    },
    {
      'emoji': '🦷',
      'title': 'İlk Diş',
      'ay': 6,
      'tamamlandi': false,
      'tarih': null,
    },
    {
      'emoji': '🐛',
      'title': 'Emekleme',
      'ay': 8,
      'tamamlandi': false,
      'tarih': null,
    },
    {
      'emoji': '🧍',
      'title': 'Tutunarak Ayakta Durma',
      'ay': 9,
      'tamamlandi': false,
      'tarih': null,
    },
    {
      'emoji': '👋',
      'title': 'El Sallama',
      'ay': 10,
      'tamamlandi': false,
      'tarih': null,
    },
    {
      'emoji': '🗣️',
      'title': 'İlk Kelime',
      'ay': 12,
      'tamamlandi': false,
      'tarih': null,
    },
    {
      'emoji': '👣',
      'title': 'İlk Adım',
      'ay': 12,
      'tamamlandi': false,
      'tarih': null,
    },
  ];

  void _toggleMilestone(int index) {
    setState(() {
      _milestones[index]['tamamlandi'] = !_milestones[index]['tamamlandi'];
      if (_milestones[index]['tamamlandi']) {
        final now = DateTime.now();
        final aylar = [
          'Oca',
          'Şub',
          'Mar',
          'Nis',
          'May',
          'Haz',
          'Tem',
          'Ağu',
          'Eyl',
          'Eki',
          'Kas',
          'Ara',
        ];
        _milestones[index]['tarih'] =
            '${now.day} ${aylar[now.month - 1]} ${now.year}';
      } else {
        _milestones[index]['tarih'] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tamamlanan = _milestones.where((m) => m['tamamlandi']).length;
    final toplam = _milestones.length;

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
                          '🏆 Gelişim Aşamaları',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // PROGRESS BAR
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40E91E63),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'İlerleme',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '$tamamlanan / $toplam',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: tamamlanan / toplam,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // LİSTE
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = _milestones[index];
                    final tamamlandi = milestone['tamamlandi'] as bool;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: tamamlandi
                            ? Border.all(
                                color: const Color(0xFF4CAF50),
                                width: 2,
                              )
                            : null,
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
                            color: tamamlandi
                                ? const Color(0xFF4CAF50).withAlpha(25)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              milestone['emoji'],
                              style: TextStyle(
                                fontSize: 24,
                                color: tamamlandi ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          milestone['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: tamamlandi
                                ? const Color(0xFF333333)
                                : Colors.grey,
                            decoration: tamamlandi
                                ? TextDecoration.none
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          tamamlandi
                              ? '✓ ${milestone['tarih']}'
                              : '${milestone['ay']}. ayda bekleniyor',
                          style: TextStyle(
                            color: tamamlandi
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: GestureDetector(
                          onTap: () => _toggleMilestone(index),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: tamamlandi
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tamamlandi ? Icons.check : Icons.circle_outlined,
                              color: tamamlandi ? Colors.white : Colors.grey,
                              size: 24,
                            ),
                          ),
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
    );
  }
}
