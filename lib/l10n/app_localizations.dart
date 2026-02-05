import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
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

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
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
  /// **'Bottle'**
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
  /// **'CATEGORY'**
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
  /// **'AMOUNT'**
  String get amount;

  /// No description provided for @milkType.
  ///
  /// In en, this message translates to:
  /// **'MILK TYPE'**
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
  /// **'Tap to set'**
  String get tapToSet;

  /// No description provided for @totalSleep.
  ///
  /// In en, this message translates to:
  /// **'Total sleep: {duration}'**
  String totalSleep(String duration);

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get type;

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
  /// **'OPTIONAL NOTES'**
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
  /// **'RECENT ACTIVITIES'**
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
  /// **'Breastfeeding'**
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
  /// **'{years} Years Old'**
  String ageYears(int years);

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
  /// **'{days} Days Old'**
  String ageDays(int days);

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
  /// **'FEEDING'**
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
  /// **'RECENT ACTIVITY'**
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
  /// **'Bottle Feeding'**
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
