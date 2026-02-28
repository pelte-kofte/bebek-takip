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
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
    );
    return '$_temp0';
  }

  @override
  String ageYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years года',
      many: '$years лет',
      few: '$years года',
      one: '$years год',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months месяца',
      many: '$months месяцев',
      few: '$months месяца',
      one: '$months месяц',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String ageMonthsDays(int months, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months месяца',
      many: '$months месяцев',
      few: '$months месяца',
      one: '$months месяц',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня',
      many: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
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

  @override
  String get tip_siyah_mekonyum_title => 'Первый стул';

  @override
  String get tip_siyah_mekonyum_desc =>
      'В первые 2-4 дня это нормально, независимо от того, получает малыш грудное молоко или смесь. Повода для тревоги нет.';

  @override
  String get tip_eye_tracking_title => 'Зрительное слежение';

  @override
  String get tip_eye_tracking_desc =>
      'Пока малыш чётко видит только на расстоянии около 25-30 см. Поднесите лицо ближе и медленно двигайтесь, чтобы он следил глазами.';

  @override
  String get tip_neck_support_title => 'Поддержка шеи';

  @override
  String get tip_neck_support_desc =>
      'Всегда поддерживайте голову и шею малыша, когда берёте его на руки. Мышцы шеи ещё очень слабые.';

  @override
  String get tip_reflex_stepping_title => 'Шаговый рефлекс';

  @override
  String get tip_reflex_stepping_desc =>
      'Держите малыша вертикально и дайте стопам коснуться ровной поверхности. Вы можете заметить шаговые движения.';

  @override
  String get tip_sound_interest_title => 'Интерес к звукам';

  @override
  String get tip_sound_interest_desc =>
      'Малыш очень чувствителен к звукам. Попробуйте привлечь его внимание мягкой погремушкой или спокойной музыкальной игрушкой.';

  @override
  String get tip_parent_interaction_title => 'Контакт с родителями';

  @override
  String get tip_parent_interaction_desc =>
      'Смотрите в глаза и говорите мягким голосом. Малыш узнаёт ваш голос и чувствует себя в безопасности.';

  @override
  String get tip_color_worlds_title => 'Мир цветов';

  @override
  String get tip_color_worlds_desc =>
      'Новорождённые лучше всего видят чёрно-белые контрасты. Попробуйте показывать карточки с такими узорами.';

  @override
  String get tip_mini_athlete_title => 'Маленький спортсмен';

  @override
  String get tip_mini_athlete_desc =>
      'Время на животике укрепляет мышцы шеи и спины. Пробуйте несколько минут каждый день.';

  @override
  String get tip_sound_hunter_title => 'Охотник за звуками';

  @override
  String get tip_sound_hunter_desc =>
      'Тихо щёлкните пальцами рядом с ушком малыша. Он может попытаться повернуть голову к звуку.';

  @override
  String get tip_touch_explore_title => 'Тактильное исследование';

  @override
  String get tip_touch_explore_desc =>
      'Дайте малышу почувствовать разные текстуры руками и стопами: мягкие, шероховатые и прохладные поверхности.';

  @override
  String get tip_agu_conversation_1_2_title => 'Baby Talk Chats';

  @override
  String get tip_agu_conversation_1_2_desc =>
      'When your baby makes sounds, listen. Reply gently when they finish. These tiny chats build communication.';

  @override
  String get tip_tummy_time_strength_1_2_title =>
      'Strong Shoulders (Tummy Time)';

  @override
  String get tip_tummy_time_strength_1_2_desc =>
      'Place your baby on their tummy for short periods. Encourage head lifting with colorful toys in front.';

  @override
  String get tip_baby_massage_1_2_title => 'Soothing Massage';

  @override
  String get tip_baby_massage_1_2_desc =>
      'After bath time, massage gently starting from the feet. It supports body awareness and helps your baby relax.';

  @override
  String get tip_gesture_speech_1_2_title => 'Gesture-Based Talking';

  @override
  String get tip_gesture_speech_1_2_desc =>
      'Use gestures while talking. Wave for \"we\'re going\" and rub hands for \"all done\". This supports visual memory.';

  @override
  String get tip_open_hands_1_2_title => 'Free Fingers';

  @override
  String get tip_open_hands_1_2_desc =>
      'Hands are opening more now. Offer soft toys to practice grasping and releasing.';

  @override
  String get tip_side_by_side_bonding_1_2_title => 'Side-by-Side Bonding';

  @override
  String get tip_side_by_side_bonding_1_2_desc =>
      'Lie side by side with your baby. Smile and speak lovingly as they try to turn toward you.';

  @override
  String get tip_sound_hunter_listening_title => 'Охотник за звуками';

  @override
  String get tip_sound_hunter_listening_desc =>
      'Тихо потрясите погремушкой там, где малыш её не видит. Поворот на звук развивает слух и концентрацию.';

  @override
  String get tip_sound_hunter_level2_1_2_title => 'Sound Hunter (Level 2)';

  @override
  String get tip_sound_hunter_level2_1_2_desc =>
      'Make different sounds from left and right. Finding the source strengthens attention skills.';

  @override
  String get tip_texture_discovery_1_2_title => 'Touch and Discover';

  @override
  String get tip_texture_discovery_1_2_desc =>
      'Offer objects with different textures. Each new feeling is a new discovery for your baby.';

  @override
  String get tip_outdoor_explorer_4_5_title => 'Outdoor Explorer';

  @override
  String get tip_outdoor_explorer_4_5_desc =>
      'Show trees and animals outside. Let your baby touch and explore while hearing your voice.';

  @override
  String get tip_reaching_exercise_1_2_title => 'Reaching Practice';

  @override
  String get tip_reaching_exercise_1_2_desc =>
      'Place toys within reach. Even attempts to grab them help strengthen muscles.';

  @override
  String get tip_supported_bounce_1_2_title => 'Supported Bouncing';

  @override
  String get tip_supported_bounce_1_2_desc =>
      'Hold your baby upright on your lap and let them bounce gently with support. It helps leg strength and exploration.';

  @override
  String get tip_visual_tracking_1_2_title => 'Visual Tracking';

  @override
  String get tip_visual_tracking_1_2_desc =>
      'Move a colorful sound-making toy in slow circles within view. Eye tracking is a great visual exercise.';

  @override
  String get tip_face_play_1_2_title => 'Face Play';

  @override
  String get tip_face_play_1_2_desc =>
      'Get close, make eye contact, and use playful facial expressions. Your voice and face are your baby\'s favorite toys.';

  @override
  String get tip_emotion_labeling_1_2_title => 'Emotion Naming';

  @override
  String get tip_emotion_labeling_1_2_desc =>
      'When your baby cries, name the feeling kindly and reassure them. Feeling understood helps emotional safety.';

  @override
  String get tip_first_meal_title => 'First Tasting';

  @override
  String get tip_first_meal_desc =>
      'Start solids based on your doctor\'s advice. Spoon feeding can be fun, but stay alert for allergy signs.';

  @override
  String get tip_hand_to_hand_transfer_4_5_title => 'Active Hands';

  @override
  String get tip_hand_to_hand_transfer_4_5_desc =>
      'Around months 4-5, babies try moving objects between hands. Offer easy-to-grasp items and observe.';

  @override
  String get tip_supported_sitting_4_5_title => 'Supported Sitting';

  @override
  String get tip_supported_sitting_4_5_desc =>
      'Practice supported sitting with pillows. Place a toy in front to motivate balance and upper-body support.';

  @override
  String get tip_feet_discovery_4_5_title => 'Discovering Feet';

  @override
  String get tip_feet_discovery_4_5_desc =>
      'Your baby may catch feet and bring them to the mouth while lying down. Let feet explore different surfaces.';

  @override
  String get tip_independent_play_4_5_title => 'Independent Play';

  @override
  String get tip_independent_play_4_5_desc =>
      'Place a few textured toys nearby and step back a little. Independent play supports confidence.';

  @override
  String ageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца',
      many: '$count месяцев',
      few: '$count месяца',
      one: '$count месяц',
    );
    return '$_temp0';
  }

  @override
  String get appPreferences => 'Настройки приложения';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get darkMode => 'Тёмный режим';

  @override
  String get darkModeSubtitle => 'Комфортная тёмная тема для глаз';

  @override
  String get notifications => 'Уведомления';

  @override
  String get feedingReminder => 'Напоминание о кормлении';

  @override
  String get diaperReminder => 'Напоминание о подгузнике';

  @override
  String get off => 'Выкл';

  @override
  String get reminderTime => 'Время напоминания';

  @override
  String get dataManagement => 'Управление данными';

  @override
  String get createReport => 'Создать отчёт';

  @override
  String get weeklyMonthlyStats => 'Недельная/месячная статистика';

  @override
  String get deleteAllDataTitle => 'Удалить все данные';

  @override
  String get deleteAllDataSubtitle => 'Удалить все записи безвозвратно';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get developer => 'Разработчик';

  @override
  String get deleteAllDataWarning =>
      'Это действие безвозвратно удалит все записи. Отменить нельзя.';

  @override
  String get debug => 'DEBUG';

  @override
  String get testSleepNotification => 'Тест уведомления о сне';

  @override
  String get fireSleepNotificationNow => 'Отправить уведомление о сне сейчас';

  @override
  String get testNursingNotification => 'Тест уведомления о кормлении';

  @override
  String get fireNursingNotificationNow =>
      'Отправить уведомление о кормлении сейчас';

  @override
  String get user => 'Пользователь';

  @override
  String get selectBaby => 'Выбрать малыша';

  @override
  String get newBabyAdd => 'Добавить нового малыша';

  @override
  String get babyProfileTitle => 'Профиль малыша';

  @override
  String get babyInformation => 'Информация о малыше';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get birthDateLabel => 'Дата рождения';

  @override
  String get notesOptional => 'Заметки (необязательно)';

  @override
  String get growthRecords => 'Записи роста';

  @override
  String get deleteThisBabyData => 'Удалить данные этого малыша';

  @override
  String get otherBabiesUnaffected => 'Другие дети не будут затронуты';

  @override
  String get onlyThisBabyPrefix => 'Будут удалены только все записи малыша ';

  @override
  String get allRecordsWillBeDeleted => '.';

  @override
  String get deleteActionIrreversible =>
      'Другие дети не будут затронуты. Это действие нельзя отменить.';

  @override
  String get birth => 'Рождение';

  @override
  String monthNumber(int month) {
    return '$month. мес.';
  }

  @override
  String get selectMonth => 'Выберите месяц';

  @override
  String get otherMonth => 'Другой месяц';

  @override
  String get period => 'Период';

  @override
  String get status => 'Статус';

  @override
  String get scheduledDate => 'Запланированная дата';

  @override
  String get editVaccine => 'Изменить вакцину';

  @override
  String get vaccineName => 'Название вакцины';

  @override
  String get allLabel => 'Все';

  @override
  String get routineFilter => 'Регулярно';

  @override
  String get asNeededFilter => 'По необходимости';

  @override
  String get vaccineProtocolsFilter => 'Протоколы вакцинации';

  @override
  String get everyDay => 'Every day';

  @override
  String get asNeeded => 'По необходимости';

  @override
  String get vaccineProtocolLabel => 'Протокол вакцинации';

  @override
  String linkedToVaccine(String vaccine) {
    return 'linked to $vaccine';
  }

  @override
  String get noVaccineLink => 'No linked vaccine';

  @override
  String doseCountLabel(int count) {
    return 'Зарегистрировано доз: $count';
  }

  @override
  String get logGivenNow => 'Отметить как дано';

  @override
  String get medicationDoseLogged => 'Dose logged';

  @override
  String get scheduleType => 'Тип схемы';

  @override
  String get dailySchedule => 'Ежедневно';

  @override
  String get prnSchedule => 'По необходимости';

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
  String get chooseExistingMedication => 'Выбрать существующее лекарство';

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

  @override
  String get time => 'Время';

  @override
  String get diaperWet => 'Мокрый';

  @override
  String get diaperDirty => 'Грязный';

  @override
  String get diaperBoth => 'Оба';

  @override
  String get eventTimeTooOld =>
      'Выбранное время должно быть в пределах последних 48 часов';

  @override
  String get editTitleFeeding => 'Изменить кормление';

  @override
  String get editTitleDiaper => 'Изменить подгузник';

  @override
  String get editTitleSleep => 'Изменить сон';

  @override
  String get editTitleNursing => 'Изменить грудное вскармливание';

  @override
  String get savedMessage => 'Сохранено';

  @override
  String get alreadySavedRecently => 'Уже сохранено только что';

  @override
  String get undo => 'Отменить';

  @override
  String get yesterday => 'Вчера';

  @override
  String get notGivenYet => 'Ещё не давали';

  @override
  String get viewHistory => 'История';

  @override
  String get noMedicationHistory => 'Нет истории приёма';

  @override
  String lastGivenLabel(String value) {
    return 'Последний приём: $value';
  }
}
