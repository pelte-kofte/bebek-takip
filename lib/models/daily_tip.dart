import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum DailyTipCategory {
  sleep,
  feeding,
  development,
  health,
  parentSupport,
  safety,
}

class DailyTip {
  final String id;
  final String? titleKey;
  final String? descriptionKey;
  final String? fallbackTitle;
  final String? fallbackDescription;
  final String illustrationPath;
  final int minMonths;
  final int maxMonths;
  final DailyTipCategory category;
  final bool isGeneralTip;

  const DailyTip({
    required this.id,
    this.titleKey,
    this.descriptionKey,
    this.fallbackTitle,
    this.fallbackDescription,
    required this.illustrationPath,
    required this.minMonths,
    required this.maxMonths,
    required this.category,
    this.isGeneralTip = false,
  });

  int get minMonth => minMonths;
  int get maxMonth => maxMonths;

  String title(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (titleKey == null) {
      return _localizedFallback(
        l10n,
        id: id,
        legacyTurkishFallback: fallbackTitle,
        isDescription: false,
      );
    }
    return _localizedValue(l10n, titleKey, fallbackTitle);
  }

  String titleForLocalizations(AppLocalizations l10n) {
    if (titleKey == null) {
      return _localizedFallback(
        l10n,
        id: id,
        legacyTurkishFallback: fallbackTitle,
        isDescription: false,
      );
    }
    return _localizedValue(l10n, titleKey, fallbackTitle);
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (descriptionKey == null) {
      return _localizedFallback(
        l10n,
        id: id,
        legacyTurkishFallback: fallbackDescription,
        isDescription: true,
      );
    }
    return _localizedValue(l10n, descriptionKey, fallbackDescription);
  }

  String descriptionForLocalizations(AppLocalizations l10n) {
    if (descriptionKey == null) {
      return _localizedFallback(
        l10n,
        id: id,
        legacyTurkishFallback: fallbackDescription,
        isDescription: true,
      );
    }
    return _localizedValue(l10n, descriptionKey, fallbackDescription);
  }

  bool matchesAge(int ageInMonths) {
    return ageInMonths >= minMonths && ageInMonths <= maxMonths;
  }

  static String _localizedValue(
    AppLocalizations l10n,
    String? key,
    String? fallback,
  ) {
    if (key == null) {
      return fallback ?? '';
    }
    switch (key) {
      case 'tip_siyah_mekonyum_title':
        return l10n.tip_siyah_mekonyum_title;
      case 'tip_siyah_mekonyum_desc':
        return l10n.tip_siyah_mekonyum_desc;
      case 'tip_eye_tracking_title':
        return l10n.tip_eye_tracking_title;
      case 'tip_eye_tracking_desc':
        return l10n.tip_eye_tracking_desc;
      case 'tip_neck_support_title':
        return l10n.tip_neck_support_title;
      case 'tip_neck_support_desc':
        return l10n.tip_neck_support_desc;
      case 'tip_reflex_stepping_title':
        return l10n.tip_reflex_stepping_title;
      case 'tip_reflex_stepping_desc':
        return l10n.tip_reflex_stepping_desc;
      case 'tip_sound_interest_title':
        return l10n.tip_sound_interest_title;
      case 'tip_sound_interest_desc':
        return l10n.tip_sound_interest_desc;
      case 'tip_parent_interaction_title':
        return l10n.tip_parent_interaction_title;
      case 'tip_parent_interaction_desc':
        return l10n.tip_parent_interaction_desc;
      case 'tip_color_worlds_title':
        return l10n.tip_color_worlds_title;
      case 'tip_color_worlds_desc':
        return l10n.tip_color_worlds_desc;
      case 'tip_mini_athlete_title':
        return l10n.tip_mini_athlete_title;
      case 'tip_mini_athlete_desc':
        return l10n.tip_mini_athlete_desc;
      case 'tip_sound_hunter_title':
        return l10n.tip_sound_hunter_title;
      case 'tip_sound_hunter_desc':
        return l10n.tip_sound_hunter_desc;
      case 'tip_touch_explore_title':
        return l10n.tip_touch_explore_title;
      case 'tip_touch_explore_desc':
        return l10n.tip_touch_explore_desc;
      case 'tip_agu_conversation_1_2_title':
        return l10n.tip_agu_conversation_1_2_title;
      case 'tip_agu_conversation_1_2_desc':
        return l10n.tip_agu_conversation_1_2_desc;
      case 'tip_tummy_time_strength_1_2_title':
        return l10n.tip_tummy_time_strength_1_2_title;
      case 'tip_tummy_time_strength_1_2_desc':
        return l10n.tip_tummy_time_strength_1_2_desc;
      case 'tip_baby_massage_1_2_title':
        return l10n.tip_baby_massage_1_2_title;
      case 'tip_baby_massage_1_2_desc':
        return l10n.tip_baby_massage_1_2_desc;
      case 'tip_gesture_speech_1_2_title':
        return l10n.tip_gesture_speech_1_2_title;
      case 'tip_gesture_speech_1_2_desc':
        return l10n.tip_gesture_speech_1_2_desc;
      case 'tip_open_hands_1_2_title':
        return l10n.tip_open_hands_1_2_title;
      case 'tip_open_hands_1_2_desc':
        return l10n.tip_open_hands_1_2_desc;
      case 'tip_side_by_side_bonding_1_2_title':
        return l10n.tip_side_by_side_bonding_1_2_title;
      case 'tip_side_by_side_bonding_1_2_desc':
        return l10n.tip_side_by_side_bonding_1_2_desc;
      case 'tip_sound_hunter_listening_title':
        return l10n.tip_sound_hunter_listening_title;
      case 'tip_sound_hunter_listening_desc':
        return l10n.tip_sound_hunter_listening_desc;
      case 'tip_sound_hunter_level2_1_2_title':
        return l10n.tip_sound_hunter_level2_1_2_title;
      case 'tip_sound_hunter_level2_1_2_desc':
        return l10n.tip_sound_hunter_level2_1_2_desc;
      case 'tip_texture_discovery_1_2_title':
        return l10n.tip_texture_discovery_1_2_title;
      case 'tip_texture_discovery_1_2_desc':
        return l10n.tip_texture_discovery_1_2_desc;
      case 'tip_outdoor_explorer_4_5_title':
        return l10n.tip_outdoor_explorer_4_5_title;
      case 'tip_outdoor_explorer_4_5_desc':
        return l10n.tip_outdoor_explorer_4_5_desc;
      case 'tip_reaching_exercise_1_2_title':
        return l10n.tip_reaching_exercise_1_2_title;
      case 'tip_reaching_exercise_1_2_desc':
        return l10n.tip_reaching_exercise_1_2_desc;
      case 'tip_supported_bounce_1_2_title':
        return l10n.tip_supported_bounce_1_2_title;
      case 'tip_supported_bounce_1_2_desc':
        return l10n.tip_supported_bounce_1_2_desc;
      case 'tip_visual_tracking_1_2_title':
        return l10n.tip_visual_tracking_1_2_title;
      case 'tip_visual_tracking_1_2_desc':
        return l10n.tip_visual_tracking_1_2_desc;
      case 'tip_face_play_1_2_title':
        return l10n.tip_face_play_1_2_title;
      case 'tip_face_play_1_2_desc':
        return l10n.tip_face_play_1_2_desc;
      case 'tip_emotion_labeling_1_2_title':
        return l10n.tip_emotion_labeling_1_2_title;
      case 'tip_emotion_labeling_1_2_desc':
        return l10n.tip_emotion_labeling_1_2_desc;
      case 'tip_first_meal_title':
        return l10n.tip_first_meal_title;
      case 'tip_first_meal_desc':
        return l10n.tip_first_meal_desc;
      case 'tip_hand_to_hand_transfer_4_5_title':
        return l10n.tip_hand_to_hand_transfer_4_5_title;
      case 'tip_hand_to_hand_transfer_4_5_desc':
        return l10n.tip_hand_to_hand_transfer_4_5_desc;
      case 'tip_supported_sitting_4_5_title':
        return l10n.tip_supported_sitting_4_5_title;
      case 'tip_supported_sitting_4_5_desc':
        return l10n.tip_supported_sitting_4_5_desc;
      case 'tip_feet_discovery_4_5_title':
        return l10n.tip_feet_discovery_4_5_title;
      case 'tip_feet_discovery_4_5_desc':
        return l10n.tip_feet_discovery_4_5_desc;
      case 'tip_independent_play_4_5_title':
        return l10n.tip_independent_play_4_5_title;
      case 'tip_independent_play_4_5_desc':
        return l10n.tip_independent_play_4_5_desc;
      case 'tip_engelli_kosu_title':
        return l10n.tip_engelli_kosu_title;
      case 'tip_engelli_kosu_desc':
        return l10n.tip_engelli_kosu_desc;
      case 'tip_hafif_agir_title':
        return l10n.tip_hafif_agir_title;
      case 'tip_hafif_agir_desc':
        return l10n.tip_hafif_agir_desc;
      case 'tip_beni_ismimle_cagir_title':
        return l10n.tip_beni_ismimle_cagir_title;
      case 'tip_beni_ismimle_cagir_desc':
        return l10n.tip_beni_ismimle_cagir_desc;
      case 'tip_su_ne_title':
        return l10n.tip_su_ne_title;
      case 'tip_su_ne_desc':
        return l10n.tip_su_ne_desc;
      case 'tip_komut_dinlemece_title':
        return l10n.tip_komut_dinlemece_title;
      case 'tip_komut_dinlemece_desc':
        return l10n.tip_komut_dinlemece_desc;
      case 'tip_buyuk_yuruyus_title':
        return l10n.tip_buyuk_yuruyus_title;
      case 'tip_buyuk_yuruyus_desc':
        return l10n.tip_buyuk_yuruyus_desc;
      case 'tip_duzenleme_saati_title':
        return l10n.tip_duzenleme_saati_title;
      case 'tip_duzenleme_saati_desc':
        return l10n.tip_duzenleme_saati_desc;
      case 'tip_emekleme_parkuru_title':
        return l10n.tip_emekleme_parkuru_title;
      case 'tip_emekleme_parkuru_desc':
        return l10n.tip_emekleme_parkuru_desc;
      case 'tip_aynadaki_bebek_title':
        return l10n.tip_aynadaki_bebek_title;
      case 'tip_aynadaki_bebek_desc':
        return l10n.tip_aynadaki_bebek_desc;
      case 'tip_yuvarla_bakalim_title':
        return l10n.tip_yuvarla_bakalim_title;
      case 'tip_yuvarla_bakalim_desc':
        return l10n.tip_yuvarla_bakalim_desc;
      case 'tip_nesne_karsilastirma_title':
        return l10n.tip_nesne_karsilastirma_title;
      case 'tip_nesne_karsilastirma_desc':
        return l10n.tip_nesne_karsilastirma_desc;
      case 'tip_kucuk_okuyucu_title':
        return l10n.tip_kucuk_okuyucu_title;
      case 'tip_kucuk_okuyucu_desc':
        return l10n.tip_kucuk_okuyucu_desc;
      case 'tip_yercekimi_deneyi_title':
        return l10n.tip_yercekimi_deneyi_title;
      case 'tip_yercekimi_deneyi_desc':
        return l10n.tip_yercekimi_deneyi_desc;
      case 'tip_adimadim_macera_title':
        return l10n.tip_adimadim_macera_title;
      case 'tip_adimadim_macera_desc':
        return l10n.tip_adimadim_macera_desc;
      case 'tip_comert_bebek_title':
        return l10n.tip_comert_bebek_title;
      case 'tip_comert_bebek_desc':
        return l10n.tip_comert_bebek_desc;
      case 'tip_yemek_zamani_title':
        return l10n.tip_yemek_zamani_title;
      case 'tip_yemek_zamani_desc':
        return l10n.tip_yemek_zamani_desc;
      case 'tip_alkis_zamani_title':
        return l10n.tip_alkis_zamani_title;
      case 'tip_alkis_zamani_desc':
        return l10n.tip_alkis_zamani_desc;
      case 'tip_alo_kim_o_title':
        return l10n.tip_alo_kim_o_title;
      case 'tip_alo_kim_o_desc':
        return l10n.tip_alo_kim_o_desc;
      case 'tip_baybay_partisi_title':
        return l10n.tip_baybay_partisi_title;
      case 'tip_baybay_partisi_desc':
        return l10n.tip_baybay_partisi_desc;
      case 'tip_birak_izle_title':
        return l10n.tip_birak_izle_title;
      case 'tip_birak_izle_desc':
        return l10n.tip_birak_izle_desc;
      case 'tip_goster_bakalim_title':
        return l10n.tip_goster_bakalim_title;
      case 'tip_goster_bakalim_desc':
        return l10n.tip_goster_bakalim_desc;
      case 'tip_hazine_kutusu_title':
        return l10n.tip_hazine_kutusu_title;
      case 'tip_hazine_kutusu_desc':
        return l10n.tip_hazine_kutusu_desc;
      case 'tip_minik_kitap_kurdu_title':
        return l10n.tip_minik_kitap_kurdu_title;
      case 'tip_minik_kitap_kurdu_desc':
        return l10n.tip_minik_kitap_kurdu_desc;
      case 'tip_mobilya_dagcilari_title':
        return l10n.tip_mobilya_dagcilari_title;
      case 'tip_mobilya_dagcilari_desc':
        return l10n.tip_mobilya_dagcilari_desc;
      case 'tip_saksak_alkis_title':
        return l10n.tip_saksak_alkis_title;
      case 'tip_saksak_alkis_desc':
        return l10n.tip_saksak_alkis_desc;
      case 'tip_sira_sende_title':
        return l10n.tip_sira_sende_title;
      case 'tip_sira_sende_desc':
        return l10n.tip_sira_sende_desc;
      case 'tip_veral_oyunu_title':
        return l10n.tip_veral_oyunu_title;
      case 'tip_veral_oyunu_desc':
        return l10n.tip_veral_oyunu_desc;
      case 'tip_yuvarla_bekle_title':
        return l10n.tip_yuvarla_bekle_title;
      case 'tip_yuvarla_bekle_desc':
        return l10n.tip_yuvarla_bekle_desc;
      default:
        return fallback ?? key;
    }
  }

