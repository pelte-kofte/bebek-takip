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

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Nilico'**
  String get appName;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Parenting made simple & memorable.'**
  String get tagline;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Offline First'**
  String get freeForever;

  /// No description provided for @instantStart.
  ///
  /// In en, this message translates to:
  /// **'Start Instantly'**
  String get instantStart;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get securePrivate;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get tapToStart;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Feeding Tracker'**
  String get feedingTracker;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Log nursing, bottles, and solids with ease. Spot patterns naturally.'**
  String get feedingTrackerDesc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sleep Patterns'**
  String get sleepPatterns;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Understand your baby\'s rhythm and improve sleep quality for everyone.'**
  String get sleepPatternsDesc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Growth Charts'**
  String get growthCharts;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Visualize height and weight changes over time with beautiful charts.'**
  String get growthChartsDesc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Precious Memories'**
  String get preciousMemories;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Save milestones and funny moments. They grow up so fast!'**
  String get preciousMemoriesDesc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Daily Rhythm'**
  String get dailyRhythm;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Gentle routines bring calm days and peaceful nights.'**
  String get dailyRhythmDesc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get startYourJourney;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get mlAbbrev;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get tapToSetTime;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sleep notification fired'**
  String get notificationSleepFired;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Nursing notification fired'**
  String get notificationNursingFired;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOutSuccessfully;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get saveFailedTryAgain;

  /// UI text
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

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Photo upload is not supported on web'**
  String get webPhotoUploadUnsupported;

  /// No description provided for @babyDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} data deleted'**
  String babyDataDeleted(String name);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Baby name'**
  String get babyNameHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Allergies, preferences, notes...'**
  String get babyNotesHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'e.g. Hepatitis B, BCG, combo vaccine'**
  String get vaccineNameHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'e.g. Dose 1, DTaP-IPV-Hib'**
  String get vaccineDoseHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Vaccine name cannot be empty'**
  String get vaccineNameCannotBeEmpty;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'e.g. 7.5'**
  String get growthWeightHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'e.g. 68.5'**
  String get growthHeightHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Doctor visit, vaccine day, etc.'**
  String get growthNotesHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Please enter weight and height'**
  String get pleaseEnterWeightHeight;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'e.g. First steps'**
  String get memoryTitleHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Write down the memory...'**
  String get memoryNoteHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get activities;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get vaccines;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get development;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add Activity'**
  String get addActivity;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get whatHappened;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Nursing'**
  String get nursing;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get bottle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaper;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minAbbrev;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourAbbrev;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get solid;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'WHAT WAS GIVEN?'**
  String get whatWasGiven;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'E.g.: Banana puree, carrot...'**
  String get solidFoodHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Milk Type'**
  String get milkType;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Breast milk'**
  String get breastMilk;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'SLEEP STARTED AT'**
  String get sleepStartedAt;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'WOKE UP AT'**
  String get wokeUpAt;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get tapToSet;

  /// No description provided for @totalSleep.
  ///
  /// In en, this message translates to:
  /// **'Total sleep: {duration}'**
  String totalSleep(String duration);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get healthType;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get healthTime;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wet;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get dirty;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get optionalNotes;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add a note about the diaper change...'**
  String get diaperNoteHint;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Please set a duration'**
  String get pleaseSetDuration;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Please set an amount'**
  String get pleaseSetAmount;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Please set wake up time'**
  String get pleaseSetWakeUpTime;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sleep duration must be greater than 0'**
  String get sleepDurationMustBeGreater;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get summary;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'RECENT CARE RECORDS'**
  String get recentActivities;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get record;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Nursing'**
  String get breastfeeding;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Bottle (Breast milk)'**
  String get bottleBreastMilk;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Diaper change'**
  String get diaperChange;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'First feeding time?'**
  String get firstFeedingTime;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Track your baby\'s feeding'**
  String get trackBabyFeeding;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Diaper change time!'**
  String get diaperChangeTime;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Track hygiene here'**
  String get trackHygiene;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sweet dreams...'**
  String get sweetDreams;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Track sleep pattern here'**
  String get trackSleepPattern;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Select another date'**
  String get selectAnotherDate;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Feeding'**
  String get editFeeding;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Diaper'**
  String get editDiaper;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Sleep'**
  String get editSleep;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get deleteConfirm;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'My Vaccines'**
  String get myVaccines;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add Vaccine'**
  String get addVaccine;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Upcoming Vaccines'**
  String get upcomingVaccines;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Completed Vaccines'**
  String get completedVaccines;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Turkish Vaccine Calendar'**
  String get turkishVaccineCalendar;

  /// No description provided for @vaccinesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} vaccines available'**
  String vaccinesAvailable(int count);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get alreadyAdded;

  /// No description provided for @addVaccines.
  ///
  /// In en, this message translates to:
  /// **'Add {count} Vaccines'**
  String addVaccines(int count);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Select Vaccine'**
  String get selectVaccine;

  /// No description provided for @vaccinesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} vaccines added'**
  String vaccinesAdded(int count);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No vaccine records yet'**
  String get noVaccineRecords;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Load Turkish vaccine calendar or add manually'**
  String get loadTurkishCalendar;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Load Turkish Vaccine Calendar'**
  String get loadTurkishVaccineCalendar;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Load Turkish Vaccine Calendar'**
  String get loadCalendarTitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'The standard Turkish vaccine calendar will be loaded. Existing vaccines won\'t be deleted.'**
  String get loadCalendarDesc;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} year old} other{{count} years old}}'**
  String ageYears(int count);

  /// No description provided for @ageYearsMonths.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, one{{years} year} other{{years} years}} {months, plural, one{{months} month old} other{{months} months old}}'**
  String ageYearsMonths(int years, int months);

  /// No description provided for @ageMonthsDays.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, one{{months} month} other{{months} months}} {days, plural, one{{days} day old} other{{days} days old}}'**
  String ageMonthsDays(int months, int days);

  /// No description provided for @ageDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day old} other{{count} days old}}'**
  String ageDays(int count);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Total Breastfeeding'**
  String get totalBreastfeeding;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get totalDuration;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Daily Avg.'**
  String get dailyAvg;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Avg. Duration'**
  String get avgDuration;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Left Breast'**
  String get leftBreast;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Right Breast'**
  String get rightBreast;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solidFood;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Diaper Changes'**
  String get diaperChanges;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Longest Sleep'**
  String get longestSleep;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sleep Count'**
  String get sleepCount;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get saveAsPdf;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'PDF sharing is available on mobile'**
  String get pdfMobileOnly;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sharing is available on mobile'**
  String get sharingMobileOnly;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'PDF saved successfully!'**
  String get pdfSaved;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Baby Tracker Report'**
  String get babyTrackerReport;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Generated with Baby Tracker App'**
  String get generatedWith;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add note (optional)'**
  String get addOptionalNote;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'FEEDING'**
  String get feeding_tab;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'DIAPER'**
  String get diaper_tab;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'SLEEP'**
  String get sleep_tab;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurements;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add height and weight measurements'**
  String get addMeasurements;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'More data needed for chart'**
  String get moreDataNeeded;

  /// No description provided for @addMoreMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Add {count} more measurements'**
  String addMoreMeasurements(int count);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'At least 2 measurements needed for chart'**
  String get atLeast2Measurements;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Growth Tracking'**
  String get growthTracking;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Growth Record'**
  String get growthEntryTitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Track height and weight'**
  String get growthEntrySubtitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get growthDateField;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'WEIGHT (kg)'**
  String get growthWeightField;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'HEIGHT (cm)'**
  String get growthHeightField;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'NOTES (Optional)'**
  String get growthNotesField;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get centimeterUnit;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kilogramUnit;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'NURSING'**
  String get feedingTimer;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'SLEEPING'**
  String get sleepingTimer;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'STOP & SAVE'**
  String get stopAndSave;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeTimer;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'LAST FED'**
  String get lastFed;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'LAST DIAPER'**
  String get lastDiaper;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'LAST SLEEP'**
  String get lastSleep;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'RECENT CARE RECORDS'**
  String get recentActivity;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'SEE HISTORY'**
  String get seeHistory;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No activities in the last 24 hours'**
  String get noActivitiesLast24h;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get bottleFeeding;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Track your baby\'s growth'**
  String get trackYourBabyGrowth;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add weight and height measurements'**
  String get addHeightWeightMeasurements;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add first measurement'**
  String get addFirstMeasurement;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Last updated today'**
  String get lastUpdatedToday;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Last updated 1 day ago'**
  String get lastUpdated1Day;

  /// No description provided for @lastUpdatedDays.
  ///
  /// In en, this message translates to:
  /// **'Last updated {days} days ago'**
  String lastUpdatedDays(int days);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'VIEW GROWTH CHARTS'**
  String get viewGrowthCharts;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weightLabel;

  /// UI text
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

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'DAILY TIP'**
  String get dailyTip;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Daily Tips'**
  String get dailyTipsTitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'All tips'**
  String get allTips;

  /// No description provided for @tip_engelli_kosu_title.
  ///
  /// In en, this message translates to:
  /// **'Obstacle Course (Crawling Edition)'**
  String get tip_engelli_kosu_title;

  /// No description provided for @tip_engelli_kosu_desc.
  ///
  /// In en, this message translates to:
  /// **'Place small pillow or blanket obstacles on the floor. Getting over them to reach a toy helps build problem-solving skills.'**
  String get tip_engelli_kosu_desc;

  /// No description provided for @tip_hafif_agir_title.
  ///
  /// In en, this message translates to:
  /// **'Heavy or Light?'**
  String get tip_hafif_agir_title;

  /// No description provided for @tip_hafif_agir_desc.
  ///
  /// In en, this message translates to:
  /// **'Place a feather-light cloth in one hand and a heavier block in the other. Let your baby compare the feel, texture, and weight.'**
  String get tip_hafif_agir_desc;

  /// No description provided for @tip_beni_ismimle_cagir_title.
  ///
  /// In en, this message translates to:
  /// **'Call Me by My Name'**
  String get tip_beni_ismimle_cagir_title;

  /// No description provided for @tip_beni_ismimle_cagir_desc.
  ///
  /// In en, this message translates to:
  /// **'While your baby is looking away, softly say their name. Encourage them to turn toward you. Recognizing their name is a big milestone this month.'**
  String get tip_beni_ismimle_cagir_desc;

  /// No description provided for @tip_su_ne_title.
  ///
  /// In en, this message translates to:
  /// **'What\'s That? (Pointing)'**
  String get tip_su_ne_title;

  /// No description provided for @tip_su_ne_desc.
  ///
  /// In en, this message translates to:
  /// **'Point to different objects in the room and name them. Trying to point too shows your baby is exploring the world with you.'**
  String get tip_su_ne_desc;

  /// No description provided for @tip_komut_dinlemece_title.
  ///
  /// In en, this message translates to:
  /// **'Listening Game'**
  String get tip_komut_dinlemece_title;

  /// No description provided for @tip_komut_dinlemece_desc.
  ///
  /// In en, this message translates to:
  /// **'Give simple one-step directions like \"Give me the ball\" or \"Look at me.\" This helps your baby connect words with actions.'**
  String get tip_komut_dinlemece_desc;

  /// No description provided for @tip_buyuk_yuruyus_title.
  ///
  /// In en, this message translates to:
  /// **'The Big Walk'**
  String get tip_buyuk_yuruyus_title;

  /// No description provided for @tip_buyuk_yuruyus_desc.
  ///
  /// In en, this message translates to:
  /// **'Hold your baby\'s hands or use a safe push walker to encourage steps. Stay close as they practice balance and enjoy the excitement of early walking.'**
  String get tip_buyuk_yuruyus_desc;

  /// No description provided for @tip_duzenleme_saati_title.
  ///
  /// In en, this message translates to:
  /// **'Tidy-Up Time'**
  String get tip_duzenleme_saati_title;

  /// No description provided for @tip_duzenleme_saati_desc.
  ///
  /// In en, this message translates to:
  /// **'Put scattered toys into a basket or box together. Say, \"Let\'s put it in the box!\" and encourage your baby to toss them in.'**
  String get tip_duzenleme_saati_desc;

  /// No description provided for @tip_emekleme_parkuru_title.
  ///
  /// In en, this message translates to:
  /// **'Crawling Course'**
  String get tip_emekleme_parkuru_title;

  /// No description provided for @tip_emekleme_parkuru_desc.
  ///
  /// In en, this message translates to:
  /// **'Make a small obstacle course with soft blankets and pillows. Place a favorite toy a little farther away and encourage your baby to crawl toward it.'**
  String get tip_emekleme_parkuru_desc;

  /// No description provided for @tip_aynadaki_bebek_title.
  ///
  /// In en, this message translates to:
  /// **'The Mysterious Baby in the Mirror'**
  String get tip_aynadaki_bebek_title;

  /// No description provided for @tip_aynadaki_bebek_desc.
  ///
  /// In en, this message translates to:
  /// **'Sit your baby in front of a safe mirror. Let them watch their reflection and touch the mirror. Ask, \"Who is that?\" to support self-recognition and visual development.'**
  String get tip_aynadaki_bebek_desc;

  /// No description provided for @tip_yuvarla_bakalim_title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Roll It'**
  String get tip_yuvarla_bakalim_title;

  /// No description provided for @tip_yuvarla_bakalim_desc.
  ///
  /// In en, this message translates to:
  /// **'Sit on the floor facing each other and roll a soft ball back and forth. Encourage your baby to catch it and push it back to build hand-eye coordination.'**
  String get tip_yuvarla_bakalim_desc;

  /// No description provided for @tip_nesne_karsilastirma_title.
  ///
  /// In en, this message translates to:
  /// **'Comparing Objects'**
  String get tip_nesne_karsilastirma_title;

  /// No description provided for @tip_nesne_karsilastirma_desc.
  ///
  /// In en, this message translates to:
  /// **'Place a soft toy in one hand and a hard block in the other. Give your baby time to notice differences in texture and weight.'**
  String get tip_nesne_karsilastirma_desc;

  /// No description provided for @tip_kucuk_okuyucu_title.
  ///
  /// In en, this message translates to:
  /// **'Little Reader'**
  String get tip_kucuk_okuyucu_title;

  /// No description provided for @tip_kucuk_okuyucu_desc.
  ///
  /// In en, this message translates to:
  /// **'Look through sturdy board books together. Give your baby space to turn the pages, helping a little if needed, to support fine motor skills and curiosity.'**
  String get tip_kucuk_okuyucu_desc;

  /// No description provided for @tip_yercekimi_deneyi_title.
  ///
  /// In en, this message translates to:
  /// **'Gravity Experiment'**
  String get tip_yercekimi_deneyi_title;

  /// No description provided for @tip_yercekimi_deneyi_desc.
  ///
  /// In en, this message translates to:
  /// **'When your baby drops a toy on purpose and waits for you to pick it up, that\'s a cause-and-effect game. Say, \"It fell!\" and join the discovery.'**
  String get tip_yercekimi_deneyi_desc;

  /// No description provided for @tip_adimadim_macera_title.
  ///
  /// In en, this message translates to:
  /// **'First Step Excitement'**
  String get tip_adimadim_macera_title;

  /// No description provided for @tip_adimadim_macera_desc.
  ///
  /// In en, this message translates to:
  /// **'Hold your baby securely under the arms and let their feet press into the floor. Gently guide them forward so they can feel the motion of walking.'**
  String get tip_adimadim_macera_desc;

  /// No description provided for @tip_comert_bebek_title.
  ///
  /// In en, this message translates to:
  /// **'Generous Baby'**
  String get tip_comert_bebek_title;

  /// No description provided for @tip_comert_bebek_desc.
  ///
  /// In en, this message translates to:
  /// **'Ask, \"Can you give it to me?\" and hold out your hand for the toy. Celebrate with a warm \"Thank you!\" when your baby shares it.'**
  String get tip_comert_bebek_desc;

  /// No description provided for @tip_yemek_zamani_title.
  ///
  /// In en, this message translates to:
  /// **'Mealtime'**
  String get tip_yemek_zamani_title;

  /// No description provided for @tip_yemek_zamani_desc.
  ///
  /// In en, this message translates to:
  /// **'Sit at the table together and enjoy the funniest little moments. Reaching for soft cooked vegetables helps build arm coordination and tiny motor movements.'**
  String get tip_yemek_zamani_desc;

  /// No description provided for @tip_alkis_zamani_title.
  ///
  /// In en, this message translates to:
  /// **'Clap Time'**
  String get tip_alkis_zamani_title;

  /// No description provided for @tip_alkis_zamani_desc.
  ///
  /// In en, this message translates to:
  /// **'Clap along and encourage your baby to join in. Trying to copy the rhythm helps build attention and coordination.'**
  String get tip_alkis_zamani_desc;

  /// No description provided for @tip_alo_kim_o_title.
  ///
  /// In en, this message translates to:
  /// **'Hello, Who\'s There?'**
  String get tip_alo_kim_o_title;

  /// No description provided for @tip_alo_kim_o_desc.
  ///
  /// In en, this message translates to:
  /// **'Hold a toy phone to your ear and make short pretend calls, then offer it to your baby. This playful role game supports sound imitation and social interaction.'**
  String get tip_alo_kim_o_desc;

  /// No description provided for @tip_baybay_partisi_title.
  ///
  /// In en, this message translates to:
  /// **'Bye-Bye Party'**
  String get tip_baybay_partisi_title;

  /// No description provided for @tip_baybay_partisi_desc.
  ///
  /// In en, this message translates to:
  /// **'Wave and say \"bye-bye\" when someone leaves. Encourage your baby to wave too. Copying this simple gesture supports early communication.'**
  String get tip_baybay_partisi_desc;

  /// No description provided for @tip_birak_izle_title.
  ///
  /// In en, this message translates to:
  /// **'Drop and Watch'**
  String get tip_birak_izle_title;

  /// No description provided for @tip_birak_izle_desc.
  ///
  /// In en, this message translates to:
  /// **'Let your baby drop a toy and watch where it goes together. Following the fall helps build cause-and-effect understanding.'**
  String get tip_birak_izle_desc;

  /// No description provided for @tip_goster_bakalim_title.
  ///
  /// In en, this message translates to:
  /// **'Show Me'**
  String get tip_goster_bakalim_title;

  /// No description provided for @tip_goster_bakalim_desc.
  ///
  /// In en, this message translates to:
  /// **'Ask simple questions like \"Where is the ball?\" or \"Show me the light.\" Point first, then encourage your baby to look and point too.'**
  String get tip_goster_bakalim_desc;

  /// No description provided for @tip_hazine_kutusu_title.
  ///
  /// In en, this message translates to:
  /// **'Treasure Box'**
  String get tip_hazine_kutusu_title;

  /// No description provided for @tip_hazine_kutusu_desc.
  ///
  /// In en, this message translates to:
  /// **'Prepare a small box with safe household objects. Let your baby pull items out and inspect them. Each object becomes a new discovery.'**
  String get tip_hazine_kutusu_desc;

  /// No description provided for @tip_minik_kitap_kurdu_title.
  ///
  /// In en, this message translates to:
  /// **'Little Bookworm'**
  String get tip_minik_kitap_kurdu_title;

  /// No description provided for @tip_minik_kitap_kurdu_desc.
  ///
  /// In en, this message translates to:
  /// **'Flip through a sturdy board book together. Name the pictures and give your baby a chance to turn the pages too.'**
  String get tip_minik_kitap_kurdu_desc;

  /// No description provided for @tip_mobilya_dagcilari_title.
  ///
  /// In en, this message translates to:
  /// **'Furniture Climbers'**
  String get tip_mobilya_dagcilari_title;

  /// No description provided for @tip_mobilya_dagcilari_desc.
  ///
  /// In en, this message translates to:
  /// **'Support your baby\'s attempts to pull up on a sofa or another safe low surface. Climbing and holding on builds strength and balance.'**
  String get tip_mobilya_dagcilari_desc;

  /// No description provided for @tip_saksak_alkis_title.
  ///
  /// In en, this message translates to:
  /// **'Clap-Clap Fun'**
  String get tip_saksak_alkis_title;

  /// No description provided for @tip_saksak_alkis_desc.
  ///
  /// In en, this message translates to:
  /// **'Clap your hands with a happy rhythm. As your baby tries to copy you, they build rhythm awareness and two-handed coordination.'**
  String get tip_saksak_alkis_desc;

  /// No description provided for @tip_sira_sende_title.
  ///
  /// In en, this message translates to:
  /// **'Your Turn'**
  String get tip_sira_sende_title;

  /// No description provided for @tip_sira_sende_desc.
  ///
  /// In en, this message translates to:
  /// **'Move a simple toy first, then hand it over and say, \"Your turn.\" It\'s an easy way to introduce turn-taking and back-and-forth play.'**
  String get tip_sira_sende_desc;

  /// No description provided for @tip_veral_oyunu_title.
  ///
  /// In en, this message translates to:
  /// **'Give-and-Take Game'**
  String get tip_veral_oyunu_title;

  /// No description provided for @tip_veral_oyunu_desc.
  ///
  /// In en, this message translates to:
  /// **'Let your baby take a toy from you and offer it back. This simple exchange supports sharing and social connection.'**
  String get tip_veral_oyunu_desc;

  /// No description provided for @tip_yuvarla_bekle_title.
  ///
  /// In en, this message translates to:
  /// **'Roll and Wait'**
  String get tip_yuvarla_bekle_title;

  /// No description provided for @tip_yuvarla_bekle_desc.
  ///
  /// In en, this message translates to:
  /// **'Roll a soft ball toward your baby and pause for their response. That brief wait helps them understand turn-taking and stay engaged.'**
  String get tip_yuvarla_bekle_desc;

  /// UI text
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

  /// UI text
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

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No sleep'**
  String get noSleep;

  /// UI text
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

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nilico'**
  String get welcomeToNilico;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sign in to prepare for backup and sync features coming soon. You can also continue without signing in.'**
  String get loginBenefitText;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Continue without login'**
  String get continueWithoutLogin;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Login is optional. All features work without an account.'**
  String get loginOptionalNote;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sign in to protect your data'**
  String get signInToProtectData;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Backup & sync coming soon'**
  String get backupSyncComingSoon;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'View privacy policy'**
  String get privacyPolicySubtitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'View terms and conditions'**
  String get termsOfUseSubtitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Could not open page'**
  String get pageCouldNotOpen;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No medications/supplements yet'**
  String get noMedications;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get supplement;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get medicationName;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get medicationNameRequired;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemDefault;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get ukrainian;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'First Poop'**
  String get tip_siyah_mekonyum_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'In the first 2-4 days, this is normal whether your baby takes breast milk or formula. No need to worry.'**
  String get tip_siyah_mekonyum_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Eye Tracking'**
  String get tip_eye_tracking_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Your baby can clearly see only about 25-30 cm for now. Move your face slowly and let your baby follow with their eyes.'**
  String get tip_eye_tracking_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Neck Support'**
  String get tip_neck_support_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Always support your baby\'s head and neck when holding them. Neck muscles are still very weak.'**
  String get tip_neck_support_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Stepping Reflex'**
  String get tip_reflex_stepping_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Hold your baby upright and let their feet touch a flat surface. You may see stepping reflexes.'**
  String get tip_reflex_stepping_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Interest in Sounds'**
  String get tip_sound_interest_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Your baby is very sensitive to sounds. Try getting attention with a soft rattle or gentle music box.'**
  String get tip_sound_interest_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Parent Interaction'**
  String get tip_parent_interaction_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Make eye contact and talk softly. Your baby recognizes your voice and feels secure with it.'**
  String get tip_parent_interaction_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'World of Colors'**
  String get tip_color_worlds_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Newborns see high-contrast black and white patterns best. Try showing black-and-white cards.'**
  String get tip_color_worlds_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Mini Athlete'**
  String get tip_mini_athlete_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Tummy time strengthens neck and back muscles. Try a few minutes each day.'**
  String get tip_mini_athlete_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sound Hunter'**
  String get tip_sound_hunter_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Snap softly near your baby\'s ear. They may try turning toward the sound.'**
  String get tip_sound_hunter_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Touch Exploration'**
  String get tip_touch_explore_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Let your baby feel different textures on hands and feet: soft, rough, and cool surfaces.'**
  String get tip_touch_explore_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Baby Talk Chats'**
  String get tip_agu_conversation_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'When your baby makes sounds, listen. Reply gently when they finish. These tiny chats build communication.'**
  String get tip_agu_conversation_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Strong Shoulders (Tummy Time)'**
  String get tip_tummy_time_strength_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Place your baby on their tummy for short periods. Encourage head lifting with colorful toys in front.'**
  String get tip_tummy_time_strength_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Soothing Massage'**
  String get tip_baby_massage_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'After bath time, massage gently starting from the feet. It supports body awareness and helps your baby relax.'**
  String get tip_baby_massage_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Gesture-Based Talking'**
  String get tip_gesture_speech_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Use gestures while talking. Wave for \"we\'re going\" and rub hands for \"all done\". This supports visual memory.'**
  String get tip_gesture_speech_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Free Fingers'**
  String get tip_open_hands_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Hands are opening more now. Offer soft toys to practice grasping and releasing.'**
  String get tip_open_hands_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Side-by-Side Bonding'**
  String get tip_side_by_side_bonding_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Lie side by side with your baby. Smile and speak lovingly as they try to turn toward you.'**
  String get tip_side_by_side_bonding_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sound Hunter'**
  String get tip_sound_hunter_listening_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Shake a rattle softly where your baby cannot see it. Turning toward sound builds hearing and focus.'**
  String get tip_sound_hunter_listening_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Sound Hunter (Level 2)'**
  String get tip_sound_hunter_level2_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Make different sounds from left and right. Finding the source strengthens attention skills.'**
  String get tip_sound_hunter_level2_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Touch and Discover'**
  String get tip_texture_discovery_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Offer objects with different textures. Each new feeling is a new discovery for your baby.'**
  String get tip_texture_discovery_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Outdoor Explorer'**
  String get tip_outdoor_explorer_4_5_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Show trees and animals outside. Let your baby touch and explore while hearing your voice.'**
  String get tip_outdoor_explorer_4_5_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Reaching Practice'**
  String get tip_reaching_exercise_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Place toys within reach. Even attempts to grab them help strengthen muscles.'**
  String get tip_reaching_exercise_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Supported Bouncing'**
  String get tip_supported_bounce_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Hold your baby upright on your lap and let them bounce gently with support. It helps leg strength and exploration.'**
  String get tip_supported_bounce_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Visual Tracking'**
  String get tip_visual_tracking_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Move a colorful sound-making toy in slow circles within view. Eye tracking is a great visual exercise.'**
  String get tip_visual_tracking_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Face Play'**
  String get tip_face_play_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Get close, make eye contact, and use playful facial expressions. Your voice and face are your baby\'s favorite toys.'**
  String get tip_face_play_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Emotion Naming'**
  String get tip_emotion_labeling_1_2_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'When your baby cries, name the feeling kindly and reassure them. Feeling understood helps emotional safety.'**
  String get tip_emotion_labeling_1_2_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'First Tasting'**
  String get tip_first_meal_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Start solids based on your doctor\'s advice. Spoon feeding can be fun, but stay alert for allergy signs.'**
  String get tip_first_meal_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Active Hands'**
  String get tip_hand_to_hand_transfer_4_5_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Around months 4-5, babies try moving objects between hands. Offer easy-to-grasp items and observe.'**
  String get tip_hand_to_hand_transfer_4_5_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Supported Sitting'**
  String get tip_supported_sitting_4_5_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Practice supported sitting with pillows. Place a toy in front to motivate balance and upper-body support.'**
  String get tip_supported_sitting_4_5_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Discovering Feet'**
  String get tip_feet_discovery_4_5_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Your baby may catch feet and bring them to the mouth while lying down. Let feet explore different surfaces.'**
  String get tip_feet_discovery_4_5_desc;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Independent Play'**
  String get tip_independent_play_4_5_title;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Place a few textured toys nearby and step back a little. Independent play supports confidence.'**
  String get tip_independent_play_4_5_desc;

  /// No description provided for @ageMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} month old} other{{count} months old}}'**
  String ageMonths(int count);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Comfortable low-light theme'**
  String get darkModeSubtitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Feeding Reminder'**
  String get feedingReminder;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Diaper Reminder'**
  String get diaperReminder;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get dataManagement;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Create report'**
  String get createReport;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Weekly/Monthly insights'**
  String get weeklyMonthlyStats;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllDataTitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all records'**
  String get deleteAllDataSubtitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'This action permanently deletes all records. This cannot be undone.'**
  String get deleteAllDataWarning;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Test Sleep Notification'**
  String get testSleepNotification;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Fire sleep notification now'**
  String get fireSleepNotificationNow;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Test Nursing Notification'**
  String get testNursingNotification;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Fire nursing notification now'**
  String get fireNursingNotificationNow;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Select Baby'**
  String get selectBaby;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add New Baby'**
  String get newBabyAdd;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Baby Profile'**
  String get babyProfileTitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Baby Information'**
  String get babyInformation;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDateLabel;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Growth Records'**
  String get growthRecords;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Delete this baby\'s data'**
  String get deleteThisBabyData;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Other babies are not affected'**
  String get otherBabiesUnaffected;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Only '**
  String get onlyThisBabyPrefix;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **' baby\'s records will be deleted.'**
  String get allRecordsWillBeDeleted;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Other babies are not affected. This action cannot be undone.'**
  String get deleteActionIrreversible;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Birth'**
  String get birth;

  /// No description provided for @monthNumber.
  ///
  /// In en, this message translates to:
  /// **'{month}. Month'**
  String monthNumber(int month);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get selectMonth;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Other month'**
  String get otherMonth;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Scheduled Date'**
  String get scheduledDate;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Vaccine'**
  String get editVaccine;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Vaccine Name'**
  String get vaccineName;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routineFilter;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'As-needed'**
  String get asNeededFilter;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Vaccine protocols'**
  String get vaccineProtocolsFilter;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'As needed'**
  String get asNeeded;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Vaccine protocol'**
  String get vaccineProtocolLabel;

  /// No description provided for @linkedToVaccine.
  ///
  /// In en, this message translates to:
  /// **'linked to {vaccine}'**
  String linkedToVaccine(String vaccine);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No linked vaccine'**
  String get noVaccineLink;

  /// No description provided for @doseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Doses logged: {count}'**
  String doseCountLabel(int count);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Log given now'**
  String get logGivenNow;

  /// No description provided for @logDose.
  ///
  /// In en, this message translates to:
  /// **'Log dose'**
  String get logDose;

  /// No description provided for @givenNow.
  ///
  /// In en, this message translates to:
  /// **'Given now'**
  String get givenNow;

  /// No description provided for @allDoneToday.
  ///
  /// In en, this message translates to:
  /// **'All done today'**
  String get allDoneToday;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @todayProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Today: {done} / {total} doses'**
  String todayProgressLabel(int done, int total);

  /// No description provided for @nextDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Next dose: {value}'**
  String nextDoseLabel(String value);

  /// No description provided for @givenTodayCount.
  ///
  /// In en, this message translates to:
  /// **'Given today: {count}'**
  String givenTodayCount(int count);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Dose logged'**
  String get medicationDoseLogged;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Schedule type'**
  String get scheduleType;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailySchedule;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'As-needed'**
  String get prnSchedule;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add at least one daily time'**
  String get dailyTimeRequired;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @medicationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} reminder'**
  String medicationReminderTitle(String name);

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Time to give this medication'**
  String get medicationReminderBody;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Set reminders for this medication?'**
  String get medicationSetRemindersTitle;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'You can change this later by editing the medication.'**
  String get medicationSetRemindersBody;

  /// No description provided for @medicationReminderBodyWithDose.
  ///
  /// In en, this message translates to:
  /// **'Dose: {dose}'**
  String medicationReminderBodyWithDose(String dose);

  /// No description provided for @notifFeedingTitle.
  ///
  /// In en, this message translates to:
  /// **'🍼 Feeding Reminder'**
  String get notifFeedingTitle;

  /// No description provided for @notifFeedingBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to feed your baby'**
  String get notifFeedingBody;

  /// No description provided for @notifDiaperTitle.
  ///
  /// In en, this message translates to:
  /// **'👶 Diaper Reminder'**
  String get notifDiaperTitle;

  /// No description provided for @notifDiaperBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to check your baby\'s diaper'**
  String get notifDiaperBody;

  /// No description provided for @notifSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep in progress'**
  String get notifSleepTitle;

  /// No description provided for @notifSleepBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the notification to stop'**
  String get notifSleepBody;

  /// No description provided for @notifNursingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nursing in progress'**
  String get notifNursingTitle;

  /// No description provided for @notifNursingTitleWithSide.
  ///
  /// In en, this message translates to:
  /// **'Nursing in progress ({side})'**
  String notifNursingTitleWithSide(String side);

  /// No description provided for @notifNursingBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the notification to stop'**
  String get notifNursingBody;

  /// No description provided for @notifMedTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} reminder'**
  String notifMedTitle(String name);

  /// No description provided for @notifMedBody.
  ///
  /// In en, this message translates to:
  /// **'Dose: {dose} {unit}'**
  String notifMedBody(String dose, String unit);

  /// No description provided for @notifGenericBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get notifGenericBody;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Add vaccine protocol'**
  String get addVaccineProtocol;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Choose existing medication'**
  String get chooseExistingMedication;

  /// UI text
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

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Vaccine protocol added'**
  String get vaccineProtocolAdded;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get diaperWet;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get diaperDirty;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get diaperBoth;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Selected time must be within the last 48 hours'**
  String get eventTimeTooOld;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Feeding'**
  String get editTitleFeeding;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Diaper'**
  String get editTitleDiaper;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Sleep'**
  String get editTitleSleep;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Edit Nursing'**
  String get editTitleNursing;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedMessage;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Already saved a moment ago'**
  String get alreadySavedRecently;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'Not given yet'**
  String get notGivenYet;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get viewHistory;

  /// UI text
  ///
  /// In en, this message translates to:
  /// **'No given history'**
  String get noMedicationHistory;

  /// No description provided for @lastGivenLabel.
  ///
  /// In en, this message translates to:
  /// **'Last given: {value}'**
  String lastGivenLabel(String value);
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
