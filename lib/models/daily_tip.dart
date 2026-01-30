class DailyTip {
  final String id;
  final String title;
  final String description;
  final String illustrationPath;

  const DailyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.illustrationPath,
  });

  static const List<DailyTip> tips = [
    DailyTip(
      id: 'eye_tracking',
      title: 'Göz Takibi',
      description:
          'Bebeğin şu an 25–30 cm uzağı görebilir. Yüzünü ona yaklaştır ve gözlerini takip etmesini sağla.',
      illustrationPath: 'assets/illustrations/tips/tip_eye_tracking.png',
    ),
    DailyTip(
      id: 'neck_support',
      title: 'Boyun Desteği',
      description:
          'Bebeğini kucağına aldığında başını ve boynunu mutlaka destekle. Boyun kasları henüz çok zayıf.',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.png',
    ),
    DailyTip(
      id: 'reflex_stepping',
      title: 'Yürüme Refleksi',
      description:
          'Bebeğini dik tutup ayaklarını düz bir yüzeye değdir. Adım atma refleksini göreceksin!',
      illustrationPath: 'assets/illustrations/tips/tip_reflex_stepping.png',
    ),
    DailyTip(
      id: 'sound_interest',
      title: 'Ses İlgisi',
      description:
          'Bebeğin seslere karşı çok duyarlı. Yumuşak bir çıngırak veya müzik kutusuyla dikkatini çekmeyi dene.',
      illustrationPath: 'assets/illustrations/tips/tip_sound_interest.png',
    ),
    DailyTip(
      id: 'parent_interaction',
      title: 'Ebeveyn Etkileşimi',
      description:
          'Bebeğinle göz teması kur ve yavaşça konuş. Senin sesini tanıyor ve güven hissediyor.',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.png',
    ),
    DailyTip(
      id: 'color_worlds',
      title: 'Renk Dünyası',
      description:
          'Yenidoğanlar siyah-beyaz kontrastları en iyi görür. Siyah-beyaz desenli kartlar göstermeyi dene.',
      illustrationPath: 'assets/illustrations/tips/tip_color_worlds.png',
    ),
    DailyTip(
      id: 'mini_athlete',
      title: 'Mini Atlet',
      description:
          'Karın üstü (tummy time) egzersizi boyun ve sırt kaslarını güçlendirir. Günde birkaç dakika dene.',
      illustrationPath: 'assets/illustrations/tips/tip_mini_athlete.png',
    ),
    DailyTip(
      id: 'sound_hunter',
      title: 'Ses Avcısı',
      description:
          'Bebeğin kulağının yanında yavaşça parmak şıklat. Başını sese doğru çevirmeye çalışacaktır.',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.png',
    ),
    DailyTip(
      id: 'touch_explore',
      title: 'Dokunma Keşfi',
      description:
          'Farklı dokuları bebeğinin avuç içine ve ayak tabanına dokundur. Yumuşak, pürüzlü, serin yüzeyler dene.',
      illustrationPath: 'assets/illustrations/tips/tip_touch_explore.png',
    ),
  ];

  /// Returns the tip of the day based on the current date.
  static DailyTip get today {
    final index = DateTime.now().day % tips.length;
    return tips[index];
  }
}