  static String _localizedFallback(
    AppLocalizations l10n, {
    required String id,
    required bool isDescription,
    String? legacyTurkishFallback,
  }) {
    final locale = l10n.localeName.toLowerCase();
    final isTurkish = locale.startsWith('tr');
    if (isTurkish) {
      return legacyTurkishFallback ?? '';
    }
    final englishFallback = isDescription
        ? _fallbackDescriptionEnById[id]
        : _fallbackTitleEnById[id];
    return englishFallback ?? '';
  }

  static const Map<String, String> _fallbackTitleEnById = <String, String>{
    'sound_hunter_listening': 'Find the Rattle',
    'newborn_day_night_cues': 'Day-Night Cues',
    'newborn_hunger_cues': 'Early Hunger Cues',
    'roll_safe_space': 'Safe Rolling Space',
    'midline_hand_game': 'Hands Meet in the Middle',
    'short_song_repetition': 'Repeat a Short Song',
    'supported_mirror_time': 'Supported Mirror Time',
    'cool_teether_not_frozen': 'Cool, Not Frozen',
    'solid_readiness_watch': 'Watch for Readiness',
    'toy_just_out_of_reach': 'Place the Toy Nearby',
    'short_nap_signal': 'Short Nap Cue',
    'more_floor_less_seat': 'More Floor Time',
    'small_item_scan': 'Check for Small Pieces',
    'single_allergen_try': 'Try One Allergen at a Time',
    'no_honey_yet': 'Wait on Honey',
    'grape_and_nut_safety': 'Cut Grapes Lengthwise',
    'soft_texture_check': 'Check Soft Textures',
    'upright_mealtime': 'Sit Upright for Meals',
    'mess_is_learning': 'Mess Is Learning',
    'spoon_touch_turn': 'Let the Spoon Be Explored',
    'small_bites_only': 'Keep Pieces Small',
    'self_feeding_practice': 'Self-Feeding Practice',
    'safe_furniture_edges': 'Safer Climbing Space',
    'naming_body_parts': 'Name Body Parts',
    'sleep_transition_cue': 'Sleep Transition Cue',
    'coffee_table_edges': 'Watch Table Edges',
    'basket_object_names': 'Name Basket Items',
    'repeat_allergen_calmly': 'Repeat Familiar Allergens',
    'wave_and_wait_turns': 'Wave-and-Wait Turns',
    'cup_practice': 'Open Cup Practice',
    'one_step_helper': 'Tiny Helper Tasks',
    'toddlers_need_boundaries': 'Calm, Clear Limits',
    'walking_path_safety': 'Clear a Walking Path',
    'iron_rich_plate': 'Iron-Rich Meals',
    'two_safe_choices': 'Offer Two Safe Choices',
    'straw_practice': 'Straw Cup Practice',
    'chair_straps_every_time': 'Use Straps Every Time',
    'hand_wash_song': 'Handwashing Song',
    'same_book_again': 'Read the Same Book Again',
    'hot_drink_distance': 'Keep Hot Drinks Away',
    'hunger_full_words': 'Words for Hungry and Full',
    'short_transition_warning': 'Short Transition Warning',
    'basket_cleanup_together': 'Tidy the Basket Together',
    'quiet_reset_corner': 'Quiet Reset Corner',
    'count_objects_outside': 'Count Things Outside',
    'open_cup_small_sips': 'Small Sips from an Open Cup',
    'same_three_bed_steps': 'Same Three Bedtime Steps',
    'hard_food_shape_check': 'Check Hard Food Shapes',
    'rotate_iron_sources': 'Rotate Iron Sources',
    'simple_copy_moves': 'Copy Simple Moves',
    'pretend_play_start': 'Start Pretend Play',
    'snack_sitting_rule': 'Sit for Snacks',
    'two_word_modeling': 'Two-Word Models',
    'big_emotions_need_co_regulation': 'Stay Close to Big Feelings',
    'toddlers_need_sleep_anchor': 'Keep Bedtime Steady',
    'two_step_tiny_direction': 'Two-Step Directions',
    'popcorn_wait_rule': 'Wait on Popcorn',
    'small_fork_practice': 'Small Fork Practice',
    'hug_after_the_storm': 'Hug After the Storm',
    'watch_climbing_closely': 'Stay Close for Climbers',
    'fill_the_last_word': 'Pause for the Last Word',
    'bedtime_two_choices': 'Two Bedtime Choices',
    'water_break_between_meals': 'Water Break Between Meals',
    'rotate_toys_three_choices': 'Rotate a Few Toys',
    'name_feeling_after_calm': 'Name the Feeling Later',
    'finish_snack_at_table': 'Finish Snacks at the Table',
    'mini_doctor_role_play': 'Mini Doctor Play',
    'countdown_for_transitions': 'Count Down for Transitions',
    'wash_hands_before_snacks': 'Clean Hands Before Snacks',
    'same_family_meal_base': 'Share the Family Meal',
    'short_wait_practice': 'Short Waiting Practice',
    'general_connection_minutes': 'Ten Minutes of Full Attention',
    'general_safe_sleep_space': 'Check the Sleep Space',
    'general_offer_water_with_meals': 'Offer Water at Meals',
    'general_name_the_day': 'Narrate Daily Routines',
    'general_parent_pause': 'Pause for a Breath',
    'general_growth_watch': 'Note Unusual Patterns',
    'general_follow_child_lead': 'Follow Their Lead in Play',
    'general_supervise_every_meal': 'Stay Close at Meals',
    'general_repeat_allergens_calmly': 'Repeat Familiar Allergen Foods',
    'general_clean_hands_before_care': 'Clean Hands Before Care',
    'general_reread_books': 'Re-Read the Same Book',
    'general_keep_lights_soft': 'Keep Night Lights Soft',
    'general_scan_for_small_bits': 'Scan for Small Bits',
    'general_connect_before_redirect': 'Connect Before You Redirect',
    'general_offer_water_near_meals': 'Offer Water Near Meals',
    'general_short_routine_words': 'Use Short Routine Words',
    'general_no_added_salt_sugar': 'No Need for Added Salt or Sugar',
    'general_make_floor_space': 'Make Space on the Floor',
    'general_notice_your_breath': 'Notice Your Breath',
    'general_daylight_minutes': 'A Little Daylight',
    'general_upright_high_chair': 'Upright High-Chair Position',
    'general_soft_transition_phrase': 'Use a Soft Transition Phrase',
  };

