import 'package:flutter/material.dart';

class NinniScreen extends StatefulWidget {
  const NinniScreen({super.key});

  @override
  State<NinniScreen> createState() => _NinniScreenState();
}

class _NinniScreenState extends State<NinniScreen> {
  int? _calanNinni;

  final List<Map<String, String>> _ninniler = [
    {'isim': 'Dandini Dandini Dastana', 'emoji': '🌙'},
    {'isim': 'Uyusun Da Büyüsün', 'emoji': '⭐'},
    {'isim': 'Ninni Ninni Ninni', 'emoji': '🌛'},
    {'isim': 'Hu Hu Huuuu', 'emoji': '💫'},
    {'isim': 'Yıldızlar Parlasın', 'emoji': '✨'},
    {'isim': 'Rüyalar Ülkesi', 'emoji': '🌈'},
  ];

  void _ninniCal(int index) {
    setState(() {
      if (_calanNinni == index) {
        _calanNinni = null; // Durdur
      } else {
        _calanNinni = index; // Çal
      }
    });

    if (_calanNinni != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎵 ${_ninniler[index]['isim']} çalıyor...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Ninniler'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade200, Colors.purple.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _calanNinni != null ? '🎶' : '🌙',
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 10),
                Text(
                  _calanNinni != null
                      ? '${_ninniler[_calanNinni!]['isim']}'
                      : 'Bir ninni seç',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _ninniler.length,
              itemBuilder: (context, index) {
                final ninni = _ninniler[index];
                final caliyor = _calanNinni == index;
                return Card(
                  color: caliyor ? Colors.indigo.shade50 : null,
                  child: ListTile(
                    leading: Text(
                      ninni['emoji']!,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      ninni['isim']!,
                      style: TextStyle(
                        fontWeight: caliyor
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        caliyor ? Icons.pause_circle : Icons.play_circle,
                        size: 40,
                        color: caliyor ? Colors.indigo : Colors.grey,
                      ),
                      onPressed: () => _ninniCal(index),
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
