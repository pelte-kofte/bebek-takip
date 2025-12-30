import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../models/ikonlar.dart';

class AddScreen extends StatelessWidget {
  final VoidCallback? onSaved;

  const AddScreen({super.key, this.onSaved});

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
            Dil.neEklemekIstersin,
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
                icon: Ikonlar.breastfeeding(size: 32),
                label: Dil.beslenme,
                color: const Color(0xFFE91E63),
                onTap: () => _showMamaDialog(context),
              ),
              _AddOption(
                icon: Ikonlar.diaperClean(size: 32),
                label: Dil.bez,
                color: const Color(0xFF9C27B0),
                onTap: () => _showKakaDialog(context),
              ),
              _AddOption(
                icon: Ikonlar.sleep(size: 32),
                label: Dil.uyku,
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
                icon: Ikonlar.memory(size: 32),
                label: Dil.ani,
                color: const Color(0xFFFF9800),
                onTap: () => _showAniDialog(context),
              ),
              _AddOption(
                icon: Ikonlar.growth(size: 32),
                label: Dil.olcum,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Ikonlar.breastfeeding(size: 28),
                      const SizedBox(width: 8),
                      Text(
                        Dil.beslenmeEkle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TurSecimWidget(
                        icon: Ikonlar.breastfeeding(size: 28),
                        label: Dil.emzirme,
                        value: 'Anne Sütü',
                        selected: tur,
                        onSelect: (t) => setModalState(() => tur = t),
                      ),
                      _TurSecimWidget(
                        icon: Ikonlar.bottle(size: 28),
                        label: Dil.formula,
                        value: 'Formül',
                        selected: tur,
                        onSelect: (t) => setModalState(() => tur = t),
                      ),
                      _TurSecimWidget(
                        icon: Ikonlar.bottle(size: 28),
                        label: Dil.biberon,
                        value: 'Biberon',
                        selected: tur,
                        onSelect: (t) => setModalState(() => tur = t),
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
                          Row(
                            children: [
                              Ikonlar.leftBreast(size: 40),
                              const SizedBox(width: 12),
                              Text(
                                Dil.solMeme,
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
                                '$solDakika ${Dil.dk}',
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
                          Row(
                            children: [
                              Ikonlar.rightBreast(size: 40),
                              const SizedBox(width: 12),
                              Text(
                                Dil.sagMeme,
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
                                '$sagDakika ${Dil.dk}',
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
                                Ikonlar.timer(size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${Dil.toplam}: ',
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
                        onSaved?.call();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        '✓ ${Dil.kaydet}',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Ikonlar.diaperClean(size: 28),
                const SizedBox(width: 8),
                Text(
                  Dil.bezDegisimi,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BezOptionWidget(
                  ctx: ctx,
                  icon: Ikonlar.diaperWet(size: 32),
                  label: Dil.islak,
                  color: Colors.blue,
                  onSaved: onSaved,
                ),
                _BezOptionWidget(
                  ctx: ctx,
                  icon: Ikonlar.diaperDirty(size: 32),
                  label: Dil.kirli,
                  color: Colors.brown,
                  onSaved: onSaved,
                ),
                _BezOptionWidget(
                  ctx: ctx,
                  icon: Ikonlar.diaperClean(size: 32),
                  label: Dil.ikisiBirden,
                  color: Colors.green,
                  onSaved: onSaved,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Ikonlar.sleep(size: 28),
                  const SizedBox(width: 8),
                  Text(
                    Dil.uykuEkle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                ],
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
                    onSaved?.call();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '✓ ${Dil.kaydet}',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Ikonlar.memory(size: 28),
                    const SizedBox(width: 8),
                    Text(
                      Dil.aniEkle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ],
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
                    labelText: Dil.baslik,
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
                    labelText: Dil.not,
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
                        onSaved?.call();
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '✓ ${Dil.kaydet}',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Ikonlar.growth(size: 28),
                    const SizedBox(width: 8),
                    Text(
                      Dil.olcumEkle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
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
                          '${secilenTarih.day} ${Dil.aylar[secilenTarih.month - 1]} ${secilenTarih.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Dil.tarihSec,
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
                    labelText: '${Dil.boy} (cm)',
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
                    labelText: '${Dil.kilo} (kg)',
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
                    labelText: '${Dil.basCevresi} (cm) - ${Dil.opsiyonel}',
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
                        onSaved?.call();
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '✓ ${Dil.kaydet}',
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
        ),
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
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
            child: Center(child: icon),
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
  final Widget icon;
  final String label;
  final String value;
  final String selected;
  final Function(String) onSelect;

  const _TurSecimWidget({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            icon,
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

class _BezOptionWidget extends StatelessWidget {
  final BuildContext ctx;
  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback? onSaved;

  const _BezOptionWidget({
    required this.ctx,
    required this.icon,
    required this.label,
    required this.color,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final kayitlar = VeriYonetici.getKakaKayitlari();
        kayitlar.insert(0, {'tarih': DateTime.now(), 'tur': label});
        await VeriYonetici.saveKakaKayitlari(kayitlar);
        onSaved?.call();
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
            icon,
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
