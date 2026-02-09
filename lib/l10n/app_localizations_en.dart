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
  String get category => 'CATEGORY';

  @override
  String get milk => 'Milk';

  @override
  String get solid => 'Solid';

  @override
  String get whatWasGiven => 'WHAT WAS GIVEN?';

  @override
  String get solidFoodHint => 'E.g.: Banana puree, carrot...';

  @override
  String get amount => 'AMOUNT';

  @override
  String get milkType => 'MILK TYPE';

  @override
  String get breastMilk => 'Breast milk';

  @override
  String get formula => 'Formula';

  @override
  String get sleepStartedAt => 'SLEEP STARTED AT';

  @override
  String get wokeUpAt => 'WOKE UP AT';

  @override
  String get tapToSet => 'Tap to set';

  @override
  String totalSleep(String duration) {
    return 'Total sleep: $duration';
  }

  @override
  String get type => 'TYPE';

  @override
  String get wet => 'Wet';

  @override
  String get dirty => 'Dirty';

  @override
  String get both => 'Both';

  @override
  String get optionalNotes => 'OPTIONAL NOTES';

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
  String get recentActivities => 'RECENT ACTIVITIES';

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
  String ageYears(int years) {
    return '$years Years Old';
  }

  @override
  String ageYearsMonths(int years, int months) {
    return '$years Year $months Months Old';
  }

  @override
  String ageMonthsDays(int months, int days) {
    return '$months Months $days Days Old';
  }

  @override
  String ageDays(int days) {
    return '$days Days Old';
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
  String get recentActivity => 'RECENT ACTIVITY';

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
}
