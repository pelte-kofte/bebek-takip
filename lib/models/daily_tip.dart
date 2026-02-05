class DailyTip {
  final String id;
  final String title;
  final String description;
  final String illustrationPath;
  final int minMonth;
  final int maxMonth;

  const DailyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.illustrationPath,
    required this.minMonth,
    required this.maxMonth,
  });

  static const List<DailyTip> tips = [
    DailyTip(
      id: 'siyah_mekonyum',
      title: 'İlk Kaka',
      description:
          'Bebeğin ister anne sütü ister formül mama alsın, yaşamının ilk 2–4 gününde bu durumla karşılaşmak çok normaldir. Endişelenmene gerek yok.',
      illustrationPath: 'assets/illustrations/tips/tip_mekonyum.png',
      minMonth: 0,
      maxMonth: 1,
    ),
    DailyTip(
      id: 'eye_tracking',
      title: 'Göz Takibi',
      description:
          'Bebeğin şu an sadece 25–30 cm uzağı net görebilir. Yüzünü ona yaklaştır ve gözlerinle yavaşça hareket et. Seni gözleriyle takip etmeye çalışması, görsel gelişimi için ilk egzersizidir.',
      illustrationPath: 'assets/illustrations/tips/tip_eye_tracking.png',
      minMonth: 3,
      maxMonth: 6,
    ),
    DailyTip(
      id: 'neck_support',
      title: 'Boyun Desteği',
      description:
          'Bebeğini kucağına aldığında başını ve boynunu mutlaka destekle. Boyun kasları henüz çok zayıf.',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.png',
      minMonth: 3,
      maxMonth: 6,
    ),
    DailyTip(
      id: 'reflex_stepping',
      title: 'Yürüme Refleksi',
      description:
          'Bebeğini dik tutup ayaklarını düz bir yüzeye değdir. Adım atma refleksini göreceksin!',
      illustrationPath: 'assets/illustrations/tips/tip_reflex_stepping.png',
      minMonth: 3,
      maxMonth: 6,
    ),
    DailyTip(
      id: 'sound_interest',
      title: 'Ses İlgisi',
      description:
          'Bebeğin seslere karşı çok duyarlı. Yumuşak bir çıngırak veya müzik kutusuyla dikkatini çekmeyi dene.',
      illustrationPath: 'assets/illustrations/tips/tip_sound_interest.png',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'parent_interaction',
      title: 'Ebeveyn Etkileşimi',
      description:
          'Bebeğinle göz teması kur ve yavaşça konuş. Senin sesini tanıyor ve güven hissediyor.',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.png',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'color_worlds',
      title: 'Renk Dünyası',
      description:
          'Yenidoğanlar siyah-beyaz kontrastları en iyi görür. Siyah-beyaz desenli kartlar göstermeyi dene.',
      illustrationPath: 'assets/illustrations/tips/tip_color_worlds.png',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'mini_athlete',
      title: 'Mini Atlet',
      description:
          'Karın üstü (tummy time) egzersizi boyun ve sırt kaslarını güçlendirir. Günde birkaç dakika dene.',
      illustrationPath: 'assets/illustrations/tips/tip_mini_athlete.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'sound_hunter',
      title: 'Ses Avcısı',
      description:
          'Bebeğin kulağının yanında yavaşça parmak şıklat. Başını sese doğru çevirmeye çalışacaktır.',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.png',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'touch_explore',
      title: 'Dokunma Keşfi',
      description:
          'Farklı dokuları bebeğinin avuç içine ve ayak tabanına dokundur. Yumuşak, pürüzlü, serin yüzeyler dene.',
      illustrationPath: 'assets/illustrations/tips/tip_touch_explore.png',
      minMonth: 0,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tip_agu_conversation_1_2',
      title: 'Agu Sohbetleri',
      description:
          'Bebeğin sesler çıkardığında onu dinle. O bitirdiğinde yumuşak bir sesle karşılık ver. Bu minik sohbetler iletişimin temelini atar.',
      illustrationPath:
          'assets/illustrations/tips/tip_agu_conversation_1_2.png',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tip_tummy_time_strength_1_2',
      title: 'Güçlü Omuzlar (Tummy Time)',
      description:
          'Bebeğini kısa sürelerle karnının üzerine yatır. Önüne renkli oyuncaklar koyarak başını kaldırmasını teşvik et. Bu, emeklemenin ilk adımıdır.',
      illustrationPath:
          'assets/illustrations/tips/tip_tummy_time_strength_1_2.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_baby_massage_1_2',
      title: 'Huzur Masajı',
      description:
          'Banyo sonrası ayaklardan başlayarak yumuşak dokunuşlarla masaj yap. Bu hem beden farkındalığını artırır hem de onu sakinleştirir.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_gesture_speech_1_2',
      title: 'İşaretli Konuşma',
      description:
          'Konuşurken hareketlerini kullan. "Gidiyoruz" derken el salla, "Bitti" derken ellerini sürt. Görsel hafızası güçlenir',
      illustrationPath: 'assets/illustrations/tips/tip_gesture_speech_1_2.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_open_hands_1_2',
      title: 'Özgür Parmaklar',
      description:
          'Artık elleri yumruk olmaktan çıkıyor. Parmaklarını açıp kapamasını izle. Avucuna yumuşak oyuncaklar vererek yakalama becerisini destekle.',
      illustrationPath: 'assets/illustrations/tips/tip_open_hands_1_2.png',
      minMonth: 2,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_side_by_side_bonding_1_2',
      title: 'Yan Yana Keyif',
      description:
          'Bebeğinle yan yana uzan. Seni gördüğünde sana doğru dönmeye çalışacaktır. Gülümse ve sevgi dolu sözler fısılda.',
      illustrationPath:
          'assets/illustrations/tips/tip_side_by_side_bonding_1_2.png',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tip_sound_hunter',
      title: 'Ses Avcısı',
      description:
          'Bebeğinin görmediği bir noktada hafifçe bir çıngırak salla. Başını sesin geldiği yöne çevirmesi, işitme ve odaklanmayı geliştirir.',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.png',
      minMonth: 2,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_sound_hunter_level2_1_2',
      title: 'Ses Avcısı (Seviye 2)',
      description:
          'Sağından ve solundan farklı sesler çıkar. Kaynağı bulmaya çalışması dikkat becerilerini güçlendirir.',
      illustrationPath:
          'assets/illustrations/tips/tip_sound_hunter_level2_1_2.png',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_texture_discovery_1_2',
      title: 'Dokun ve Keşfet',
      description:
          'Farklı dokulardaki nesneleri dokundur. Her yeni his, onun için keşfedilecek yeni bir dünyadır.',
      illustrationPath:
          'assets/illustrations/tips/tip_texture_discovery_1_2.png',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_outdoor_explorer_4_5',
      title: 'Dış Dünya Kaşifi',
      description:
          'Dışarıda gördüğün ağaçları, hayvanları ona göster. Dokunmasını sağla ve anlat. Dünyayı senin sesinle tanımak ona güven verir.',
      illustrationPath:
          'assets/illustrations/tips/tip_outdoor_explorer_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'tip_reaching_exercise_1_2',
      title: 'Uzanma Antrenmanı',
      description:
          'Ulaşabileceği yerlere oyuncaklar koy. Tam yakalayamasa bile hamle yapması kaslarını güçlendirir.',
      illustrationPath:
          'assets/illustrations/tips/tip_reaching_exercise_1_2.png',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_supported_bounce_1_2',
      title: 'Diz Üstü Yaylanma',
      description:
          'Onu kucağında dik tutup ayaklarını dizlerine bastırarak hafifçe yaylanmasını sağla. Bu "zıplama" oyunu bacak kaslarını güçlendirirken, dünyayı seninle aynı bakış açısından görmesini sağlar.',
      illustrationPath:
          'assets/illustrations/tips/tip_supported_bounce_1_2.png',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_visual_tracking_1_2',
      title: 'Görsel Takip',
      description:
          'Bir ipe ses çıkaran renkli bir oyuncak bağla ve bebeğinin görüş alanında yavaşça daireler çizerek hareket ettir. Gözleriyle takip etmesi, görsel takip yeteneği için müthiş bir egzersizdir.',
      illustrationPath: 'assets/illustrations/tips/tip_visual_tracking_1_2.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_face_play_1_2',
      title: 'Mimik Dansı',
      description:
          'Bebeğine yüzünü yaklaştır, göz teması kur ve komik mimikler yap. Senin ses tonun ve yüzündeki her değişim, onun en sevdiği ve en öğretici oyuncağıdır.',
      illustrationPath: 'assets/illustrations/tips/tip_face_play_1_2.png',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tip_emotion_labeling_1_2',
      title: 'Duygu',
      description:
          'Bebeğin acıktığı veya sıkıldığı için ağladığında, onun hissini isimlendir. "Karnın acıktı, seni anlıyorum, şimdi halledeceğiz" diyerek anlaşıldığını hissettir.',
      illustrationPath:
          'assets/illustrations/tips/tip_emotion_labeling_1_2.png',
      minMonth: 1,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_first_meal',
      title: 'İlk Tadım',
      description:
          'Katı gıdaya hekiminizin önerisinde geçin. Kaşıkl abeslenme her ne kadar eğlenceli olsa da alerji durumuna karşı tetikte olun',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.png',
      minMonth: 5,
      maxMonth: 8,
    ),
    DailyTip(
      id: 'tip_hand_to_hand_transfer_4_5',
      title: 'Aktif Eller',
      description:
          '4-5. aydan itibaren nesneleri bir elinden diğerine geçirmeye çalışacaktır. Ona kavraması kolay nesneler ver ve nesneyi evirip çevirmesini, bir elinden diğerine aktarmasını hayranlıkla izle.',
      illustrationPath:
          'assets/illustrations/tips/tip_hand_to_hand_transfer_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'tip_supported_sitting_4_5',
      title: 'Destekli Oturma',
      description:
          'Miniğinin dengesini kurması için sırtını yastıklarla destekleyerek oturtma denemeleri yap. Önüne dikkatini çekecek bir oyuncak koy ki, kollarından destek alıp dünyayı bu yeni açıdan izlemenin tadını çıkarsın.',
      illustrationPath:
          'assets/illustrations/tips/tip_supported_sitting_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'tip_feet_discovery_4_5',
      title: 'Ayaklarla Tanışma',
      description:
          'Bebeğin sırt üstü yatarken artık ayaklarını yakalayıp ağzına götürebilir. Bu "vücut keşfi" seanslarında ayaklarını serbest bırak, farklı yüzeylere (halı, parke, yumuşak battaniye) basmasını sağla; minik adımların provası başlıyor.',
      illustrationPath: 'assets/illustrations/tips/tip_feet_discovery_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'tip_independent_play_4_5',
      title: 'Kendi Başına Oyun',
      description:
          'Önüne ilgisini çeken, farklı dokularda birkaç oyuncak bırak ve biraz geri çekil. Kendi kendini oyalamayı ve nesnelerle bağımsız bağ kurmayı öğrenmesi, özgüveni için dev bir adımdır.',
      illustrationPath:
          'assets/illustrations/tips/tip_independent_play_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
  ];

  /// Returns the tip of the day based on the current date.
  static DailyTip todayForBaby(int babyAgeInMonths) {
    final availableTips = tips.where((tip) {
      return babyAgeInMonths >= tip.minMonth && babyAgeInMonths < tip.maxMonth;
    }).toList();

    if (availableTips.isEmpty) {
      return tips.first; // fallback (normalde buraya düşmez)
    }

    final index = DateTime.now().day % availableTips.length;
    return availableTips[index];
  }
}
