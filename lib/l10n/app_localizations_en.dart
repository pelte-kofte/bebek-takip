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
  String get freeForever => 'Free Forever';

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
  String get time => 'Time';

  @override
  String get wet => 'Wet';

  @override
  String get dirty => 'Dirty';

  @override
  String get both => 'Both';

  @override
  String get diaperWet => 'Wet';

  @override
  String get diaperDirty => 'Dirty';

  @override
  String get diaperBoth => 'Both';

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
  String get eventTimeTooOld =>
      'Selected time must be within the last 48 hours';

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
  String get editTitleFeeding => 'Edit Feeding';

  @override
  String get editTitleDiaper => 'Edit Diaper';

  @override
  String get editTitleSleep => 'Edit Sleep';

  @override
  String get editTitleNursing => 'Edit Nursing';

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
  String get allTips => 'All tips';

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
    return 'âœ… Breastfeeding saved: L ${left}min, R ${right}min';
  }

  @override
  String sleepSavedSnack(String duration) {
    return 'âœ… Sleep saved: $duration';
  }

  @override
  String get sleepTooShort => 'âš ï¸ Sleep under 1 minute, not saved';

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
      'Sign in to prepare for backup and sync features coming soon. You can also continue without signing in.';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get continueWithoutLogin => 'Continue without login';

  @override
  String get loginOptionalNote =>
      'Login is optional. All features work without an account.';

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
  String get russian => 'Ğ ÑƒÑÑĞºĞ¸Ğ¹';

  @override
  String get ukrainian => 'Ğ£ĞºÑ€Ğ°Ñ—Ğ½ÑÑŒĞºĞ°';

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
  String get tip_tip_agu_conversation_1_2_title => 'Baby Talk Chats';

  @override
  String get tip_tip_agu_conversation_1_2_desc =>
      'When your baby makes sounds, listen. Reply gently when they finish. These tiny chats build communication.';

  @override
  String get tip_tip_tummy_time_strength_1_2_title =>
      'Strong Shoulders (Tummy Time)';

  @override
  String get tip_tip_tummy_time_strength_1_2_desc =>
      'Place your baby on their tummy for short periods. Encourage head lifting with colorful toys in front.';

  @override
  String get tip_tip_baby_massage_1_2_title => 'Soothing Massage';

  @override
  String get tip_tip_baby_massage_1_2_desc =>
      'After bath time, massage gently starting from the feet. It supports body awareness and helps your baby relax.';

  @override
  String get tip_tip_gesture_speech_1_2_title => 'Gesture-Based Talking';

  @override
  String get tip_tip_gesture_speech_1_2_desc =>
      'Use gestures while talking. Wave for \"we\'re going\" and rub hands for \"all done\". This supports visual memory.';

  @override
  String get tip_tip_open_hands_1_2_title => 'Free Fingers';

  @override
  String get tip_tip_open_hands_1_2_desc =>
      'Hands are opening more now. Offer soft toys to practice grasping and releasing.';

  @override
  String get tip_tip_side_by_side_bonding_1_2_title => 'Side-by-Side Bonding';

  @override
  String get tip_tip_side_by_side_bonding_1_2_desc =>
      'Lie side by side with your baby. Smile and speak lovingly as they try to turn toward you.';

  @override
  String get tip_tip_sound_hunter_title => 'Sound Hunter';

  @override
  String get tip_tip_sound_hunter_desc =>
      'Shake a rattle softly where your baby cannot see it. Turning toward sound builds hearing and focus.';

  @override
  String get tip_tip_sound_hunter_level2_1_2_title => 'Sound Hunter (Level 2)';

  @override
  String get tip_tip_sound_hunter_level2_1_2_desc =>
      'Make different sounds from left and right. Finding the source strengthens attention skills.';

  @override
  String get tip_tip_texture_discovery_1_2_title => 'Touch and Discover';

  @override
  String get tip_tip_texture_discovery_1_2_desc =>
      'Offer objects with different textures. Each new feeling is a new discovery for your baby.';

  @override
  String get tip_tip_outdoor_explorer_4_5_title => 'Outdoor Explorer';

  @override
  String get tip_tip_outdoor_explorer_4_5_desc =>
      'Show trees and animals outside. Let your baby touch and explore while hearing your voice.';

  @override
  String get tip_tip_reaching_exercise_1_2_title => 'Reaching Practice';

  @override
  String get tip_tip_reaching_exercise_1_2_desc =>
      'Place toys within reach. Even attempts to grab them help strengthen muscles.';

  @override
  String get tip_tip_supported_bounce_1_2_title => 'Supported Bouncing';

  @override
  String get tip_tip_supported_bounce_1_2_desc =>
      'Hold your baby upright on your lap and let them bounce gently with support. It helps leg strength and exploration.';

  @override
  String get tip_tip_visual_tracking_1_2_title => 'Visual Tracking';

  @override
  String get tip_tip_visual_tracking_1_2_desc =>
      'Move a colorful sound-making toy in slow circles within view. Eye tracking is a great visual exercise.';

  @override
  String get tip_tip_face_play_1_2_title => 'Face Play';

  @override
  String get tip_tip_face_play_1_2_desc =>
      'Get close, make eye contact, and use playful facial expressions. Your voice and face are your baby\'s favorite toys.';

  @override
  String get tip_tip_emotion_labeling_1_2_title => 'Emotion Naming';

  @override
  String get tip_tip_emotion_labeling_1_2_desc =>
      'When your baby cries, name the feeling kindly and reassure them. Feeling understood helps emotional safety.';

  @override
  String get tip_tip_first_meal_title => 'First Tasting';

  @override
  String get tip_tip_first_meal_desc =>
      'Start solids based on your doctor\'s advice. Spoon feeding can be fun, but stay alert for allergy signs.';

  @override
  String get tip_tip_hand_to_hand_transfer_4_5_title => 'Active Hands';

  @override
  String get tip_tip_hand_to_hand_transfer_4_5_desc =>
      'Around months 4-5, babies try moving objects between hands. Offer easy-to-grasp items and observe.';

  @override
  String get tip_tip_supported_sitting_4_5_title => 'Supported Sitting';

  @override
  String get tip_tip_supported_sitting_4_5_desc =>
      'Practice supported sitting with pillows. Place a toy in front to motivate balance and upper-body support.';

  @override
  String get tip_tip_feet_discovery_4_5_title => 'Discovering Feet';

  @override
  String get tip_tip_feet_discovery_4_5_desc =>
      'Your baby may catch feet and bring them to the mouth while lying down. Let feet explore different surfaces.';

  @override
  String get tip_tip_independent_play_4_5_title => 'Independent Play';

  @override
  String get tip_tip_independent_play_4_5_desc =>
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
  String get medicationDoseLogged => 'Dose logged';

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
  String medicationReminderBodyWithDose(String dose) {
    return 'Dose: $dose';
  }

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
}
