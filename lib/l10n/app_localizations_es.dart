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
  String get instantStart => 'Start Instantly';

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
  String get saveFailedTryAgain => 'Couldn\'t save. Please try again.';

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
  String get dailyTipsTitle => 'Daily Tips';

  @override
  String get allTips => 'Todos los consejos';

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
  String get tip_sound_hunter_listening_title => 'Cazador de sonidos';

  @override
  String get tip_sound_hunter_listening_desc =>
      'Agita un sonajero suavemente en un punto que tu bebé no vea. Girar hacia el sonido favorece la audición y la atención.';

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
  String get logDose => 'Registrar dosis';

  @override
  String get givenNow => 'Dar ahora';

  @override
  String get allDoneToday => 'Todo listo hoy';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get before => 'Antes';

  @override
  String get after => 'Despues';

  @override
  String todayProgressLabel(int done, int total) {
    return 'Hoy: $done / $total dosis';
  }

  @override
  String nextDoseLabel(String value) {
    return 'Proxima dosis: $value';
  }

  @override
  String givenTodayCount(int count) {
    return 'Dado hoy: $count';
  }

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
