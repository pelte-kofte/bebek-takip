// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Nilico';

  @override
  String get tagline => 'Батьківство — просто та незабутньо.';

  @override
  String get freeForever => 'Безкоштовно назавжди';

  @override
  String get securePrivate => 'Безпечно та конфіденційно';

  @override
  String get tapToStart => 'Натисніть, щоб почати';

  @override
  String get feedingTracker => 'Трекер годувань';

  @override
  String get feedingTrackerDesc =>
      'Записуйте грудне вигодовування, пляшечки та прикорм. Помічайте закономірності.';

  @override
  String get sleepPatterns => 'Режим сну';

  @override
  String get sleepPatternsDesc =>
      'Вивчайте ритм сну вашого малюка та покращуйте якість сну для всіх.';

  @override
  String get growthCharts => 'Графіки росту';

  @override
  String get growthChartsDesc =>
      'Наочно відстежуйте зміни росту та ваги за допомогою гарних графіків.';

  @override
  String get preciousMemories => 'Дорогоцінні спогади';

  @override
  String get preciousMemoriesDesc =>
      'Зберігайте важливі моменти та кумедні історії. Вони так швидко ростуть!';

  @override
  String get dailyRhythm => 'Денний ритм';

  @override
  String get dailyRhythmDesc =>
      'М\'який режим дня приносить спокійні дні та тихі ночі.';

  @override
  String get skip => 'Пропустити';

  @override
  String get startYourJourney => 'Розпочніть свою подорож';

  @override
  String get continueBtn => 'Продовжити';

  @override
  String get save => 'Зберегти';

  @override
  String get update => 'Оновити';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get edit => 'Змінити';

  @override
  String get ok => 'ОК';

  @override
  String get add => 'Додати';

  @override
  String get yes => 'Так';

  @override
  String get no => 'Ні';

  @override
  String get share => 'Поділитися';

  @override
  String get mlAbbrev => 'мл';

  @override
  String get selectTime => 'Оберіть час';

  @override
  String get tapToSetTime => 'Встановити час';

  @override
  String get notificationSleepFired => 'Сповіщення про сон надіслано';

  @override
  String get notificationNursingFired => 'Сповіщення про годування надіслано';

  @override
  String get signedOutSuccessfully => 'Вихід виконано успішно';

  @override
  String errorWithMessage(String message) {
    return 'Помилка: $message';
  }

  @override
  String get allDataDeleted => 'Усі дані видалено';

  @override
  String googleSignInFailed(String error) {
    return 'Вхід через Google не вдався: $error';
  }

  @override
  String signInFailed(String error) {
    return 'Не вдалося увійти: $error';
  }

  @override
  String get webPhotoUploadUnsupported =>
      'Завантаження фото не підтримується у веб-версії';

  @override
  String babyDataDeleted(String name) {
    return 'Дані $name видалено';
  }

  @override
  String get babyNameHint => 'Ім\'я малюка';

  @override
  String get babyNotesHint => 'Алергії, уподобання, нотатки...';

  @override
  String get vaccineNameHint => 'напр. Гепатит B, БЦЖ, комбінована вакцина';

  @override
  String get vaccineDoseHint => 'напр. Доза 1, АКДП-ІПВ-ХІБ';

  @override
  String get vaccineNameCannotBeEmpty => 'Назва вакцини не може бути порожньою';

  @override
  String get growthWeightHint => 'напр. 7,5';

  @override
  String get growthHeightHint => 'напр. 68,5';

  @override
  String get growthNotesHint => 'Візит до лікаря, день вакцинації тощо.';

  @override
  String get pleaseEnterWeightHeight => 'Введіть вагу та зріст';

  @override
  String get memoryTitleHint => 'напр. Перші кроки';

  @override
  String get memoryNoteHint => 'Запишіть спогад...';

  @override
  String get home => 'Головна';

  @override
  String get activities => 'Догляд';

  @override
  String get vaccines => 'Вакцини';

  @override
  String get development => 'Розвиток';

  @override
  String get memories => 'Спогади';

  @override
  String get settings => 'Налаштування';

  @override
  String get addActivity => 'Додати запис';

  @override
  String get whatHappened => 'Що сталося?';

  @override
  String get nursing => 'Грудне вигодовування';

  @override
  String get bottle => 'Годування';

  @override
  String get sleep => 'Сон';

  @override
  String get diaper => 'Підгузок';

  @override
  String get side => 'Сторона';

  @override
  String get left => 'Ліва';

  @override
  String get right => 'Права';

  @override
  String get duration => 'Тривалість';

  @override
  String get minAbbrev => 'хв';

  @override
  String get hourAbbrev => 'год';

  @override
  String get category => 'Категорія';

  @override
  String get milk => 'Молоко';

  @override
  String get solid => 'Прикорм';

  @override
  String get whatWasGiven => 'ЩО ДАВАЛИ?';

  @override
  String get solidFoodHint => 'Напр.: бананове пюре, морква...';

  @override
  String get amount => 'Кількість';

  @override
  String get milkType => 'Тип молока';

  @override
  String get breastMilk => 'Грудне молоко';

  @override
  String get formula => 'Суміш';

  @override
  String get sleepStartedAt => 'СОН ПОЧАВСЯ О';

  @override
  String get wokeUpAt => 'ПРОКИНУВСЯ О';

  @override
  String get tapToSet => 'Встановити час';

  @override
  String totalSleep(String duration) {
    return 'Загальний сон: $duration';
  }

  @override
  String get type => 'Тип';

  @override
  String get healthType => 'Тип';

  @override
  String get healthTime => 'Час';

  @override
  String get wet => 'Мокрий';

  @override
  String get dirty => 'Брудний';

  @override
  String get both => 'Обидва';

  @override
  String get optionalNotes => 'Нотатки (необов\'язково)';

  @override
  String get diaperNoteHint => 'Додайте нотатку про зміну підгузка...';

  @override
  String get pleaseSetDuration => 'Вкажіть тривалість';

  @override
  String get pleaseSetAmount => 'Вкажіть кількість';

  @override
  String get pleaseSetWakeUpTime => 'Вкажіть час пробудження';

  @override
  String get sleepDurationMustBeGreater => 'Тривалість сну має бути більше 0';

  @override
  String get today => 'Сьогодні';

  @override
  String get summary => 'ЗВЕДЕННЯ';

  @override
  String get recentActivities => 'НЕЩОДАВНІ ЗАПИСИ ДОГЛЯДУ';

  @override
  String get record => 'запис';

  @override
  String get records => 'записів';

  @override
  String get breastfeeding => 'Грудне вигодовування';

  @override
  String get bottleBreastMilk => 'Пляшечка (грудне молоко)';

  @override
  String get total => 'Усього';

  @override
  String get diaperChange => 'Зміна підгузка';

  @override
  String get firstFeedingTime => 'Час першого годування?';

  @override
  String get trackBabyFeeding => 'Відстежуйте годування малюка';

  @override
  String get diaperChangeTime => 'Час змінити підгузок!';

  @override
  String get trackHygiene => 'Відстежуйте гігієну тут';

  @override
  String get sweetDreams => 'Солодких снів...';

  @override
  String get trackSleepPattern => 'Відстежуйте режим сну тут';

  @override
  String get selectAnotherDate => 'Оберіть іншу дату';

  @override
  String get editFeeding => 'Змінити годування';

  @override
  String get editDiaper => 'Змінити підгузок';

  @override
  String get editSleep => 'Змінити сон';

  @override
  String get start => 'Початок';

  @override
  String get end => 'Кінець';

  @override
  String get attention => 'Увага';

  @override
  String get deleteConfirm => 'Ви впевнені, що хочете видалити цей запис?';

  @override
  String get myVaccines => 'Мої вакцини';

  @override
  String get addVaccine => 'Додати вакцину';

  @override
  String get applied => 'Зроблено';

  @override
  String get pending => 'Очікується';

  @override
  String get upcomingVaccines => 'Майбутні вакцини';

  @override
  String get completedVaccines => 'Зроблені вакцини';

  @override
  String get selectDate => 'Оберіть дату';

  @override
  String get calendar => 'Календар';

  @override
  String get turkishVaccineCalendar => 'Турецький календар вакцинації';

  @override
  String vaccinesAvailable(int count) {
    return '$count вакцин доступно';
  }

  @override
  String get selectAll => 'Обрати все';

  @override
  String get clear => 'Очистити';

  @override
  String get alreadyAdded => 'Вже додано';

  @override
  String addVaccines(int count) {
    return 'Додати $count вакцин';
  }

  @override
  String get selectVaccine => 'Оберіть вакцину';

  @override
  String vaccinesAdded(int count) {
    return '$count вакцин додано';
  }

  @override
  String get noVaccineRecords => 'Записів про вакцини поки немає';

  @override
  String get loadTurkishCalendar =>
      'Завантажте турецький календар або додайте вручну';

  @override
  String get loadTurkishVaccineCalendar =>
      'Завантажити турецький календар вакцинації';

  @override
  String get loadCalendarTitle => 'Завантажити турецький календар вакцинації';

  @override
  String get loadCalendarDesc =>
      'Буде завантажено стандартний турецький календар вакцинації. Існуючі вакцини не будуть видалені.';

  @override
  String ageYears(int years) {
    return '$years років';
  }

  @override
  String ageYearsMonths(int years, int months) {
    return '$years рік $months міс.';
  }

  @override
  String ageMonthsDays(int months, int days) {
    return '$months міс. $days дн.';
  }

  @override
  String ageDays(int days) {
    return '$days дн.';
  }

  @override
  String get weeklyReport => 'Тижневий звіт';

  @override
  String get monthlyReport => 'Місячний звіт';

  @override
  String get weekly => 'Тиждень';

  @override
  String get monthly => 'Місяць';

  @override
  String get feeding => 'Годування';

  @override
  String get totalBreastfeeding => 'Усього грудного вигодовування';

  @override
  String get totalDuration => 'Загальна тривалість';

  @override
  String get dailyAvg => 'Сер. за день';

  @override
  String get avgDuration => 'Сер. тривалість';

  @override
  String get leftBreast => 'Ліва груди';

  @override
  String get rightBreast => 'Права груди';

  @override
  String get solidFood => 'Прикорм';

  @override
  String get diaperChanges => 'Зміни підгузків';

  @override
  String get longestSleep => 'Найдовший сон';

  @override
  String get sleepCount => 'Кіл-ть снів';

  @override
  String get growth => 'Ріст';

  @override
  String get height => 'Зріст';

  @override
  String get weight => 'Вага';

  @override
  String get saveAsPdf => 'Зберегти як PDF';

  @override
  String get pdfMobileOnly => 'Збереження PDF доступне на мобільному';

  @override
  String get sharingMobileOnly => 'Поділитися можна на мобільному';

  @override
  String get pdfSaved => 'PDF успішно збережено!';

  @override
  String get babyTrackerReport => 'Звіт трекера малюка';

  @override
  String get generatedWith => 'Створено за допомогою Baby Tracker App';

  @override
  String get months => 'міс.';

  @override
  String get january => 'Січень';

  @override
  String get february => 'Лютий';

  @override
  String get march => 'Березень';

  @override
  String get april => 'Квітень';

  @override
  String get may => 'Травень';

  @override
  String get june => 'Червень';

  @override
  String get july => 'Липень';

  @override
  String get august => 'Серпень';

  @override
  String get september => 'Вересень';

  @override
  String get october => 'Жовтень';

  @override
  String get november => 'Листопад';

  @override
  String get december => 'Грудень';

  @override
  String get addOptionalNote => 'Додати нотатку (необов\'язково)';

  @override
  String get times => 'разів';

  @override
  String get feeding_tab => 'ГОДУВАННЯ';

  @override
  String get diaper_tab => 'ПІДГУЗОК';

  @override
  String get sleep_tab => 'СОН';

  @override
  String get list => 'Список';

  @override
  String get chart => 'Графік';

  @override
  String get noMeasurements => 'Вимірювань поки немає';

  @override
  String get addMeasurements => 'Додайте вимірювання зросту та ваги';

  @override
  String get moreDataNeeded => 'Потрібно більше даних для графіка';

  @override
  String addMoreMeasurements(int count) {
    return 'Додайте ще $count вимірювань';
  }

  @override
  String get atLeast2Measurements =>
      'Для графіка потрібно мінімум 2 вимірювання';

  @override
  String get growthTracking => 'Відстеження росту';

  @override
  String get feedingTimer => 'ГОДУВАННЯ';

  @override
  String get sleepingTimer => 'СОН';

  @override
  String get stopAndSave => 'СТОП І ЗБЕРЕГТИ';

  @override
  String get activeTimer => 'АКТИВНИЙ';

  @override
  String get lastFed => 'ОСТАННЄ ГОДУВАННЯ';

  @override
  String get lastDiaper => 'ОСТАННІЙ ПІДГУЗОК';

  @override
  String get lastSleep => 'ОСТАННІЙ СОН';

  @override
  String get recentActivity => 'НЕЩОДАВНІ ЗАПИСИ ДОГЛЯДУ';

  @override
  String get seeHistory => 'ІСТОРІЯ';

  @override
  String get noActivitiesLast24h => 'Немає активності за останні 24 години';

  @override
  String get bottleFeeding => 'Годування';

  @override
  String get trackYourBabyGrowth => 'Відстежуйте ріст малюка';

  @override
  String get addHeightWeightMeasurements =>
      'Додайте вимірювання ваги та зросту';

  @override
  String get addFirstMeasurement => 'Додати перше вимірювання';

  @override
  String get lastUpdatedToday => 'Оновлено сьогодні';

  @override
  String get lastUpdated1Day => 'Оновлено 1 день тому';

  @override
  String lastUpdatedDays(int days) {
    return 'Оновлено $days дн. тому';
  }

  @override
  String get viewGrowthCharts => 'ГРАФІКИ РОСТУ';

  @override
  String get weightLabel => 'ВАГА';

  @override
  String get heightLabel => 'ЗРІСТ';

  @override
  String mAgo(int count) {
    return '$count хв тому';
  }

  @override
  String hmAgo(int hours, int minutes) {
    return '$hoursгод $minutesхв тому';
  }

  @override
  String dAgo(int days) {
    return '$daysд тому';
  }

  @override
  String get noRecordsYet => 'Записів поки немає';

  @override
  String get dailyTip => 'ПОРАДА ДНЯ';

  @override
  String get allTips => 'Усі поради';

  @override
  String get upcomingVaccine => 'МАЙБУТНЯ ВАКЦИНА';

  @override
  String nextVaccineLabel(String name) {
    return 'Наступна: $name';
  }

  @override
  String leftMinRightMin(int left, int right) {
    return 'Л $leftхв • П $rightхв';
  }

  @override
  String breastfeedingSavedSnack(int left, int right) {
    return '✅ Годування збережено: Л $leftхв, П $rightхв';
  }

  @override
  String sleepSavedSnack(String duration) {
    return '✅ Сон збережено: $duration';
  }

  @override
  String get sleepTooShort => '⚠️ Сон менше 1 хвилини, не збережено';

  @override
  String kgThisMonth(String value) {
    return '+$valueкг за місяць';
  }

  @override
  String cmThisMonth(String value) {
    return '+$valueсм за місяць';
  }

  @override
  String get noSleep => 'Немає сну';

  @override
  String get justNow => 'щойно';

  @override
  String minutesAgo(int count) {
    return '$count хв тому';
  }

  @override
  String hoursAgo(int count) {
    return '$countгод тому';
  }

  @override
  String daysAgo(int count) {
    return '$countд тому';
  }

  @override
  String get welcomeToNilico => 'Ласкаво просимо до Nilico';

  @override
  String get createYourAccount => 'Створіть акаунт';

  @override
  String get loginBenefitText =>
      'Увійдіть, щоб підготуватися до майбутніх функцій резервного копіювання та синхронізації. Можна продовжити без входу.';

  @override
  String get signInWithApple => 'Увійти через Apple';

  @override
  String get signInWithGoogle => 'Увійти через Google';

  @override
  String get continueWithoutLogin => 'Продовжити без входу';

  @override
  String get loginOptionalNote =>
      'Вхід необов\'язковий. Усі функції працюють без акаунту.';

  @override
  String get account => 'Акаунт';

  @override
  String get signIn => 'Увійти';

  @override
  String get signOut => 'Вийти';

  @override
  String signedInAs(String email) {
    return 'Ви увійшли як $email';
  }

  @override
  String get guestMode => 'Гостьовий режим';

  @override
  String get signInToProtectData => 'Увійдіть, щоб захистити дані';

  @override
  String get backupSyncComingSoon =>
      'Резервне копіювання та синхронізація незабаром';

  @override
  String get privacyPolicy => 'Політика конфіденційності';

  @override
  String get privacyPolicySubtitle => 'Переглянути політику конфіденційності';

  @override
  String get termsOfUse => 'Умови використання';

  @override
  String get termsOfUseSubtitle => 'Переглянути умови використання';

  @override
  String get pageCouldNotOpen => 'Не вдалося відкрити сторінку';

  @override
  String get health => 'Здоров\'я';

  @override
  String get medications => 'Ліки';

  @override
  String get noMedications => 'Ліків та добавок поки немає';

  @override
  String get medication => 'Ліки';

  @override
  String get supplement => 'Добавка';

  @override
  String get addMedication => 'Додати ліки';

  @override
  String get editMedication => 'Змінити ліки';

  @override
  String get medicationName => 'Назва';

  @override
  String get medicationNameRequired => 'Введіть назву';

  @override
  String get dosage => 'Дозування';

  @override
  String get schedule => 'Розклад';

  @override
  String get notes => 'Нотатки';

  @override
  String get language => 'Мова';

  @override
  String get systemDefault => 'Система';

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
  String get languageUpdated => 'Мову оновлено';
}
