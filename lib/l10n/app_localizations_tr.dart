// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Nilico';

  @override
  String get tagline => 'Ebeveynlik artik daha kolay ve unutulmaz.';

  @override
  String get freeForever => 'Tamamen Ücretsiz';

  @override
  String get securePrivate => 'Güvenli ve Gizli';

  @override
  String get tapToStart => 'Başlamak için dokun';

  @override
  String get feedingTracker => 'Beslenme Takibi';

  @override
  String get feedingTrackerDesc =>
      'Emzirme, biberon ve ek gıdaları kolayca kaydedin. Doğal kalıpları keşfet.';

  @override
  String get sleepPatterns => 'Uyku Düzeni';

  @override
  String get sleepPatternsDesc =>
      'Bebeğinizin ritmini anlayın ve herkes için uyku kalitesini artırın.';

  @override
  String get growthCharts => 'Büyüme Grafikleri';

  @override
  String get growthChartsDesc =>
      'Boy ve kilo degişimlerini güzel grafiklerle görselleştirin.';

  @override
  String get preciousMemories => 'Değerli Anılar';

  @override
  String get preciousMemoriesDesc =>
      'Kilometre taşları ve komik anları kaydedin. Çok çabuk büyüyorlar!';

  @override
  String get dailyRhythm => 'Günlük Ritim';

  @override
  String get dailyRhythmDesc =>
      'Yumuşak rutinler, sakin günler ve huzurlu geceler getirir.';

  @override
  String get skip => 'Atla';

  @override
  String get startYourJourney => 'Yolculuğuna Başla';

  @override
  String get continueBtn => 'Devam';

  @override
  String get save => 'Kaydet';

  @override
  String get update => 'Güncelle';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get ok => 'Tamam';

  @override
  String get add => 'Ekle';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get share => 'Paylaş';

  @override
  String get mlAbbrev => 'ml';

  @override
  String get selectTime => 'Saat seç';

  @override
  String get tapToSetTime => 'Saat seç';

  @override
  String get notificationSleepFired => 'Uyku bildirimi tetiklendi';

  @override
  String get notificationNursingFired => 'Emzirme bildirimi tetiklendi';

  @override
  String get signedOutSuccessfully => 'Çıkış yapıldı';

  @override
  String errorWithMessage(String message) {
    return 'Hata: $message';
  }

  @override
  String get allDataDeleted => 'Tüm veriler silindi';

  @override
  String googleSignInFailed(String error) {
    return 'Google girişi başarısız: $error';
  }

  @override
  String signInFailed(String error) {
    return 'Giriş başarısız: $error';
  }

  @override
  String get webPhotoUploadUnsupported =>
      'Web sürümünde fotoğraf yükleme desteklenmiyor';

  @override
  String babyDataDeleted(String name) {
    return '$name verileri silindi';
  }

  @override
  String get babyNameHint => 'Bebek adı';

  @override
  String get babyNotesHint => 'Alerjiler, tercihler, notlar...';

  @override
  String get vaccineNameHint => 'örn: Hepatit B, BCG, Karma Aşı';

  @override
  String get vaccineDoseHint => 'örn: 1. Doz, DabT-IPA-Hib';

  @override
  String get vaccineNameCannotBeEmpty => 'Aşı adı boş bırakılamaz';

  @override
  String get growthWeightHint => 'örn. 7.5';

  @override
  String get growthHeightHint => 'örn. 68.5';

  @override
  String get growthNotesHint => 'Doktor kontrolü, aşı günü vb...';

  @override
  String get pleaseEnterWeightHeight => 'Lütfen kilo ve boy bilgilerini girin';

  @override
  String get memoryTitleHint => 'örn. İlk adımlar';

  @override
  String get memoryNoteHint => 'Anıyı buraya yaz...';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get activities => 'Bakım';

  @override
  String get vaccines => 'Aşılar';

  @override
  String get development => 'Gelişim';

  @override
  String get memories => 'Anılar';

  @override
  String get settings => 'Ayarlar';

  @override
  String get addActivity => 'Aktivite Ekle';

  @override
  String get whatHappened => 'Ne oldu?';

  @override
  String get nursing => 'Emzirme';

  @override
  String get bottle => 'Beslenme';

  @override
  String get sleep => 'Uyku';

  @override
  String get diaper => 'Bez';

  @override
  String get side => 'Taraf';

  @override
  String get left => 'Sol';

  @override
  String get right => 'Sağ';

  @override
  String get duration => 'Süre';

  @override
  String get minAbbrev => 'dk';

  @override
  String get hourAbbrev => 'sa';

  @override
  String get category => 'Kategori';

  @override
  String get milk => 'Süt';

  @override
  String get solid => 'Ek gıda';

  @override
  String get whatWasGiven => 'NE VERiLDi?';

  @override
  String get solidFoodHint => 'Or: Muz püresi, havuç...';

  @override
  String get amount => 'Miktar';

  @override
  String get milkType => 'Süt Türü';

  @override
  String get breastMilk => 'Anne sütü';

  @override
  String get formula => 'Mama';

  @override
  String get sleepStartedAt => 'UYKU BAŞLANGICI';

  @override
  String get wokeUpAt => 'UYANDI';

  @override
  String get tapToSet => 'Saat seç';

  @override
  String totalSleep(String duration) {
    return 'Toplam uyku: $duration';
  }

  @override
  String get type => 'Tür';

  @override
  String get healthType => 'Tür';

  @override
  String get healthTime => 'Saat';

  @override
  String get wet => 'Islak';

  @override
  String get dirty => 'Kirli';

  @override
  String get both => 'İkisi birden';

  @override
  String get optionalNotes => 'Not (Opsiyonel)';

  @override
  String get diaperNoteHint => 'Bez değişimi hakkında not ekleyin...';

  @override
  String get pleaseSetDuration => 'Lütfen süre ayarlayın';

  @override
  String get pleaseSetAmount => 'Lütfen miktar ayarlayın';

  @override
  String get pleaseSetWakeUpTime => 'Lütfen uyanma zamanını ayarlayın';

  @override
  String get sleepDurationMustBeGreater => 'Uyku suresi 0\'dan buyuk olmalı';

  @override
  String get today => 'Bugün';

  @override
  String get summary => 'ÖZET';

  @override
  String get recentActivities => 'SON BAKIM VERİLERİ';

  @override
  String get record => 'kayıt';

  @override
  String get records => 'kayıt';

  @override
  String get breastfeeding => 'Emzirme';

  @override
  String get bottleBreastMilk => 'Biberon (Anne sütü)';

  @override
  String get total => 'Toplam';

  @override
  String get diaperChange => 'Bez Değişimi';

  @override
  String get firstFeedingTime => 'İlk mama zamanı geldi mi?';

  @override
  String get trackBabyFeeding => 'Bebeğinizin beslenmesini takip edin';

  @override
  String get diaperChangeTime => 'Bez degiştirme zamanı!';

  @override
  String get trackHygiene => 'Hijyen takibini burada yapın';

  @override
  String get sweetDreams => 'Tatlı ruyalar...';

  @override
  String get trackSleepPattern => 'Uyku düzenini buradan izleyin';

  @override
  String get selectAnotherDate => 'Başka tarih seç';

  @override
  String get editFeeding => 'Beslenme Düzenle';

  @override
  String get editDiaper => 'Bez Düzenle';

  @override
  String get editSleep => 'Uyku Düzenle';

  @override
  String get start => 'Başlangıç';

  @override
  String get end => 'Bitiş';

  @override
  String get attention => 'Dikkat';

  @override
  String get deleteConfirm => 'Bu kaydı silmek istediğinize emin misiniz?';

  @override
  String get myVaccines => 'Aşılarım';

  @override
  String get addVaccine => 'Aşı Ekle';

  @override
  String get applied => 'Uygulandı';

  @override
  String get pending => 'Bekleniyor';

  @override
  String get upcomingVaccines => 'Gelecek Aşılar';

  @override
  String get completedVaccines => 'Tamamlanan Aşılar';

  @override
  String get selectDate => 'Tarih seç';

  @override
  String get calendar => 'Takvim';

  @override
  String get turkishVaccineCalendar => 'Türk Aşı Takvimi';

  @override
  String vaccinesAvailable(int count) {
    return '$count aşi mevcut';
  }

  @override
  String get selectAll => 'Tümünü Seç';

  @override
  String get clear => 'Temizle';

  @override
  String get alreadyAdded => 'Zaten ekli';

  @override
  String addVaccines(int count) {
    return '$count Aşı Ekle';
  }

  @override
  String get selectVaccine => 'Aşı Secin';

  @override
  String vaccinesAdded(int count) {
    return '$count Aşı eklendi';
  }

  @override
  String get noVaccineRecords => 'Henüz aşı kaydı yok';

  @override
  String get loadTurkishCalendar =>
      'Türkiye aşı takvimini yükleyin veya manuel olarak ekleyin';

  @override
  String get loadTurkishVaccineCalendar => 'Türkiye Aşı Takvimini Yükle';

  @override
  String get loadCalendarTitle => 'Turkiye Aşı Takvimini Yükle';

  @override
  String get loadCalendarDesc =>
      'Türkiye\'nin standart aşı takvimi yüklenecek. Mevcut aşılar silinmeyecek.';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Yaş',
    );
    return '$_temp0';
  }

  @override
  String ageYearsMonths(int years, int months) {
    return '$years Yaş $months Ay';
  }

  @override
  String ageMonthsDays(int months, int days) {
    return '$months Ay $days Günlük';
  }

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Günlük',
    );
    return '$_temp0';
  }

  @override
  String get weeklyReport => 'Haftalık Rapor';

  @override
  String get monthlyReport => 'Aylık Rapor';

  @override
  String get weekly => 'Haftalık';

  @override
  String get monthly => 'Aylık';

  @override
  String get feeding => 'Beslenme';

  @override
  String get totalBreastfeeding => 'Toplam Emzirme';

  @override
  String get totalDuration => 'Toplam Süre';

  @override
  String get dailyAvg => 'Günlük Ort.';

  @override
  String get avgDuration => 'Ort. Süre';

  @override
  String get leftBreast => 'Sol Meme';

  @override
  String get rightBreast => 'Sağ Meme';

  @override
  String get solidFood => 'Ek gıda';

  @override
  String get diaperChanges => 'Bez Değişimi';

  @override
  String get longestSleep => 'En Uzun Uyku';

  @override
  String get sleepCount => 'Uyku Sayısı';

  @override
  String get growth => 'Büyüme';

  @override
  String get height => 'Boy';

  @override
  String get weight => 'Kilo';

  @override
  String get saveAsPdf => 'PDF Olarak Kaydet';

  @override
  String get pdfMobileOnly => 'PDF paylaşımı mobilde kullanılabilir';

  @override
  String get sharingMobileOnly => 'Paylaşım mobilde kullanılabilir';

  @override
  String get pdfSaved => 'PDF başarıyla kaydedildi!';

  @override
  String get babyTrackerReport => 'Nilico Raporu';

  @override
  String get generatedWith => 'Nilico ile oluşturuldu';

  @override
  String get months => 'ay';

  @override
  String get january => 'Ocak';

  @override
  String get february => 'Şubat';

  @override
  String get march => 'Mart';

  @override
  String get april => 'Nisan';

  @override
  String get may => 'Mayıs';

  @override
  String get june => 'Haziran';

  @override
  String get july => 'Temmuz';

  @override
  String get august => 'Ağustos';

  @override
  String get september => 'Eylül';

  @override
  String get october => 'Ekim';

  @override
  String get november => 'Kasım';

  @override
  String get december => 'Aralık';

  @override
  String get addOptionalNote => 'Not ekle (opsiyonel)';

  @override
  String get times => 'kez';

  @override
  String get feeding_tab => 'MAMA';

  @override
  String get diaper_tab => 'BEZ';

  @override
  String get sleep_tab => 'UYKU';

  @override
  String get list => 'Liste';

  @override
  String get chart => 'Grafik';

  @override
  String get noMeasurements => 'Henüz ölçüm yok';

  @override
  String get addMeasurements => 'Boy ve kilo ölçümlerini ekleyin';

  @override
  String get moreDataNeeded => 'Grafik için daha fazla veri gerekli';

  @override
  String addMoreMeasurements(int count) {
    return '$count ölçüm daha ekleyin';
  }

  @override
  String get atLeast2Measurements => 'Grafik için en az 2 ölçüm gerekli';

  @override
  String get growthTracking => 'Büyüme Takibi';

  @override
  String get feedingTimer => 'EMZİRME';

  @override
  String get sleepingTimer => 'UYKU';

  @override
  String get stopAndSave => 'DURDUR & KAYDET';

  @override
  String get activeTimer => 'AKTİF';

  @override
  String get lastFed => 'SON MAMA';

  @override
  String get lastDiaper => 'SON BEZ';

  @override
  String get lastSleep => 'SON UYKU';

  @override
  String get recentActivity => 'SON BAKIM VERİLERİ';

  @override
  String get seeHistory => 'GEÇMİŞİ GÖR';

  @override
  String get noActivitiesLast24h => 'Son 24 saatte aktivite yok';

  @override
  String get bottleFeeding => 'Beslenme';

  @override
  String get trackYourBabyGrowth => 'Bebeğinizin büyümesini takip edin';

  @override
  String get addHeightWeightMeasurements => 'Boy ve kilo ölçümlerini ekleyin';

  @override
  String get addFirstMeasurement => 'İlk ölçümü ekle';

  @override
  String get lastUpdatedToday => 'Son güncelleme bugün';

  @override
  String get lastUpdated1Day => 'Son güncelleme 1 gün önce';

  @override
  String lastUpdatedDays(int days) {
    return 'Son güncelleme $days gün önce';
  }

  @override
  String get viewGrowthCharts => 'BÜYÜME GRAFİKLERİNİ GÖR';

  @override
  String get weightLabel => 'KİLO';

  @override
  String get heightLabel => 'BOY';

  @override
  String mAgo(int count) {
    return '${count}dk önce';
  }

  @override
  String hmAgo(int hours, int minutes) {
    return '${hours}sa ${minutes}dk önce';
  }

  @override
  String dAgo(int days) {
    return '${days}g önce';
  }

  @override
  String get noRecordsYet => 'Henüz kayıt yok';

  @override
  String get dailyTip => 'GÜNÜN İPUCU';

  @override
  String get allTips => 'Tüm ipuçları';

  @override
  String get upcomingVaccine => 'YAKLAŞAN AŞI';

  @override
  String nextVaccineLabel(String name) {
    return 'Sonraki: $name';
  }

  @override
  String leftMinRightMin(int left, int right) {
    return 'Sol ${left}dk • Sağ ${right}dk';
  }

  @override
  String breastfeedingSavedSnack(int left, int right) {
    return '✅ Emzirme kaydedildi: Sol ${left}dk, Sağ ${right}dk';
  }

  @override
  String sleepSavedSnack(String duration) {
    return '✅ Uyku kaydedildi: $duration';
  }

  @override
  String get sleepTooShort => '⚠️ Uyku 1 dakikadan kısa, kaydedilmedi';

  @override
  String kgThisMonth(String value) {
    return '+${value}kg bu ay';
  }

  @override
  String cmThisMonth(String value) {
    return '+${value}cm bu ay';
  }

  @override
  String get noSleep => 'Uyku yok';

  @override
  String get justNow => 'az önce';

  @override
  String minutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String hoursAgo(int count) {
    return '$count sa önce';
  }

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get welcomeToNilico => 'Nilico\'ya Hoş Geldiniz';

  @override
  String get createYourAccount => 'Hesabını oluştur';

  @override
  String get loginBenefitText =>
      'Verilerini güvende tutmak ve yakında gelecek yedekleme özellikleri için giriş yapabilirsin. İstersen giriş yapmadan da devam edebilirsin.';

  @override
  String get signInWithApple => 'Apple ile giriş yap';

  @override
  String get signInWithGoogle => 'Google ile giriş yap';

  @override
  String get continueWithoutLogin => 'Giriş yapmadan devam et';

  @override
  String get loginOptionalNote =>
      'Giriş isteğe bağlıdır. Tüm özellikler hesap olmadan çalışır.';

  @override
  String get account => 'Hesap';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String signedInAs(String email) {
    return '$email olarak giriş yapıldı';
  }

  @override
  String get guestMode => 'Misafir Modu';

  @override
  String get signInToProtectData => 'Verilerini korumak için giriş yap';

  @override
  String get backupSyncComingSoon => 'Yedekleme ve senkronizasyon yakında';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get privacyPolicySubtitle => 'Gizlilik politikasını görüntüle';

  @override
  String get termsOfUse => 'Kullanım Şartları';

  @override
  String get termsOfUseSubtitle => 'Kullanım koşullarını görüntüle';

  @override
  String get pageCouldNotOpen => 'Sayfa açılamadı';

  @override
  String get health => 'Sağlık';

  @override
  String get medications => 'İlaçlar';

  @override
  String get noMedications => 'Henüz ilaç/takviye eklenmedi';

  @override
  String get medication => 'İlaç';

  @override
  String get supplement => 'Takviye';

  @override
  String get addMedication => 'İlaç Ekle';

  @override
  String get editMedication => 'İlacı Düzenle';

  @override
  String get medicationName => 'Ad';

  @override
  String get medicationNameRequired => 'Lütfen bir ad girin';

  @override
  String get dosage => 'Doz';

  @override
  String get schedule => 'Kullanım Sıklığı';

  @override
  String get notes => 'Notlar';

  @override
  String get language => 'Dil';

  @override
  String get systemDefault => 'Sistem';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get ukrainian => 'Українська';

  @override
  String get spanish => 'Español';

  @override
  String get languageUpdated => 'Dil güncellendi';

  @override
  String get tip_siyah_mekonyum_title => 'İlk Kaka';

  @override
  String get tip_siyah_mekonyum_desc =>
      'Bebeğin ister anne sütü ister formül mama alsın, yaşamının ilk 2–4 gününde bu durumla karşılaşmak çok normaldir. Endişelenmene gerek yok.';

  @override
  String get tip_eye_tracking_title => 'Göz Takibi';

  @override
  String get tip_eye_tracking_desc =>
      'Bebeğin şu an sadece 25–30 cm uzağı net görebilir. Yüzünü ona yaklaştır ve gözlerinle yavaşça hareket et. Seni gözleriyle takip etmeye çalışması, görsel gelişimi için ilk egzersizidir.';

  @override
  String get tip_neck_support_title => 'Boyun Desteği';

  @override
  String get tip_neck_support_desc =>
      'Bebeğini kucağına aldığında başını ve boynunu mutlaka destekle. Boyun kasları henüz çok zayıf.';

  @override
  String get tip_reflex_stepping_title => 'Yürüme Refleksi';

  @override
  String get tip_reflex_stepping_desc =>
      'Bebeğini dik tutup ayaklarını düz bir yüzeye değdir. Adım atma refleksini göreceksin!';

  @override
  String get tip_sound_interest_title => 'Ses İlgisi';

  @override
  String get tip_sound_interest_desc =>
      'Bebeğin seslere karşı çok duyarlı. Yumuşak bir çıngırak veya müzik kutusuyla dikkatini çekmeyi dene.';

  @override
  String get tip_parent_interaction_title => 'Ebeveyn Etkileşimi';

  @override
  String get tip_parent_interaction_desc =>
      'Bebeğinle göz teması kur ve yavaşça konuş. Senin sesini tanıyor ve güven hissediyor.';

  @override
  String get tip_color_worlds_title => 'Renk Dünyası';

  @override
  String get tip_color_worlds_desc =>
      'Yenidoğanlar siyah-beyaz kontrastları en iyi görür. Siyah-beyaz desenli kartlar göstermeyi dene.';

  @override
  String get tip_mini_athlete_title => 'Mini Atlet';

  @override
  String get tip_mini_athlete_desc =>
      'Karın üstü (tummy time) egzersizi boyun ve sırt kaslarını güçlendirir. Günde birkaç dakika dene.';

  @override
  String get tip_sound_hunter_title => 'Ses Avcısı';

  @override
  String get tip_sound_hunter_desc =>
      'Bebeğin kulağının yanında yavaşça parmak şıklat. Başını sese doğru çevirmeye çalışacaktır.';

  @override
  String get tip_touch_explore_title => 'Dokunma Keşfi';

  @override
  String get tip_touch_explore_desc =>
      'Farklı dokuları bebeğinin avuç içine ve ayak tabanına dokundur. Yumuşak, pürüzlü, serin yüzeyler dene.';

  @override
  String get tip_tip_agu_conversation_1_2_title => 'Agu Sohbetleri';

  @override
  String get tip_tip_agu_conversation_1_2_desc =>
      'Bebeğin sesler çıkardığında onu dinle. O bitirdiğinde yumuşak bir sesle karşılık ver. Bu minik sohbetler iletişimin temelini atar.';

  @override
  String get tip_tip_tummy_time_strength_1_2_title =>
      'Güçlü Omuzlar (Tummy Time)';

  @override
  String get tip_tip_tummy_time_strength_1_2_desc =>
      'Bebeğini kısa sürelerle karnının üzerine yatır. Önüne renkli oyuncaklar koyarak başını kaldırmasını teşvik et. Bu, emeklemenin ilk adımıdır.';

  @override
  String get tip_tip_baby_massage_1_2_title => 'Huzur Masajı';

  @override
  String get tip_tip_baby_massage_1_2_desc =>
      'Banyo sonrası ayaklardan başlayarak yumuşak dokunuşlarla masaj yap. Bu hem beden farkındalığını artırır hem de onu sakinleştirir.';

  @override
  String get tip_tip_gesture_speech_1_2_title => 'İşaretli Konuşma';

  @override
  String get tip_tip_gesture_speech_1_2_desc =>
      'Konuşurken hareketlerini kullan. \"Gidiyoruz\" derken el salla, \"Bitti\" derken ellerini sürt. Görsel hafızası güçlenir';

  @override
  String get tip_tip_open_hands_1_2_title => 'Özgür Parmaklar';

  @override
  String get tip_tip_open_hands_1_2_desc =>
      'Artık elleri yumruk olmaktan çıkıyor. Parmaklarını açıp kapamasını izle. Avucuna yumuşak oyuncaklar vererek yakalama becerisini destekle.';

  @override
  String get tip_tip_side_by_side_bonding_1_2_title => 'Yan Yana Keyif';

  @override
  String get tip_tip_side_by_side_bonding_1_2_desc =>
      'Bebeğinle yan yana uzan. Seni gördüğünde sana doğru dönmeye çalışacaktır. Gülümse ve sevgi dolu sözler fısılda.';

  @override
  String get tip_tip_sound_hunter_title => 'Ses Avcısı';

  @override
  String get tip_tip_sound_hunter_desc =>
      'Bebeğinin görmediği bir noktada hafifçe bir çıngırak salla. Başını sesin geldiği yöne çevirmesi, işitme ve odaklanmayı geliştirir.';

  @override
  String get tip_tip_sound_hunter_level2_1_2_title => 'Ses Avcısı (Seviye 2)';

  @override
  String get tip_tip_sound_hunter_level2_1_2_desc =>
      'Sağından ve solundan farklı sesler çıkar. Kaynağı bulmaya çalışması dikkat becerilerini güçlendirir.';

  @override
  String get tip_tip_texture_discovery_1_2_title => 'Dokun ve Keşfet';

  @override
  String get tip_tip_texture_discovery_1_2_desc =>
      'Farklı dokulardaki nesneleri dokundur. Her yeni his, onun için keşfedilecek yeni bir dünyadır.';

  @override
  String get tip_tip_outdoor_explorer_4_5_title => 'Dış Dünya Kaşifi';

  @override
  String get tip_tip_outdoor_explorer_4_5_desc =>
      'Dışarıda gördüğün ağaçları, hayvanları ona göster. Dokunmasını sağla ve anlat. Dünyayı senin sesinle tanımak ona güven verir.';

  @override
  String get tip_tip_reaching_exercise_1_2_title => 'Uzanma Antrenmanı';

  @override
  String get tip_tip_reaching_exercise_1_2_desc =>
      'Ulaşabileceği yerlere oyuncaklar koy. Tam yakalayamasa bile hamle yapması kaslarını güçlendirir.';

  @override
  String get tip_tip_supported_bounce_1_2_title => 'Diz Üstü Yaylanma';

  @override
  String get tip_tip_supported_bounce_1_2_desc =>
      'Onu kucağında dik tutup ayaklarını dizlerine bastırarak hafifçe yaylanmasını sağla. Bu \"zıplama\" oyunu bacak kaslarını güçlendirirken, dünyayı seninle aynı bakış açısından görmesini sağlar.';

  @override
  String get tip_tip_visual_tracking_1_2_title => 'Görsel Takip';

  @override
  String get tip_tip_visual_tracking_1_2_desc =>
      'Bir ipe ses çıkaran renkli bir oyuncak bağla ve bebeğinin görüş alanında yavaşça daireler çizerek hareket ettir. Gözleriyle takip etmesi, görsel takip yeteneği için müthiş bir egzersizdir.';

  @override
  String get tip_tip_face_play_1_2_title => 'Mimik Dansı';

  @override
  String get tip_tip_face_play_1_2_desc =>
      'Bebeğine yüzünü yaklaştır, göz teması kur ve komik mimikler yap. Senin ses tonun ve yüzündeki her değişim, onun en sevdiği ve en öğretici oyuncağıdır.';

  @override
  String get tip_tip_emotion_labeling_1_2_title => 'Duygu';

  @override
  String get tip_tip_emotion_labeling_1_2_desc =>
      'Bebeğin acıktığı veya sıkıldığı için ağladığında, onun hissini isimlendir. \"Karnın acıktı, seni anlıyorum, şimdi halledeceğiz\" diyerek anlaşıldığını hissettir.';

  @override
  String get tip_tip_first_meal_title => 'İlk Tadım';

  @override
  String get tip_tip_first_meal_desc =>
      'Katı gıdaya hekiminizin önerisinde geçin. Kaşıkl abeslenme her ne kadar eğlenceli olsa da alerji durumuna karşı tetikte olun';

  @override
  String get tip_tip_hand_to_hand_transfer_4_5_title => 'Aktif Eller';

  @override
  String get tip_tip_hand_to_hand_transfer_4_5_desc =>
      '4-5. aydan itibaren nesneleri bir elinden diğerine geçirmeye çalışacaktır. Ona kavraması kolay nesneler ver ve nesneyi evirip çevirmesini, bir elinden diğerine aktarmasını hayranlıkla izle.';

  @override
  String get tip_tip_supported_sitting_4_5_title => 'Destekli Oturma';

  @override
  String get tip_tip_supported_sitting_4_5_desc =>
      'Miniğinin dengesini kurması için sırtını yastıklarla destekleyerek oturtma denemeleri yap. Önüne dikkatini çekecek bir oyuncak koy ki, kollarından destek alıp dünyayı bu yeni açıdan izlemenin tadını çıkarsın.';

  @override
  String get tip_tip_feet_discovery_4_5_title => 'Ayaklarla Tanışma';

  @override
  String get tip_tip_feet_discovery_4_5_desc =>
      'Bebeğin sırt üstü yatarken artık ayaklarını yakalayıp ağzına götürebilir. Bu \"vücut keşfi\" seanslarında ayaklarını serbest bırak, farklı yüzeylere (halı, parke, yumuşak battaniye) basmasını sağla; minik adımların provası başlıyor.';

  @override
  String get tip_tip_independent_play_4_5_title => 'Kendi Başına Oyun';

  @override
  String get tip_tip_independent_play_4_5_desc =>
      'Önüne ilgisini çeken, farklı dokularda birkaç oyuncak bırak ve biraz geri çekil. Kendi kendini oyalamayı ve nesnelerle bağımsız bağ kurmayı öğrenmesi, özgüveni için dev bir adımdır.';

  @override
  String ageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aylık',
    );
    return '$_temp0';
  }

  @override
  String get appPreferences => 'Uygulama tercihleri';

  @override
  String get appearance => 'Görünüm';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get darkModeSubtitle => 'Göz yormayan koyu tema';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get feedingReminder => 'Beslenme Hatırlatıcı';

  @override
  String get diaperReminder => 'Bez Hatırlatıcı';

  @override
  String get off => 'Kapalı';

  @override
  String get reminderTime => 'Hatırlatma Saati';

  @override
  String get dataManagement => 'Veri Yönetimi';

  @override
  String get createReport => 'Rapor Oluştur';

  @override
  String get weeklyMonthlyStats => 'Haftalık/Aylık istatistikler';

  @override
  String get deleteAllDataTitle => 'Tüm Verileri Sil';

  @override
  String get deleteAllDataSubtitle => 'Tüm kayıtları kalıcı olarak sil';

  @override
  String get about => 'Hakkında';

  @override
  String get version => 'Versiyon';

  @override
  String get developer => 'Geliştirici';

  @override
  String get deleteAllDataWarning =>
      'Bu işlem tüm kayıtları kalıcı olarak siler. Geri alınamaz.';

  @override
  String get debug => 'DEBUG';

  @override
  String get testSleepNotification => 'Uyku Bildirimi Testi';

  @override
  String get fireSleepNotificationNow => 'Uyku bildirimini şimdi tetikle';

  @override
  String get testNursingNotification => 'Emzirme Bildirimi Testi';

  @override
  String get fireNursingNotificationNow => 'Emzirme bildirimini şimdi tetikle';

  @override
  String get user => 'Kullanıcı';

  @override
  String get selectBaby => 'Bebek Seç';

  @override
  String get newBabyAdd => 'Yeni Bebek Ekle';

  @override
  String get babyProfileTitle => 'Bebek Profili';

  @override
  String get babyInformation => 'Bebek Bilgileri';

  @override
  String get addPhoto => 'Fotoğraf ekle';

  @override
  String get changePhoto => 'Fotoğrafı Değiştir';

  @override
  String get removePhoto => 'Fotoğrafı Kaldır';

  @override
  String get birthDateLabel => 'Doğum Tarihi';

  @override
  String get notesOptional => 'Notlar (isteğe bağlı)';

  @override
  String get growthRecords => 'Büyüme Kayıtları';

  @override
  String get deleteThisBabyData => 'Bu bebeğin verilerini sil';

  @override
  String get otherBabiesUnaffected => 'Diğer bebekler etkilenmez';

  @override
  String get onlyThisBabyPrefix => 'Sadece ';

  @override
  String get allRecordsWillBeDeleted => ' bebeğinin tüm kayıtları silinecek.';

  @override
  String get deleteActionIrreversible =>
      'Diğer bebekler etkilenmez. Bu işlem geri alınamaz.';

  @override
  String get birth => 'Doğum';

  @override
  String monthNumber(int month) {
    return '$month. Ay';
  }

  @override
  String get selectMonth => 'Ay Seçin';

  @override
  String get otherMonth => 'Diğer Ay';

  @override
  String get period => 'Dönem';

  @override
  String get status => 'Durum';

  @override
  String get scheduledDate => 'Planlanan Tarih';

  @override
  String get editVaccine => 'Aşı Düzenle';

  @override
  String get vaccineName => 'Aşı Adı';

  @override
  String get allLabel => 'Tümü';

  @override
  String get routineFilter => 'Rutin';

  @override
  String get asNeededFilter => 'Gerektikçe';

  @override
  String get vaccineProtocolsFilter => 'Aşı protokolleri';

  @override
  String get everyDay => 'Every day';

  @override
  String get asNeeded => 'Gerektikçe';

  @override
  String get vaccineProtocolLabel => 'Aşı protokolü';

  @override
  String linkedToVaccine(String vaccine) {
    return 'linked to $vaccine';
  }

  @override
  String get noVaccineLink => 'No linked vaccine';

  @override
  String doseCountLabel(int count) {
    return 'Kaydedilen doz: $count';
  }

  @override
  String get logGivenNow => 'Verildi olarak kaydet';

  @override
  String get medicationDoseLogged => 'Dose logged';

  @override
  String get scheduleType => 'Kullanım türü';

  @override
  String get dailySchedule => 'Günlük';

  @override
  String get prnSchedule => 'Gerektikçe';

  @override
  String get dailyTimeRequired => 'Add at least one daily time';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String medicationReminderTitle(String name) {
    return '$name reminder';
  }

  @override
  String get medicationReminderBody => 'Time to give this medication';

  @override
  String medicationReminderBodyWithDose(String dose) {
    return 'Dose: $dose';
  }

  @override
  String get addVaccineProtocol => 'Add vaccine protocol';

  @override
  String get createNew => 'Create new';

  @override
  String get chooseExistingMedication => 'Mevcut ilacı seç';

  @override
  String get feverReducerHint => 'Fever reducer';

  @override
  String beforeHours(int hours) {
    return 'Before: ${hours}h';
  }

  @override
  String afterHours(int hours) {
    return 'After: ${hours}h';
  }

  @override
  String get vaccineProtocolAdded => 'Vaccine protocol added';
}
