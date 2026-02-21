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
  String get sleepStartedAt => 'Sueño empezó a las';

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
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '$count año',
    );
    return '$_temp0';
  }

  @override
  String ageYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years años',
      one: '$years año',
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
      other: '$days días',
      one: '$days día',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '$count día',
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
  String get diaper_tab => 'Pañal';

  @override
  String get sleep_tab => 'Sueño';

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
  String get lastDiaper => 'Últ. Pañal';

  @override
  String get lastSleep => 'Últ. Sueño';

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

  @override
  String get tip_siyah_mekonyum_title => 'Primera caca';

  @override
  String get tip_siyah_mekonyum_desc =>
      'Durante los primeros 2-4 días, esto es normal tanto si tu bebé toma leche materna como fórmula. No hay motivo de preocupación.';

  @override
  String get tip_eye_tracking_title => 'Seguimiento visual';

  @override
  String get tip_eye_tracking_desc =>
      'Por ahora, tu bebé solo ve con claridad a unos 25-30 cm. Acerca tu rostro y muévete despacio para que intente seguirte con la mirada.';

  @override
  String get tip_neck_support_title => 'Soporte del cuello';

  @override
  String get tip_neck_support_desc =>
      'Sostén siempre la cabeza y el cuello de tu bebé al cargarlo. Los músculos del cuello todavía son muy débiles.';

  @override
  String get tip_reflex_stepping_title => 'Reflejo de pasos';

  @override
  String get tip_reflex_stepping_desc =>
      'Sostén a tu bebé en posición vertical y deja que sus pies toquen una superficie plana. Es posible que veas el reflejo de dar pasos.';

  @override
  String get tip_sound_interest_title => 'Interés por los sonidos';

  @override
  String get tip_sound_interest_desc =>
      'Tu bebé es muy sensible a los sonidos. Prueba captar su atención con un sonajero suave o una cajita de música.';

  @override
  String get tip_parent_interaction_title => 'Interacción con los padres';

  @override
  String get tip_parent_interaction_desc =>
      'Haz contacto visual y habla con voz suave. Tu bebé reconoce tu voz y se siente seguro con ella.';

  @override
  String get tip_color_worlds_title => 'Mundo de colores';

  @override
  String get tip_color_worlds_desc =>
      'Los recién nacidos ven mejor los contrastes en blanco y negro. Puedes mostrarle tarjetas con ese tipo de patrones.';

  @override
  String get tip_mini_athlete_title => 'Pequeño atleta';

  @override
  String get tip_mini_athlete_desc =>
      'El tiempo boca abajo fortalece los músculos del cuello y la espalda. Inténtalo unos minutos cada día.';

  @override
  String get tip_sound_hunter_title => 'Cazador de sonidos';

  @override
  String get tip_sound_hunter_desc =>
      'Haz un chasquido suave cerca de la oreja de tu bebé. Puede intentar girar la cabeza hacia el sonido.';

  @override
  String get tip_touch_explore_title => 'Exploración táctil';

  @override
  String get tip_touch_explore_desc =>
      'Permite que tu bebé toque diferentes texturas con manos y pies: superficies suaves, rugosas y frescas.';

  @override
  String get tip_tip_agu_conversation_1_2_title => 'Charlas de balbuceo';

  @override
  String get tip_tip_agu_conversation_1_2_desc =>
      'Cuando tu bebé emita sonidos, escúchalo. Respóndele con suavidad cuando termine. Estas pequeñas charlas construyen la comunicación.';

  @override
  String get tip_tip_tummy_time_strength_1_2_title =>
      'Hombros fuertes (tiempo boca abajo)';

  @override
  String get tip_tip_tummy_time_strength_1_2_desc =>
      'Coloca a tu bebé boca abajo por periodos cortos. Anímalo a levantar la cabeza con juguetes coloridos delante.';

  @override
  String get tip_tip_baby_massage_1_2_title => 'Masaje relajante';

  @override
  String get tip_tip_baby_massage_1_2_desc =>
      'Después del baño, masajea suavemente empezando por los pies. Favorece la conciencia corporal y ayuda a tu bebé a relajarse.';

  @override
  String get tip_tip_gesture_speech_1_2_title => 'Hablar con gestos';

  @override
  String get tip_tip_gesture_speech_1_2_desc =>
      'Usa gestos mientras hablas. Saluda con la mano para nos vamos y frota las manos para terminamos. Esto fortalece la memoria visual.';

  @override
  String get tip_tip_open_hands_1_2_title => 'Dedos libres';

  @override
  String get tip_tip_open_hands_1_2_desc =>
      'Sus manos se abren cada vez más. Ofrécele juguetes suaves para practicar agarrar y soltar.';

  @override
  String get tip_tip_side_by_side_bonding_1_2_title => 'Vínculo lado a lado';

  @override
  String get tip_tip_side_by_side_bonding_1_2_desc =>
      'Acuéstate junto a tu bebé. Sonríe y háblale con cariño mientras intenta girarse hacia ti.';

  @override
  String get tip_tip_sound_hunter_title => 'Cazador de sonidos';

  @override
  String get tip_tip_sound_hunter_desc =>
      'Agita un sonajero suavemente en un punto que tu bebé no vea. Girar hacia el sonido favorece la audición y la atención.';

  @override
  String get tip_tip_sound_hunter_level2_1_2_title =>
      'Cazador de sonidos (nivel 2)';

  @override
  String get tip_tip_sound_hunter_level2_1_2_desc =>
      'Haz sonidos diferentes a su izquierda y derecha. Buscar el origen fortalece su capacidad de atención.';

  @override
  String get tip_tip_texture_discovery_1_2_title => 'Tocar y descubrir';

  @override
  String get tip_tip_texture_discovery_1_2_desc =>
      'Ofrécele objetos con distintas texturas. Cada nueva sensación es un nuevo descubrimiento para tu bebé.';

  @override
  String get tip_tip_outdoor_explorer_4_5_title => 'Explorador al aire libre';

  @override
  String get tip_tip_outdoor_explorer_4_5_desc =>
      'Muéstrale árboles y animales cuando estén afuera. Déjalo tocar y explorar mientras escucha tu voz.';

  @override
  String get tip_tip_reaching_exercise_1_2_title => 'Práctica de alcance';

  @override
  String get tip_tip_reaching_exercise_1_2_desc =>
      'Coloca juguetes a su alcance. Incluso intentar agarrarlos ayuda a fortalecer sus músculos.';

  @override
  String get tip_tip_supported_bounce_1_2_title => 'Rebote con apoyo';

  @override
  String get tip_tip_supported_bounce_1_2_desc =>
      'Sostén a tu bebé erguido sobre tu regazo y permite un rebote suave con apoyo. Ayuda a fortalecer las piernas y a explorar.';

  @override
  String get tip_tip_visual_tracking_1_2_title => 'Seguimiento visual';

  @override
  String get tip_tip_visual_tracking_1_2_desc =>
      'Mueve lentamente un juguete colorido que haga sonido dentro de su campo visual. Es un gran ejercicio para el seguimiento visual.';

  @override
  String get tip_tip_face_play_1_2_title => 'Juego de expresiones';

  @override
  String get tip_tip_face_play_1_2_desc =>
      'Acércate, haz contacto visual y usa expresiones faciales divertidas. Tu voz y tu rostro son sus juguetes favoritos.';

  @override
  String get tip_tip_emotion_labeling_1_2_title => 'Nombrar emociones';

  @override
  String get tip_tip_emotion_labeling_1_2_desc =>
      'Cuando tu bebé llore, nombra la emoción con calma y reconfórtalo. Sentirse comprendido favorece su seguridad emocional.';

  @override
  String get tip_tip_first_meal_title => 'Primera degustación';

  @override
  String get tip_tip_first_meal_desc =>
      'Inicia los sólidos según la recomendación de tu pediatra. Dar comida con cuchara puede ser divertido, pero observa posibles signos de alergia.';

  @override
  String get tip_tip_hand_to_hand_transfer_4_5_title => 'Manos activas';

  @override
  String get tip_tip_hand_to_hand_transfer_4_5_desc =>
      'Hacia los 4-5 meses, los bebés intentan pasar objetos de una mano a otra. Ofrécele objetos fáciles de agarrar y obsérvalo.';

  @override
  String get tip_tip_supported_sitting_4_5_title => 'Sentado con apoyo';

  @override
  String get tip_tip_supported_sitting_4_5_desc =>
      'Practica sentado con apoyo usando cojines. Coloca un juguete delante para motivar el equilibrio y el apoyo del tronco superior.';

  @override
  String get tip_tip_feet_discovery_4_5_title => 'Descubriendo los pies';

  @override
  String get tip_tip_feet_discovery_4_5_desc =>
      'Tu bebé puede agarrar sus pies y llevarlos a la boca cuando está acostado. Deja que los pies exploren diferentes superficies.';

  @override
  String get tip_tip_independent_play_4_5_title => 'Juego independiente';

  @override
  String get tip_tip_independent_play_4_5_desc =>
      'Coloca cerca algunos juguetes de distintas texturas y aléjate un poco. El juego independiente fortalece su confianza.';

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
  String get darkModeSubtitle => 'Tema oscuro cómodo para la vista';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get feedingReminder => 'Recordatorio de alimentación';

  @override
  String get diaperReminder => 'Recordatorio de pañal';

  @override
  String get off => 'Desactivado';

  @override
  String get reminderTime => 'Hora del recordatorio';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get createReport => 'Crear informe';

  @override
  String get weeklyMonthlyStats => 'Estadísticas semanales/mensuales';

  @override
  String get deleteAllDataTitle => 'Eliminar todos los datos';

  @override
  String get deleteAllDataSubtitle =>
      'Eliminar permanentemente todos los registros';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get developer => 'Desarrollador';

  @override
  String get deleteAllDataWarning =>
      'Esta acción elimina todos los registros de forma permanente. No se puede deshacer.';

  @override
  String get debug => 'DEBUG';

  @override
  String get testSleepNotification => 'Probar notificación de sueño';

  @override
  String get fireSleepNotificationNow => 'Lanzar notificación de sueño ahora';

  @override
  String get testNursingNotification => 'Probar notificación de lactancia';

  @override
  String get fireNursingNotificationNow =>
      'Lanzar notificación de lactancia ahora';

  @override
  String get user => 'Usuario';

  @override
  String get selectBaby => 'Seleccionar bebé';

  @override
  String get newBabyAdd => 'Agregar nuevo bebé';

  @override
  String get babyProfileTitle => 'Perfil del bebé';

  @override
  String get babyInformation => 'Información del bebé';

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
  String get deleteThisBabyData => 'Eliminar los datos de este bebé';

  @override
  String get otherBabiesUnaffected => 'Los demás bebés no se verán afectados';

  @override
  String get onlyThisBabyPrefix => 'Solo se eliminarán todos los registros de ';

  @override
  String get allRecordsWillBeDeleted => '.';

  @override
  String get deleteActionIrreversible =>
      'Los demás bebés no se verán afectados. Esta acción no se puede deshacer.';

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
  String get period => 'Período';

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
  String get asNeededFilter => 'Según necesidad';

  @override
  String get vaccineProtocolsFilter => 'Protocolos de vacunas';

  @override
  String get everyDay => 'Every day';

  @override
  String get asNeeded => 'Según necesidad';

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
  String get scheduleType => 'Tipo de pauta';

  @override
  String get dailySchedule => 'Diario';

  @override
  String get prnSchedule => 'Según necesidad';

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

  @override
  String get time => 'Hora';

  @override
  String get diaperWet => 'Mojado';

  @override
  String get diaperDirty => 'Sucio';

  @override
  String get diaperBoth => 'Ambos';

  @override
  String get eventTimeTooOld =>
      'La hora seleccionada debe estar dentro de las últimas 48 horas';

  @override
  String get editTitleFeeding => 'Editar alimentación';

  @override
  String get editTitleDiaper => 'Editar pañal';

  @override
  String get editTitleSleep => 'Editar sueño';

  @override
  String get editTitleNursing => 'Editar lactancia';

  @override
  String get savedMessage => 'Guardado';

  @override
  String get alreadySavedRecently => 'Ya se guardó hace un momento';

  @override
  String get undo => 'Deshacer';

  @override
  String get yesterday => 'Ayer';

  @override
  String get notGivenYet => 'Aún no administrado';

  @override
  String get viewHistory => 'Ver historial';

  @override
  String get noMedicationHistory => 'Sin historial de administración';

  @override
  String lastGivenLabel(String value) {
    return 'Última dosis: $value';
  }
}
