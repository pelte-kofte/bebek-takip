import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            'Ne eklemek istersin?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AddOption(
                emoji: '🍼',
                label: 'Mama',
                color: const Color(0xFFE91E63),
                onTap: () => _showMamaDialog(context),
              ),
              _AddOption(
                emoji: '👶',
                label: 'Bez',
                color: const Color(0xFF9C27B0),
                onTap: () => _showKakaDialog(context),
              ),
              _AddOption(
                emoji: '😴',
                label: 'Uyku',
                color: const Color(0xFF3F51B5),
                onTap: () => _showUykuDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AddOption(
                emoji: '📸',
                label: 'Anı',
                color: const Color(0xFFFF9800),
                onTap: () => _showAniDialog(context),
              ),
              _AddOption(
                emoji: '📏',
                label: 'Ölçüm',
                color: const Color(0xFF4CAF50),
                onTap: () => _showGrowthDialog(context),
              ),
              const SizedBox(width: 70),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showMamaDialog(BuildContext context) {
    Navigator.pop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String tur = 'Anne Sütü';
    int solDakika = 10;
    int sagDakika = 10;
    int miktar = 100;
    TimeOfDay saat = TimeOfDay.now();

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
                  const Text(
                    '🍼 Mama Ekle',
                    style: TextStyle(
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
                      _TurSecimWidget(
                        emoji: '🤱',
                        label: 'Anne Sütü',
                        selected: tur,
                        onSelect: (t) => setModalState(() => tur = t),
                      ),
                      _TurSecimWidget(
                        emoji: '🍼',
                        label: 'Formül',
                        selected: tur,
                        onSelect: (t) => setModalState(() => tur = t),
                      ),
                      _TurSecimWidget(
                        emoji: '🥛',
                        label: 'Biberon',
                        selected: tur,
                        onSelect: (t) => setModalState(() => tur = t),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ANNE SÜTÜ - MEME SEÇİMİ VE SÜRE
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
                          // Sol Meme
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63).withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'L',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sol Meme',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setModalState(
                                  () =>
                                      solDakika = (solDakika - 1).clamp(0, 60),
                                ),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE91E63),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$solDakika dk',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => setModalState(
                                  () =>
                                      solDakika = (solDakika + 1).clamp(0, 60),
                                ),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE91E63),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Sağ Meme
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63).withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'R',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sağ Meme',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setModalState(
                                  () =>
                                      sagDakika = (sagDakika - 1).clamp(0, 60),
                                ),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE91E63),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$sagDakika dk',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => setModalState(
                                  () =>
                                      sagDakika = (sagDakika + 1).clamp(0, 60),
                                ),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE91E63),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
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
                                const Text(
                                  '⏱️ Toplam: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${solDakika + sagDakika} dakika',
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

                  // FORMÜL VEYA BİBERON - MİKTAR
                  if (tur == 'Formül' || tur == 'Biberon') ...[
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
                          GestureDetector(
                            onTap: () => setModalState(
                              () => miktar = (miktar - 10).clamp(0, 500),
                            ),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE91E63),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
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
                          GestureDetector(
                            onTap: () => setModalState(
                              () => miktar = (miktar + 10).clamp(0, 500),
                            ),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE91E63),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // SAAT SEÇİMİ
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: saat,
                      );
                      if (picked != null) setModalState(() => saat = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
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
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFFE91E63),
                          ),
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
                  ),
                  const SizedBox(height: 24),

                  // KAYDET BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final tarih = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          saat.hour,
                          saat.minute,
                        );
                        final kayitlar = VeriYonetici.getMamaKayitlari();

                        if (tur == 'Anne Sütü') {
                          kayitlar.insert(0, {
                            'tarih': tarih,
                            'tur': 'Anne Sütü',
                            'solDakika': solDakika,
                            'sagDakika': sagDakika,
                            'miktar': 0,
                          });
                        } else {
                          String kayitTur = tur == 'Biberon'
                              ? 'Biberon Anne Sütü'
                              : 'Formül';
                          kayitlar.insert(0, {
                            'tarih': tarih,
                            'tur': kayitTur,
                            'miktar': miktar,
                            'solDakika': 0,
                            'sagDakika': 0,
                          });
                        }

                        await VeriYonetici.saveMamaKayitlari(kayitlar);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '✓ Kaydet',
                        style: TextStyle(
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

  void _showKakaDialog(BuildContext context) {
    Navigator.pop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '👶 Bez Değişimi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BezOption(
                  ctx: ctx,
                  emoji: '💧',
                  label: 'Islak',
                  color: Colors.blue,
                ),
                _BezOption(
                  ctx: ctx,
                  emoji: '💩',
                  label: 'Kirli',
                  color: Colors.brown,
                ),
                _BezOption(
                  ctx: ctx,
                  emoji: '💧💩',
                  label: 'İkisi de',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showUykuDialog(BuildContext context) {
    Navigator.pop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TimeOfDay baslangic = TimeOfDay.now();
    TimeOfDay bitis = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '😴 Uyku Ekle',
                style: TextStyle(
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
                        'Başlangıç',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: baslangic,
                          );
                          if (picked != null)
                            setModalState(() => baslangic = picked);
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
                            '${baslangic.hour.toString().padLeft(2, '0')}:${baslangic.minute.toString().padLeft(2, '0')}',
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
                        'Bitiş',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: bitis,
                          );
                          if (picked != null)
                            setModalState(() => bitis = picked);
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
                            '${bitis.hour.toString().padLeft(2, '0')}:${bitis.minute.toString().padLeft(2, '0')}',
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
                    final now = DateTime.now();
                    final baslangicDT = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      baslangic.hour,
                      baslangic.minute,
                    );
                    var bitisDT = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      bitis.hour,
                      bitis.minute,
                    );
                    if (bitisDT.isBefore(baslangicDT))
                      bitisDT = bitisDT.add(const Duration(days: 1));
                    final sure = bitisDT.difference(baslangicDT);
                    final kayitlar = VeriYonetici.getUykuKayitlari();
                    kayitlar.insert(0, {
                      'baslangic': baslangicDT,
                      'bitis': bitisDT,
                      'sure': sure,
                    });
                    await VeriYonetici.saveUykuKayitlari(kayitlar);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '✓ Kaydet',
                    style: TextStyle(
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
      ),
    );
  }

  void _showAniDialog(BuildContext context) {
    Navigator.pop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baslikController = TextEditingController();
    final notController = TextEditingController();
    String emoji = '👶';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                const Text(
                  '📸 Anı Ekle',
                  style: TextStyle(
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
                                  : (isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100),
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
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notController,
                  maxLines: 3,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Not',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    border: const OutlineInputBorder(),
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
                        anilar.insert(0, {
                          'baslik': baslikController.text,
                          'not': notController.text,
                          'tarih': DateTime.now(),
                          'emoji': emoji,
                        });
                        await VeriYonetici.saveAnilar(anilar);
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '✓ Kaydet',
                      style: TextStyle(
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
        ),
      ),
    );
  }

  void _showGrowthDialog(BuildContext context) {
    Navigator.pop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boyController = TextEditingController();
    final kiloController = TextEditingController();
    final basController = TextEditingController();
    DateTime secilenTarih = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                const Text(
                  '📏 Ölçüm Ekle',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: secilenTarih,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null)
                      setModalState(() => secilenTarih = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.green.shade900.withAlpha(50)
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4CAF50)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${secilenTarih.day}/${secilenTarih.month}/${secilenTarih.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tarih Seç',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: boyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Boy (cm)',
                    hintText: 'Örn: 68.5',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.straighten,
                      color: Color(0xFF4CAF50),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: kiloController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Kilo (kg)',
                    hintText: 'Örn: 7.5',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.monitor_weight,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: basController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Baş Çevresi (cm) - Opsiyonel',
                    hintText: 'Örn: 42.0',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.circle_outlined,
                      color: Color(0xFFFF9800),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (boyController.text.isNotEmpty &&
                          kiloController.text.isNotEmpty) {
                        final kayitlar = VeriYonetici.getBoyKiloKayitlari();
                        kayitlar.insert(0, {
                          'tarih': secilenTarih,
                          'boy':
                              double.tryParse(
                                boyController.text.replaceAll(',', '.'),
                              ) ??
                              0,
                          'kilo':
                              double.tryParse(
                                kiloController.text.replaceAll(',', '.'),
                              ) ??
                              0,
                          'basCevresi':
                              double.tryParse(
                                basController.text.replaceAll(',', '.'),
                              ) ??
                              0,
                        });
                        kayitlar.sort(
                          (a, b) => (b['tarih'] as DateTime).compareTo(
                            a['tarih'] as DateTime,
                          ),
                        );
                        await VeriYonetici.saveBoyKiloKayitlari(kayitlar);
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '✓ Kaydet',
                      style: TextStyle(
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
        ),
      ),
    );
  }
}

// YARDIMCI WİDGETLAR
class _AddOption extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withAlpha(50), width: 2),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TurSecimWidget extends StatelessWidget {
  final String emoji;
  final String label;
  final String selected;
  final Function(String) onSelect;

  const _TurSecimWidget({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BezOption extends StatelessWidget {
  final BuildContext ctx;
  final String emoji;
  final String label;
  final Color color;

  const _BezOption({
    required this.ctx,
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final kayitlar = VeriYonetici.getKakaKayitlari();
        kayitlar.insert(0, {'tarih': DateTime.now(), 'tur': label});
        await VeriYonetici.saveKakaKayitlari(kayitlar);
        Navigator.pop(ctx);
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