  static const Map<String, String> _fallbackDescriptionEnById =
      <String, String>{
        'sound_hunter_listening':
            'Shake a rattle just out of sight and let your baby turn toward the sound. This supports hearing and attention.',
        'newborn_day_night_cues':
            'Let daylight in during the day and keep night care dim and calm. Small differences can help rhythm over time.',
        'newborn_hunger_cues':
            'Hand-to-mouth movements, rooting, and restlessness can be early hunger cues. Spotting them early may make feeding calmer.',
        'roll_safe_space':
            'As rolling starts, give your baby a bit more open floor space and move hard corners or unstable items away.',
        'midline_hand_game':
            'Offer light toys that encourage both hands to meet at midline. This supports body awareness.',
        'short_song_repetition':
            'Singing the same short song a few times a day can build attention and connection.',
        'supported_mirror_time':
            'Spend a short time looking in a mirror together. Watching faces and movement can build social interest.',
        'cool_teether_not_frozen':
            'You can offer a cool teether, but avoid making it very hard or icy. Gentle coolness is often enough.',
        'solid_readiness_watch':
            'Near 6 months, look for steady head control, supported sitting, and interest in food when planning solids.',
        'toy_just_out_of_reach':
            'Put a toy close enough to reach for but not grab right away. Small efforts support trunk and arm control.',
        'short_nap_signal':
            'Use the same short cue before naps, like dimming the room or saying one calm phrase. Repetition can be soothing.',
        'more_floor_less_seat':
            'Safe floor play gives natural chances to roll, reach, and build trunk control.',
        'small_item_scan':
            'Scan the play area for buttons, coins, battery covers, and tiny caps that can end up on the floor.',
        'single_allergen_try':
            'Introducing allergenic foods one at a time makes it easier to see what was offered.',
        'no_honey_yet':
            'Leave honey until after the first birthday. Natural food flavors are enough for now.',
        'grape_and_nut_safety':
            'Whole grapes, whole nuts, and popcorn are not suitable now. Offer softer, safer pieces instead.',
        'soft_texture_check':
            'Make sure food is soft enough to mash easily with fingers. Firm, chunky pieces are safer to delay.',
        'upright_mealtime':
            'Offer meals in a supported, upright position. Avoid feeding while lying down or moving around.',
        'mess_is_learning':
            'Touching the spoon, bowl, and puree can be messy, but it is part of learning. Small portions can keep it manageable.',
        'spoon_touch_turn':
            'Let your baby touch the spoon before bringing it to the mouth. Familiarity can make meals feel easier.',
        'small_bites_only':
            'Offer short, soft pieces rather than long sticks. Hard raw vegetables and large apple chunks are safer to avoid.',
        'self_feeding_practice':
            'Offer soft finger foods in small amounts. Early self-feeding helps fine motor skills and meal curiosity.',
        'safe_furniture_edges':
            'Recheck table edges, sockets, and items that can tip over. Pulling up and climbing can arrive quickly.',
        'naming_body_parts':
            'Point out simple body parts like nose, ears, and hands during play. Repetition supports language growth.',
        'sleep_transition_cue':
            'Use a short, familiar bedtime routine like dim lights, calm words, and the same lullaby.',
        'coffee_table_edges':
            'Coffee-table corners matter again when standing and cruising start. Softening high-use areas can reduce bumps.',
        'basket_object_names':
            'Choose two or three safe objects from a basket and repeat their names. Familiar words support language growth.',
        'repeat_allergen_calmly':
            'If a previously tolerated allergen is going well, offering it again from time to time can support variety. Keep new foods one at a time.',
        'wave_and_wait_turns':
            'Simple turn-taking games like waving, clapping, or rolling a ball can build early waiting skills.',
        'cup_practice':
            'Try a small open cup with a little water at calm meals. Holding it together is completely fine.',
        'one_step_helper':
            'One-step jobs like putting a toy in a basket or bringing a spoon can build confidence and listening.',
        'toddlers_need_boundaries':
            'Short, steady limits often work best at this age. A calm, consistent response can support security.',
        'walking_path_safety':
            'Secure slippery rugs and open up busy walkways. A safe path can support confident first steps.',
        'iron_rich_plate':
            'Rotate foods like eggs, yogurt, beans, meat, or lentils across the week. Variety can help support iron intake.',
        'two_safe_choices':
            'Two simple choices during the day can support cooperation and growing independence.',
        'straw_practice':
            'Short straw-cup tries with a little water can support oral-motor coordination. Go slowly and keep it calm.',
        'chair_straps_every_time':
            'Fasten straps in the high chair or stroller every time, even for short moments. It lowers fall risk.',
        'hand_wash_song':
            'Use the same short song while washing hands. It can turn the routine into a familiar game.',
        'same_book_again':
            'Wanting the same book again is normal. Familiar repetition supports language and comfort.',
        'hot_drink_distance':
            'Keep hot drinks away from table edges and reach zones. This is an important safety habit in active toddler months.',
        'hunger_full_words':
            'Simple phrases like “Are you hungry?” or “All full?” can support awareness of body cues over time.',
        'short_transition_warning':
            'A quick heads-up like “We will tidy up soon” can make transitions smoother.',
        'basket_cleanup_together':
            'Tossing toys into a basket together can be a game. Repetition supports following simple directions.',
        'quiet_reset_corner':
            'A small calm corner with a pillow, book, or comfort item can help you reconnect after busy moments.',
        'count_objects_outside':
            'Name or count trees, cars, or birds on short walks. It can support attention and words.',
        'open_cup_small_sips':
            'Keep open-cup practice brief and use small amounts. Helping hold the cup is completely normal.',
        'same_three_bed_steps':
            'Repeating the same three small steps before bed can make bedtime feel more predictable.',
        'hard_food_shape_check':
            'Hard raw vegetables, large apple pieces, and round firm bites still need care at this age. Soften or adapt them first.',
        'rotate_iron_sources':
            'Rotate different iron-containing foods across the week to keep meals varied.',
        'simple_copy_moves':
            'Take turns copying easy actions like waving, nodding, or clapping. It can make social play feel fun.',
        'pretend_play_start':
            'Pretend play like feeding a doll or answering a toy phone supports imagination.',
        'snack_sitting_rule':
            'Offer snacks while sitting, not walking. This supports safer eating and steadier routines.',
        'two_word_modeling':
            'Use short models like “Mama came,” “Ball here,” or “Water done.” Simple repetition supports language.',
        'big_emotions_need_co_regulation':
            'Staying calm and close during tears or frustration is often the strongest support.',
        'toddlers_need_sleep_anchor':
            'A similar bedtime, even on weekends, can help keep sleep more settled.',
        'two_step_tiny_direction':
            'Playful two-step directions like “Get the ball and put it in the basket” can support listening and language.',
        'popcorn_wait_rule':
            'Popcorn, whole nuts, and other round hard foods are still not suitable. Choose safer alternatives instead.',
        'small_fork_practice':
            'Try a small fork with soft, safe bites. Early practice can support fine motor skills.',
        'hug_after_the_storm':
            'After a hard moment, a short hug and calm words can help you reconnect.',
        'watch_climbing_closely':
            'Children who love climbing need close supervision. Set up the space to reduce access to high fall risks.',
        'fill_the_last_word':
            'In a familiar book, pause before the last word of a sentence. Your child may join with a sound, look, or word.',
        'bedtime_two_choices':
            'Two simple choices before bed, like which pajamas to wear, can make the routine smoother while you keep the structure.',
        'water_break_between_meals':
            'Small offers of water with or between meals can fit easily into the day. There is no need to add sugary drinks.',
        'rotate_toys_three_choices':
            'Leaving out only two or three toys at once can make it easier to focus.',
        'name_feeling_after_calm':
            'After the big moment passes, short phrases like “You were upset” can help your child feel understood.',
        'finish_snack_at_table':
            'Starting and finishing snacks while seated can build a safer habit.',
        'mini_doctor_role_play':
            'Caring for a toy with pretend feeding, bandages, or listening games can support imagination.',
        'countdown_for_transitions':
            'A short countdown before ending play can soften some transitions.',
        'wash_hands_before_snacks':
            'A quick hand wash after play or coming inside can become a useful snack-time habit.',
        'same_family_meal_base':
            'When safely prepared and served, parts of family meals can support modeling and shared mealtime.',
        'short_wait_practice':
            'Very short pauses before rolling a ball or handing over a cup can gently build waiting skills.',
        'general_connection_minutes':
            'Even a short period of following your child''s lead without distractions can strengthen connection.',
        'general_safe_sleep_space':
            'Recheck the sleep space from time to time for loose blankets, cords, and small distracting items.',
        'general_offer_water_with_meals':
            'For children already on solids, small offers of water with meals can help build routine.',
        'general_name_the_day':
            'Briefly talking through diaper changes, baths, meals, and play can support language and predictability.',
        'general_parent_pause':
            'In hard moments, a 10-second pause can help you respond more calmly. Parent support is part of care too.',
        'general_growth_watch':
            'Noting lasting changes in appetite, sleep, or behavior can make later conversations with a clinician clearer.',
        'general_follow_child_lead':
            'Spending short stretches following your child''s chosen play can strengthen connection.',
        'general_supervise_every_meal':
            'Being close and attentive at meal times helps you notice safety cues more easily.',
        'general_repeat_allergens_calmly':
            'Reoffering allergen foods that have already been tolerated can help keep variety going. Keep new foods one at a time.',
        'general_clean_hands_before_care':
            'A quick hand clean before close care tasks like feeding or eye wiping is a helpful habit.',
        'general_reread_books':
            'Re-reading familiar books is not wasted time. Repeated words and pictures can feel comforting and teachable.',
        'general_keep_lights_soft':
            'Softer light at night can make it easier to settle again after waking.',
        'general_scan_for_small_bits':
            'Check play spaces from time to time for coins, batteries, magnets, buttons, and small caps.',
        'general_connect_before_redirect':
            'A brief moment of connection before redirection often makes cooperation easier.',
        'general_offer_water_near_meals':
            'Linking small offers of water to meal times can make the routine easier to remember.',
        'general_short_routine_words':
            'Short phrases like “Diaper, then play” can help your child understand what comes next.',
        'general_no_added_salt_sugar':
            'Most foods do not need added salt or sugar. Simple flavors are enough.',
        'general_make_floor_space':
            'A safe floor area creates natural chances to reach, roll, crawl, and walk.',
        'general_notice_your_breath':
            'Sometimes one calm breath is enough to reset. A steadier adult tone can help children settle too.',
        'general_daylight_minutes':
            'When possible, a short time outside during the day can support rhythm and movement.',
        'general_upright_high_chair':
            'For solids, upright seating and good support can make meals safer.',
        'general_soft_transition_phrase':
            'A familiar phrase like “We’ll finish soon” can make daily transitions feel more predictable.',
      };

