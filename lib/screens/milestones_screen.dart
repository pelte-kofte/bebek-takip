import 'package:flutter/material.dart';
import '../models/dil.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  final List<Map<String, dynamic>> _milestones = [
    {'emoji': '😊', 'title': 'İlk Gülümseme', 'ay': 2, 'tamamlandi': false},
    {'emoji': '🎒', 'title': 'Başını Tutma', 'ay': 3, 'tamamlandi': false},
    {'emoji': '🔄', 'title': 'Dönme', 'ay': 4, 'tamamlandi': false},
    {'emoji': '🪑', 'title': 'Desteksiz Oturma', 'ay': 6, 'tamamlandi': false},
    {'emoji': '🦷', 'title': 'İlk Diş', 'ay': 6, 'tamamlandi': false},
    {'emoji': '🐛', 'title': 'Emekleme', 'ay': 8, 'tamamlandi': false},
    {'emoji': '🧍', 'title': 'Tutunarak Ayakta Durma', 'ay': 9, 'tamamlandi': false},
    {'emoji': '👋', 'title': 'El Sallama', 'ay': 10, 'tamamlandi': false},
    {'emoji': '🗣️', 'title': 'İlk Kelime', 'ay': 12, 'tamamlandi': false},
    {'emoji': '👣', 'title': 'İlk Adım', 'ay': 12, 'tamamlandi': false},
  ];

  void _toggleMilestone(int index) {
    setState(() {
      _milestones[index]['tamamlandi'] = !_milestones[index]['tamamlandi'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final tamamlanan = _milestones.where((m) => m['tamamlandi'] == true).length;
    final toplam = _milestones.length;
    final progress = tamamlanan / toplam;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏆 ${Dil.gelisimAsamalari}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : const Color(0x1A000000), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(Dil.ilerleme, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                              Text('$tamamlanan / $toplam', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = _milestones[index];
                    final tamamlandi = milestone['tamamlandi'] as bool;

                    return GestureDetector(
                      onTap: () => _toggleMilestone(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: tamamlandi ? Border.all(color: Colors.green, width: 2) : null,
                          boxShadow: [BoxShadow(color: isDark ? Colors.black26 : const Color(0x1A000000), blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: tamamlandi ? Colors.green.withAlpha(25) : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text(milestone['emoji'], style: const TextStyle(fontSize: 24))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    milestone['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: tamamlandi ? Colors.green : textColor,
                                      decoration: tamamlandi ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tamamlandi
                                        ? '✓ ${Dil.tamamlandi}!'
                                        : '${milestone['ay']}. ${Dil.ayindaBekleniyor}',
                                    style: TextStyle(
                                      color: tamamlandi ? Colors.green : subtitleColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                color: tamamlandi ? Colors.green : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                tamamlandi ? Icons.check : Icons.circle_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}