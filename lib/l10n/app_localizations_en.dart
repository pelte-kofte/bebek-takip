// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nilico';

  @override
  String get tagline => 'Parenting made simple & memorable.';

  @override
  String get freeForever => 'Offline First';

  @override
  String get instantStart => 'Start Instantly';

  @override
  String get securePrivate => 'Secure & Private';

  @override
  String get tapToStart => 'Tap to start';

  @override
  String get feedingTracker => 'Feeding Tracker';

  @override
  String get feedingTrackerDesc =>
      'Log nursing, bottles, and solids with ease. Spot patterns naturally.';

  @override
  String get sleepPatterns => 'Sleep Patterns';

  @override
  String get sleepPatternsDesc =>
      'Understand your baby\'s rhythm and improve sleep quality for everyone.';

  @override
  String get growthCharts => 'Growth Charts';

  @override
  String get growthChartsDesc =>
      'Visualize height and weight changes over time with beautiful charts.';

  @override
  String get preciousMemories => 'Precious Memories';

  @override
  String get preciousMemoriesDesc =>
      'Save milestones and funny moments. They grow up so fast!';

  @override
  String get dailyRhythm => 'Daily Rhythm';

  @override
  String get dailyRhythmDesc =>
      'Gentle routines bring calm days and peaceful nights.';

  @override
  String get skip => 'Skip';

  @override
  String get startYourJourney => 'Start Your Journey';

  @override
  String get continueBtn => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get ok => 'OK';

  @override
  String get add => 'Add';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get share => 'Share';

  @override
  String get mlAbbrev => 'ml';

  @override
  String get selectTime => 'Select time';

  @override
  String get tapToSetTime => 'Set time';

  @override
  String get notificationSleepFired => 'Sleep notification fired';

  @override
  String get notificationNursingFired => 'Nursing notification fired';

  @override
  String get signedOutSuccessfully => 'Signed out successfully';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get saveFailedTryAgain => 'Couldn\'t save. Please try again.';

  @override
  String get allDataDeleted => 'All data deleted';

  @override
  String googleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String signInFailed(String error) {
    return 'Sign in failed: $error';
  }

  @override
  String get webPhotoUploadUnsupported =>
      'Photo upload is not supported on web';

  @override
  String babyDataDeleted(String name) {
    return '$name data deleted';
  }

  @override
  String get babyNameHint => 'Baby name';

  @override
  String get babyNotesHint => 'Allergies, preferences, notes...';

  @override
  String get vaccineNameHint => 'e.g. Hepatitis B, BCG, combo vaccine';

  @override
  String get vaccineDoseHint => 'e.g. Dose 1, DTaP-IPV-Hib';

  @override
  String get vaccineNameCannotBeEmpty => 'Vaccine name cannot be empty';

  @override
  String get growthWeightHint => 'e.g. 7.5';

  @override
  String get growthHeightHint => 'e.g. 68.5';

  @override
  String get growthNotesHint => 'Doctor visit, vaccine day, etc.';

  @override
  String get pleaseEnterWeightHeight => 'Please enter weight and height';

  @override
  String get memoryTitleHint => 'e.g. First steps';

  @override
  String get memoryNoteHint => 'Write down the memory...';

  @override
  String get home => 'Home';

  @override
  String get activities => 'Care';

  @override
  String get vaccines => 'Vaccines';

  @override
  String get development => 'Development';

  @override
  String get memories => 'Memories';

  @override
  String get settings => 'Settings';

  @override
  String get addActivity => 'Add Activity';

  @override
  String get whatHappened => 'What happened?';

  @override
  String get nursing => 'Nursing';

  @override
  String get bottle => 'Feeding';

  @override
  String get sleep => 'Sleep';

  @override
  String get diaper => 'Diaper';

  @override
  String get side => 'Side';

  @override
  String get left => 'Left';

  @override
  String get right => 'Right';

  @override
  String get duration => 'Duration';

  @override
  String get minAbbrev => 'min';

  @override
  String get hourAbbrev => 'h';

  @override
  String get category => 'Category';

  @override
  String get milk => 'Milk';

  @override
  String get solid => 'Solid';

  @override
  String get whatWasGiven => 'WHAT WAS GIVEN?';

  @override
  String get solidFoodHint => 'E.g.: Banana puree, carrot...';

  @override
  String get amount => 'Amount';

  @override
  String get milkType => 'Milk Type';

  @override
  String get breastMilk => 'Breast milk';

  @override
  String get formula => 'Formula';

  @override
  String get sleepStartedAt => 'SLEEP STARTED AT';

  @override
  String get wokeUpAt => 'WOKE UP AT';

  @override
  String get tapToSet => 'Set time';

  @override
  String totalSleep(String duration) {
    return 'Total sleep: $duration';
  }

  @override
  String get type => 'Type';

  @override
  String get healthType => 'Type';

  @override
  String get healthTime => 'Time';

  @override
  String get wet => 'Wet';

  @override
  String get dirty => 'Dirty';

  @override
  String get both => 'Both';

  @override
  String get optionalNotes => 'Optional notes';

  @override
  String get diaperNoteHint => 'Add a note about the diaper change...';

  @override
  String get pleaseSetDuration => 'Please set a duration';

  @override
  String get pleaseSetAmount => 'Please set an amount';

  @override
  String get pleaseSetWakeUpTime => 'Please set wake up time';

  @override
  String get sleepDurationMustBeGreater =>
      'Sleep duration must be greater than 0';

  @override
  String get today => 'Today';

  @override
  String get summary => 'SUMMARY';

  @override
  String get recentActivities => 'RECENT CARE RECORDS';

  @override
  String get record => 'record';

  @override
  String get records => 'records';

  @override
  String get breastfeeding => 'Nursing';

  @override
  String get bottleBreastMilk => 'Bottle (Breast milk)';

  @override
  String get total => 'Total';

  @override
  String get diaperChange => 'Diaper change';

  @override
  String get firstFeedingTime => 'First feeding time?';

  @override
  String get trackBabyFeeding => 'Track your baby\'s feeding';

  @override
  String get diaperChangeTime => 'Diaper change time!';

  @override
  String get trackHygiene => 'Track hygiene here';

  @override
  String get sweetDreams => 'Sweet dreams...';

  @override
  String get trackSleepPattern => 'Track sleep pattern here';

  @override
  String get selectAnotherDate => 'Select another date';

  @override
  String get editFeeding => 'Edit Feeding';

  @override
  String get editDiaper => 'Edit Diaper';

  @override
  String get editSleep => 'Edit Sleep';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get attention => 'Attention';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this record?';

  @override
  String get myVaccines => 'My Vaccines';

  @override
  String get addVaccine => 'Add Vaccine';

  @override
  String get applied => 'Applied';

  @override
  String get pending => 'Pending';

  @override
  String get upcomingVaccines => 'Upcoming Vaccines';

  @override
  String get completedVaccines => 'Completed Vaccines';

  @override
  String get selectDate => 'Select date';

  @override
  String get calendar => 'Calendar';

  @override
  String get turkishVaccineCalendar => 'Turkish Vaccine Calendar';

  @override
  String vaccinesAvailable(int count) {
    return '$count vaccines available';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get clear => 'Clear';

  @override
  String get alreadyAdded => 'Already added';

  @override
  String addVaccines(int count) {
    return 'Add $count Vaccines';
  }

  @override
  String get selectVaccine => 'Select Vaccine';

  @override
  String vaccinesAdded(int count) {
    return '$count vaccines added';
  }

  @override
  String get noVaccineRecords => 'No vaccine records yet';

  @override
  String get loadTurkishCalendar =>
      'Load Turkish vaccine calendar or add manually';

  @override
  String get loadTurkishVaccineCalendar => 'Load Turkish Vaccine Calendar';

  @override
  String get loadCalendarTitle => 'Load Turkish Vaccine Calendar';

  @override
  String get loadCalendarDesc =>
      'The standard Turkish vaccine calendar will be loaded. Existing vaccines won\'t be deleted.';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years old',
      one: '$count year old',
    );
    return '$_temp0';
  }

  @override
  String ageYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years',
      one: '$years year',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months old',
      one: '$months month old',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String ageMonthsDays(int months, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '$months month',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days old',
      one: '$days day old',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days old',
      one: '$count day old',
    );
    return '$_temp0';
  }

  @override
  String get weeklyReport => 'Weekly Report';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get feeding => 'Feeding';

  @override
  String get totalBreastfeeding => 'Total Breastfeeding';

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get dailyAvg => 'Daily Avg.';

  @override
  String get avgDuration => 'Avg. Duration';

  @override
  String get leftBreast => 'Left Breast';

  @override
  String get rightBreast => 'Right Breast';

  @override
  String get solidFood => 'Solid Food';

  @override
  String get diaperChanges => 'Diaper Changes';

  @override
  String get longestSleep => 'Longest Sleep';

  @override
  String get sleepCount => 'Sleep Count';

  @override
  String get growth => 'Growth';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get saveAsPdf => 'Save as PDF';

  @override
  String get pdfMobileOnly => 'PDF sharing is available on mobile';

  @override
  String get sharingMobileOnly => 'Sharing is available on mobile';

  @override
  String get pdfSaved => 'PDF saved successfully!';

  @override
  String get babyTrackerReport => 'Baby Tracker Report';

  @override
  String get generatedWith => 'Generated with Baby Tracker App';

  @override
  String get months => 'months';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get addOptionalNote => 'Add note (optional)';

  @override
  String get times => 'times';

  @override
  String get feeding_tab => 'FEEDING';

  @override
  String get diaper_tab => 'DIAPER';

  @override
  String get sleep_tab => 'SLEEP';

  @override
  String get list => 'List';

  @override
  String get chart => 'Chart';

  @override
  String get noMeasurements => 'No measurements yet';

  @override
  String get addMeasurements => 'Add height and weight measurements';

  @override
  String get moreDataNeeded => 'More data needed for chart';

  @override
  String addMoreMeasurements(int count) {
    return 'Add $count more measurements';
  }

  @override
  String get atLeast2Measurements => 'At least 2 measurements needed for chart';

  @override
  String get growthTracking => 'Growth Tracking';

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
  String get feedingTimer => 'NURSING';

  @override
  String get sleepingTimer => 'SLEEPING';

  @override
  String get stopAndSave => 'STOP & SAVE';

  @override
  String get activeTimer => 'ACTIVE';

  @override
  String get lastFed => 'LAST FED';

  @override
  String get lastDiaper => 'LAST DIAPER';

  @override
  String get lastSleep => 'LAST SLEEP';

  @override
  String get recentActivity => 'RECENT CARE RECORDS';

  @override
  String get seeHistory => 'SEE HISTORY';

  @override
  String get noActivitiesLast24h => 'No activities in the last 24 hours';

  @override
  String get bottleFeeding => 'Feeding';

  @override
  String get trackYourBabyGrowth => 'Track your baby\'s growth';

  @override
  String get addHeightWeightMeasurements =>
      'Add weight and height measurements';

  @override
  String get addFirstMeasurement => 'Add first measurement';

  @override
  String get lastUpdatedToday => 'Last updated today';

  @override
  String get lastUpdated1Day => 'Last updated 1 day ago';

  @override
  String lastUpdatedDays(int days) {
    return 'Last updated $days days ago';
  }

  @override
  String get viewGrowthCharts => 'VIEW GROWTH CHARTS';

  @override
  String get weightLabel => 'WEIGHT';

  @override
  String get heightLabel => 'HEIGHT';

  @override
  String mAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hmAgo(int hours, int minutes) {
    return '${hours}h ${minutes}m ago';
  }

  @override
  String dAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String get dailyTip => 'DAILY TIP';

  @override
  String get dailyTipsTitle => 'Daily Tips';

  @override
  String get allTips => 'All tips';

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
  String get upcomingVaccine => 'UPCOMING VACCINE';

  @override
  String nextVaccineLabel(String name) {
    return 'Next: $name';
  }

  @override
  String leftMinRightMin(int left, int right) {
    return 'L ${left}min • R ${right}min';
  }

  @override
  String breastfeedingSavedSnack(int left, int right) {
    return '✅ Breastfeeding saved: L ${left}min, R ${right}min';
  }

  @override
  String sleepSavedSnack(String duration) {
    return '✅ Sleep saved: $duration';
  }

  @override
  String get sleepTooShort => '⚠️ Sleep under 1 minute, not saved';

  @override
  String kgThisMonth(String value) {
    return '+${value}kg this month';
  }

  @override
  String cmThisMonth(String value) {
    return '+${value}cm this month';
  }

  @override
  String get noSleep => 'No sleep';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get welcomeToNilico => 'Welcome to Nilico';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get loginBenefitText =>
      'Sign in to back up your baby data and sync across devices. You can also continue without an account for now.';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get continueWithoutLogin => 'Continue without login';

  @override
  String get loginOptionalNote => 'You can sign in later at any time.';

  @override
  String get account => 'Account';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get signInToProtectData => 'Sign in to protect your data';

  @override
  String get backupSyncComingSoon => 'Backup & sync coming soon';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'View privacy policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsOfUseSubtitle => 'View terms and conditions';

  @override
  String get pageCouldNotOpen => 'Could not open page';

  @override
  String get health => 'Health';

  @override
  String get medications => 'Medications';

  @override
  String get noMedications => 'No medications/supplements yet';

  @override
  String get medication => 'Medication';

  @override
  String get supplement => 'Supplement';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get medicationName => 'Name';

  @override
  String get medicationNameRequired => 'Please enter a name';

  @override
  String get dosage => 'Dosage';

  @override
  String get schedule => 'Schedule';

  @override
  String get notes => 'Notes';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System';

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
  String get languageUpdated => 'Language updated';

  @override
  String get tip_siyah_mekonyum_title => 'First Poop';

  @override
  String get tip_siyah_mekonyum_desc =>
      'In the first 2-4 days, this is normal whether your baby takes breast milk or formula. No need to worry.';

  @override
  String get tip_eye_tracking_title => 'Eye Tracking';

  @override
  String get tip_eye_tracking_desc =>
      'Your baby can clearly see only about 25-30 cm for now. Move your face slowly and let your baby follow with their eyes.';

  @override
  String get tip_neck_support_title => 'Neck Support';

  @override
  String get tip_neck_support_desc =>
      'Always support your baby\'s head and neck when holding them. Neck muscles are still very weak.';

  @override
  String get tip_reflex_stepping_title => 'Stepping Reflex';

  @override
  String get tip_reflex_stepping_desc =>
      'Hold your baby upright and let their feet touch a flat surface. You may see stepping reflexes.';

  @override
  String get tip_sound_interest_title => 'Interest in Sounds';

  @override
  String get tip_sound_interest_desc =>
      'Your baby is very sensitive to sounds. Try getting attention with a soft rattle or gentle music box.';

  @override
  String get tip_parent_interaction_title => 'Parent Interaction';

  @override
  String get tip_parent_interaction_desc =>
      'Make eye contact and talk softly. Your baby recognizes your voice and feels secure with it.';

  @override
  String get tip_color_worlds_title => 'World of Colors';

  @override
  String get tip_color_worlds_desc =>
      'Newborns see high-contrast black and white patterns best. Try showing black-and-white cards.';

  @override
  String get tip_mini_athlete_title => 'Mini Athlete';

  @override
  String get tip_mini_athlete_desc =>
      'Tummy time strengthens neck and back muscles. Try a few minutes each day.';

  @override
  String get tip_sound_hunter_title => 'Sound Hunter';

  @override
  String get tip_sound_hunter_desc =>
      'Snap softly near your baby\'s ear. They may try turning toward the sound.';

  @override
  String get tip_touch_explore_title => 'Touch Exploration';

  @override
  String get tip_touch_explore_desc =>
      'Let your baby feel different textures on hands and feet: soft, rough, and cool surfaces.';

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
  String get tip_sound_hunter_listening_title => 'Sound Hunter';

  @override
  String get tip_sound_hunter_listening_desc =>
      'Shake a rattle softly where your baby cannot see it. Turning toward sound builds hearing and focus.';

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
      other: '$count months old',
      one: '$count month old',
    );
    return '$_temp0';
  }

  @override
  String get appPreferences => 'App preferences';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'Comfortable low-light theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get feedingReminder => 'Feeding Reminder';

  @override
  String get diaperReminder => 'Diaper Reminder';

  @override
  String get off => 'Off';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get dataManagement => 'Data management';

  @override
  String get createReport => 'Create report';

  @override
  String get weeklyMonthlyStats => 'Weekly/Monthly insights';

  @override
  String get deleteAllDataTitle => 'Delete all data';

  @override
  String get deleteAllDataSubtitle => 'Permanently delete all records';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get deleteAllDataWarning =>
      'This action permanently deletes all records. This cannot be undone.';

  @override
  String get debug => 'Debug';

  @override
  String get testSleepNotification => 'Test Sleep Notification';

  @override
  String get fireSleepNotificationNow => 'Fire sleep notification now';

  @override
  String get testNursingNotification => 'Test Nursing Notification';

  @override
  String get fireNursingNotificationNow => 'Fire nursing notification now';

  @override
  String get user => 'User';

  @override
  String get selectBaby => 'Select Baby';

  @override
  String get newBabyAdd => 'Add New Baby';

  @override
  String get babyProfileTitle => 'Baby Profile';

  @override
  String get babyInformation => 'Baby Information';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get birthDateLabel => 'Birth Date';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get growthRecords => 'Growth Records';

  @override
  String get deleteThisBabyData => 'Delete this baby\'s data';

  @override
  String get otherBabiesUnaffected => 'Other babies are not affected';

  @override
  String get onlyThisBabyPrefix => 'Only ';

  @override
  String get allRecordsWillBeDeleted => ' baby\'s records will be deleted.';

  @override
  String get deleteActionIrreversible =>
      'Other babies are not affected. This action cannot be undone.';

  @override
  String get birth => 'Birth';

  @override
  String monthNumber(int month) {
    return '$month. Month';
  }

  @override
  String get selectMonth => 'Select month';

  @override
  String get otherMonth => 'Other month';

  @override
  String get period => 'Period';

  @override
  String get status => 'Status';

  @override
  String get scheduledDate => 'Scheduled Date';

  @override
  String get editVaccine => 'Edit Vaccine';

  @override
  String get vaccineName => 'Vaccine Name';

  @override
  String get allLabel => 'All';

  @override
  String get routineFilter => 'Routine';

  @override
  String get asNeededFilter => 'As-needed';

  @override
  String get vaccineProtocolsFilter => 'Vaccine protocols';

  @override
  String get everyDay => 'Every day';

  @override
  String get asNeeded => 'As needed';

  @override
  String get vaccineProtocolLabel => 'Vaccine protocol';

  @override
  String linkedToVaccine(String vaccine) {
    return 'linked to $vaccine';
  }

  @override
  String get noVaccineLink => 'No linked vaccine';

  @override
  String doseCountLabel(int count) {
    return 'Doses logged: $count';
  }

  @override
  String get logGivenNow => 'Log given now';

  @override
  String get logDose => 'Log dose';

  @override
  String get givenNow => 'Given now';

  @override
  String get allDoneToday => 'All done today';

  @override
  String get notAvailable => 'Not available';

  @override
  String get before => 'Before';

  @override
  String get after => 'After';

  @override
  String todayProgressLabel(int done, int total) {
    return 'Today: $done / $total doses';
  }

  @override
  String nextDoseLabel(String value) {
    return 'Next dose: $value';
  }

  @override
  String givenTodayCount(int count) {
    return 'Given today: $count';
  }

  @override
  String get medicationDoseLogged => 'Dose logged';

  @override
  String get scheduleType => 'Schedule type';

  @override
  String get dailySchedule => 'Daily';

  @override
  String get prnSchedule => 'As-needed';

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
  String get chooseExistingMedication => 'Choose existing medication';

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
  String get time => 'Time';

  @override
  String get diaperWet => 'Wet';

  @override
  String get diaperDirty => 'Dirty';

  @override
  String get diaperBoth => 'Both';

  @override
  String get eventTimeTooOld =>
      'Selected time must be within the last 48 hours';

  @override
  String get editTitleFeeding => 'Edit Feeding';

  @override
  String get editTitleDiaper => 'Edit Diaper';

  @override
  String get editTitleSleep => 'Edit Sleep';

  @override
  String get editTitleNursing => 'Edit Nursing';

  @override
  String get savedMessage => 'Saved';

  @override
  String get alreadySavedRecently => 'Already saved a moment ago';

  @override
  String get undo => 'Undo';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get notGivenYet => 'Not given yet';

  @override
  String get viewHistory => 'View history';

  @override
  String get noMedicationHistory => 'No given history';

  @override
  String lastGivenLabel(String value) {
    return 'Last given: $value';
  }
}