  static const List<DailyTip> tips = [
    DailyTip(
      id: 'siyah_mekonyum',
      titleKey: 'tip_siyah_mekonyum_title',
      descriptionKey: 'tip_siyah_mekonyum_desc',
      illustrationPath: 'assets/illustrations/tips/tip_mekonyum.webp',
      minMonths: 0,
      maxMonths: 1,
      category: DailyTipCategory.health,
    ),
    DailyTip(
      id: 'eye_tracking',
      titleKey: 'tip_eye_tracking_title',
      descriptionKey: 'tip_eye_tracking_desc',
      illustrationPath: 'assets/illustrations/tips/tip_eye_tracking.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'neck_support',
      titleKey: 'tip_neck_support_title',
      descriptionKey: 'tip_neck_support_desc',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'reflex_stepping',
      titleKey: 'tip_reflex_stepping_title',
      descriptionKey: 'tip_reflex_stepping_desc',
      illustrationPath: 'assets/illustrations/tips/tip_reflex_stepping.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'sound_interest',
      titleKey: 'tip_sound_interest_title',
      descriptionKey: 'tip_sound_interest_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sound_interest.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'parent_interaction',
      titleKey: 'tip_parent_interaction_title',
      descriptionKey: 'tip_parent_interaction_desc',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'color_worlds',
      titleKey: 'tip_color_worlds_title',
      descriptionKey: 'tip_color_worlds_desc',
      illustrationPath: 'assets/illustrations/tips/tip_color_worlds.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'mini_athlete',
      titleKey: 'tip_mini_athlete_title',
      descriptionKey: 'tip_mini_athlete_desc',
      illustrationPath: 'assets/illustrations/tips/tip_mini_athlete.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'sound_hunter',
      titleKey: 'tip_sound_hunter_title',
      descriptionKey: 'tip_sound_hunter_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'touch_explore',
      titleKey: 'tip_touch_explore_title',
      descriptionKey: 'tip_touch_explore_desc',
      illustrationPath: 'assets/illustrations/tips/tip_touch_explore.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'agu_conversation_1_2',
      titleKey: 'tip_agu_conversation_1_2_title',
      descriptionKey: 'tip_agu_conversation_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_agu_conversation_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'tummy_time_strength_1_2',
      titleKey: 'tip_tummy_time_strength_1_2_title',
      descriptionKey: 'tip_tummy_time_strength_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_tummy_time_strength_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'baby_massage_1_2',
      titleKey: 'tip_baby_massage_1_2_title',
      descriptionKey: 'tip_baby_massage_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.sleep,
    ),
    DailyTip(
      id: 'gesture_speech_1_2',
      titleKey: 'tip_gesture_speech_1_2_title',
      descriptionKey: 'tip_gesture_speech_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_gesture_speech_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'open_hands_1_2',
      titleKey: 'tip_open_hands_1_2_title',
      descriptionKey: 'tip_open_hands_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_open_hands_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'side_by_side_bonding_1_2',
      titleKey: 'tip_side_by_side_bonding_1_2_title',
      descriptionKey: 'tip_side_by_side_bonding_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_side_by_side_bonding_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'sound_hunter_listening',
      fallbackTitle: 'Çıngırağın Yerini Bul',
      fallbackDescription:
          'Bebeğinin görmediği bir noktada hafifçe çıngırak salla. Sesin geldiği yöne dönmeye çalışması işitme ve dikkat becerilerini destekler.',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'sound_hunter_level2_1_2',
      titleKey: 'tip_sound_hunter_level2_1_2_title',
      descriptionKey: 'tip_sound_hunter_level2_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_sound_hunter_level2_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'texture_discovery_1_2',
      titleKey: 'tip_texture_discovery_1_2_title',
      descriptionKey: 'tip_texture_discovery_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_texture_discovery_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'newborn_day_night_cues',
      fallbackTitle: 'Gündüz Gece İpucu',
      fallbackDescription:
          'Gündüz perdeleri açıp doğal ışığı içeri al, gece bakımını ise daha loş ve sakin tut. Bu küçük farklar zamanla ritim kurmasına yardım eder.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.sleep,
    ),
    DailyTip(
      id: 'newborn_hunger_cues',
      fallbackTitle: 'Erken Açlık İşaretleri',
      fallbackDescription:
          'Eline ağzına götürme, aranma ve huzursuzlanma gibi erken işaretleri fark etmek beslenmeyi ağlama başlamadan önce kolaylaştırabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.webp',
      minMonths: 0,
      maxMonths: 3,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'outdoor_explorer_4_5',
      titleKey: 'tip_outdoor_explorer_4_5_title',
      descriptionKey: 'tip_outdoor_explorer_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_outdoor_explorer_4_5.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'reaching_exercise_1_2',
      titleKey: 'tip_reaching_exercise_1_2_title',
      descriptionKey: 'tip_reaching_exercise_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_reaching_exercise_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'supported_bounce_1_2',
      titleKey: 'tip_supported_bounce_1_2_title',
      descriptionKey: 'tip_supported_bounce_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_supported_bounce_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'visual_tracking_1_2',
      titleKey: 'tip_visual_tracking_1_2_title',
      descriptionKey: 'tip_visual_tracking_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_visual_tracking_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'face_play_1_2',
      titleKey: 'tip_face_play_1_2_title',
      descriptionKey: 'tip_face_play_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_face_play_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'emotion_labeling_1_2',
      titleKey: 'tip_emotion_labeling_1_2_title',
      descriptionKey: 'tip_emotion_labeling_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_emotion_labeling_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'first_meal',
      titleKey: 'tip_first_meal_title',
      descriptionKey: 'tip_first_meal_desc',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'hand_to_hand_transfer_4_5',
      titleKey: 'tip_hand_to_hand_transfer_4_5_title',
      descriptionKey: 'tip_hand_to_hand_transfer_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_hand_to_hand_transfer_4_5.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'supported_sitting_4_5',
      titleKey: 'tip_supported_sitting_4_5_title',
      descriptionKey: 'tip_supported_sitting_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_supported_sitting_4_5.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'feet_discovery_4_5',
      titleKey: 'tip_feet_discovery_4_5_title',
      descriptionKey: 'tip_feet_discovery_4_5_desc',
      illustrationPath: 'assets/illustrations/tips/tip_feet_discovery_4_5.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'independent_play_4_5',
      titleKey: 'tip_independent_play_4_5_title',
      descriptionKey: 'tip_independent_play_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_independent_play_4_5.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'roll_safe_space',
      fallbackTitle: 'Yuvarlanma Alanı',
      fallbackDescription:
          'Yuvarlanma başladığında oyun alanını biraz daha geniş tut. Sert köşeleri ve devrilebilecek küçük eşyaları çevreden uzaklaştır.',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'midline_hand_game',
      fallbackTitle: 'Orta Çizgi Oyunu',
      fallbackDescription:
          'İki elini ortada buluşturmasını teşvik eden hafif oyuncaklar ver. Ellerini birlikte kullanmak beden farkındalığını güçlendirir.',
      illustrationPath:
          'assets/illustrations/tips/tip_hand_to_hand_transfer_4_5.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'short_song_repetition',
      fallbackTitle: 'Kısa Şarkı Tekrarı',
      fallbackDescription:
          'Aynı kısa şarkıyı gün içinde birkaç kez söyle. Tanıdık tekrarlar hem dikkatini toplamasını hem de bağ kurmasını kolaylaştırır.',
      illustrationPath:
          'assets/illustrations/tips/tip_side_by_side_bonding_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'supported_mirror_time',
      fallbackTitle: 'Destekli Ayna Zamanı',
      fallbackDescription:
          'Kısa sürelerle aynaya birlikte bak. Yüzünü, gülümsemeni ve hareketlerini izlemesi sosyal ilgiyi artırabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_face_play_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'cool_teether_not_frozen',
      fallbackTitle: 'Dondurmadan Serinlet',
      fallbackDescription:
          'Diş kaşıyıcıyı serin kullanabilirsin ama çok soğuk ya da sert hale getirmemeye çalış. Nazik serinlik çoğu zaman yeterlidir.',
      illustrationPath: 'assets/illustrations/tips/tip_touch_explore.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.health,
    ),
    DailyTip(
      id: 'solid_readiness_watch',
      fallbackTitle: 'Hazır Oluş İşaretlerini İzle',
      fallbackDescription:
          'Yaklaşık 6 aya doğru baş kontrolü, destekle oturabilme ve yiyeceğe ilgi gibi hazır oluş işaretlerini gözlemlemek ek gıdaya geçişi planlamayı kolaylaştırır.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'toy_just_out_of_reach',
      fallbackTitle: 'Oyuncağı Biraz Uzağa Koy',
      fallbackDescription:
          'Uzanabileceği ama hemen alamayacağı kadar yakın bir oyuncak koy. Küçük çabalar gövde ve kol kontrolünü destekler.',
      illustrationPath: 'assets/illustrations/tips/tip_reaching_exercise_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'short_nap_signal',
      fallbackTitle: 'Kısa Uyku Sinyali',
      fallbackDescription:
          'Gündüz uykularından önce aynı kısa sinyali kullan: perdeyi çekmek, sakin bir cümle söylemek ya da kısa bir ninni gibi. Tekrar rahatlatıcı olabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.sleep,
    ),
    DailyTip(
      id: 'more_floor_less_seat',
      fallbackTitle: 'Zemine Daha Çok Zaman',
      fallbackDescription:
          'Uyanık zamanın bir kısmını güvenli zemin oyunlarına ayırmak dönme, uzanma ve gövde kontrolü için iyi bir fırsattır.',
      illustrationPath: 'assets/illustrations/tips/tip_mini_athlete.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'small_item_scan',
      fallbackTitle: 'Küçük Parça Taraması',
      fallbackDescription:
          'Oyun alanını kısa bir göz taramasıyla kontrol et. Düğme, pil kapağı, bozuk para ya da küçük kapaklar fark edilmeden yere inebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.webp',
      minMonths: 4,
      maxMonths: 6,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'engelli_kosu',
      titleKey: 'tip_engelli_kosu_title',
      descriptionKey: 'tip_engelli_kosu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_engelli_kosu.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'hafif_agir',
      titleKey: 'tip_hafif_agir_title',
      descriptionKey: 'tip_hafif_agir_desc',
      illustrationPath: 'assets/illustrations/tips/tip_hafif_agir.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'beni_ismimle_cagir',
      titleKey: 'tip_beni_ismimle_cagir_title',
      descriptionKey: 'tip_beni_ismimle_cagir_desc',
      illustrationPath: 'assets/illustrations/tips/tip_beni_ismimle_cagir.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'su_ne',
      titleKey: 'tip_su_ne_title',
      descriptionKey: 'tip_su_ne_desc',
      illustrationPath: 'assets/illustrations/tips/tip_su_ne.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'komut_dinlemece',
      titleKey: 'tip_komut_dinlemece_title',
      descriptionKey: 'tip_komut_dinlemece_desc',
      illustrationPath: 'assets/illustrations/tips/tip_komut_dinlemece.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'buyuk_yuruyus',
      titleKey: 'tip_buyuk_yuruyus_title',
      descriptionKey: 'tip_buyuk_yuruyus_desc',
      illustrationPath: 'assets/illustrations/tips/tip_buyuk_yuruyus.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'duzenleme_saati',
      titleKey: 'tip_duzenleme_saati_title',
      descriptionKey: 'tip_duzenleme_saati_desc',
      illustrationPath: 'assets/illustrations/tips/tip_duzenleme_saati.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'emekleme_parkuru',
      titleKey: 'tip_emekleme_parkuru_title',
      descriptionKey: 'tip_emekleme_parkuru_desc',
      illustrationPath: 'assets/illustrations/tips/tip_emekleme_parkuru.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'aynadaki_bebek',
      titleKey: 'tip_aynadaki_bebek_title',
      descriptionKey: 'tip_aynadaki_bebek_desc',
      illustrationPath: 'assets/illustrations/tips/tip_aynadaki_bebek.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'yuvarla_bakalim',
      titleKey: 'tip_yuvarla_bakalim_title',
      descriptionKey: 'tip_yuvarla_bakalim_desc',
      illustrationPath: 'assets/illustrations/tips/tip_yuvarla_bakalim.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'nesne_karsilastirma',
      titleKey: 'tip_nesne_karsilastirma_title',
      descriptionKey: 'tip_nesne_karsilastirma_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_nesne_karsilastirma.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'kucuk_okuyucu',
      titleKey: 'tip_kucuk_okuyucu_title',
      descriptionKey: 'tip_kucuk_okuyucu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_kucuk_okuyucu.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'yercekimi_deneyi',
      titleKey: 'tip_yercekimi_deneyi_title',
      descriptionKey: 'tip_yercekimi_deneyi_desc',
      illustrationPath: 'assets/illustrations/tips/tip_yercekimi_deneyi.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'adimadim_macera',
      titleKey: 'tip_adimadim_macera_title',
      descriptionKey: 'tip_adimadim_macera_desc',
      illustrationPath: 'assets/illustrations/tips/tip_adimadim_macera.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'comert_bebek',
      titleKey: 'tip_comert_bebek_title',
      descriptionKey: 'tip_comert_bebek_desc',
      illustrationPath: 'assets/illustrations/tips/tip_comert_bebek.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'yemek_zamani',
      titleKey: 'tip_yemek_zamani_title',
      descriptionKey: 'tip_yemek_zamani_desc',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'single_allergen_try',
      fallbackTitle: 'Tek Tek Alerjen Denemesi',
      fallbackDescription:
          'Alerjen içeren yiyecekleri ilk zamanlarda tek tek sunmak hangi gıdayı denediğini takip etmeyi kolaylaştırır.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'no_honey_yet',
      fallbackTitle: 'Bal İçin Biraz Daha Bekle',
      fallbackDescription:
          'Balı ilk yaş gününden sonraya bırak. Bu dönemde tat vermek için meyve, yoğurt ya da sebzelerin doğal tadı yeterlidir.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'grape_and_nut_safety',
      fallbackTitle: 'Üzümü Boyuna Böl',
      fallbackDescription:
          'Bütün üzüm, bütün kuruyemiş ve patlamış mısır bu döneme uygun değildir. Lokmaları yumuşak ve güvenli boyutta sunmak daha güvenlidir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'soft_texture_check',
      fallbackTitle: 'Yumuşak Doku Kontrolü',
      fallbackDescription:
          'Ek gıda verirken yiyeceğin parmakla kolay ezilecek kadar yumuşak olmasına dikkat et. Sert ve iri parçaları ertelemek daha güvenlidir.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'upright_mealtime',
      fallbackTitle: 'Oturarak Öğün',
      fallbackDescription:
          'Öğünleri mümkün olduğunca dik ve destekli oturuşta sun. Yatar pozisyonda ya da hareket halindeyken yedirmekten kaçınmak daha güvenlidir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'mess_is_learning',
      fallbackTitle: 'Kirlenmek Öğrenmenin Parçası',
      fallbackDescription:
          'Kaşığa, kaseye ve püreye dokunması bazen ortalığı dağıtır ama aynı zamanda öğrenmenin bir parçasıdır. Küçük miktarlar sunmak stresi azaltabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'spoon_touch_turn',
      fallbackTitle: 'Kaşığa Dokunma Sırası',
      fallbackDescription:
          'Kaşığı hemen ağzına götürmek yerine önce eline değmesine izin ver. Araçla tanışması öğünlere merakla yaklaşmasını destekleyebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'small_bites_only',
      fallbackTitle: 'Lokma Boyunu Küçük Tut',
      fallbackDescription:
          'Uzun çubuklar yerine kısa ve yumuşak parçalar sunmak kavramayı kolaylaştırabilir. Sert çiğ sebze ve iri elma parçalarını bekletmek daha güvenlidir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 6,
      maxMonths: 8,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'alkis_zamani',
      titleKey: 'tip_alkis_zamani_title',
      descriptionKey: 'tip_alkis_zamani_desc',
      illustrationPath: 'assets/illustrations/tips/tip_alkis_zamani.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'alo_kim_o',
      titleKey: 'tip_alo_kim_o_title',
      descriptionKey: 'tip_alo_kim_o_desc',
      illustrationPath: 'assets/illustrations/tips/tip_alo_kim_o.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'baybay_partisi',
      titleKey: 'tip_baybay_partisi_title',
      descriptionKey: 'tip_baybay_partisi_desc',
      illustrationPath: 'assets/illustrations/tips/tip_baybay_partisi.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'birak_izle',
      titleKey: 'tip_birak_izle_title',
      descriptionKey: 'tip_birak_izle_desc',
      illustrationPath: 'assets/illustrations/tips/tip_birak_izle.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'goster_bakalim',
      titleKey: 'tip_goster_bakalim_title',
      descriptionKey: 'tip_goster_bakalim_desc',
      illustrationPath: 'assets/illustrations/tips/tip_goster_bakalim.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'hazine_kutusu',
      titleKey: 'tip_hazine_kutusu_title',
      descriptionKey: 'tip_hazine_kutusu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_hazine_kutusu.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'minik_kitap_kurdu',
      titleKey: 'tip_minik_kitap_kurdu_title',
      descriptionKey: 'tip_minik_kitap_kurdu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_minik_kitap_kurdu.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'mobilya_dagcilari',
      titleKey: 'tip_mobilya_dagcilari_title',
      descriptionKey: 'tip_mobilya_dagcilari_desc',
      illustrationPath: 'assets/illustrations/tips/tip_mobilya_dagcilari.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'saksak_alkis',
      titleKey: 'tip_saksak_alkis_title',
      descriptionKey: 'tip_saksak_alkis_desc',
      illustrationPath: 'assets/illustrations/tips/tip_saksak_alkis.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'sira_sende',
      titleKey: 'tip_sira_sende_title',
      descriptionKey: 'tip_sira_sende_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sira_sende.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'veral_oyunu',
      titleKey: 'tip_veral_oyunu_title',
      descriptionKey: 'tip_veral_oyunu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_veral_oyunu.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'yuvarla_bekle',
      titleKey: 'tip_yuvarla_bekle_title',
      descriptionKey: 'tip_yuvarla_bekle_desc',
      illustrationPath: 'assets/illustrations/tips/tip_yuvarla_bekle.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'self_feeding_practice',
      fallbackTitle: 'Kendi Kendine Yeme Denemesi',
      fallbackDescription:
          'Yumuşak parmak gıdaları küçük porsiyonlarla sun. Kendi kendine yeme denemeleri ince motor becerilerini ve öğün merakını artırır.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'safe_furniture_edges',
      fallbackTitle: 'Tırmanma Dönemi Güvenliği',
      fallbackDescription:
          'Sehpaların köşelerini, prizleri ve devrilebilecek eşyaları yeniden kontrol et. Ayağa kalkma ve tırmanma dönemi düşündüğünden hızlı gelir.',
      illustrationPath: 'assets/illustrations/tips/tip_mobilya_dagcilari.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'naming_body_parts',
      fallbackTitle: 'Vücudunu Tanıyalım',
      fallbackDescription:
          'Burun, kulak, el gibi basit vücut bölümlerini oyunla göster. Tekrarlanan isimlendirme dil gelişimini güçlendirir.',
      illustrationPath: 'assets/illustrations/tips/tip_goster_bakalim.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'sleep_transition_cue',
      fallbackTitle: 'Uyku Geçiş Rutini',
      fallbackDescription:
          'Her gece benzer bir kısa rutin uygula: ışığı azalt, sakin konuş, aynı ninniyi seç. Tekrar eden sinyaller uykuya geçişi kolaylaştırır.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.sleep,
    ),
    DailyTip(
      id: 'coffee_table_edges',
      fallbackTitle: 'Sehpa Kenarlarına Dikkat',
      fallbackDescription:
          'Ayağa kalkma ve tutunma döneminde sehpa köşeleri yeniden dikkat ister. Sık kullanılan alanları yumuşatmak küçük çarpmaları azaltabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_mobilya_dagcilari.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'basket_object_names',
      fallbackTitle: 'Sepetteki Eşyaları Adlandır',
      fallbackDescription:
          'Küçük bir sepetten iki üç güvenli nesne seçip isimlerini tekrar et. Tanıdık sözcükleri sık duyması dil gelişimini destekler.',
      illustrationPath: 'assets/illustrations/tips/tip_hazine_kutusu.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'repeat_allergen_calmly',
      fallbackTitle: 'Aynı Alerjeni Sakin Tekrarla',
      fallbackDescription:
          'Daha önce tolere ettiği bir alerjen gıdayı zaman zaman tekrar sunmak öğün çeşitliliğini korumaya yardımcı olabilir. Yeni denemeleri yine tek tek tutmak işini kolaylaştırır.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'wave_and_wait_turns',
      fallbackTitle: 'Sırayla El Sallama',
      fallbackDescription:
          'El sallama, alkış ya da top yuvarlama gibi basit sıra oyunları bekleme ve karşılıklılık becerisini güçlendirebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_baybay_partisi.webp',
      minMonths: 9,
      maxMonths: 12,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'cup_practice',
      fallbackTitle: 'Açık Bardak Alıştırması',
      fallbackDescription:
          'Kısa öğünlerde küçük bir açık bardakla su denemesi yap. Birlikte tutarak içmeyi öğrenmesi ağız-motor koordinasyonuna katkı sağlar.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'one_step_helper',
      fallbackTitle: 'Minik Yardımcı Görevleri',
      fallbackDescription:
          'Oyuncağı sepete koymak ya da kaşığı getirmek gibi tek adımlı görevler ver. Başardığında kısa ve net övgü kullan.',
      illustrationPath: 'assets/illustrations/tips/tip_duzenleme_saati.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'toddlers_need_boundaries',
      fallbackTitle: 'Sakin ve Net Sınırlar',
      fallbackDescription:
          'Bu dönemde kısa, tutarlı sınırlar daha iyi çalışır. Aynı kurala aynı sakin tepkiyi vermek hem güven hem düzen hissi sağlar.',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'walking_path_safety',
      fallbackTitle: 'İlk Yürüyüşler İçin Alan Aç',
      fallbackDescription:
          'Kaygan halıları sabitle ve sık geçtiği alanları boşalt. Güvenli bir yürüyüş koridoru özgüvenli adımları destekler.',
      illustrationPath: 'assets/illustrations/tips/tip_buyuk_yuruyus.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'iron_rich_plate',
      fallbackTitle: 'Demirden Zengin Tabaklar',
      fallbackDescription:
          'Yumurta, yoğurt, bakliyat ya da et içeren dengeli öğünleri dönüşümlü sun. Demir kaynaklarını C vitamini içeren yiyeceklerle eşleştirmek faydalı olabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.health,
    ),
    DailyTip(
      id: 'two_safe_choices',
      fallbackTitle: 'İki Güvenli Seçenek Sun',
      fallbackDescription:
          'Gün içinde küçük kararlarda iki basit seçenek sunmak hem iş birliğini hem de bağımsızlık hissini destekleyebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'straw_practice',
      fallbackTitle: 'Pipet Denemesi',
      fallbackDescription:
          'Kısa öğünlerde küçük su miktarıyla pipet denemeleri ağız-motor koordinasyonuna katkı sağlayabilir. Yavaş ve sakin ilerlemek yeterlidir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'chair_straps_every_time',
      fallbackTitle: 'Sandalye Kemeri Her Seferinde',
      fallbackDescription:
          'Yüksek sandalye ya da bebek arabasında kısa süreli kullanımda bile kemerleri takmak düşme riskini azaltır.',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'hand_wash_song',
      fallbackTitle: 'El Yıkama Şarkısı',
      fallbackDescription:
          'Ellerini yıkarken aynı kısa şarkıyı söylemek rutini oyuna çevirebilir. Özellikle yemek öncesi ve dışarıdan gelince işe yarar.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.health,
    ),
    DailyTip(
      id: 'same_book_again',
      fallbackTitle: 'Aynı Kitabı Yeniden Oku',
      fallbackDescription:
          'Aynı kitabı tekrar tekrar istemesi çok normaldir. Tahmin edebildiği tekrarlar dili ve güven hissini besler.',
      illustrationPath: 'assets/illustrations/tips/tip_kucuk_okuyucu.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'hot_drink_distance',
      fallbackTitle: 'Sıcak İçecek Mesafesi',
      fallbackDescription:
          'Sıcak içecekleri masa kenarından ve uzanabileceği yerlerden uzak tutmak bu hareketli dönemde önemli bir güvenlik adımıdır.',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'hunger_full_words',
      fallbackTitle: 'Açlık ve Tokluk Sözleri',
      fallbackDescription:
          '“Aç mısın?”, “Tok oldun mu?” gibi basit cümleler kurmak beden sinyallerini fark etmesine zamanla destek olabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'short_transition_warning',
      fallbackTitle: 'Kısa Geçiş Uyarısı',
      fallbackDescription:
          'Oyundan yemeğe ya da banyodan uykuya geçerken kısa bir haber vermek geçişleri yumuşatabilir: “Birazdan toplayacağız” gibi.',
      illustrationPath: 'assets/illustrations/tips/tip_baybay_partisi.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.sleep,
    ),
    DailyTip(
      id: 'basket_cleanup_together',
      fallbackTitle: 'Sepete Birlikte Topla',
      fallbackDescription:
          'Oyuncakları birlikte sepete atmak küçük bir oyun olabilir. Tekrarlanan toplama denemeleri yönerge takibini destekler.',
      illustrationPath: 'assets/illustrations/tips/tip_duzenleme_saati.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'quiet_reset_corner',
      fallbackTitle: 'Sessiz Sakinleşme Köşesi',
      fallbackDescription:
          'Yastık, kitap ve sevdiği bir nesneyle kısa bir sakin köşe oluşturmak yoğun anlardan sonra birlikte toparlanmayı kolaylaştırabilir.',
      illustrationPath:
          'assets/illustrations/tips/tip_side_by_side_bonding_1_2.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'count_objects_outside',
      fallbackTitle: 'Dışarıda Nesne Say',
      fallbackDescription:
          'Yürürken ağaç, kuş ya da araba gibi gördüklerini kısa kısa adlandırmak dikkat ve kelime hazinesine katkı sağlayabilir.',
      illustrationPath:
          'assets/illustrations/tips/tip_outdoor_explorer_4_5.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'open_cup_small_sips',
      fallbackTitle: 'Açık Bardakta Küçük Yudum',
      fallbackDescription:
          'Açık bardak denemelerini kısa ve küçük miktarlarda tutmak öğrenmeyi kolaylaştırır. Birlikte tutman gerekirse bu da tamamen normaldir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'same_three_bed_steps',
      fallbackTitle: 'Uyku Öncesi Aynı Üç Adım',
      fallbackDescription:
          'Örneğin perde, kitap, sarılma gibi aynı üç küçük adımı tekrar etmek uyku öncesi öngörülebilirlik sağlar.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.sleep,
    ),
    DailyTip(
      id: 'hard_food_shape_check',
      fallbackTitle: 'Sert Lokma Kontrolü',
      fallbackDescription:
          'Sert çiğ sebzeler, iri elma parçaları ve yuvarlak sert lokmalar bu dönemde hâlâ dikkat ister. Yiyeceği yumuşatmak ya da uygun şekilde hazırlamak daha güvenlidir.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'rotate_iron_sources',
      fallbackTitle: 'Demir Kaynağını Dönüştür',
      fallbackDescription:
          'Hafta boyunca yumurta, bakliyat, et ya da yoğurt gibi farklı öğeleri dönüşümlü sunmak çeşitliliği artırabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.health,
    ),
    DailyTip(
      id: 'simple_copy_moves',
      fallbackTitle: 'Basit Taklit Hareketleri',
      fallbackDescription:
          'El sallama, baş sallama ya da alkış gibi kolay hareketleri sırayla taklit etmek sosyal etkileşimi eğlenceli hale getirebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_alkis_zamani.webp',
      minMonths: 12,
      maxMonths: 18,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'pretend_play_start',
      fallbackTitle: 'Taklit Oyunlarını Başlat',
      fallbackDescription:
          'Oyuncak telefonu kulağa götürmek, bebeği beslemek ya da arabayı sürmek gibi taklit oyunları hayal gücünü büyütür.',
      illustrationPath: 'assets/illustrations/tips/tip_alo_kim_o.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'snack_sitting_rule',
      fallbackTitle: 'Atıştırmalıkta Oturarak Yeme',
      fallbackDescription:
          'Atıştırmalıkları yürürken değil otururken sun. Bu küçük kural boğulma riskini azaltır ve öğün düzenini güçlendirir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'two_word_modeling',
      fallbackTitle: 'İki Kelimelik Mini Cümleler',
      fallbackDescription:
          'Gün içinde kısa modeller kullan: "anne geldi", "top burada", "su bitti". Basit tekrarlar konuşma gelişimini destekler.',
      illustrationPath: 'assets/illustrations/tips/tip_baybay_partisi.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'big_emotions_need_co_regulation',
      fallbackTitle: 'Büyük Duygulara Yakınlık',
      fallbackDescription:
          'Öfke ve ağlama anlarında önce sakin kalıp yanında durmak çoğu zaman en güçlü destektir. Düzenlenmeyi senden öğrenir.',
      illustrationPath:
          'assets/illustrations/tips/tip_emotion_labeling_1_2.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'toddlers_need_sleep_anchor',
      fallbackTitle: 'Uyku Saatini Sabitle',
      fallbackDescription:
          'Hafta sonları da benzer yatış saatini korumak, 18-24 ay döneminde uyku düzenini daha stabil tutmaya yardımcı olabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.sleep,
    ),
    DailyTip(
      id: 'two_step_tiny_direction',
      fallbackTitle: 'İki Adımlı Mini Yönerge',
      fallbackDescription:
          '“Topu al, sepete koy” gibi kısa iki adımlı oyunlu yönergeler hem dili hem de dikkatini destekleyebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_duzenleme_saati.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'popcorn_wait_rule',
      fallbackTitle: 'Patlamış Mısır İçin Bekle',
      fallbackDescription:
          'Patlamış mısır, bütün kuruyemiş ve yuvarlak sert lokmalar bu yaşta hâlâ uygun değildir. Daha güvenli alternatifler seçmek iyi olur.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'small_fork_practice',
      fallbackTitle: 'Küçük Çatalla Deneme',
      fallbackDescription:
          'Güvenli ve yumuşak lokmalarla küçük bir çatala birlikte deneme yapmak ince motor becerilerini destekleyebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'hug_after_the_storm',
      fallbackTitle: 'Fırtına Sonrası Sarılma',
      fallbackDescription:
          'Zor bir an geçtikten sonra kısa bir sarılma ve sakin bir cümle yeniden bağ kurmayı kolaylaştırabilir.',
      illustrationPath:
          'assets/illustrations/tips/tip_emotion_labeling_1_2.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'watch_climbing_closely',
      fallbackTitle: 'Tırmanışı Yakından İzle',
      fallbackDescription:
          'Tırmanmayı seven çocuklar için “yanındayım” gözetimi önemlidir. Düşebileceği yüksek yüzeyleri ulaşamayacağı şekilde düzenlemek iyi bir güvenlik adımıdır.',
      illustrationPath: 'assets/illustrations/tips/tip_mobilya_dagcilari.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'fill_the_last_word',
      fallbackTitle: 'Eksik Kelimeyi Tamamla',
      fallbackDescription:
          'Sık okuduğun kitapta tanıdık cümlenin son kelimesinde kısa bir duraklama yap. Sesiyle ya da bakışıyla katılması iletişimi canlandırabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_kucuk_okuyucu.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'bedtime_two_choices',
      fallbackTitle: 'Uyku Öncesi İki Seçenek',
      fallbackDescription:
          'Uyku öncesinde iki basit seçenek sunmak işe yarayabilir: “Mavi pijama mı sarı pijama mı?” gibi. Çerçeve sende kaldığında süreç daha sakin olabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.sleep,
    ),
    DailyTip(
      id: 'water_break_between_meals',
      fallbackTitle: 'Ara Öğünde Su Molası',
      fallbackDescription:
          'Öğün ve atıştırmalıkların yanında ya da arasında kısa su teklifleri rutine yardımcı olabilir. Şekerli içecek eklemeye gerek yoktur.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.health,
    ),
    DailyTip(
      id: 'rotate_toys_three_choices',
      fallbackTitle: 'Oyuncakları Dönüştür',
      fallbackDescription:
          'Aynı anda çok sayıda oyuncak yerine iki üç seçenek bırakmak odağını korumayı kolaylaştırabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_hazine_kutusu.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'name_feeling_after_calm',
      fallbackTitle: 'Duyguyu Sonradan Adlandır',
      fallbackDescription:
          'Yoğun an geçtikten sonra “çok kızmıştın” gibi kısa cümlelerle duyguyu adlandırmak anlaşılmış hissetmesine yardımcı olabilir.',
      illustrationPath:
          'assets/illustrations/tips/tip_emotion_labeling_1_2.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'finish_snack_at_table',
      fallbackTitle: 'Atıştırmalığı Masada Bitir',
      fallbackDescription:
          'Atıştırmalığı yürürken taşımak yerine oturarak başlayıp oturarak bitirmek daha güvenli bir alışkanlık oluşturabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.safety,
    ),
    DailyTip(
      id: 'mini_doctor_role_play',
      fallbackTitle: 'Mini Doktor Oyunu',
      fallbackDescription:
          'Oyuncak ayıya dinleme, sarma ya da besleme gibi oyunlar bakım becerilerini ve hayal gücünü destekleyebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_alo_kim_o.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'countdown_for_transitions',
      fallbackTitle: 'Geçişte Geri Say',
      fallbackDescription:
          'Oyundan ayrılmadan önce kısa bir geri sayım yapmak bazı çocuklarda geçişleri yumuşatabilir: “Üç tur daha, sonra toplayacağız” gibi.',
      illustrationPath: 'assets/illustrations/tips/tip_baybay_partisi.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
    ),
    DailyTip(
      id: 'wash_hands_before_snacks',
      fallbackTitle: 'Eller Temiz Sonra Atıştır',
      fallbackDescription:
          'Dışarı dönüşü ya da oyun sonrası kısa el yıkama rutini atıştırmalık öncesinde iyi bir alışkanlık kurabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.health,
    ),
    DailyTip(
      id: 'same_family_meal_base',
      fallbackTitle: 'Ailece Aynı Öğün Masası',
      fallbackDescription:
          'Uygun hazırlama ve güvenli sunumla aile öğünlerinin bazı parçalarını paylaşmak model almayı ve sofra katılımını destekleyebilir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.feeding,
    ),
    DailyTip(
      id: 'short_wait_practice',
      fallbackTitle: 'Kısa Bekleme Alıştırması',
      fallbackDescription:
          'Topu yuvarlatmadan ya da bardağı vermeden önce bir iki saniyelik küçük beklemeler yapmak sıra ve sabır becerisine yumuşak bir giriş olabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_yuvarla_bekle.webp',
      minMonths: 18,
      maxMonths: 24,
      category: DailyTipCategory.development,
    ),
    DailyTip(
      id: 'general_connection_minutes',
      fallbackTitle: 'Günde 10 Dakika Tam Dikkat',
      fallbackDescription:
          'Telefonu kenara bırakıp sadece onun seçtiği oyuna eşlik ettiğin kısa bir zaman bile bağ kurmayı güçlendirir.',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_safe_sleep_space',
      fallbackTitle: 'Uyku Alanını Düzenli Kontrol Et',
      fallbackDescription:
          'Uyku alanında gevşek battaniye, kordon ya da dikkat dağıtan küçük parçalar olmadığını ara ara yeniden kontrol et.',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.safety,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_offer_water_with_meals',
      fallbackTitle: 'Öğünde Su Hatırlatması',
      fallbackDescription:
          'Ek gıdaya geçmiş çocuklarda öğün sırasında küçük su teklifleri düzen kurmaya yardımcı olur.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 24,
      category: DailyTipCategory.feeding,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_name_the_day',
      fallbackTitle: 'Günlük Rutinleri Anlat',
      fallbackDescription:
          'Bez değişimi, banyo, yemek ve oyun sırasında ne yaptığını anlatmak hem dili hem öngörülebilirlik hissini destekler.',
      illustrationPath: 'assets/illustrations/tips/tip_goster_bakalim.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.development,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_parent_pause',
      fallbackTitle: 'Önce Sen Nefes Al',
      fallbackDescription:
          'Zor anlarda 10 saniyelik kısa bir duraklama, daha sakin tepki vermene yardım eder. Düzenli ebeveyn desteği de bakımın parçasıdır.',
      illustrationPath:
          'assets/illustrations/tips/tip_side_by_side_bonding_1_2.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_growth_watch',
      fallbackTitle: 'Rutin Dışı Durumları Not Al',
      fallbackDescription:
          'İştah, uyku ya da davranışta belirgin ve uzun süren değişiklikleri not almak gerektiğinde doktor görüşmesini kolaylaştırır.',
      illustrationPath:
          'assets/illustrations/tips/tip_emotion_labeling_1_2.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.health,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_follow_child_lead',
      fallbackTitle: 'Çocuğun Liderliğini İzle',
      fallbackDescription:
          'Oyunda kısa süre onun seçtiği şeye eşlik etmek bağlantıyı güçlendirebilir. Her an öğretmeye çalışmak gerekmez.',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_supervise_every_meal',
      fallbackTitle: 'Her Öğünde Gözetim',
      fallbackDescription:
          'İster süt ister ek gıda olsun, yemek zamanında yanında olmak güvenlik açısından önemlidir. Dikkatin tamamen onda olduğunda çok şey daha kolay fark edilir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.safety,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_repeat_allergens_calmly',
      fallbackTitle: 'Aynı Alerjeni Tekrar Sun',
      fallbackDescription:
          'Daha önce iyi tolere ettiği alerjen gıdaları arada tekrar sunmak çeşitliliği korumaya yardımcı olabilir. Yeni gıdaları ise tek tek denemek takip etmeyi kolaylaştırır.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 24,
      category: DailyTipCategory.feeding,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_clean_hands_before_care',
      fallbackTitle: 'Bakım Öncesi El Temizliği',
      fallbackDescription:
          'Beslenme, göz silme ya da yara bandı gibi yakın bakım anlarından önce kısa el temizliği iyi bir alışkanlıktır.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.health,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_reread_books',
      fallbackTitle: 'Aynı Kitap Tekrar Olur',
      fallbackDescription:
          'Aynı kitabı tekrar tekrar okumak sıkıcı değil, öğreticidir. Tanıdık cümleler ve resimler güven verir.',
      illustrationPath: 'assets/illustrations/tips/tip_kucuk_okuyucu.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.development,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_keep_lights_soft',
      fallbackTitle: 'Gece Işığını Sakin Tut',
      fallbackDescription:
          'Gece uyanmalarında çok parlak ışıklar yerine daha yumuşak bir ortam tercih etmek yeniden sakinleşmeyi kolaylaştırabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.sleep,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_scan_for_small_bits',
      fallbackTitle: 'Küçük Parça Taraması Yap',
      fallbackDescription:
          'Oyun alanını zaman zaman bozuk para, pil, mıknatıs, düğme ve küçük kapaklar için gözden geçirmek iyi bir güvenlik alışkanlığıdır.',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.safety,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_connect_before_redirect',
      fallbackTitle: 'Önce Bağ Kur Sonra Yönlendir',
      fallbackDescription:
          'Zor bir anda önce yanına inip kısa temas kurmak, ardından yönlendirmek çoğu çocukta iş birliğini kolaylaştırır.',
      illustrationPath:
          'assets/illustrations/tips/tip_side_by_side_bonding_1_2.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_offer_water_near_meals',
      fallbackTitle: 'Su Teklifini Öğüne Yaklaştır',
      fallbackDescription:
          'Ek gıdaya geçmiş çocuklarda küçük su tekliflerini öğünlerle ilişkilendirmek düzen kurmayı kolaylaştırabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 6,
      maxMonths: 24,
      category: DailyTipCategory.feeding,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_short_routine_words',
      fallbackTitle: 'Rutinleri Kısaca Anlat',
      fallbackDescription:
          '“Şimdi bez, sonra oyun” gibi kısa cümlelerle günü anlatmak ne olacağını anlamasına yardımcı olabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_goster_bakalim.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.development,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_no_added_salt_sugar',
      fallbackTitle: 'Tuz ve Şekeri Eklemeye Gerek Yok',
      fallbackDescription:
          'Çoğu öğünde yiyeceklerin kendi tadı yeterlidir. Ek tuz ya da şeker eklemeden sade ve güvenli sunum yapmak iyi bir başlangıç olabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonths: 6,
      maxMonths: 24,
      category: DailyTipCategory.feeding,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_make_floor_space',
      fallbackTitle: 'Yer Oyunu İçin Alan Aç',
      fallbackDescription:
          'Güvenli bir yer alanı açmak uzanma, dönme, emekleme ve yürüme denemelerine doğal fırsat verir.',
      illustrationPath: 'assets/illustrations/tips/tip_mini_athlete.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.development,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_notice_your_breath',
      fallbackTitle: 'Kendi Nefesini Fark Et',
      fallbackDescription:
          'Zor bir anda bir nefes kadar durmak bazen yeterli olur. Sakinleşen yetişkin tonu çocuğa da yansıyabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.parentSupport,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_daylight_minutes',
      fallbackTitle: 'Dışarıda Kısa Gün Işığı',
      fallbackDescription:
          'Mümkün olduğunda gün içinde kısa bir dışarı zamanı hem ritim hem de hareket ihtiyacı için iyi gelebilir.',
      illustrationPath:
          'assets/illustrations/tips/tip_outdoor_explorer_4_5.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.health,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_upright_high_chair',
      fallbackTitle: 'Yüksek Sandalyede Dik Oturuş',
      fallbackDescription:
          'Ek gıda döneminde dik oturuş ve uygun destek öğünleri daha güvenli hale getirebilir. Kaykılan oturuşları kısa düzeltmelerle desteklemek işe yarayabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonths: 6,
      maxMonths: 24,
      category: DailyTipCategory.safety,
      isGeneralTip: true,
    ),
    DailyTip(
      id: 'general_soft_transition_phrase',
      fallbackTitle: 'Yumuşak Geçiş Cümlesi',
      fallbackDescription:
          '“Birazdan bitireceğiz” gibi tanıdık bir geçiş cümlesini tekrar etmek gün içinde birçok değişimi daha öngörülebilir kılabilir.',
      illustrationPath: 'assets/illustrations/tips/tip_baybay_partisi.webp',
      minMonths: 0,
      maxMonths: 24,
      category: DailyTipCategory.sleep,
      isGeneralTip: true,
    ),
  ];

  static List<DailyTip> tipsForBaby(int? babyAgeInMonths) {
    if (babyAgeInMonths != null) {
      final exactMatches = tips
          .where((tip) {
            return !tip.isGeneralTip && tip.matchesAge(babyAgeInMonths);
          })
          .toList(growable: false);
      if (exactMatches.isNotEmpty) {
        return exactMatches;
      }
    }

    final generalTips = tips
        .where((tip) {
          if (!tip.isGeneralTip) return false;
          return babyAgeInMonths == null || tip.matchesAge(babyAgeInMonths);
        })
        .toList(growable: false);
    if (generalTips.isNotEmpty) {
      return generalTips;
    }

    return tips;
  }

  /// Returns the tip of the day based on the current date and baby age.
  static DailyTip todayForBaby(int? babyAgeInMonths, {DateTime? onDate}) {
    final availableTips = tipsForBaby(babyAgeInMonths);
    final date = onDate ?? DateTime.now();
    final seedDate = DateTime(date.year, date.month, date.day);
    final seed = seedDate.difference(DateTime(2024, 1, 1)).inDays;
    final index = seed.remainder(availableTips.length);
    return availableTips[index];
  }
}
