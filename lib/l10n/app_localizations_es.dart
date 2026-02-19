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
  String get feedingTracker => 'Registro de alimentaciÃ³n';

  @override
  String get feedingTrackerDesc =>
      'Registra lactancia, biberones y sÃ³lidos fÃ¡cilmente. Detecta patrones de forma natural.';

  @override
  String get sleepPatterns => 'Patrones de sueÃ±o';

  @override
  String get sleepPatternsDesc =>
      'Comprende el ritmo de tu bebÃ© y mejora la calidad del sueÃ±o para todos.';

  @override
  String get growthCharts => 'GrÃ¡ficos de crecimiento';

  @override
  String get growthChartsDesc =>
      'Visualiza los cambios de altura y peso a lo largo del tiempo con grÃ¡ficos hermosos.';

  @override
  String get preciousMemories => 'Recuerdos preciosos';

  @override
  String get preciousMemoriesDesc =>
      'Guarda hitos y momentos divertidos. Â¡Crecen muy rÃ¡pido!';

  @override
  String get dailyRhythm => 'Ritmo diario';

  @override
  String get dailyRhythmDesc =>
      'Las rutinas suaves traen dÃ­as tranquilos y noches apacibles.';

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
  String get add => 'AÃ±adir';

  @override
  String get yes => 'SÃ­';

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
  String get notificationSleepFired => 'NotificaciÃ³n de sueÃ±o enviada';

  @override
  String get notificationNursingFired => 'NotificaciÃ³n de lactancia enviada';

  @override
  String get signedOutSuccessfully => 'SesiÃ³n cerrada correctamente';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get allDataDeleted => 'Todos los datos eliminados';

  @override
  String googleSignInFailed(String error) {
    return 'Error al iniciar sesiÃ³n con Google: $error';
  }

  @override
  String signInFailed(String error) {
    return 'Error al iniciar sesiÃ³n: $error';
  }

  @override
  String get webPhotoUploadUnsupported =>
      'La carga de fotos no estÃ¡ disponible en la web';

  @override
  String babyDataDeleted(String name) {
    return 'Datos de $name eliminados';
  }

  @override
  String get babyNameHint => 'Nombre del bebÃ©';

  @override
  String get babyNotesHint => 'Alergias, preferencias, notas...';

  @override
  String get vaccineNameHint => 'ej. Hepatitis B, BCG, vacuna combinada';

  @override
  String get vaccineDoseHint => 'ej. Dosis 1, DTaP-IPV-Hib';

  @override
  String get vaccineNameCannotBeEmpty =>
      'El nombre de la vacuna no puede estar vacÃ­o';

  @override
  String get growthWeightHint => 'ej. 7,5';

  @override
  String get growthHeightHint => 'ej. 68,5';

  @override
  String get growthNotesHint => 'Visita al mÃ©dico, dÃ­a de vacunaciÃ³n, etc.';

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
  String get addActivity => 'AÃ±adir actividad';

  @override
  String get whatHappened => 'Â¿QuÃ© pasÃ³?';

  @override
  String get nursing => 'Lactancia';

  @override
  String get bottle => 'BiberÃ³n';

  @override
  String get sleep => 'SueÃ±o';

  @override
  String get diaper => 'PaÃ±al';

  @override
  String get side => 'Lado';

  @override
  String get left => 'Izquierdo';

  @override
  String get right => 'Derecho';

  @override
  String get duration => 'DuraciÃ³n';

  @override
  String get minAbbrev => 'min';

  @override
  String get hourAbbrev => 'h';

  @override
  String get category => 'CategorÃ­a';

  @override
  String get milk => 'Leche';

  @override
  String get solid => 'SÃ³lido';

  @override
  String get whatWasGiven => 'Â¿QUÃ‰ SE DIO?';

  @override
  String get solidFoodHint => 'Ej.: purÃ© de plÃ¡tano, zanahoria...';

  @override
  String get amount => 'Cantidad';

  @override
  String get milkType => 'Tipo de leche';

  @override
  String get breastMilk => 'Leche materna';

  @override
  String get formula => 'FÃ³rmula';

  @override
  String get sleepStartedAt => 'SUEÃ‘O EMPEZÃ“ A LAS';

  @override
  String get wokeUpAt => 'SE DESPERTÃ“ A LAS';

  @override
  String get tapToSet => 'Establecer hora';

  @override
  String totalSleep(String duration) {
    return 'SueÃ±o total: $duration';
  }

  @override
  String get type => 'Tipo';

  @override
  String get healthType => 'Tipo';

  @override
  String get healthTime => 'Hora';

  @override
  String get time => 'Hora';

  @override
  String get wet => 'Mojado';

  @override
  String get dirty => 'Sucio';

  @override
  String get both => 'Ambos';

  @override
  String get diaperWet => 'Mojado';

  @override
  String get diaperDirty => 'Sucio';

  @override
  String get diaperBoth => 'Ambos';

  @override
  String get optionalNotes => 'Notas opcionales';

  @override
  String get diaperNoteHint => 'AÃ±ade una nota sobre el cambio de paÃ±al...';

  @override
  String get pleaseSetDuration => 'Establece una duraciÃ³n';

  @override
  String get pleaseSetAmount => 'Establece una cantidad';

  @override
  String get pleaseSetWakeUpTime => 'Establece la hora de despertar';

  @override
  String get sleepDurationMustBeGreater =>
      'La duraciÃ³n del sueÃ±o debe ser mayor que 0';

  @override
  String get eventTimeTooOld =>
      'La hora seleccionada debe estar dentro de las Ãºltimas 48 horas';

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
  String get bottleBreastMilk => 'BiberÃ³n (leche materna)';

  @override
  String get total => 'Total';

  @override
  String get diaperChange => 'Cambio de paÃ±al';

  @override
  String get firstFeedingTime => 'Â¿Hora de la primera toma?';

  @override
  String get trackBabyFeeding => 'Registra la alimentaciÃ³n de tu bebÃ©';

  @override
  String get diaperChangeTime => 'Â¡Hora de cambiar el paÃ±al!';

  @override
  String get trackHygiene => 'Registra la higiene aquÃ­';

  @override
  String get sweetDreams => 'Dulces sueÃ±os...';

  @override
  String get trackSleepPattern => 'Registra el patrÃ³n de sueÃ±o aquÃ­';

  @override
  String get selectAnotherDate => 'Seleccionar otra fecha';

  @override
  String get editFeeding => 'Editar alimentaciÃ³n';

  @override
  String get editDiaper => 'Editar paÃ±al';

  @override
  String get editSleep => 'Editar sueÃ±o';

  @override
  String get editTitleFeeding => 'Editar alimentaciÃ³n';

  @override
  String get editTitleDiaper => 'Editar paÃ±al';

  @override
  String get editTitleSleep => 'Editar sueÃ±o';

  @override
  String get editTitleNursing => 'Editar lactancia';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get attention => 'AtenciÃ³n';

  @override
  String get deleteConfirm =>
      'Â¿EstÃ¡s seguro de que quieres eliminar este registro?';

  @override
  String get myVaccines => 'Mis vacunas';

  @override
  String get addVaccine => 'AÃ±adir vacuna';

  @override
  String get applied => 'Aplicada';

  @override
  String get pending => 'Pendiente';

  @override
  String get upcomingVaccines => 'PrÃ³ximas vacunas';

  @override
  String get completedVaccines => 'Vacunas completadas';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get calendar => 'Calendario';

  @override
  String get turkishVaccineCalendar => 'Calendario de vacunaciÃ³n turco';

  @override
  String vaccinesAvailable(int count) {
    return '$count vacunas disponibles';
  }

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get clear => 'Limpiar';

  @override
  String get alreadyAdded => 'Ya aÃ±adida';

  @override
  String addVaccines(int count) {
    return 'AÃ±adir $count vacunas';
  }

  @override
  String get selectVaccine => 'Seleccionar vacuna';

  @override
  String vaccinesAdded(int count) {
    return '$count vacunas aÃ±adidas';
  }

  @override
  String get noVaccineRecords => 'No hay registros de vacunas aÃºn';

  @override
  String get loadTurkishCalendar =>
      'Carga el calendario turco o aÃ±ade manualmente';

  @override
  String get loadTurkishVaccineCalendar =>
      'Cargar calendario de vacunaciÃ³n turco';

  @override
  String get loadCalendarTitle => 'Cargar calendario de vacunaciÃ³n turco';

  @override
  String get loadCalendarDesc =>
      'Se cargarÃ¡ el calendario de vacunaciÃ³n turco estÃ¡ndar. Las vacunas existentes no se eliminarÃ¡n.';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aÃ±os',
      one: '$count aÃ±o',
    );
    return '$_temp0';
  }

  @override
  String ageYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years aÃ±os',
      one: '$years aÃ±o',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '$months mes',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String ageMonthsDays(int months, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '$months mes',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dÃ­as',
      one: '$days dÃ­a',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dÃ­as',
      one: '$count dÃ­a',
    );
    return '$_temp0';
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
  String get feeding => 'AlimentaciÃ³n';

  @override
  String get totalBreastfeeding => 'Total lactancia';

  @override
  String get totalDuration => 'DuraciÃ³n total';

  @override
  String get dailyAvg => 'Prom. diario';

  @override
  String get avgDuration => 'DuraciÃ³n prom.';

  @override
  String get leftBreast => 'Pecho izquierdo';

  @override
  String get rightBreast => 'Pecho derecho';

  @override
  String get solidFood => 'Alimento sÃ³lido';

  @override
  String get diaperChanges => 'Cambios de paÃ±al';

  @override
  String get longestSleep => 'SueÃ±o mÃ¡s largo';

  @override
  String get sleepCount => 'NÃºm. de sueÃ±os';

  @override
  String get growth => 'Crecimiento';

  @override
  String get height => 'Altura';

  @override
  String get weight => 'Peso';

  @override
  String get saveAsPdf => 'Guardar como PDF';

  @override
  String get pdfMobileOnly => 'El PDF estÃ¡ disponible en mÃ³vil';

  @override
  String get sharingMobileOnly => 'Compartir estÃ¡ disponible en mÃ³vil';

  @override
  String get pdfSaved => 'Â¡PDF guardado correctamente!';

  @override
  String get babyTrackerReport => 'Informe del seguimiento del bebÃ©';

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
  String get addOptionalNote => 'AÃ±adir nota (opcional)';

  @override
  String get times => 'veces';

  @override
  String get feeding_tab => 'ALIMENTACIÃ“N';

  @override
  String get diaper_tab => 'PAÃ‘AL';

  @override
  String get sleep_tab => 'SUEÃ‘O';

  @override
  String get list => 'Lista';

  @override
  String get chart => 'GrÃ¡fico';

  @override
  String get noMeasurements => 'No hay mediciones aÃºn';

  @override
  String get addMeasurements => 'AÃ±ade mediciones de altura y peso';

  @override
  String get moreDataNeeded => 'Se necesitan mÃ¡s datos para el grÃ¡fico';

  @override
  String addMoreMeasurements(int count) {
    return 'AÃ±ade $count mediciones mÃ¡s';
  }

  @override
  String get atLeast2Measurements =>
      'Se necesitan al menos 2 mediciones para el grÃ¡fico';

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
  String get lastFed => 'ÃšLT. ALIMENTACIÃ“N';

  @override
  String get lastDiaper => 'ÃšLT. PAÃ‘AL';

  @override
  String get lastSleep => 'ÃšLT. SUEÃ‘O';

  @override
  String get recentActivity => 'REGISTROS DE CUIDADOS RECIENTES';

  @override
  String get seeHistory => 'VER HISTORIAL';

  @override
  String get noActivitiesLast24h => 'Sin actividad en las Ãºltimas 24 horas';

  @override
  String get bottleFeeding => 'BiberÃ³n';

  @override
  String get trackYourBabyGrowth => 'Sigue el crecimiento de tu bebÃ©';

  @override
  String get addHeightWeightMeasurements =>
      'AÃ±ade mediciones de peso y altura';

  @override
  String get addFirstMeasurement => 'AÃ±adir primera mediciÃ³n';

  @override
  String get lastUpdatedToday => 'Actualizado hoy';

  @override
  String get lastUpdated1Day => 'Actualizado hace 1 dÃ­a';

  @override
  String lastUpdatedDays(int days) {
    return 'Actualizado hace $days dÃ­as';
  }

  @override
  String get viewGrowthCharts => 'VER GRÃFICOS DE CRECIMIENTO';

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
  String get noRecordsYet => 'No hay registros aÃºn';

  @override
  String get dailyTip => 'CONSEJO DEL DÃA';

  @override
  String get allTips => 'Todos los consejos';

  @override
  String get upcomingVaccine => 'PRÃ“XIMA VACUNA';

  @override
  String nextVaccineLabel(String name) {
    return 'Siguiente: $name';
  }

  @override
  String leftMinRightMin(int left, int right) {
    return 'I ${left}min â€¢ D ${right}min';
  }

  @override
  String breastfeedingSavedSnack(int left, int right) {
    return 'âœ… Lactancia guardada: I ${left}min, D ${right}min';
  }

  @override
  String sleepSavedSnack(String duration) {
    return 'âœ… SueÃ±o guardado: $duration';
  }

  @override
  String get sleepTooShort => 'âš ï¸ SueÃ±o menor a 1 minuto, no guardado';

  @override
  String kgThisMonth(String value) {
    return '+${value}kg este mes';
  }

  @override
  String cmThisMonth(String value) {
    return '+${value}cm este mes';
  }

  @override
  String get noSleep => 'Sin sueÃ±o';

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
      'Inicia sesiÃ³n para prepararte para las funciones de copia de seguridad y sincronizaciÃ³n que llegarÃ¡n pronto. TambiÃ©n puedes continuar sin iniciar sesiÃ³n.';

  @override
  String get signInWithApple => 'Iniciar sesiÃ³n con Apple';

  @override
  String get signInWithGoogle => 'Iniciar sesiÃ³n con Google';

  @override
  String get continueWithoutLogin => 'Continuar sin iniciar sesiÃ³n';

  @override
  String get loginOptionalNote =>
      'El inicio de sesiÃ³n es opcional. Todas las funciones funcionan sin cuenta.';

  @override
  String get account => 'Cuenta';

  @override
  String get signIn => 'Iniciar sesiÃ³n';

  @override
  String get signOut => 'Cerrar sesiÃ³n';

  @override
  String signedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get guestMode => 'Modo invitado';

  @override
  String get signInToProtectData => 'Inicia sesiÃ³n para proteger tus datos';

  @override
  String get backupSyncComingSoon =>
      'Copia de seguridad y sincronizaciÃ³n pronto';

  @override
  String get privacyPolicy => 'PolÃ­tica de privacidad';

  @override
  String get privacyPolicySubtitle => 'Ver polÃ­tica de privacidad';

  @override
  String get termsOfUse => 'TÃ©rminos de uso';

  @override
  String get termsOfUseSubtitle => 'Ver tÃ©rminos y condiciones';

  @override
  String get pageCouldNotOpen => 'No se pudo abrir la pÃ¡gina';

  @override
  String get health => 'Salud';

  @override
  String get medications => 'Medicamentos';

  @override
  String get noMedications => 'No hay medicamentos ni suplementos aÃºn';

  @override
  String get medication => 'Medicamento';

  @override
  String get supplement => 'Suplemento';

  @override
  String get addMedication => 'AÃ±adir medicamento';

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
  String get turkish => 'TÃ¼rkÃ§e';

  @override
  String get english => 'English';

  @override
  String get russian => 'Ğ ÑƒÑÑĞºĞ¸Ğ¹';

  @override
  String get ukrainian => 'Ğ£ĞºÑ€Ğ°Ñ—Ğ½ÑÑŒĞºĞ°';

  @override
  String get spanish => 'EspaÃ±ol';

  @override
  String get languageUpdated => 'Idioma actualizado';

  @override
  String get tip_siyah_mekonyum_title => 'Primera caca';

  @override
  String get tip_siyah_mekonyum_desc =>
      'Durante los primeros 2-4 dÃ­as, esto es normal tanto si tu bebÃ© toma leche materna como fÃ³rmula. No hay motivo de preocupaciÃ³n.';

  @override
  String get tip_eye_tracking_title => 'Seguimiento visual';

  @override
  String get tip_eye_tracking_desc =>
      'Por ahora, tu bebÃ© solo ve con claridad a unos 25-30 cm. Acerca tu rostro y muÃ©vete despacio para que intente seguirte con la mirada.';

  @override
  String get tip_neck_support_title => 'Soporte del cuello';

  @override
  String get tip_neck_support_desc =>
      'SostÃ©n siempre la cabeza y el cuello de tu bebÃ© al cargarlo. Los mÃºsculos del cuello todavÃ­a son muy dÃ©biles.';

  @override
  String get tip_reflex_stepping_title => 'Reflejo de pasos';

  @override
  String get tip_reflex_stepping_desc =>
      'SostÃ©n a tu bebÃ© en posiciÃ³n vertical y deja que sus pies toquen una superficie plana. Es posible que veas el reflejo de dar pasos.';

  @override
  String get tip_sound_interest_title => 'InterÃ©s por los sonidos';

  @override
  String get tip_sound_interest_desc =>
      'Tu bebÃ© es muy sensible a los sonidos. Prueba captar su atenciÃ³n con un sonajero suave o una cajita de mÃºsica.';

  @override
  String get tip_parent_interaction_title => 'InteracciÃ³n con los padres';

  @override
  String get tip_parent_interaction_desc =>
      'Haz contacto visual y habla con voz suave. Tu bebÃ© reconoce tu voz y se siente seguro con ella.';

  @override
  String get tip_color_worlds_title => 'Mundo de colores';

  @override
  String get tip_color_worlds_desc =>
      'Los reciÃ©n nacidos ven mejor los contrastes en blanco y negro. Puedes mostrarle tarjetas con ese tipo de patrones.';

  @override
  String get tip_mini_athlete_title => 'PequeÃ±o atleta';

  @override
  String get tip_mini_athlete_desc =>
      'El tiempo boca abajo fortalece los mÃºsculos del cuello y la espalda. IntÃ©ntalo unos minutos cada dÃ­a.';

  @override
  String get tip_sound_hunter_title => 'Cazador de sonidos';

  @override
  String get tip_sound_hunter_desc =>
      'Haz un chasquido suave cerca de la oreja de tu bebÃ©. Puede intentar girar la cabeza hacia el sonido.';

  @override
  String get tip_touch_explore_title => 'ExploraciÃ³n tÃ¡ctil';

  @override
  String get tip_touch_explore_desc =>
      'Permite que tu bebÃ© toque diferentes texturas con manos y pies: superficies suaves, rugosas y frescas.';

  @override
  String get tip_tip_agu_conversation_1_2_title => 'Charlas de balbuceo';

  @override
  String get tip_tip_agu_conversation_1_2_desc =>
      'Cuando tu bebÃ© emita sonidos, escÃºchalo. RespÃ³ndele con suavidad cuando termine. Estas pequeÃ±as charlas construyen la comunicaciÃ³n.';

  @override
  String get tip_tip_tummy_time_strength_1_2_title =>
      'Hombros fuertes (tiempo boca abajo)';

  @override
  String get tip_tip_tummy_time_strength_1_2_desc =>
      'Coloca a tu bebÃ© boca abajo por periodos cortos. AnÃ­malo a levantar la cabeza con juguetes coloridos delante.';

  @override
  String get tip_tip_baby_massage_1_2_title => 'Masaje relajante';

  @override
  String get tip_tip_baby_massage_1_2_desc =>
      'DespuÃ©s del baÃ±o, masajea suavemente empezando por los pies. Favorece la conciencia corporal y ayuda a tu bebÃ© a relajarse.';

  @override
  String get tip_tip_gesture_speech_1_2_title => 'Hablar con gestos';

  @override
  String get tip_tip_gesture_speech_1_2_desc =>
      'Usa gestos mientras hablas. Saluda con la mano para nos vamos y frota las manos para terminamos. Esto fortalece la memoria visual.';

  @override
  String get tip_tip_open_hands_1_2_title => 'Dedos libres';

  @override
  String get tip_tip_open_hands_1_2_desc =>
      'Sus manos se abren cada vez mÃ¡s. OfrÃ©cele juguetes suaves para practicar agarrar y soltar.';

  @override
  String get tip_tip_side_by_side_bonding_1_2_title => 'VÃ­nculo lado a lado';

  @override
  String get tip_tip_side_by_side_bonding_1_2_desc =>
      'AcuÃ©state junto a tu bebÃ©. SonrÃ­e y hÃ¡blale con cariÃ±o mientras intenta girarse hacia ti.';

  @override
  String get tip_tip_sound_hunter_title => 'Cazador de sonidos';

  @override
  String get tip_tip_sound_hunter_desc =>
      'Agita un sonajero suavemente en un punto que tu bebÃ© no vea. Girar hacia el sonido favorece la audiciÃ³n y la atenciÃ³n.';

  @override
  String get tip_tip_sound_hunter_level2_1_2_title =>
      'Cazador de sonidos (nivel 2)';

  @override
  String get tip_tip_sound_hunter_level2_1_2_desc =>
      'Haz sonidos diferentes a su izquierda y derecha. Buscar el origen fortalece su capacidad de atenciÃ³n.';

  @override
  String get tip_tip_texture_discovery_1_2_title => 'Tocar y descubrir';

  @override
  String get tip_tip_texture_discovery_1_2_desc =>
      'OfrÃ©cele objetos con distintas texturas. Cada nueva sensaciÃ³n es un nuevo descubrimiento para tu bebÃ©.';

  @override
  String get tip_tip_outdoor_explorer_4_5_title => 'Explorador al aire libre';

  @override
  String get tip_tip_outdoor_explorer_4_5_desc =>
      'MuÃ©strale Ã¡rboles y animales cuando estÃ©n afuera. DÃ©jalo tocar y explorar mientras escucha tu voz.';

  @override
  String get tip_tip_reaching_exercise_1_2_title => 'PrÃ¡ctica de alcance';

  @override
  String get tip_tip_reaching_exercise_1_2_desc =>
      'Coloca juguetes a su alcance. Incluso intentar agarrarlos ayuda a fortalecer sus mÃºsculos.';

  @override
  String get tip_tip_supported_bounce_1_2_title => 'Rebote con apoyo';

  @override
  String get tip_tip_supported_bounce_1_2_desc =>
      'SostÃ©n a tu bebÃ© erguido sobre tu regazo y permite un rebote suave con apoyo. Ayuda a fortalecer las piernas y a explorar.';

  @override
  String get tip_tip_visual_tracking_1_2_title => 'Seguimiento visual';

  @override
  String get tip_tip_visual_tracking_1_2_desc =>
      'Mueve lentamente un juguete colorido que haga sonido dentro de su campo visual. Es un gran ejercicio para el seguimiento visual.';

  @override
  String get tip_tip_face_play_1_2_title => 'Juego de expresiones';

  @override
  String get tip_tip_face_play_1_2_desc =>
      'AcÃ©rcate, haz contacto visual y usa expresiones faciales divertidas. Tu voz y tu rostro son sus juguetes favoritos.';

  @override
  String get tip_tip_emotion_labeling_1_2_title => 'Nombrar emociones';

  @override
  String get tip_tip_emotion_labeling_1_2_desc =>
      'Cuando tu bebÃ© llore, nombra la emociÃ³n con calma y reconfÃ³rtalo. Sentirse comprendido favorece su seguridad emocional.';

  @override
  String get tip_tip_first_meal_title => 'Primera degustaciÃ³n';

  @override
  String get tip_tip_first_meal_desc =>
      'Inicia los sÃ³lidos segÃºn la recomendaciÃ³n de tu pediatra. Dar comida con cuchara puede ser divertido, pero observa posibles signos de alergia.';

  @override
  String get tip_tip_hand_to_hand_transfer_4_5_title => 'Manos activas';

  @override
  String get tip_tip_hand_to_hand_transfer_4_5_desc =>
      'Hacia los 4-5 meses, los bebÃ©s intentan pasar objetos de una mano a otra. OfrÃ©cele objetos fÃ¡ciles de agarrar y obsÃ©rvalo.';

  @override
  String get tip_tip_supported_sitting_4_5_title => 'Sentado con apoyo';

  @override
  String get tip_tip_supported_sitting_4_5_desc =>
      'Practica sentado con apoyo usando cojines. Coloca un juguete delante para motivar el equilibrio y el apoyo del tronco superior.';

  @override
  String get tip_tip_feet_discovery_4_5_title => 'Descubriendo los pies';

  @override
  String get tip_tip_feet_discovery_4_5_desc =>
      'Tu bebÃ© puede agarrar sus pies y llevarlos a la boca cuando estÃ¡ acostado. Deja que los pies exploren diferentes superficies.';

  @override
  String get tip_tip_independent_play_4_5_title => 'Juego independiente';

  @override
  String get tip_tip_independent_play_4_5_desc =>
      'Coloca cerca algunos juguetes de distintas texturas y alÃ©jate un poco. El juego independiente fortalece su confianza.';

  @override
  String ageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '$count mes',
    );
    return '$_temp0';
  }

  @override
  String get appPreferences => 'Preferencias de la app';

  @override
  String get appearance => 'Apariencia';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get darkModeSubtitle => 'Tema oscuro cÃ³modo para la vista';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get feedingReminder => 'Recordatorio de alimentaciÃ³n';

  @override
  String get diaperReminder => 'Recordatorio de paÃ±al';

  @override
  String get off => 'Desactivado';

  @override
  String get reminderTime => 'Hora del recordatorio';

  @override
  String get dataManagement => 'GestiÃ³n de datos';

  @override
  String get createReport => 'Crear informe';

  @override
  String get weeklyMonthlyStats => 'EstadÃ­sticas semanales/mensuales';

  @override
  String get deleteAllDataTitle => 'Eliminar todos los datos';

  @override
  String get deleteAllDataSubtitle =>
      'Eliminar permanentemente todos los registros';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'VersiÃ³n';

  @override
  String get developer => 'Desarrollador';

  @override
  String get deleteAllDataWarning =>
      'Esta acciÃ³n elimina todos los registros de forma permanente. No se puede deshacer.';

  @override
  String get debug => 'DEBUG';

  @override
  String get testSleepNotification => 'Probar notificaciÃ³n de sueÃ±o';

  @override
  String get fireSleepNotificationNow => 'Lanzar notificaciÃ³n de sueÃ±o ahora';

  @override
  String get testNursingNotification => 'Probar notificaciÃ³n de lactancia';

  @override
  String get fireNursingNotificationNow =>
      'Lanzar notificaciÃ³n de lactancia ahora';

  @override
  String get user => 'Usuario';

  @override
  String get selectBaby => 'Seleccionar bebÃ©';

  @override
  String get newBabyAdd => 'Agregar nuevo bebÃ©';

  @override
  String get babyProfileTitle => 'Perfil del bebÃ©';

  @override
  String get babyInformation => 'InformaciÃ³n del bebÃ©';

  @override
  String get addPhoto => 'Agregar foto';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get birthDateLabel => 'Fecha de nacimiento';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get growthRecords => 'Registros de crecimiento';

  @override
  String get deleteThisBabyData => 'Eliminar los datos de este bebÃ©';

  @override
  String get otherBabiesUnaffected =>
      'Los demÃ¡s bebÃ©s no se verÃ¡n afectados';

  @override
  String get onlyThisBabyPrefix =>
      'Solo se eliminarÃ¡n todos los registros de ';

  @override
  String get allRecordsWillBeDeleted => '.';

  @override
  String get deleteActionIrreversible =>
      'Los demÃ¡s bebÃ©s no se verÃ¡n afectados. Esta acciÃ³n no se puede deshacer.';

  @override
  String get birth => 'Nacimiento';

  @override
  String monthNumber(int month) {
    return 'Mes $month';
  }

  @override
  String get selectMonth => 'Seleccionar mes';

  @override
  String get otherMonth => 'Otro mes';

  @override
  String get period => 'PerÃ­odo';

  @override
  String get status => 'Estado';

  @override
  String get scheduledDate => 'Fecha programada';

  @override
  String get editVaccine => 'Editar vacuna';

  @override
  String get vaccineName => 'Nombre de la vacuna';

  @override
  String get allLabel => 'Todos';

  @override
  String get routineFilter => 'Rutina';

  @override
  String get asNeededFilter => 'SegÃºn necesidad';

  @override
  String get vaccineProtocolsFilter => 'Protocolos de vacunas';

  @override
  String get everyDay => 'Every day';

  @override
  String get asNeeded => 'SegÃºn necesidad';

  @override
  String get vaccineProtocolLabel => 'Protocolo de vacuna';

  @override
  String linkedToVaccine(String vaccine) {
    return 'linked to $vaccine';
  }

  @override
  String get noVaccineLink => 'No linked vaccine';

  @override
  String doseCountLabel(int count) {
    return 'Dosis registradas: $count';
  }

  @override
  String get logGivenNow => 'Registrar ahora';

  @override
  String get medicationDoseLogged => 'Dose logged';

  @override
  String get savedMessage => 'Guardado';

  @override
  String get alreadySavedRecently => 'Ya se guardó hace un momento';

  @override
  String get undo => 'Deshacer';

  @override
  String get yesterday => 'Ayer';

  @override
  String get notGivenYet => 'AÃºn no administrado';

  @override
  String get viewHistory => 'Ver historial';

  @override
  String get noMedicationHistory => 'Sin historial de administraciÃ³n';

  @override
  String lastGivenLabel(String value) {
    return 'Ãšltima dosis: $value';
  }

  @override
  String get scheduleType => 'Tipo de pauta';

  @override
  String get dailySchedule => 'Diario';

  @override
  String get prnSchedule => 'SegÃºn necesidad';

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
  String get chooseExistingMedication => 'Elegir medicamento existente';

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
