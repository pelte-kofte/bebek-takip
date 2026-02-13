// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Nilico';

  @override
  String get tagline => 'Родительство — просто и незабываемо.';

  @override
  String get freeForever => 'Бесплатно навсегда';

  @override
  String get securePrivate => 'Безопасно и конфиденциально';

  @override
  String get tapToStart => 'Нажмите, чтобы начать';

  @override
  String get feedingTracker => 'Трекер кормлений';

  @override
  String get feedingTrackerDesc =>
      'Записывайте грудное вскармливание, бутылочки и прикорм. Замечайте закономерности.';

  @override
  String get sleepPatterns => 'Режим сна';

  @override
  String get sleepPatternsDesc =>
      'Изучайте ритм сна вашего малыша и улучшайте качество сна для всех.';

  @override
  String get growthCharts => 'Графики роста';

  @override
  String get growthChartsDesc =>
      'Наглядно отслеживайте изменения роста и веса с помощью красивых графиков.';

  @override
  String get preciousMemories => 'Драгоценные воспоминания';

  @override
  String get preciousMemoriesDesc =>
      'Сохраняйте важные моменты и забавные истории. Они так быстро растут!';

  @override
  String get dailyRhythm => 'Дневной ритм';

  @override
  String get dailyRhythmDesc =>
      'Мягкий режим дня приносит спокойные дни и тихие ночи.';

  @override
  String get skip => 'Пропустить';

  @override
  String get startYourJourney => 'Начните своё путешествие';

  @override
  String get continueBtn => 'Продолжить';

  @override
  String get save => 'Сохранить';

  @override
  String get update => 'Обновить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get ok => 'ОК';

  @override
  String get add => 'Добавить';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get share => 'Поделиться';

  @override
  String get mlAbbrev => 'мл';

  @override
  String get selectTime => 'Выберите время';

  @override
  String get tapToSetTime => 'Установить время';

  @override
  String get notificationSleepFired => 'Уведомление о сне отправлено';

  @override
  String get notificationNursingFired => 'Уведомление о кормлении отправлено';

  @override
  String get signedOutSuccessfully => 'Выход выполнен успешно';

  @override
  String errorWithMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get allDataDeleted => 'Все данные удалены';

  @override
  String googleSignInFailed(String error) {
    return 'Вход через Google не удался: $error';
  }

  @override
  String signInFailed(String error) {
    return 'Не удалось войти: $error';
  }

  @override
  String get webPhotoUploadUnsupported =>
      'Загрузка фото не поддерживается в веб-версии';

  @override
  String babyDataDeleted(String name) {
    return 'Данные $name удалены';
  }

  @override
  String get babyNameHint => 'Имя малыша';

  @override
  String get babyNotesHint => 'Аллергии, предпочтения, заметки...';

  @override
  String get vaccineNameHint => 'напр. Гепатит B, БЦЖ, комбинированная вакцина';

  @override
  String get vaccineDoseHint => 'напр. Доза 1, АКДС-ИПВ-ХИБ';

  @override
  String get vaccineNameCannotBeEmpty =>
      'Название вакцины не может быть пустым';

  @override
  String get growthWeightHint => 'напр. 7,5';

  @override
  String get growthHeightHint => 'напр. 68,5';

  @override
  String get growthNotesHint => 'Визит к врачу, день вакцинации и т.д.';

  @override
  String get pleaseEnterWeightHeight => 'Введите вес и рост';

  @override
  String get memoryTitleHint => 'напр. Первые шаги';

  @override
  String get memoryNoteHint => 'Запишите воспоминание...';

  @override
  String get home => 'Главная';

  @override
  String get activities => 'Уход';

  @override
  String get vaccines => 'Вакцины';

  @override
  String get development => 'Развитие';

  @override
  String get memories => 'Воспоминания';

  @override
  String get settings => 'Настройки';

  @override
  String get addActivity => 'Добавить запись';

  @override
  String get whatHappened => 'Что произошло?';

  @override
  String get nursing => 'Грудное вскармливание';

  @override
  String get bottle => 'Кормление';

  @override
  String get sleep => 'Сон';

  @override
  String get diaper => 'Подгузник';

  @override
  String get side => 'Сторона';

  @override
  String get left => 'Левая';

  @override
  String get right => 'Правая';

  @override
  String get duration => 'Длительность';

  @override
  String get minAbbrev => 'мин';

  @override
  String get hourAbbrev => 'ч';

  @override
  String get category => 'Категория';

  @override
  String get milk => 'Молоко';

  @override
  String get solid => 'Прикорм';

  @override
  String get whatWasGiven => 'ЧТО ДАВАЛИ?';

  @override
  String get solidFoodHint => 'Напр.: банановое пюре, морковь...';

  @override
  String get amount => 'Количество';

  @override
  String get milkType => 'Тип молока';

  @override
  String get breastMilk => 'Грудное молоко';

  @override
  String get formula => 'Смесь';

  @override
  String get sleepStartedAt => 'СОН НАЧАЛСЯ В';

  @override
  String get wokeUpAt => 'ПРОСНУЛСЯ В';

  @override
  String get tapToSet => 'Установить время';

  @override
  String totalSleep(String duration) {
    return 'Общий сон: $duration';
  }

  @override
  String get type => 'Тип';

  @override
  String get healthType => 'Тип';

  @override
  String get healthTime => 'Время';

  @override
  String get wet => 'Мокрый';

  @override
  String get dirty => 'Грязный';

  @override
  String get both => 'Оба';

  @override
  String get optionalNotes => 'Заметки (необязательно)';

  @override
  String get diaperNoteHint => 'Добавьте заметку о смене подгузника...';

  @override
  String get pleaseSetDuration => 'Укажите длительность';

  @override
  String get pleaseSetAmount => 'Укажите количество';

  @override
  String get pleaseSetWakeUpTime => 'Укажите время пробуждения';

  @override
  String get sleepDurationMustBeGreater =>
      'Длительность сна должна быть больше 0';

  @override
  String get today => 'Сегодня';

  @override
  String get summary => 'СВОДКА';

  @override
  String get recentActivities => 'НЕДАВНИЕ ЗАПИСИ УХОДА';

  @override
  String get record => 'запись';

  @override
  String get records => 'записей';

  @override
  String get breastfeeding => 'Грудное вскармливание';

  @override
  String get bottleBreastMilk => 'Бутылочка (грудное молоко)';

  @override
  String get total => 'Всего';

  @override
  String get diaperChange => 'Смена подгузника';

  @override
  String get firstFeedingTime => 'Время первого кормления?';

  @override
  String get trackBabyFeeding => 'Отслеживайте кормление малыша';

  @override
  String get diaperChangeTime => 'Время сменить подгузник!';

  @override
  String get trackHygiene => 'Отслеживайте гигиену здесь';

  @override
  String get sweetDreams => 'Сладких снов...';

  @override
  String get trackSleepPattern => 'Отслеживайте режим сна здесь';

  @override
  String get selectAnotherDate => 'Выберите другую дату';

  @override
  String get editFeeding => 'Изменить кормление';

  @override
  String get editDiaper => 'Изменить подгузник';

  @override
  String get editSleep => 'Изменить сон';

  @override
  String get start => 'Начало';

  @override
  String get end => 'Конец';

  @override
  String get attention => 'Внимание';

  @override
  String get deleteConfirm => 'Вы уверены, что хотите удалить эту запись?';

  @override
  String get myVaccines => 'Мои вакцины';

  @override
  String get addVaccine => 'Добавить вакцину';

  @override
  String get applied => 'Сделано';

  @override
  String get pending => 'Ожидается';

  @override
  String get upcomingVaccines => 'Предстоящие вакцины';

  @override
  String get completedVaccines => 'Сделанные вакцины';

  @override
  String get selectDate => 'Выберите дату';

  @override
  String get calendar => 'Календарь';

  @override
  String get turkishVaccineCalendar => 'Турецкий календарь вакцинации';

  @override
  String vaccinesAvailable(int count) {
    return '$count вакцин доступно';
  }

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get clear => 'Очистить';

  @override
  String get alreadyAdded => 'Уже добавлено';

  @override
  String addVaccines(int count) {
    return 'Добавить $count вакцин';
  }

  @override
  String get selectVaccine => 'Выберите вакцину';

  @override
  String vaccinesAdded(int count) {
    return '$count вакцин добавлено';
  }

  @override
  String get noVaccineRecords => 'Записей о вакцинах пока нет';

  @override
  String get loadTurkishCalendar =>
      'Загрузите турецкий календарь или добавьте вручную';

  @override
  String get loadTurkishVaccineCalendar =>
      'Загрузить турецкий календарь вакцинации';

  @override
  String get loadCalendarTitle => 'Загрузить турецкий календарь вакцинации';

  @override
  String get loadCalendarDesc =>
      'Будет загружен стандартный турецкий календарь вакцинации. Существующие вакцины не будут удалены.';

  @override
  String ageYears(int years) {
    return '$years лет';
  }

  @override
  String ageYearsMonths(int years, int months) {
    return '$years год $months мес.';
  }

  @override
  String ageMonthsDays(int months, int days) {
    return '$months мес. $days дн.';
  }

  @override
  String ageDays(int days) {
    return '$days дн.';
  }

  @override
  String get weeklyReport => 'Недельный отчёт';

  @override
  String get monthlyReport => 'Месячный отчёт';

  @override
  String get weekly => 'Неделя';

  @override
  String get monthly => 'Месяц';

  @override
  String get feeding => 'Кормление';

  @override
  String get totalBreastfeeding => 'Всего грудного вскармливания';

  @override
  String get totalDuration => 'Общая длительность';

  @override
  String get dailyAvg => 'Сред. в день';

  @override
  String get avgDuration => 'Сред. длительность';

  @override
  String get leftBreast => 'Левая грудь';

  @override
  String get rightBreast => 'Правая грудь';

  @override
  String get solidFood => 'Прикорм';

  @override
  String get diaperChanges => 'Смены подгузников';

  @override
  String get longestSleep => 'Самый долгий сон';

  @override
  String get sleepCount => 'Кол-во снов';

  @override
  String get growth => 'Рост';

  @override
  String get height => 'Рост';

  @override
  String get weight => 'Вес';

  @override
  String get saveAsPdf => 'Сохранить как PDF';

  @override
  String get pdfMobileOnly => 'Сохранение PDF доступно на мобильном';

  @override
  String get sharingMobileOnly => 'Поделиться можно на мобильном';

  @override
  String get pdfSaved => 'PDF успешно сохранён!';

  @override
  String get babyTrackerReport => 'Отчёт трекера малыша';

  @override
  String get generatedWith => 'Создано с помощью Baby Tracker App';

  @override
  String get months => 'мес.';

  @override
  String get january => 'Январь';

  @override
  String get february => 'Февраль';

  @override
  String get march => 'Март';

  @override
  String get april => 'Апрель';

  @override
  String get may => 'Май';

  @override
  String get june => 'Июнь';

  @override
  String get july => 'Июль';

  @override
  String get august => 'Август';

  @override
  String get september => 'Сентябрь';

  @override
  String get october => 'Октябрь';

  @override
  String get november => 'Ноябрь';

  @override
  String get december => 'Декабрь';

  @override
  String get addOptionalNote => 'Добавить заметку (необязательно)';

  @override
  String get times => 'раз';

  @override
  String get feeding_tab => 'КОРМЛЕНИЕ';

  @override
  String get diaper_tab => 'ПОДГУЗНИК';

  @override
  String get sleep_tab => 'СОН';

  @override
  String get list => 'Список';

  @override
  String get chart => 'График';

  @override
  String get noMeasurements => 'Измерений пока нет';

  @override
  String get addMeasurements => 'Добавьте измерения роста и веса';

  @override
  String get moreDataNeeded => 'Нужно больше данных для графика';

  @override
  String addMoreMeasurements(int count) {
    return 'Добавьте ещё $count измерений';
  }

  @override
  String get atLeast2Measurements => 'Для графика нужно минимум 2 измерения';

  @override
  String get growthTracking => 'Отслеживание роста';

  @override
  String get feedingTimer => 'КОРМЛЕНИЕ';

  @override
  String get sleepingTimer => 'СОН';

  @override
  String get stopAndSave => 'СТОП И СОХРАНИТЬ';

  @override
  String get activeTimer => 'АКТИВЕН';

  @override
  String get lastFed => 'ПОСЛ. КОРМЛЕНИЕ';

  @override
  String get lastDiaper => 'ПОСЛ. ПОДГУЗНИК';

  @override
  String get lastSleep => 'ПОСЛ. СОН';

  @override
  String get recentActivity => 'НЕДАВНИЕ ЗАПИСИ УХОДА';

  @override
  String get seeHistory => 'ИСТОРИЯ';

  @override
  String get noActivitiesLast24h => 'Нет активности за последние 24 часа';

  @override
  String get bottleFeeding => 'Кормление';

  @override
  String get trackYourBabyGrowth => 'Отслеживайте рост малыша';

  @override
  String get addHeightWeightMeasurements => 'Добавьте измерения веса и роста';

  @override
  String get addFirstMeasurement => 'Добавить первое измерение';

  @override
  String get lastUpdatedToday => 'Обновлено сегодня';

  @override
  String get lastUpdated1Day => 'Обновлено 1 день назад';

  @override
  String lastUpdatedDays(int days) {
    return 'Обновлено $days дн. назад';
  }

  @override
  String get viewGrowthCharts => 'ГРАФИКИ РОСТА';

  @override
  String get weightLabel => 'ВЕС';

  @override
  String get heightLabel => 'РОСТ';

  @override
  String mAgo(int count) {
    return '$count мин назад';
  }

  @override
  String hmAgo(int hours, int minutes) {
    return '$hoursч $minutesмин назад';
  }

  @override
  String dAgo(int days) {
    return '$daysд назад';
  }

  @override
  String get noRecordsYet => 'Записей пока нет';

  @override
  String get dailyTip => 'СОВЕТ ДНЯ';

  @override
  String get allTips => 'Все советы';

  @override
  String get upcomingVaccine => 'ПРЕДСТОЯЩАЯ ВАКЦИНА';

  @override
  String nextVaccineLabel(String name) {
    return 'Следующая: $name';
  }

  @override
  String leftMinRightMin(int left, int right) {
    return 'Л $leftмин • П $rightмин';
  }

  @override
  String breastfeedingSavedSnack(int left, int right) {
    return '✅ Кормление сохранено: Л $leftмин, П $rightмин';
  }

  @override
  String sleepSavedSnack(String duration) {
    return '✅ Сон сохранён: $duration';
  }

  @override
  String get sleepTooShort => '⚠️ Сон менее 1 минуты, не сохранён';

  @override
  String kgThisMonth(String value) {
    return '+$valueкг за месяц';
  }

  @override
  String cmThisMonth(String value) {
    return '+$valueсм за месяц';
  }

  @override
  String get noSleep => 'Нет сна';

  @override
  String get justNow => 'только что';

  @override
  String minutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String hoursAgo(int count) {
    return '$countч назад';
  }

  @override
  String daysAgo(int count) {
    return '$countд назад';
  }

  @override
  String get welcomeToNilico => 'Добро пожаловать в Nilico';

  @override
  String get createYourAccount => 'Создайте аккаунт';

  @override
  String get loginBenefitText =>
      'Войдите, чтобы подготовиться к будущим функциям резервного копирования и синхронизации. Можно продолжить без входа.';

  @override
  String get signInWithApple => 'Войти через Apple';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get continueWithoutLogin => 'Продолжить без входа';

  @override
  String get loginOptionalNote =>
      'Вход необязателен. Все функции работают без аккаунта.';

  @override
  String get account => 'Аккаунт';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String signedInAs(String email) {
    return 'Вы вошли как $email';
  }

  @override
  String get guestMode => 'Гостевой режим';

  @override
  String get signInToProtectData => 'Войдите, чтобы защитить данные';

  @override
  String get backupSyncComingSoon =>
      'Резервное копирование и синхронизация скоро';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyPolicySubtitle => 'Просмотреть политику конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get termsOfUseSubtitle => 'Просмотреть условия использования';

  @override
  String get pageCouldNotOpen => 'Не удалось открыть страницу';

  @override
  String get health => 'Здоровье';

  @override
  String get medications => 'Лекарства';

  @override
  String get noMedications => 'Лекарств и добавок пока нет';

  @override
  String get medication => 'Лекарство';

  @override
  String get supplement => 'Добавка';

  @override
  String get addMedication => 'Добавить лекарство';

  @override
  String get editMedication => 'Изменить лекарство';

  @override
  String get medicationName => 'Название';

  @override
  String get medicationNameRequired => 'Введите название';

  @override
  String get dosage => 'Дозировка';

  @override
  String get schedule => 'Расписание';

  @override
  String get notes => 'Заметки';

  @override
  String get language => 'Язык';

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
  String get languageUpdated => 'Язык обновлён';
}
