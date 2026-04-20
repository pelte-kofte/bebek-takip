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
  String get instantStart => 'Start Instantly';

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
  String get saveFailedTryAgain => 'Couldn\'t save. Please try again.';

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
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count року',
      many: '$count років',
      few: '$count роки',
      one: '$count рік',
    );
    return '$_temp0';
  }

  @override
  String ageYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years року',
      many: '$years років',
      few: '$years роки',
      one: '$years рік',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months місяця',
      many: '$months місяців',
      few: '$months місяці',
      one: '$months місяць',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String ageMonthsDays(int months, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months місяця',
      many: '$months місяців',
      few: '$months місяці',
      one: '$months місяць',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня',
      many: '$days днів',
      few: '$days дні',
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
      many: '$count днів',
      few: '$count дні',
      one: '$count день',
    );
    return '$_temp0';
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
  String get growthEntryTitle => 'Growth Record';

  @override
  String get growthEntrySubtitle => 'Track height and weight';

  @override
  String get growthDateField => 'DATE';

  @override
  String get growthWeightField => 'WEIGHT (kg)';

  @override
  String get growthHeightField => 'HEIGHT (cm)';

  @override
  String get growthNotesField => 'NOTES (Optional)';

  @override
  String get centimeterUnit => 'cm';

  @override
  String get kilogramUnit => 'kg';

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
  String get dailyTipsTitle => 'Daily Tips';

  @override
  String get allTips => 'Усі поради';

  @override
  String get tip_engelli_kosu_title => 'Obstacle Course (Crawling Edition)';

  @override
  String get tip_engelli_kosu_desc =>
      'Place small pillow or blanket obstacles on the floor. Getting over them to reach a toy helps build problem-solving skills.';

  @override
  String get tip_hafif_agir_title => 'Heavy or Light?';

  @override
  String get tip_hafif_agir_desc =>
      'Place a feather-light cloth in one hand and a heavier block in the other. Let your baby compare the feel, texture, and weight.';

  @override
  String get tip_beni_ismimle_cagir_title => 'Call Me by My Name';

  @override
  String get tip_beni_ismimle_cagir_desc =>
      'While your baby is looking away, softly say their name. Encourage them to turn toward you. Recognizing their name is a big milestone this month.';

  @override
  String get tip_su_ne_title => 'What\'s That? (Pointing)';

  @override
  String get tip_su_ne_desc =>
      'Point to different objects in the room and name them. Trying to point too shows your baby is exploring the world with you.';

  @override
  String get tip_komut_dinlemece_title => 'Listening Game';

  @override
  String get tip_komut_dinlemece_desc =>
      'Give simple one-step directions like \"Give me the ball\" or \"Look at me.\" This helps your baby connect words with actions.';

  @override
  String get tip_buyuk_yuruyus_title => 'The Big Walk';

  @override
  String get tip_buyuk_yuruyus_desc =>
      'Hold your baby\'s hands or use a safe push walker to encourage steps. Stay close as they practice balance and enjoy the excitement of early walking.';

  @override
  String get tip_duzenleme_saati_title => 'Tidy-Up Time';

  @override
  String get tip_duzenleme_saati_desc =>
      'Put scattered toys into a basket or box together. Say, \"Let\'s put it in the box!\" and encourage your baby to toss them in.';

  @override
  String get tip_emekleme_parkuru_title => 'Crawling Course';

  @override
  String get tip_emekleme_parkuru_desc =>
      'Make a small obstacle course with soft blankets and pillows. Place a favorite toy a little farther away and encourage your baby to crawl toward it.';

  @override
  String get tip_aynadaki_bebek_title => 'The Mysterious Baby in the Mirror';

  @override
  String get tip_aynadaki_bebek_desc =>
      'Sit your baby in front of a safe mirror. Let them watch their reflection and touch the mirror. Ask, \"Who is that?\" to support self-recognition and visual development.';

  @override
  String get tip_yuvarla_bakalim_title => 'Let\'s Roll It';

  @override
  String get tip_yuvarla_bakalim_desc =>
      'Sit on the floor facing each other and roll a soft ball back and forth. Encourage your baby to catch it and push it back to build hand-eye coordination.';

  @override
  String get tip_nesne_karsilastirma_title => 'Comparing Objects';

  @override
  String get tip_nesne_karsilastirma_desc =>
      'Place a soft toy in one hand and a hard block in the other. Give your baby time to notice differences in texture and weight.';

  @override
  String get tip_kucuk_okuyucu_title => 'Little Reader';

  @override
  String get tip_kucuk_okuyucu_desc =>
      'Look through sturdy board books together. Give your baby space to turn the pages, helping a little if needed, to support fine motor skills and curiosity.';

  @override
  String get tip_yercekimi_deneyi_title => 'Gravity Experiment';

  @override
  String get tip_yercekimi_deneyi_desc =>
      'When your baby drops a toy on purpose and waits for you to pick it up, that\'s a cause-and-effect game. Say, \"It fell!\" and join the discovery.';

  @override
  String get tip_adimadim_macera_title => 'First Step Excitement';

  @override
  String get tip_adimadim_macera_desc =>
      'Hold your baby securely under the arms and let their feet press into the floor. Gently guide them forward so they can feel the motion of walking.';

  @override
  String get tip_comert_bebek_title => 'Generous Baby';

  @override
  String get tip_comert_bebek_desc =>
      'Ask, \"Can you give it to me?\" and hold out your hand for the toy. Celebrate with a warm \"Thank you!\" when your baby shares it.';

  @override
  String get tip_yemek_zamani_title => 'Mealtime';

  @override
  String get tip_yemek_zamani_desc =>
      'Sit at the table together and enjoy the funniest little moments. Reaching for soft cooked vegetables helps build arm coordination and tiny motor movements.';

  @override
  String get tip_alkis_zamani_title => 'Clap Time';

  @override
  String get tip_alkis_zamani_desc =>
      'Clap along and encourage your baby to join in. Trying to copy the rhythm helps build attention and coordination.';

  @override
  String get tip_alo_kim_o_title => 'Hello, Who\'s There?';

  @override
  String get tip_alo_kim_o_desc =>
      'Hold a toy phone to your ear and make short pretend calls, then offer it to your baby. This playful role game supports sound imitation and social interaction.';

  @override
  String get tip_baybay_partisi_title => 'Bye-Bye Party';

  @override
  String get tip_baybay_partisi_desc =>
      'Wave and say \"bye-bye\" when someone leaves. Encourage your baby to wave too. Copying this simple gesture supports early communication.';

  @override
  String get tip_birak_izle_title => 'Drop and Watch';

  @override
  String get tip_birak_izle_desc =>
      'Let your baby drop a toy and watch where it goes together. Following the fall helps build cause-and-effect understanding.';

  @override
  String get tip_goster_bakalim_title => 'Show Me';

  @override
  String get tip_goster_bakalim_desc =>
      'Ask simple questions like \"Where is the ball?\" or \"Show me the light.\" Point first, then encourage your baby to look and point too.';

  @override
  String get tip_hazine_kutusu_title => 'Treasure Box';

  @override
  String get tip_hazine_kutusu_desc =>
      'Prepare a small box with safe household objects. Let your baby pull items out and inspect them. Each object becomes a new discovery.';

  @override
  String get tip_minik_kitap_kurdu_title => 'Little Bookworm';

  @override
  String get tip_minik_kitap_kurdu_desc =>
      'Flip through a sturdy board book together. Name the pictures and give your baby a chance to turn the pages too.';

  @override
  String get tip_mobilya_dagcilari_title => 'Furniture Climbers';

  @override
  String get tip_mobilya_dagcilari_desc =>
      'Support your baby\'s attempts to pull up on a sofa or another safe low surface. Climbing and holding on builds strength and balance.';

  @override
  String get tip_saksak_alkis_title => 'Clap-Clap Fun';

  @override
  String get tip_saksak_alkis_desc =>
      'Clap your hands with a happy rhythm. As your baby tries to copy you, they build rhythm awareness and two-handed coordination.';

  @override
  String get tip_sira_sende_title => 'Your Turn';

  @override
  String get tip_sira_sende_desc =>
      'Move a simple toy first, then hand it over and say, \"Your turn.\" It\'s an easy way to introduce turn-taking and back-and-forth play.';

  @override
  String get tip_veral_oyunu_title => 'Give-and-Take Game';

  @override
  String get tip_veral_oyunu_desc =>
      'Let your baby take a toy from you and offer it back. This simple exchange supports sharing and social connection.';

  @override
  String get tip_yuvarla_bekle_title => 'Roll and Wait';

  @override
  String get tip_yuvarla_bekle_desc =>
      'Roll a soft ball toward your baby and pause for their response. That brief wait helps them understand turn-taking and stay engaged.';

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

  @override
  String get tip_siyah_mekonyum_title => 'Перший кал';

  @override
  String get tip_siyah_mekonyum_desc =>
      'У перші 2-4 дні це нормально, незалежно від того, чи отримує малюк грудне молоко, чи суміш. Підстав для хвилювання немає.';

  @override
  String get tip_eye_tracking_title => 'Візуальне стеження';

  @override
  String get tip_eye_tracking_desc =>
      'Поки що малюк чітко бачить лише на відстані приблизно 25-30 см. Наблизьте обличчя й рухайтеся повільно, щоб він стежив очима.';

  @override
  String get tip_neck_support_title => 'Підтримка шиї';

  @override
  String get tip_neck_support_desc =>
      'Завжди підтримуйте голову й шию малюка, коли берете його на руки. М\'язи шиї ще дуже слабкі.';

  @override
  String get tip_reflex_stepping_title => 'Кроковий рефлекс';

  @override
  String get tip_reflex_stepping_desc =>
      'Тримайте малюка вертикально й дайте стопам торкнутися рівної поверхні. Ви можете помітити крокові рухи.';

  @override
  String get tip_sound_interest_title => 'Інтерес до звуків';

  @override
  String get tip_sound_interest_desc =>
      'Малюк дуже чутливий до звуків. Спробуйте привернути його увагу м\'якою брязкальцем або спокійною музичною іграшкою.';

  @override
  String get tip_parent_interaction_title => 'Взаємодія з батьками';

  @override
  String get tip_parent_interaction_desc =>
      'Встановлюйте зоровий контакт і говоріть лагідним голосом. Малюк впізнає ваш голос і почувається в безпеці.';

  @override
  String get tip_color_worlds_title => 'Світ кольорів';

  @override
  String get tip_color_worlds_desc =>
      'Новонароджені найкраще бачать чорно-білі контрасти. Можна показувати картки з такими візерунками.';

  @override
  String get tip_mini_athlete_title => 'Маленький спортсмен';

  @override
  String get tip_mini_athlete_desc =>
      'Час на животику зміцнює м\'язи шиї та спини. Спробуйте кілька хвилин щодня.';

  @override
  String get tip_sound_hunter_title => 'Мисливець за звуками';

  @override
  String get tip_sound_hunter_desc =>
      'Тихо клацніть пальцями біля вушка малюка. Він може спробувати повернути голову до звуку.';

  @override
  String get tip_touch_explore_title => 'Тактильне дослідження';

  @override
  String get tip_touch_explore_desc =>
      'Дайте малюкові відчути різні текстури руками й стопами: м\'які, шорсткі та прохолодні поверхні.';

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
  String get tip_sound_hunter_listening_title => 'Мисливець за звуками';

  @override
  String get tip_sound_hunter_listening_desc =>
      'Тихо потрясіть брязкальцем там, де малюк його не бачить. Поворот на звук розвиває слух і концентрацію.';

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
      other: '$count місяця',
      many: '$count місяців',
      few: '$count місяці',
      one: '$count місяць',
    );
    return '$_temp0';
  }

  @override
  String get appPreferences => 'Налаштування застосунку';

  @override
  String get appearance => 'Вигляд';

  @override
  String get darkMode => 'Темний режим';

  @override
  String get darkModeSubtitle => 'Комфортна темна тема для очей';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get feedingReminder => 'Нагадування про годування';

  @override
  String get diaperReminder => 'Нагадування про підгузок';

  @override
  String get off => 'Вимкнено';

  @override
  String get reminderTime => 'Час нагадування';

  @override
  String get dataManagement => 'Керування даними';

  @override
  String get createReport => 'Створити звіт';

  @override
  String get weeklyMonthlyStats => 'Тижнева/місячна статистика';

  @override
  String get deleteAllDataTitle => 'Видалити всі дані';

  @override
  String get deleteAllDataSubtitle => 'Назавжди видалити всі записи';

  @override
  String get about => 'Про застосунок';

  @override
  String get version => 'Версія';

  @override
  String get developer => 'Розробник';

  @override
  String get deleteAllDataWarning =>
      'Ця дія назавжди видалить усі записи. Скасувати неможливо.';

  @override
  String get debug => 'DEBUG';

  @override
  String get testSleepNotification => 'Тест сповіщення про сон';

  @override
  String get fireSleepNotificationNow => 'Надіслати сповіщення про сон зараз';

  @override
  String get testNursingNotification => 'Тест сповіщення про годування';

  @override
  String get fireNursingNotificationNow =>
      'Надіслати сповіщення про годування зараз';

  @override
  String get user => 'Користувач';

  @override
  String get selectBaby => 'Обрати малюка';

  @override
  String get newBabyAdd => 'Додати нового малюка';

  @override
  String get babyProfileTitle => 'Профіль малюка';

  @override
  String get babyInformation => 'Інформація про малюка';

  @override
  String get addPhoto => 'Додати фото';

  @override
  String get changePhoto => 'Змінити фото';

  @override
  String get removePhoto => 'Видалити фото';

  @override
  String get birthDateLabel => 'Дата народження';

  @override
  String get notesOptional => 'Нотатки (необов\'язково)';

  @override
  String get growthRecords => 'Записи росту';

  @override
  String get deleteThisBabyData => 'Видалити дані цього малюка';

  @override
  String get otherBabiesUnaffected => 'Інші діти не постраждають';

  @override
  String get onlyThisBabyPrefix => 'Будуть видалені лише всі записи малюка ';

  @override
  String get allRecordsWillBeDeleted => '.';

  @override
  String get deleteActionIrreversible =>
      'Інші діти не постраждають. Цю дію неможливо скасувати.';

  @override
  String get birth => 'Народження';

  @override
  String monthNumber(int month) {
    return '$month-й місяць';
  }

  @override
  String get selectMonth => 'Оберіть місяць';

  @override
  String get otherMonth => 'Інший місяць';

  @override
  String get period => 'Період';

  @override
  String get status => 'Статус';

  @override
  String get scheduledDate => 'Запланована дата';

  @override
  String get editVaccine => 'Редагувати вакцину';

  @override
  String get vaccineName => 'Назва вакцини';

  @override
  String get allLabel => 'Усі';

  @override
  String get routineFilter => 'Регулярно';

  @override
  String get asNeededFilter => 'За потреби';

  @override
  String get vaccineProtocolsFilter => 'Протоколи вакцинації';

  @override
  String get everyDay => 'Every day';

  @override
  String get asNeeded => 'За потреби';

  @override
  String get vaccineProtocolLabel => 'Протокол вакцинації';

  @override
  String linkedToVaccine(String vaccine) {
    return 'linked to $vaccine';
  }

  @override
  String get noVaccineLink => 'No linked vaccine';

  @override
  String doseCountLabel(int count) {
    return 'Зареєстровано доз: $count';
  }

  @override
  String get logGivenNow => 'Позначити як дано';

  @override
  String get logDose => 'Записати дозу';

  @override
  String get givenNow => 'Дати зараз';

  @override
  String get allDoneToday => 'На сьогодні все';

  @override
  String get notAvailable => 'Недоступно';

  @override
  String get before => 'До';

  @override
  String get after => 'Після';

  @override
  String todayProgressLabel(int done, int total) {
    return 'Сьогодні: $done / $total доз';
  }

  @override
  String nextDoseLabel(String value) {
    return 'Наступна доза: $value';
  }

  @override
  String givenTodayCount(int count) {
    return 'Дано сьогодні: $count';
  }

  @override
  String get medicationDoseLogged => 'Dose logged';

  @override
  String get scheduleType => 'Тип схеми';

  @override
  String get dailySchedule => 'Щодня';

  @override
  String get prnSchedule => 'За потреби';

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
  String get medicationSetRemindersTitle =>
      'Set reminders for this medication?';

  @override
  String get medicationSetRemindersBody =>
      'You can change this later by editing the medication.';

  @override
  String medicationReminderBodyWithDose(String dose) {
    return 'Dose: $dose';
  }

  @override
  String get notifFeedingTitle => '🍼 Feeding Reminder';

  @override
  String get notifFeedingBody => 'It\'s time to feed your baby';

  @override
  String get notifDiaperTitle => '👶 Diaper Reminder';

  @override
  String get notifDiaperBody => 'It\'s time to check your baby\'s diaper';

  @override
  String get notifSleepTitle => 'Sleep in progress';

  @override
  String get notifSleepBody => 'Tap the notification to stop';

  @override
  String get notifNursingTitle => 'Nursing in progress';

  @override
  String notifNursingTitleWithSide(String side) {
    return 'Nursing in progress ($side)';
  }

  @override
  String get notifNursingBody => 'Tap the notification to stop';

  @override
  String notifMedTitle(String name) {
    return '$name reminder';
  }

  @override
  String notifMedBody(String dose, String unit) {
    return 'Dose: $dose $unit';
  }

  @override
  String get notifGenericBody => 'Reminder time';

  @override
  String get addVaccineProtocol => 'Add vaccine protocol';

  @override
  String get createNew => 'Create new';

  @override
  String get chooseExistingMedication => 'Вибрати наявний препарат';

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
  String get time => 'Час';

  @override
  String get diaperWet => 'Мокрий';

  @override
  String get diaperDirty => 'Брудний';

  @override
  String get diaperBoth => 'Обидва';

  @override
  String get eventTimeTooOld =>
      'Вибраний час має бути в межах останніх 48 годин';

  @override
  String get editTitleFeeding => 'Змінити годування';

  @override
  String get editTitleDiaper => 'Змінити підгузок';

  @override
  String get editTitleSleep => 'Змінити сон';

  @override
  String get editTitleNursing => 'Змінити грудне вигодовування';

  @override
  String get savedMessage => 'Збережено';

  @override
  String get alreadySavedRecently => 'Вже щойно збережено';

  @override
  String get undo => 'Скасувати';

  @override
  String get yesterday => 'Вчора';

  @override
  String get notGivenYet => 'Ще не давали';

  @override
  String get viewHistory => 'Історія';

  @override
  String get noMedicationHistory => 'Немає історії прийому';

  @override
  String lastGivenLabel(String value) {
    return 'Останній прийом: $value';
  }

  @override
  String get close => 'Close';

  @override
  String get remove => 'Remove';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get genericErrorRetry => 'Something went wrong. Please try again.';

  @override
  String get babyFallbackName => 'Baby';

  @override
  String get todayBadge => 'TODAY';

  @override
  String get spTitle => 'Shared Parenting';

  @override
  String get spInviteDesc =>
      'Invite another parent to follow the same baby journey together.';

  @override
  String get spEmailLabel => 'Email address';

  @override
  String get spEmailHint => 'partner@example.com';

  @override
  String get spEnterEmail => 'Please enter an email address.';

  @override
  String get spNoActiveBaby => 'No active baby selected.';

  @override
  String spInvitePendingFor(String email) {
    return 'Invitation already pending for $email.';
  }

  @override
  String spInviteSentTo(String email) {
    return 'Invitation sent to $email.';
  }

  @override
  String get spPremiumRequired =>
      'You need a premium subscription to invite co-parents.';

  @override
  String get spBabyNotFound => 'Baby not found. Please try again.';

  @override
  String get spInvalidEmail => 'Please enter a valid email address.';

  @override
  String get spReceived => 'Received';

  @override
  String get spSentLabel => 'Sent';

  @override
  String get spInviteParentBtn => 'Invite Parent';

  @override
  String get spCoparents => 'Co-parents';

  @override
  String get spRemoveDialog => 'Remove co-parent?';

  @override
  String spRemoveContent(String name) {
    return '$name will lose access to this baby immediately.';
  }

  @override
  String get spCouldNotRemove => 'Could not remove member. Please try again.';

  @override
  String get spCoparent => 'Co-parent';

  @override
  String get spGateTitle => 'Share your baby\'s journey together';

  @override
  String get spGateBullet1 => 'Invite another parent';

  @override
  String get spGateBullet2 => 'Stay in sync on the same baby';

  @override
  String get spGateBullet3 => 'Keep updates shared in one place';

  @override
  String get spUnlockPremium => 'Unlock with Premium';

  @override
  String get spJoinWithCodeTitle => 'Join with code';

  @override
  String get spInviteCodeHint => 'Enter invite code';

  @override
  String get spJoinWithCodeBtn => 'Join Baby';

  @override
  String get spEnterInviteCode => 'Please enter an invite code.';

  @override
  String get spInviteCodeTitle => 'Invite code';

  @override
  String get spInviteCodeDesc =>
      'Create one secure code and share it with the other parent. The code links the baby to their signed-in account.';

  @override
  String get spCreateInviteCodeBtn => 'Create Invite Code';

  @override
  String spInviteCodeCreated(String code) {
    return 'Invite code created: $code';
  }

  @override
  String spInviteCodeReady(String code) {
    return 'Invite code is ready: $code';
  }

  @override
  String get spInviteCodeAccepted => 'Baby linked successfully.';

  @override
  String get spInviteCodeCopied => 'Invite code copied.';

  @override
  String get spCopyCode => 'Copy';

  @override
  String get spShareCode => 'Share';

  @override
  String get spInviteCodeNotFound => 'Invite code not found.';

  @override
  String get spInviteCodeExpired => 'This invite code has expired.';

  @override
  String get spInviteCodeUnavailable =>
      'This invite code is no longer available.';

  @override
  String get spInviteCodeActive => 'This code is active now.';

  @override
  String spInviteCodeExpires(String date) {
    return 'Expires $date';
  }

  @override
  String spInviteCodeShareMessage(String babyName, String code) {
    return 'Join $babyName with this invite code: $code';
  }

  @override
  String get invInboxTitle => 'Received Invitations';

  @override
  String get invAcceptedMsg => 'Invitation accepted.';

  @override
  String get invDeclinedMsg => 'Invitation declined.';

  @override
  String get invNotFound => 'Invitation not found.';

  @override
  String get invExpired => 'This invitation has expired.';

  @override
  String get invNotForYou => 'This invitation is not addressed to you.';

  @override
  String get invNoLongerPending => 'This invitation is no longer pending.';

  @override
  String get invLoadError => 'Could not load invitations. Please try again.';

  @override
  String get invNoneReceived => 'No invitations received';

  @override
  String invFromLabel(String name) {
    return 'from $name';
  }

  @override
  String get invStatusAccepted => 'Accepted';

  @override
  String get invStatusDeclined => 'Declined';

  @override
  String get invAcceptBtn => 'Accept';

  @override
  String get invDeclineBtn => 'Decline';

  @override
  String get sentInvTitle => 'Sent Invitations';

  @override
  String get sentInvCancelError =>
      'Could not cancel invitation. Please try again.';

  @override
  String get sentInvStatusPending => 'Pending';

  @override
  String get sentInvStatusAccepted => 'Accepted';

  @override
  String get sentInvStatusDeclined => 'Declined';

  @override
  String get sentInvLoadError => 'Could not load sent invitations.';

  @override
  String get sentInvNone => 'No invitations sent yet';

  @override
  String sentInvExpires(String date) {
    return 'Expires $date';
  }

  @override
  String get premiumSignInRequired => 'Please sign in to use premium features.';

  @override
  String get premiumIsActive => 'Premium is active.';

  @override
  String get premiumActiveDesc =>
      'You have full access to memory illustrations\nand all premium features.';

  @override
  String get premiumManageSubscription => 'Manage Subscription';

  @override
  String get premiumRestorePurchases => 'Restore Purchases';

  @override
  String get premiumNoPurchasesFound => 'No previous purchases found.';

  @override
  String get premiumRestoreFailed => 'Restore failed. Please try again.';

  @override
  String get illMemoryFeelsSpecial => 'This memory feels special.';

  @override
  String get illTurnMemoriesIntoArt => 'Turn memories into art';

  @override
  String get illPremiumDesc =>
      'Turn it into a soft illustration and keep it forever.\nSome memories deserve to be felt again.';

  @override
  String get illFreeDesc =>
      'Transform your baby\'s photos into beautiful soft illustrations.\nAvailable with Premium.';

  @override
  String get illCreateBtn => 'Create Illustration';

  @override
  String get illUpgradePremium => 'Upgrade to Premium';

  @override
  String get illCreatingTitle => 'Creating your illustration…';

  @override
  String get illCreatingDesc =>
      'This usually takes about a minute.\nWe’ll show it right here when it’s ready.';

  @override
  String get illDismiss => 'Dismiss — I’ll check back later';

  @override
  String get illReadyTitle => 'Your illustration is ready.';

  @override
  String get illReadySubtitle => 'A soft memory, kept forever.';

  @override
  String get illShareFamily => 'Share with family';

  @override
  String get illSomethingWrong => 'Something went wrong.';

  @override
  String get illOwnerOnlyTitle => 'Illustrations are owner-only';

  @override
  String get illOwnerOnlyDesc =>
      'Illustration generation is only available to the baby owner. Ask the owner to create one.';

  @override
  String get illGotIt => 'Got it';

  @override
  String get illUploadingPhoto =>
      'Your photo is still uploading. Please try again in a moment.';

  @override
  String get illTimeoutError =>
      'This photo took too long to generate.\nYour credit has been refunded — please try again.';

  @override
  String get illConnectionError =>
      'Could not connect to the illustration service. Please try again later.';

  @override
  String get illPurchaseError =>
      'Purchase could not be completed. Please try again.';

  @override
  String get illOutOfTitle => 'You’re out of illustrations';

  @override
  String get illOutOfDesc => 'Turn your memories into beautiful artwork.';

  @override
  String get illPackQuickLabel => 'Quick pack';

  @override
  String get illPackQuickSub => '3 illustrations';

  @override
  String get illPackBestLabel => 'Best value';

  @override
  String get illPackBestSub => '10 illustrations';

  @override
  String get illPackMostPopular => 'Most popular';

  @override
  String get illPackLoversLabel => 'For memory lovers';

  @override
  String get illPackLoversSub => '25 illustrations';

  @override
  String get illShareFallback => 'A special moment, illustrated.';

  @override
  String get memoryStyle => 'Memory style';

  @override
  String get memoryStyleOriginal => 'Original';

  @override
  String get memoryStyleClassic => 'Classic Illustration';

  @override
  String get memoryStyleLofi => 'Lo-Fi Illustration';

  @override
  String get medicationReminders => 'Medication reminders';

  @override
  String get enabled => 'Enabled';

  @override
  String get legalSection => 'Legal';

  @override
  String get deleteBabyBtn => 'Delete baby';

  @override
  String get deleteBabySubtitle => 'Remove baby profile and all baby records.';

  @override
  String get deleteBabyTitle => 'Delete baby?';

  @override
  String deleteBabyDialogContent(String babyName) {
    return 'This will remove $babyName and all related records from this device. If you are signed in, it will also delete synced data from your account. This cannot be undone.';
  }

  @override
  String get customRange => 'Custom';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get sharedBadge => 'Спільний';

  @override
  String get notificationsDisabled => 'Сповіщення вимкнено';

  @override
  String get permissionDenied => 'Дозвіл відхилено';

  @override
  String get reminderScheduled => 'Нагадування встановлено';

  @override
  String get signInToUseSharedParenting =>
      'Увійдіть, щоб використовувати спільне батьківство.';

  @override
  String get babyCouldNotBeDeleted => 'Не вдалося видалити дитину.';

  @override
  String get coParentLoggedActivity => 'Батько зафіксував активність.';

  @override
  String get sharedBabyUpdateTitle => 'Оновлення спільної дитини';

  @override
  String get allergiesTitle => 'Алергії';

  @override
  String get addAllergy => 'Додати алергію';

  @override
  String get allergySectionSubtitle =>
      'Keep sensitivities and food reactions together in one calm place.';

  @override
  String get noAllergiesSummary =>
      'No allergy notes yet. Add one anytime if something needs attention.';

  @override
  String get reportAllergy => 'Report allergy';

  @override
  String get allergySheetSubtitle =>
      'Add a food, ingredient, or reaction note so it stays visible in the health view.';

  @override
  String get allergyActive => 'Active';

  @override
  String get allergyInactive => 'Inactive';

  @override
  String get healthOverviewTitle => 'Today at a glance';

  @override
  String get healthOverviewSubtitle =>
      'A softer snapshot of care, sleep, and daily health details.';

  @override
  String get vaccineEmptySubtitle =>
      'Start with the national schedule or add a vaccine manually whenever you need one.';

  @override
  String get allergyName => 'Назва алергену';

  @override
  String get allergyNote => 'Нотатка (необов\'язково)';

  @override
  String get noAllergies => 'Алергії не записано';

  @override
  String get deleteAllergy => 'Видалити алергію';

  @override
  String get allergyAdded => 'Алергію додано';

  @override
  String get memoriesFilterAll => 'Усі';

  @override
  String get memoriesFilterPhotos => 'Фото';

  @override
  String get memoriesFilterIllustrated => 'Ілюстровані';

  @override
  String get memoriesEmptyFilter => 'Немає спогадів за цим фільтром';

  @override
  String get illBadgeReady => 'Проілюстровано';

  @override
  String get illBadgeGenerating => 'Генерується…';

  @override
  String get illTurnIntoIllustration => 'Перетворити на ілюстрацію';

  @override
  String get illNilicoStyle => 'Стиль Nilico';

  @override
  String get illLofiIllustration => 'Lo-Fi ілюстрація';

  @override
  String get buyIllustrations => 'Buy Illustrations';

  @override
  String get buyIllustrationsSubtitle =>
      'Illustration packs for extra memories';

  @override
  String get illustrationReady => 'Ready';

  @override
  String get illustrationGenerating => 'Generating';

  @override
  String get memoriesEmptyTitle => 'Save your favorite little moments';

  @override
  String get memoriesEmptySubtitle =>
      'Photos, notes, and milestones all stay together here.\nYour first memory can be just a tap away.';

  @override
  String get addFirstMemory => 'Add your first memory';
}
