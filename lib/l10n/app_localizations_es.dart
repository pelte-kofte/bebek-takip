// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Nilico';

  @override
  String get tagline => 'Crianza simple e inolvidable.';

  @override
  String get freeForever => 'Gratis para siempre';

  @override
  String get securePrivate => 'Seguro y privado';

  @override
  String get tapToStart => 'Toca para empezar';

  @override
  String get feedingTracker => 'Registro de alimentación';

  @override
  String get feedingTrackerDesc =>
      'Registra lactancia, biberones y sólidos fácilmente. Detecta patrones de forma natural.';

  @override
  String get sleepPatterns => 'Patrones de sueño';

  @override
  String get sleepPatternsDesc =>
      'Comprende el ritmo de tu bebé y mejora la calidad del sueño para todos.';

  @override
  String get growthCharts => 'Gráficos de crecimiento';

  @override
  String get growthChartsDesc =>
      'Visualiza los cambios de altura y peso a lo largo del tiempo con gráficos hermosos.';

  @override
  String get preciousMemories => 'Recuerdos preciosos';

  @override
  String get preciousMemoriesDesc =>
      'Guarda hitos y momentos divertidos. ¡Crecen muy rápido!';

  @override
  String get dailyRhythm => 'Ritmo diario';

  @override
  String get dailyRhythmDesc =>
      'Las rutinas suaves traen días tranquilos y noches apacibles.';

  @override
  String get skip => 'Omitir';

  @override
  String get startYourJourney => 'Comienza tu aventura';

  @override
  String get continueBtn => 'Continuar';

  @override
  String get save => 'Guardar';

  @override
  String get update => 'Actualizar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get ok => 'OK';

  @override
  String get add => 'Añadir';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get share => 'Compartir';

  @override
  String get mlAbbrev => 'ml';

  @override
  String get selectTime => 'Seleccionar hora';

  @override
  String get tapToSetTime => 'Establecer hora';

  @override
  String get notificationSleepFired => 'Notificación de sueño enviada';

  @override
  String get notificationNursingFired => 'Notificación de lactancia enviada';

  @override
  String get signedOutSuccessfully => 'Sesión cerrada correctamente';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get allDataDeleted => 'Todos los datos eliminados';

  @override
  String googleSignInFailed(String error) {
    return 'Error al iniciar sesión con Google: $error';
  }

  @override
  String signInFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String get webPhotoUploadUnsupported =>
      'La carga de fotos no está disponible en la web';

  @override
  String babyDataDeleted(String name) {
    return 'Datos de $name eliminados';
  }

  @override
  String get babyNameHint => 'Nombre del bebé';

  @override
  String get babyNotesHint => 'Alergias, preferencias, notas...';

  @override
  String get vaccineNameHint => 'ej. Hepatitis B, BCG, vacuna combinada';

  @override
  String get vaccineDoseHint => 'ej. Dosis 1, DTaP-IPV-Hib';

  @override
  String get vaccineNameCannotBeEmpty =>
      'El nombre de la vacuna no puede estar vacío';

  @override
  String get growthWeightHint => 'ej. 7,5';

  @override
  String get growthHeightHint => 'ej. 68,5';

  @override
  String get growthNotesHint => 'Visita al médico, día de vacunación, etc.';

  @override
  String get pleaseEnterWeightHeight => 'Introduce peso y altura';

  @override
  String get memoryTitleHint => 'ej. Primeros pasos';

  @override
  String get memoryNoteHint => 'Escribe el recuerdo...';

  @override
  String get home => 'Inicio';

  @override
  String get activities => 'Cuidados';

  @override
  String get vaccines => 'Vacunas';

  @override
  String get development => 'Desarrollo';

  @override
  String get memories => 'Recuerdos';

  @override
  String get settings => 'Ajustes';

  @override
  String get addActivity => 'Añadir actividad';

  @override
  String get whatHappened => '¿Qué pasó?';

  @override
  String get nursing => 'Lactancia';

  @override
  String get bottle => 'Biberón';

  @override
  String get sleep => 'Sueño';

  @override
  String get diaper => 'Pañal';

  @override
  String get side => 'Lado';

  @override
  String get left => 'Izquierdo';

  @override
  String get right => 'Derecho';

  @override
  String get duration => 'Duración';

  @override
  String get minAbbrev => 'min';

  @override
  String get hourAbbrev => 'h';

  @override
  String get category => 'Categoría';

  @override
  String get milk => 'Leche';

  @override
  String get solid => 'Sólido';

  @override
  String get whatWasGiven => '¿QUÉ SE DIO?';

  @override
  String get solidFoodHint => 'Ej.: puré de plátano, zanahoria...';

  @override
  String get amount => 'Cantidad';

  @override
  String get milkType => 'Tipo de leche';

  @override
  String get breastMilk => 'Leche materna';

  @override
  String get formula => 'Fórmula';

  @override
  String get sleepStartedAt => 'SUEÑO EMPEZÓ A LAS';

  @override
  String get wokeUpAt => 'SE DESPERTÓ A LAS';

  @override
  String get tapToSet => 'Establecer hora';

  @override
  String totalSleep(String duration) {
    return 'Sueño total: $duration';
  }

  @override
  String get type => 'Tipo';

  @override
  String get healthType => 'Tipo';

  @override
  String get healthTime => 'Hora';

  @override
  String get wet => 'Mojado';

  @override
  String get dirty => 'Sucio';

  @override
  String get both => 'Ambos';

  @override
  String get optionalNotes => 'Notas opcionales';

  @override
  String get diaperNoteHint => 'Añade una nota sobre el cambio de pañal...';

  @override
  String get pleaseSetDuration => 'Establece una duración';

  @override
  String get pleaseSetAmount => 'Establece una cantidad';

  @override
  String get pleaseSetWakeUpTime => 'Establece la hora de despertar';

  @override
  String get sleepDurationMustBeGreater =>
      'La duración del sueño debe ser mayor que 0';

  @override
  String get today => 'Hoy';

  @override
  String get summary => 'RESUMEN';

  @override
  String get recentActivities => 'REGISTROS DE CUIDADOS RECIENTES';

  @override
  String get record => 'registro';

  @override
  String get records => 'registros';

  @override
  String get breastfeeding => 'Lactancia';

  @override
  String get bottleBreastMilk => 'Biberón (leche materna)';

  @override
  String get total => 'Total';

  @override
  String get diaperChange => 'Cambio de pañal';

  @override
  String get firstFeedingTime => '¿Hora de la primera toma?';

  @override
  String get trackBabyFeeding => 'Registra la alimentación de tu bebé';

  @override
  String get diaperChangeTime => '¡Hora de cambiar el pañal!';

  @override
  String get trackHygiene => 'Registra la higiene aquí';

  @override
  String get sweetDreams => 'Dulces sueños...';

  @override
  String get trackSleepPattern => 'Registra el patrón de sueño aquí';

  @override
  String get selectAnotherDate => 'Seleccionar otra fecha';

  @override
  String get editFeeding => 'Editar alimentación';

  @override
  String get editDiaper => 'Editar pañal';

  @override
  String get editSleep => 'Editar sueño';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get attention => 'Atención';

  @override
  String get deleteConfirm =>
      '¿Estás seguro de que quieres eliminar este registro?';

  @override
  String get myVaccines => 'Mis vacunas';

  @override
  String get addVaccine => 'Añadir vacuna';

  @override
  String get applied => 'Aplicada';

  @override
  String get pending => 'Pendiente';

  @override
  String get upcomingVaccines => 'Próximas vacunas';

  @override
  String get completedVaccines => 'Vacunas completadas';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get calendar => 'Calendario';

  @override
  String get turkishVaccineCalendar => 'Calendario de vacunación turco';

  @override
  String vaccinesAvailable(int count) {
    return '$count vacunas disponibles';
  }

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get clear => 'Limpiar';

  @override
  String get alreadyAdded => 'Ya añadida';

  @override
  String addVaccines(int count) {
    return 'Añadir $count vacunas';
  }

  @override
  String get selectVaccine => 'Seleccionar vacuna';

  @override
  String vaccinesAdded(int count) {
    return '$count vacunas añadidas';
  }

  @override
  String get noVaccineRecords => 'No hay registros de vacunas aún';

  @override
  String get loadTurkishCalendar =>
      'Carga el calendario turco o añade manualmente';

  @override
  String get loadTurkishVaccineCalendar =>
      'Cargar calendario de vacunación turco';

  @override
  String get loadCalendarTitle => 'Cargar calendario de vacunación turco';

  @override
  String get loadCalendarDesc =>
      'Se cargará el calendario de vacunación turco estándar. Las vacunas existentes no se eliminarán.';

  @override
  String ageYears(int years) {
    return '$years años';
  }

  @override
  String ageYearsMonths(int years, int months) {
    return '$years año $months meses';
  }

  @override
  String ageMonthsDays(int months, int days) {
    return '$months meses $days días';
  }

  @override
  String ageDays(int days) {
    return '$days días';
  }

  @override
  String get weeklyReport => 'Informe semanal';

  @override
  String get monthlyReport => 'Informe mensual';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get feeding => 'Alimentación';

  @override
  String get totalBreastfeeding => 'Total lactancia';

  @override
  String get totalDuration => 'Duración total';

  @override
  String get dailyAvg => 'Prom. diario';

  @override
  String get avgDuration => 'Duración prom.';

  @override
  String get leftBreast => 'Pecho izquierdo';

  @override
  String get rightBreast => 'Pecho derecho';

  @override
  String get solidFood => 'Alimento sólido';

  @override
  String get diaperChanges => 'Cambios de pañal';

  @override
  String get longestSleep => 'Sueño más largo';

  @override
  String get sleepCount => 'Núm. de sueños';

  @override
  String get growth => 'Crecimiento';

  @override
  String get height => 'Altura';

  @override
  String get weight => 'Peso';

  @override
  String get saveAsPdf => 'Guardar como PDF';

  @override
  String get pdfMobileOnly => 'El PDF está disponible en móvil';

  @override
  String get sharingMobileOnly => 'Compartir está disponible en móvil';

  @override
  String get pdfSaved => '¡PDF guardado correctamente!';

  @override
  String get babyTrackerReport => 'Informe del seguimiento del bebé';

  @override
  String get generatedWith => 'Generado con Baby Tracker App';

  @override
  String get months => 'meses';

  @override
  String get january => 'Enero';

  @override
  String get february => 'Febrero';

  @override
  String get march => 'Marzo';

  @override
  String get april => 'Abril';

  @override
  String get may => 'Mayo';

  @override
  String get june => 'Junio';

  @override
  String get july => 'Julio';

  @override
  String get august => 'Agosto';

  @override
  String get september => 'Septiembre';

  @override
  String get october => 'Octubre';

  @override
  String get november => 'Noviembre';

  @override
  String get december => 'Diciembre';

  @override
  String get addOptionalNote => 'Añadir nota (opcional)';

  @override
  String get times => 'veces';

  @override
  String get feeding_tab => 'ALIMENTACIÓN';

  @override
  String get diaper_tab => 'PAÑAL';

  @override
  String get sleep_tab => 'SUEÑO';

  @override
  String get list => 'Lista';

  @override
  String get chart => 'Gráfico';

  @override
  String get noMeasurements => 'No hay mediciones aún';

  @override
  String get addMeasurements => 'Añade mediciones de altura y peso';

  @override
  String get moreDataNeeded => 'Se necesitan más datos para el gráfico';

  @override
  String addMoreMeasurements(int count) {
    return 'Añade $count mediciones más';
  }

  @override
  String get atLeast2Measurements =>
      'Se necesitan al menos 2 mediciones para el gráfico';

  @override
  String get growthTracking => 'Seguimiento de crecimiento';

  @override
  String get feedingTimer => 'LACTANCIA';

  @override
  String get sleepingTimer => 'DURMIENDO';

  @override
  String get stopAndSave => 'PARAR Y GUARDAR';

  @override
  String get activeTimer => 'ACTIVO';

  @override
  String get lastFed => 'ÚLT. ALIMENTACIÓN';

  @override
  String get lastDiaper => 'ÚLT. PAÑAL';

  @override
  String get lastSleep => 'ÚLT. SUEÑO';

  @override
  String get recentActivity => 'REGISTROS DE CUIDADOS RECIENTES';

  @override
  String get seeHistory => 'VER HISTORIAL';

  @override
  String get noActivitiesLast24h => 'Sin actividad en las últimas 24 horas';

  @override
  String get bottleFeeding => 'Biberón';

  @override
  String get trackYourBabyGrowth => 'Sigue el crecimiento de tu bebé';

  @override
  String get addHeightWeightMeasurements => 'Añade mediciones de peso y altura';

  @override
  String get addFirstMeasurement => 'Añadir primera medición';

  @override
  String get lastUpdatedToday => 'Actualizado hoy';

  @override
  String get lastUpdated1Day => 'Actualizado hace 1 día';

  @override
  String lastUpdatedDays(int days) {
    return 'Actualizado hace $days días';
  }

  @override
  String get viewGrowthCharts => 'VER GRÁFICOS DE CRECIMIENTO';

  @override
  String get weightLabel => 'PESO';

  @override
  String get heightLabel => 'ALTURA';

  @override
  String mAgo(int count) {
    return 'hace ${count}min';
  }

  @override
  String hmAgo(int hours, int minutes) {
    return 'hace ${hours}h ${minutes}min';
  }

  @override
  String dAgo(int days) {
    return 'hace ${days}d';
  }

  @override
  String get noRecordsYet => 'No hay registros aún';

  @override
  String get dailyTip => 'CONSEJO DEL DÍA';

  @override
  String get allTips => 'Todos los consejos';

  @override
  String get upcomingVaccine => 'PRÓXIMA VACUNA';

  @override
  String nextVaccineLabel(String name) {
    return 'Siguiente: $name';
  }

  @override
  String leftMinRightMin(int left, int right) {
    return 'I ${left}min • D ${right}min';
  }

  @override
  String breastfeedingSavedSnack(int left, int right) {
    return '✅ Lactancia guardada: I ${left}min, D ${right}min';
  }

  @override
  String sleepSavedSnack(String duration) {
    return '✅ Sueño guardado: $duration';
  }

  @override
  String get sleepTooShort => '⚠️ Sueño menor a 1 minuto, no guardado';

  @override
  String kgThisMonth(String value) {
    return '+${value}kg este mes';
  }

  @override
  String cmThisMonth(String value) {
    return '+${value}cm este mes';
  }

  @override
  String get noSleep => 'Sin sueño';

  @override
  String get justNow => 'ahora mismo';

  @override
  String minutesAgo(int count) {
    return 'hace $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'hace ${count}h';
  }

  @override
  String daysAgo(int count) {
    return 'hace ${count}d';
  }

  @override
  String get welcomeToNilico => 'Bienvenido a Nilico';

  @override
  String get createYourAccount => 'Crea tu cuenta';

  @override
  String get loginBenefitText =>
      'Inicia sesión para prepararte para las funciones de copia de seguridad y sincronización que llegarán pronto. También puedes continuar sin iniciar sesión.';

  @override
  String get signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get continueWithoutLogin => 'Continuar sin iniciar sesión';

  @override
  String get loginOptionalNote =>
      'El inicio de sesión es opcional. Todas las funciones funcionan sin cuenta.';

  @override
  String get account => 'Cuenta';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String signedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get guestMode => 'Modo invitado';

  @override
  String get signInToProtectData => 'Inicia sesión para proteger tus datos';

  @override
  String get backupSyncComingSoon =>
      'Copia de seguridad y sincronización pronto';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicySubtitle => 'Ver política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get termsOfUseSubtitle => 'Ver términos y condiciones';

  @override
  String get pageCouldNotOpen => 'No se pudo abrir la página';

  @override
  String get health => 'Salud';

  @override
  String get medications => 'Medicamentos';

  @override
  String get noMedications => 'No hay medicamentos ni suplementos aún';

  @override
  String get medication => 'Medicamento';

  @override
  String get supplement => 'Suplemento';

  @override
  String get addMedication => 'Añadir medicamento';

  @override
  String get editMedication => 'Editar medicamento';

  @override
  String get medicationName => 'Nombre';

  @override
  String get medicationNameRequired => 'Introduce un nombre';

  @override
  String get dosage => 'Dosis';

  @override
  String get schedule => 'Horario';

  @override
  String get notes => 'Notas';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Sistema';

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
  String get languageUpdated => 'Idioma actualizado';
}
