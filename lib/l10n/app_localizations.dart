import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nilico'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Parenting made simple & memorable.'**
  String get tagline;

  /// No description provided for @freeForever.
  ///
  /// In en, this message translates to:
  /// **'Free Forever'**
  String get freeForever;

  /// No description provided for @securePrivate.
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get securePrivate;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get tapToStart;

  /// No description provided for @feedingTracker.
  ///
  /// In en, this message translates to:
  /// **'Feeding Tracker'**
  String get feedingTracker;

  /// No description provided for @feedingTrackerDesc.
  ///
  /// In en, this message translates to:
  /// **'Log nursing, bottles, and solids with ease. Spot patterns naturally.'**
  String get feedingTrackerDesc;

  /// No description provided for @sleepPatterns.
  ///
  /// In en, this message translates to:
  /// **'Sleep Patterns'**
  String get sleepPatterns;

  /// No description provided for @sleepPatternsDesc.
  ///
  /// In en, this message translates to:
  /// **'Understand your baby\'s rhythm and improve sleep quality for everyone.'**
  String get sleepPatternsDesc;

  /// No description provided for @growthCharts.
  ///
  /// In en, this message translates to:
  /// **'Growth Charts'**
  String get growthCharts;

  /// No description provided for @growthChartsDesc.
  ///
  /// In en, this message translates to:
  /// **'Visualize height and weight changes over time with beautiful charts.'**
  String get growthChartsDesc;

  /// No description provided for @preciousMemories.
  ///
  /// In en, this message translates to:
  /// **'Precious Memories'**
  String get preciousMemories;

  /// No description provided for @preciousMemoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Save milestones and funny moments. They grow up so fast!'**
  String get preciousMemoriesDesc;

  /// No description provided for @dailyRhythm.
  ///
  /// In en, this message translates to:
  /// **'Daily Rhythm'**
  String get dailyRhythm;

  /// No description provided for @dailyRhythmDesc.
  ///
  /// In en, this message translates to:
  /// **'Gentle routines bring calm days and peaceful nights.'**
  String get dailyRhythmDesc;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get startYourJourney;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @mlAbbrev.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get mlAbbrev;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @tapToSetTime.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get tapToSetTime;

  /// No description provided for @notificationSleepFired.
  ///
  /// In en, this message translates to:
  /// **'Sleep notification fired'**
  String get notificationSleepFired;

  /// No description provided for @notificationNursingFired.
  ///
  /// In en, this message translates to:
  /// **'Nursing notification fired'**
  String get notificationNursingFired;

  /// No description provided for @signedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOutSuccessfully;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get allDataDeleted;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String googleSignInFailed(String error);

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed: {error}'**
  String signInFailed(String error);

  /// No description provided for @webPhotoUploadUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Photo upload is not supported on web'**
  String get webPhotoUploadUnsupported;

  /// No description provided for @babyDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} data deleted'**
  String babyDataDeleted(String name);

  /// No description provided for @babyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Baby name'**
  String get babyNameHint;

  /// No description provided for @babyNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Allergies, preferences, notes...'**
  String get babyNotesHint;

  /// No description provided for @vaccineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hepatitis B, BCG, combo vaccine'**
  String get vaccineNameHint;

  /// No description provided for @vaccineDoseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dose 1, DTaP-IPV-Hib'**
  String get vaccineDoseHint;

  /// No description provided for @vaccineNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Vaccine name cannot be empty'**
  String get vaccineNameCannotBeEmpty;

  /// No description provided for @growthWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 7.5'**
  String get growthWeightHint;

  /// No description provided for @growthHeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 68.5'**
  String get growthHeightHint;

  /// No description provided for @growthNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit, vaccine day, etc.'**
  String get growthNotesHint;

  /// No description provided for @pleaseEnterWeightHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight and height'**
  String get pleaseEnterWeightHeight;

  /// No description provided for @memoryTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. First steps'**
  String get memoryTitleHint;

  /// No description provided for @memoryNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write down the memory...'**
  String get memoryNoteHint;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get activities;

  /// No description provided for @vaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get vaccines;

  /// No description provided for @development.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get development;

  /// No description provided for @memories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add Activity'**
  String get addActivity;

  /// No description provided for @whatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get whatHappened;

  /// No description provided for @nursing.
  ///
  /// In en, this message translates to:
  /// **'Nursing'**
  String get nursing;

  /// No description provided for @bottle.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get bottle;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @diaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaper;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @minAbbrev.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minAbbrev;

  /// No description provided for @hourAbbrev.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourAbbrev;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @solid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get solid;

  /// No description provided for @whatWasGiven.
  ///
  /// In en, this message translates to:
  /// **'WHAT WAS GIVEN?'**
  String get whatWasGiven;

  /// No description provided for @solidFoodHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Banana puree, carrot...'**
  String get solidFoodHint;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @milkType.
  ///
  /// In en, this message translates to:
  /// **'Milk Type'**
  String get milkType;

  /// No description provided for @breastMilk.
  ///
  /// In en, this message translates to:
  /// **'Breast milk'**
  String get breastMilk;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// No description provided for @sleepStartedAt.
  ///
  /// In en, this message translates to:
  /// **'SLEEP STARTED AT'**
  String get sleepStartedAt;

  /// No description provided for @wokeUpAt.
  ///
  /// In en, this message translates to:
  /// **'WOKE UP AT'**
  String get wokeUpAt;

  /// No description provided for @tapToSet.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get tapToSet;

  /// No description provided for @totalSleep.
  ///
  /// In en, this message translates to:
  /// **'Total sleep: {duration}'**
  String totalSleep(String duration);

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @healthType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get healthType;

  /// No description provided for @healthTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get healthTime;

  /// No description provided for @wet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wet;

  /// No description provided for @dirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get dirty;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get optionalNotes;

  /// No description provided for @diaperNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note about the diaper change...'**
  String get diaperNoteHint;

  /// No description provided for @pleaseSetDuration.
  ///
  /// In en, this message translates to:
  /// **'Please set a duration'**
  String get pleaseSetDuration;

  /// No description provided for @pleaseSetAmount.
  ///
  /// In en, this message translates to:
  /// **'Please set an amount'**
  String get pleaseSetAmount;

  /// No description provided for @pleaseSetWakeUpTime.
  ///
  /// In en, this message translates to:
  /// **'Please set wake up time'**
  String get pleaseSetWakeUpTime;

  /// No description provided for @sleepDurationMustBeGreater.
  ///
  /// In en, this message translates to:
  /// **'Sleep duration must be greater than 0'**
  String get sleepDurationMustBeGreater;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get summary;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'RECENT CARE RECORDS'**
  String get recentActivities;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get record;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// No description provided for @breastfeeding.
  ///
  /// In en, this message translates to:
  /// **'Nursing'**
  String get breastfeeding;

  /// No description provided for @bottleBreastMilk.
  ///
  /// In en, this message translates to:
  /// **'Bottle (Breast milk)'**
  String get bottleBreastMilk;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @diaperChange.
  ///
  /// In en, this message translates to:
  /// **'Diaper change'**
  String get diaperChange;

  /// No description provided for @firstFeedingTime.
  ///
  /// In en, this message translates to:
  /// **'First feeding time?'**
  String get firstFeedingTime;

  /// No description provided for @trackBabyFeeding.
  ///
  /// In en, this message translates to:
  /// **'Track your baby\'s feeding'**
  String get trackBabyFeeding;

  /// No description provided for @diaperChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Diaper change time!'**
  String get diaperChangeTime;

  /// No description provided for @trackHygiene.
  ///
  /// In en, this message translates to:
  /// **'Track hygiene here'**
  String get trackHygiene;

  /// No description provided for @sweetDreams.
  ///
  /// In en, this message translates to:
  /// **'Sweet dreams...'**
  String get sweetDreams;

  /// No description provided for @trackSleepPattern.
  ///
  /// In en, this message translates to:
  /// **'Track sleep pattern here'**
  String get trackSleepPattern;

  /// No description provided for @selectAnotherDate.
  ///
  /// In en, this message translates to:
  /// **'Select another date'**
  String get selectAnotherDate;

  /// No description provided for @editFeeding.
  ///
  /// In en, this message translates to:
  /// **'Edit Feeding'**
  String get editFeeding;

  /// No description provided for @editDiaper.
  ///
  /// In en, this message translates to:
  /// **'Edit Diaper'**
  String get editDiaper;

  /// No description provided for @editSleep.
  ///
  /// In en, this message translates to:
  /// **'Edit Sleep'**
  String get editSleep;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get deleteConfirm;

  /// No description provided for @myVaccines.
  ///
  /// In en, this message translates to:
  /// **'My Vaccines'**
  String get myVaccines;

  /// No description provided for @addVaccine.
  ///
  /// In en, this message translates to:
  /// **'Add Vaccine'**
  String get addVaccine;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @upcomingVaccines.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Vaccines'**
  String get upcomingVaccines;

  /// No description provided for @completedVaccines.
  ///
  /// In en, this message translates to:
  /// **'Completed Vaccines'**
  String get completedVaccines;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @turkishVaccineCalendar.
  ///
  /// In en, this message translates to:
  /// **'Turkish Vaccine Calendar'**
  String get turkishVaccineCalendar;

  /// No description provided for @vaccinesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} vaccines available'**
  String vaccinesAvailable(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @alreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get alreadyAdded;

  /// No description provided for @addVaccines.
  ///
  /// In en, this message translates to:
  /// **'Add {count} Vaccines'**
  String addVaccines(int count);

  /// No description provided for @selectVaccine.
  ///
  /// In en, this message translates to:
  /// **'Select Vaccine'**
  String get selectVaccine;

  /// No description provided for @vaccinesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} vaccines added'**
  String vaccinesAdded(int count);

  /// No description provided for @noVaccineRecords.
  ///
  /// In en, this message translates to:
  /// **'No vaccine records yet'**
  String get noVaccineRecords;

  /// No description provided for @loadTurkishCalendar.
  ///
  /// In en, this message translates to:
  /// **'Load Turkish vaccine calendar or add manually'**
  String get loadTurkishCalendar;

  /// No description provided for @loadTurkishVaccineCalendar.
  ///
  /// In en, this message translates to:
  /// **'Load Turkish Vaccine Calendar'**
  String get loadTurkishVaccineCalendar;

  /// No description provided for @loadCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Load Turkish Vaccine Calendar'**
  String get loadCalendarTitle;

  /// No description provided for @loadCalendarDesc.
  ///
  /// In en, this message translates to:
  /// **'The standard Turkish vaccine calendar will be loaded. Existing vaccines won\'t be deleted.'**
  String get loadCalendarDesc;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{# year old} other{# years old}}'**
  String ageYears(int count);

  /// No description provided for @ageYearsMonths.
  ///
  /// In en, this message translates to:
  /// **'{years} Year {months} Months Old'**
  String ageYearsMonths(int years, int months);

  /// No description provided for @ageMonthsDays.
  ///
  /// In en, this message translates to:
  /// **'{months} Months {days} Days Old'**
  String ageMonthsDays(int months, int days);

  /// No description provided for @ageDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{# day old} other{# days old}}'**
  String ageDays(int count);

  /// No description provided for @weeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @totalBreastfeeding.
  ///
  /// In en, this message translates to:
  /// **'Total Breastfeeding'**
  String get totalBreastfeeding;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get totalDuration;

  /// No description provided for @dailyAvg.
  ///
  /// In en, this message translates to:
  /// **'Daily Avg.'**
  String get dailyAvg;

  /// No description provided for @avgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg. Duration'**
  String get avgDuration;

  /// No description provided for @leftBreast.
  ///
  /// In en, this message translates to:
  /// **'Left Breast'**
  String get leftBreast;

  /// No description provided for @rightBreast.
  ///
  /// In en, this message translates to:
  /// **'Right Breast'**
  String get rightBreast;

  /// No description provided for @solidFood.
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solidFood;

  /// No description provided for @diaperChanges.
  ///
  /// In en, this message translates to:
  /// **'Diaper Changes'**
  String get diaperChanges;

  /// No description provided for @longestSleep.
  ///
  /// In en, this message translates to:
  /// **'Longest Sleep'**
  String get longestSleep;

  /// No description provided for @sleepCount.
  ///
  /// In en, this message translates to:
  /// **'Sleep Count'**
  String get sleepCount;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @saveAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get saveAsPdf;

  /// No description provided for @pdfMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'PDF sharing is available on mobile'**
  String get pdfMobileOnly;

  /// No description provided for @sharingMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'Sharing is available on mobile'**
  String get sharingMobileOnly;

  /// No description provided for @pdfSaved.
  ///
  /// In en, this message translates to:
  /// **'PDF saved successfully!'**
  String get pdfSaved;

  /// No description provided for @babyTrackerReport.
  ///
  /// In en, this message translates to:
  /// **'Baby Tracker Report'**
  String get babyTrackerReport;

  /// No description provided for @generatedWith.
  ///
  /// In en, this message translates to:
  /// **'Generated with Baby Tracker App'**
  String get generatedWith;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @addOptionalNote.
  ///
  /// In en, this message translates to:
  /// **'Add note (optional)'**
  String get addOptionalNote;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @feeding_tab.
  ///
  /// In en, this message translates to:
  /// **'FEEDING'**
  String get feeding_tab;

  /// No description provided for @diaper_tab.
  ///
  /// In en, this message translates to:
  /// **'DIAPER'**
  String get diaper_tab;

  /// No description provided for @sleep_tab.
  ///
  /// In en, this message translates to:
  /// **'SLEEP'**
  String get sleep_tab;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurements;

  /// No description provided for @addMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Add height and weight measurements'**
  String get addMeasurements;

  /// No description provided for @moreDataNeeded.
  ///
  /// In en, this message translates to:
  /// **'More data needed for chart'**
  String get moreDataNeeded;

  /// No description provided for @addMoreMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Add {count} more measurements'**
  String addMoreMeasurements(int count);

  /// No description provided for @atLeast2Measurements.
  ///
  /// In en, this message translates to:
  /// **'At least 2 measurements needed for chart'**
  String get atLeast2Measurements;

  /// No description provided for @growthTracking.
  ///
  /// In en, this message translates to:
  /// **'Growth Tracking'**
  String get growthTracking;

  /// No description provided for @feedingTimer.
  ///
  /// In en, this message translates to:
  /// **'NURSING'**
  String get feedingTimer;

  /// No description provided for @sleepingTimer.
  ///
  /// In en, this message translates to:
  /// **'SLEEPING'**
  String get sleepingTimer;

  /// No description provided for @stopAndSave.
  ///
  /// In en, this message translates to:
  /// **'STOP & SAVE'**
  String get stopAndSave;

  /// No description provided for @activeTimer.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeTimer;

  /// No description provided for @lastFed.
  ///
  /// In en, this message translates to:
  /// **'LAST FED'**
  String get lastFed;

  /// No description provided for @lastDiaper.
  ///
  /// In en, this message translates to:
  /// **'LAST DIAPER'**
  String get lastDiaper;

  /// No description provided for @lastSleep.
  ///
  /// In en, this message translates to:
  /// **'LAST SLEEP'**
  String get lastSleep;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'RECENT CARE RECORDS'**
  String get recentActivity;

  /// No description provided for @seeHistory.
  ///
  /// In en, this message translates to:
  /// **'SEE HISTORY'**
  String get seeHistory;

  /// No description provided for @noActivitiesLast24h.
  ///
  /// In en, this message translates to:
  /// **'No activities in the last 24 hours'**
  String get noActivitiesLast24h;

  /// No description provided for @bottleFeeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get bottleFeeding;

  /// No description provided for @trackYourBabyGrowth.
  ///
  /// In en, this message translates to:
  /// **'Track your baby\'s growth'**
  String get trackYourBabyGrowth;

  /// No description provided for @addHeightWeightMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Add weight and height measurements'**
  String get addHeightWeightMeasurements;

  /// No description provided for @addFirstMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add first measurement'**
  String get addFirstMeasurement;

  /// No description provided for @lastUpdatedToday.
  ///
  /// In en, this message translates to:
  /// **'Last updated today'**
  String get lastUpdatedToday;

  /// No description provided for @lastUpdated1Day.
  ///
  /// In en, this message translates to:
  /// **'Last updated 1 day ago'**
  String get lastUpdated1Day;

  /// No description provided for @lastUpdatedDays.
  ///
  /// In en, this message translates to:
  /// **'Last updated {days} days ago'**
  String lastUpdatedDays(int days);

  /// No description provided for @viewGrowthCharts.
  ///
  /// In en, this message translates to:
  /// **'VIEW GROWTH CHARTS'**
  String get viewGrowthCharts;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weightLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'HEIGHT'**
  String get heightLabel;

  /// No description provided for @mAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String mAgo(int count);

  /// No description provided for @hmAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m ago'**
  String hmAgo(int hours, int minutes);

  /// No description provided for @dAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String dAgo(int days);

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// No description provided for @dailyTip.
  ///
  /// In en, this message translates to:
  /// **'DAILY TIP'**
  String get dailyTip;

  /// No description provided for @allTips.
  ///
  /// In en, this message translates to:
  /// **'All tips'**
  String get allTips;

  /// No description provided for @upcomingVaccine.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING VACCINE'**
  String get upcomingVaccine;

  /// No description provided for @nextVaccineLabel.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String nextVaccineLabel(String name);

  /// No description provided for @leftMinRightMin.
  ///
  /// In en, this message translates to:
  /// **'L {left}min • R {right}min'**
  String leftMinRightMin(int left, int right);

  /// No description provided for @breastfeedingSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'✅ Breastfeeding saved: L {left}min, R {right}min'**
  String breastfeedingSavedSnack(int left, int right);

  /// No description provided for @sleepSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'✅ Sleep saved: {duration}'**
  String sleepSavedSnack(String duration);

  /// No description provided for @sleepTooShort.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Sleep under 1 minute, not saved'**
  String get sleepTooShort;

  /// No description provided for @kgThisMonth.
  ///
  /// In en, this message translates to:
  /// **'+{value}kg this month'**
  String kgThisMonth(String value);

  /// No description provided for @cmThisMonth.
  ///
  /// In en, this message translates to:
  /// **'+{value}cm this month'**
  String cmThisMonth(String value);

  /// No description provided for @noSleep.
  ///
  /// In en, this message translates to:
  /// **'No sleep'**
  String get noSleep;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @welcomeToNilico.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nilico'**
  String get welcomeToNilico;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @loginBenefitText.
  ///
  /// In en, this message translates to:
  /// **'Sign in to prepare for backup and sync features coming soon. You can also continue without signing in.'**
  String get loginBenefitText;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @continueWithoutLogin.
  ///
  /// In en, this message translates to:
  /// **'Continue without login'**
  String get continueWithoutLogin;

  /// No description provided for @loginOptionalNote.
  ///
  /// In en, this message translates to:
  /// **'Login is optional. All features work without an account.'**
  String get loginOptionalNote;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// No description provided for @signInToProtectData.
  ///
  /// In en, this message translates to:
  /// **'Sign in to protect your data'**
  String get signInToProtectData;

  /// No description provided for @backupSyncComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Backup & sync coming soon'**
  String get backupSyncComingSoon;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View privacy policy'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @termsOfUseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View terms and conditions'**
  String get termsOfUseSubtitle;

  /// No description provided for @pageCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open page'**
  String get pageCouldNotOpen;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @noMedications.
  ///
  /// In en, this message translates to:
  /// **'No medications/supplements yet'**
  String get noMedications;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @supplement.
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get supplement;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get medicationName;

  /// No description provided for @medicationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get medicationNameRequired;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemDefault;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @ukrainian.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get ukrainian;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @tip_siyah_mekonyum_title.
  ///
  /// In en, this message translates to:
  /// **'First Poop'**
  String get tip_siyah_mekonyum_title;

  /// No description provided for @tip_siyah_mekonyum_desc.
  ///
  /// In en, this message translates to:
  /// **'In the first 2-4 days, this is normal whether your baby takes breast milk or formula. No need to worry.'**
  String get tip_siyah_mekonyum_desc;

  /// No description provided for @tip_eye_tracking_title.
  ///
  /// In en, this message translates to:
  /// **'Eye Tracking'**
  String get tip_eye_tracking_title;

  /// No description provided for @tip_eye_tracking_desc.
  ///
  /// In en, this message translates to:
  /// **'Your baby can clearly see only about 25-30 cm for now. Move your face slowly and let your baby follow with their eyes.'**
  String get tip_eye_tracking_desc;

  /// No description provided for @tip_neck_support_title.
  ///
  /// In en, this message translates to:
  /// **'Neck Support'**
  String get tip_neck_support_title;

  /// No description provided for @tip_neck_support_desc.
  ///
  /// In en, this message translates to:
  /// **'Always support your baby\'s head and neck when holding them. Neck muscles are still very weak.'**
  String get tip_neck_support_desc;

  /// No description provided for @tip_reflex_stepping_title.
  ///
  /// In en, this message translates to:
  /// **'Stepping Reflex'**
  String get tip_reflex_stepping_title;

  /// No description provided for @tip_reflex_stepping_desc.
  ///
  /// In en, this message translates to:
  /// **'Hold your baby upright and let their feet touch a flat surface. You may see stepping reflexes.'**
  String get tip_reflex_stepping_desc;

  /// No description provided for @tip_sound_interest_title.
  ///
  /// In en, this message translates to:
  /// **'Interest in Sounds'**
  String get tip_sound_interest_title;

  /// No description provided for @tip_sound_interest_desc.
  ///
  /// In en, this message translates to:
  /// **'Your baby is very sensitive to sounds. Try getting attention with a soft rattle or gentle music box.'**
  String get tip_sound_interest_desc;

  /// No description provided for @tip_parent_interaction_title.
  ///
  /// In en, this message translates to:
  /// **'Parent Interaction'**
  String get tip_parent_interaction_title;

  /// No description provided for @tip_parent_interaction_desc.
  ///
  /// In en, this message translates to:
  /// **'Make eye contact and talk softly. Your baby recognizes your voice and feels secure with it.'**
  String get tip_parent_interaction_desc;

  /// No description provided for @tip_color_worlds_title.
  ///
  /// In en, this message translates to:
  /// **'World of Colors'**
  String get tip_color_worlds_title;

  /// No description provided for @tip_color_worlds_desc.
  ///
  /// In en, this message translates to:
  /// **'Newborns see high-contrast black and white patterns best. Try showing black-and-white cards.'**
  String get tip_color_worlds_desc;

  /// No description provided for @tip_mini_athlete_title.
  ///
  /// In en, this message translates to:
  /// **'Mini Athlete'**
  String get tip_mini_athlete_title;

  /// No description provided for @tip_mini_athlete_desc.
  ///
  /// In en, this message translates to:
  /// **'Tummy time strengthens neck and back muscles. Try a few minutes each day.'**
  String get tip_mini_athlete_desc;

  /// No description provided for @tip_sound_hunter_title.
  ///
  /// In en, this message translates to:
  /// **'Sound Hunter'**
  String get tip_sound_hunter_title;

  /// No description provided for @tip_sound_hunter_desc.
  ///
  /// In en, this message translates to:
  /// **'Snap softly near your baby\'s ear. They may try turning toward the sound.'**
  String get tip_sound_hunter_desc;

  /// No description provided for @tip_touch_explore_title.
  ///
  /// In en, this message translates to:
  /// **'Touch Exploration'**
  String get tip_touch_explore_title;

  /// No description provided for @tip_touch_explore_desc.
  ///
  /// In en, this message translates to:
  /// **'Let your baby feel different textures on hands and feet: soft, rough, and cool surfaces.'**
  String get tip_touch_explore_desc;

  /// No description provided for @tip_tip_agu_conversation_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Baby Talk Chats'**
  String get tip_tip_agu_conversation_1_2_title;

  /// No description provided for @tip_tip_agu_conversation_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'When your baby makes sounds, listen. Reply gently when they finish. These tiny chats build communication.'**
  String get tip_tip_agu_conversation_1_2_desc;

  /// No description provided for @tip_tip_tummy_time_strength_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Strong Shoulders (Tummy Time)'**
  String get tip_tip_tummy_time_strength_1_2_title;

  /// No description provided for @tip_tip_tummy_time_strength_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Place your baby on their tummy for short periods. Encourage head lifting with colorful toys in front.'**
  String get tip_tip_tummy_time_strength_1_2_desc;

  /// No description provided for @tip_tip_baby_massage_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Soothing Massage'**
  String get tip_tip_baby_massage_1_2_title;

  /// No description provided for @tip_tip_baby_massage_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'After bath time, massage gently starting from the feet. It supports body awareness and helps your baby relax.'**
  String get tip_tip_baby_massage_1_2_desc;

  /// No description provided for @tip_tip_gesture_speech_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Gesture-Based Talking'**
  String get tip_tip_gesture_speech_1_2_title;

  /// No description provided for @tip_tip_gesture_speech_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Use gestures while talking. Wave for \"we\'re going\" and rub hands for \"all done\". This supports visual memory.'**
  String get tip_tip_gesture_speech_1_2_desc;

  /// No description provided for @tip_tip_open_hands_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Free Fingers'**
  String get tip_tip_open_hands_1_2_title;

  /// No description provided for @tip_tip_open_hands_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Hands are opening more now. Offer soft toys to practice grasping and releasing.'**
  String get tip_tip_open_hands_1_2_desc;

  /// No description provided for @tip_tip_side_by_side_bonding_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Side-by-Side Bonding'**
  String get tip_tip_side_by_side_bonding_1_2_title;

  /// No description provided for @tip_tip_side_by_side_bonding_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Lie side by side with your baby. Smile and speak lovingly as they try to turn toward you.'**
  String get tip_tip_side_by_side_bonding_1_2_desc;

  /// No description provided for @tip_tip_sound_hunter_title.
  ///
  /// In en, this message translates to:
  /// **'Sound Hunter'**
  String get tip_tip_sound_hunter_title;

  /// No description provided for @tip_tip_sound_hunter_desc.
  ///
  /// In en, this message translates to:
  /// **'Shake a rattle softly where your baby cannot see it. Turning toward sound builds hearing and focus.'**
  String get tip_tip_sound_hunter_desc;

  /// No description provided for @tip_tip_sound_hunter_level2_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Sound Hunter (Level 2)'**
  String get tip_tip_sound_hunter_level2_1_2_title;

  /// No description provided for @tip_tip_sound_hunter_level2_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Make different sounds from left and right. Finding the source strengthens attention skills.'**
  String get tip_tip_sound_hunter_level2_1_2_desc;

  /// No description provided for @tip_tip_texture_discovery_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Touch and Discover'**
  String get tip_tip_texture_discovery_1_2_title;

  /// No description provided for @tip_tip_texture_discovery_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Offer objects with different textures. Each new feeling is a new discovery for your baby.'**
  String get tip_tip_texture_discovery_1_2_desc;

  /// No description provided for @tip_tip_outdoor_explorer_4_5_title.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Explorer'**
  String get tip_tip_outdoor_explorer_4_5_title;

  /// No description provided for @tip_tip_outdoor_explorer_4_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Show trees and animals outside. Let your baby touch and explore while hearing your voice.'**
  String get tip_tip_outdoor_explorer_4_5_desc;

  /// No description provided for @tip_tip_reaching_exercise_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Reaching Practice'**
  String get tip_tip_reaching_exercise_1_2_title;

  /// No description provided for @tip_tip_reaching_exercise_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Place toys within reach. Even attempts to grab them help strengthen muscles.'**
  String get tip_tip_reaching_exercise_1_2_desc;

  /// No description provided for @tip_tip_supported_bounce_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Supported Bouncing'**
  String get tip_tip_supported_bounce_1_2_title;

  /// No description provided for @tip_tip_supported_bounce_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Hold your baby upright on your lap and let them bounce gently with support. It helps leg strength and exploration.'**
  String get tip_tip_supported_bounce_1_2_desc;

  /// No description provided for @tip_tip_visual_tracking_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Visual Tracking'**
  String get tip_tip_visual_tracking_1_2_title;

  /// No description provided for @tip_tip_visual_tracking_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Move a colorful sound-making toy in slow circles within view. Eye tracking is a great visual exercise.'**
  String get tip_tip_visual_tracking_1_2_desc;

  /// No description provided for @tip_tip_face_play_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Face Play'**
  String get tip_tip_face_play_1_2_title;

  /// No description provided for @tip_tip_face_play_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Get close, make eye contact, and use playful facial expressions. Your voice and face are your baby\'s favorite toys.'**
  String get tip_tip_face_play_1_2_desc;

  /// No description provided for @tip_tip_emotion_labeling_1_2_title.
  ///
  /// In en, this message translates to:
  /// **'Emotion Naming'**
  String get tip_tip_emotion_labeling_1_2_title;

  /// No description provided for @tip_tip_emotion_labeling_1_2_desc.
  ///
  /// In en, this message translates to:
  /// **'When your baby cries, name the feeling kindly and reassure them. Feeling understood helps emotional safety.'**
  String get tip_tip_emotion_labeling_1_2_desc;

  /// No description provided for @tip_tip_first_meal_title.
  ///
  /// In en, this message translates to:
  /// **'First Tasting'**
  String get tip_tip_first_meal_title;

  /// No description provided for @tip_tip_first_meal_desc.
  ///
  /// In en, this message translates to:
  /// **'Start solids based on your doctor\'s advice. Spoon feeding can be fun, but stay alert for allergy signs.'**
  String get tip_tip_first_meal_desc;

  /// No description provided for @tip_tip_hand_to_hand_transfer_4_5_title.
  ///
  /// In en, this message translates to:
  /// **'Active Hands'**
  String get tip_tip_hand_to_hand_transfer_4_5_title;

  /// No description provided for @tip_tip_hand_to_hand_transfer_4_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Around months 4-5, babies try moving objects between hands. Offer easy-to-grasp items and observe.'**
  String get tip_tip_hand_to_hand_transfer_4_5_desc;

  /// No description provided for @tip_tip_supported_sitting_4_5_title.
  ///
  /// In en, this message translates to:
  /// **'Supported Sitting'**
  String get tip_tip_supported_sitting_4_5_title;

  /// No description provided for @tip_tip_supported_sitting_4_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Practice supported sitting with pillows. Place a toy in front to motivate balance and upper-body support.'**
  String get tip_tip_supported_sitting_4_5_desc;

  /// No description provided for @tip_tip_feet_discovery_4_5_title.
  ///
  /// In en, this message translates to:
  /// **'Discovering Feet'**
  String get tip_tip_feet_discovery_4_5_title;

  /// No description provided for @tip_tip_feet_discovery_4_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Your baby may catch feet and bring them to the mouth while lying down. Let feet explore different surfaces.'**
  String get tip_tip_feet_discovery_4_5_desc;

  /// No description provided for @tip_tip_independent_play_4_5_title.
  ///
  /// In en, this message translates to:
  /// **'Independent Play'**
  String get tip_tip_independent_play_4_5_title;

  /// No description provided for @tip_tip_independent_play_4_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Place a few textured toys nearby and step back a little. Independent play supports confidence.'**
  String get tip_tip_independent_play_4_5_desc;

  /// No description provided for @ageMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{# month old} other{# months old}}'**
  String ageMonths(int count);

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comfortable low-light theme'**
  String get darkModeSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @feedingReminder.
  ///
  /// In en, this message translates to:
  /// **'Feeding Reminder'**
  String get feedingReminder;

  /// No description provided for @diaperReminder.
  ///
  /// In en, this message translates to:
  /// **'Diaper Reminder'**
  String get diaperReminder;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get dataManagement;

  /// No description provided for @createReport.
  ///
  /// In en, this message translates to:
  /// **'Create report'**
  String get createReport;

  /// No description provided for @weeklyMonthlyStats.
  ///
  /// In en, this message translates to:
  /// **'Weekly/Monthly insights'**
  String get weeklyMonthlyStats;

  /// No description provided for @deleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllDataTitle;

  /// No description provided for @deleteAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all records'**
  String get deleteAllDataSubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @deleteAllDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This action permanently deletes all records. This cannot be undone.'**
  String get deleteAllDataWarning;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// No description provided for @testSleepNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Sleep Notification'**
  String get testSleepNotification;

  /// No description provided for @fireSleepNotificationNow.
  ///
  /// In en, this message translates to:
  /// **'Fire sleep notification now'**
  String get fireSleepNotificationNow;

  /// No description provided for @testNursingNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Nursing Notification'**
  String get testNursingNotification;

  /// No description provided for @fireNursingNotificationNow.
  ///
  /// In en, this message translates to:
  /// **'Fire nursing notification now'**
  String get fireNursingNotificationNow;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @selectBaby.
  ///
  /// In en, this message translates to:
  /// **'Select Baby'**
  String get selectBaby;

  /// No description provided for @newBabyAdd.
  ///
  /// In en, this message translates to:
  /// **'Add New Baby'**
  String get newBabyAdd;

  /// No description provided for @babyProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Profile'**
  String get babyProfileTitle;

  /// No description provided for @babyInformation.
  ///
  /// In en, this message translates to:
  /// **'Baby Information'**
  String get babyInformation;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDateLabel;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @growthRecords.
  ///
  /// In en, this message translates to:
  /// **'Growth Records'**
  String get growthRecords;

  /// No description provided for @deleteThisBabyData.
  ///
  /// In en, this message translates to:
  /// **'Delete this baby\'s data'**
  String get deleteThisBabyData;

  /// No description provided for @otherBabiesUnaffected.
  ///
  /// In en, this message translates to:
  /// **'Other babies are not affected'**
  String get otherBabiesUnaffected;

  /// No description provided for @onlyThisBabyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Only '**
  String get onlyThisBabyPrefix;

  /// No description provided for @allRecordsWillBeDeleted.
  ///
  /// In en, this message translates to:
  /// **' baby\'s records will be deleted.'**
  String get allRecordsWillBeDeleted;

  /// No description provided for @deleteActionIrreversible.
  ///
  /// In en, this message translates to:
  /// **'Other babies are not affected. This action cannot be undone.'**
  String get deleteActionIrreversible;

  /// No description provided for @birth.
  ///
  /// In en, this message translates to:
  /// **'Birth'**
  String get birth;

  /// No description provided for @monthNumber.
  ///
  /// In en, this message translates to:
  /// **'{month}. Month'**
  String monthNumber(int month);

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get selectMonth;

  /// No description provided for @otherMonth.
  ///
  /// In en, this message translates to:
  /// **'Other month'**
  String get otherMonth;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @scheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Date'**
  String get scheduledDate;

  /// No description provided for @editVaccine.
  ///
  /// In en, this message translates to:
  /// **'Edit Vaccine'**
  String get editVaccine;

  /// No description provided for @vaccineName.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Name'**
  String get vaccineName;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @routineFilter.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routineFilter;

  /// No description provided for @asNeededFilter.
  ///
  /// In en, this message translates to:
  /// **'As-needed'**
  String get asNeededFilter;

  /// No description provided for @vaccineProtocolsFilter.
  ///
  /// In en, this message translates to:
  /// **'Vaccine protocols'**
  String get vaccineProtocolsFilter;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @asNeeded.
  ///
  /// In en, this message translates to:
  /// **'As needed'**
  String get asNeeded;

  /// No description provided for @vaccineProtocolLabel.
  ///
  /// In en, this message translates to:
  /// **'Vaccine protocol'**
  String get vaccineProtocolLabel;

  /// No description provided for @linkedToVaccine.
  ///
  /// In en, this message translates to:
  /// **'linked to {vaccine}'**
  String linkedToVaccine(String vaccine);

  /// No description provided for @noVaccineLink.
  ///
  /// In en, this message translates to:
  /// **'No linked vaccine'**
  String get noVaccineLink;

  /// No description provided for @doseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Doses logged: {count}'**
  String doseCountLabel(int count);

  /// No description provided for @logGivenNow.
  ///
  /// In en, this message translates to:
  /// **'Log given now'**
  String get logGivenNow;

  /// No description provided for @medicationDoseLogged.
  ///
  /// In en, this message translates to:
  /// **'Dose logged'**
  String get medicationDoseLogged;

  /// No description provided for @scheduleType.
  ///
  /// In en, this message translates to:
  /// **'Schedule type'**
  String get scheduleType;

  /// No description provided for @dailySchedule.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailySchedule;

  /// No description provided for @prnSchedule.
  ///
  /// In en, this message translates to:
  /// **'As-needed'**
  String get prnSchedule;

  /// No description provided for @dailyTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one daily time'**
  String get dailyTimeRequired;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @medicationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} reminder'**
  String medicationReminderTitle(String name);

  /// No description provided for @medicationReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Time to give this medication'**
  String get medicationReminderBody;

  /// No description provided for @medicationReminderBodyWithDose.
  ///
  /// In en, this message translates to:
  /// **'Dose: {dose}'**
  String medicationReminderBodyWithDose(String dose);

  /// No description provided for @addVaccineProtocol.
  ///
  /// In en, this message translates to:
  /// **'Add vaccine protocol'**
  String get addVaccineProtocol;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @chooseExistingMedication.
  ///
  /// In en, this message translates to:
  /// **'Choose existing medication'**
  String get chooseExistingMedication;

  /// No description provided for @feverReducerHint.
  ///
  /// In en, this message translates to:
  /// **'Fever reducer'**
  String get feverReducerHint;

  /// No description provided for @beforeHours.
  ///
  /// In en, this message translates to:
  /// **'Before: {hours}h'**
  String beforeHours(int hours);

  /// No description provided for @afterHours.
  ///
  /// In en, this message translates to:
  /// **'After: {hours}h'**
  String afterHours(int hours);

  /// No description provided for @vaccineProtocolAdded.
  ///
  /// In en, this message translates to:
  /// **'Vaccine protocol added'**
  String get vaccineProtocolAdded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru', 'tr', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
