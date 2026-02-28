import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class DailyTip {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String illustrationPath;
  final int minMonth;
  final int maxMonth;

  const DailyTip({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.illustrationPath,
    required this.minMonth,
    required this.maxMonth,
  });

  String title(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _localizedValue(l10n, titleKey);
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _localizedValue(l10n, descriptionKey);
  }

  static String _localizedValue(AppLocalizations l10n, String key) {
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
        return key;
    }
  }

  static const List<DailyTip> tips = [
    DailyTip(
      id: 'siyah_mekonyum',
      titleKey: 'tip_siyah_mekonyum_title',
      descriptionKey: 'tip_siyah_mekonyum_desc',
      illustrationPath: 'assets/illustrations/tips/tip_mekonyum.webp',
      minMonth: 0,
      maxMonth: 1,
    ),
    DailyTip(
      id: 'eye_tracking',
      titleKey: 'tip_eye_tracking_title',
      descriptionKey: 'tip_eye_tracking_desc',
      illustrationPath: 'assets/illustrations/tips/tip_eye_tracking.webp',
      minMonth: 1,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'neck_support',
      titleKey: 'tip_neck_support_title',
      descriptionKey: 'tip_neck_support_desc',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.webp',
      minMonth: 0,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'reflex_stepping',
      titleKey: 'tip_reflex_stepping_title',
      descriptionKey: 'tip_reflex_stepping_desc',
      illustrationPath: 'assets/illustrations/tips/tip_reflex_stepping.webp',
      minMonth: 1,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'sound_interest',
      titleKey: 'tip_sound_interest_title',
      descriptionKey: 'tip_sound_interest_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sound_interest.webp',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'parent_interaction',
      titleKey: 'tip_parent_interaction_title',
      descriptionKey: 'tip_parent_interaction_desc',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.webp',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'color_worlds',
      titleKey: 'tip_color_worlds_title',
      descriptionKey: 'tip_color_worlds_desc',
      illustrationPath: 'assets/illustrations/tips/tip_color_worlds.webp',
      minMonth: 0,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'mini_athlete',
      titleKey: 'tip_mini_athlete_title',
      descriptionKey: 'tip_mini_athlete_desc',
      illustrationPath: 'assets/illustrations/tips/tip_mini_athlete.webp',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'sound_hunter',
      titleKey: 'tip_sound_hunter_title',
      descriptionKey: 'tip_sound_hunter_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.webp',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'touch_explore',
      titleKey: 'tip_touch_explore_title',
      descriptionKey: 'tip_touch_explore_desc',
      illustrationPath: 'assets/illustrations/tips/tip_touch_explore.webp',
      minMonth: 0,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'agu_conversation_1_2',
      titleKey: 'tip_agu_conversation_1_2_title',
      descriptionKey: 'tip_agu_conversation_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_agu_conversation_1_2.webp',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tummy_time_strength_1_2',
      titleKey: 'tip_tummy_time_strength_1_2_title',
      descriptionKey: 'tip_tummy_time_strength_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_tummy_time_strength_1_2.webp',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'baby_massage_1_2',
      titleKey: 'tip_baby_massage_1_2_title',
      descriptionKey: 'tip_baby_massage_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.webp',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'gesture_speech_1_2',
      titleKey: 'tip_gesture_speech_1_2_title',
      descriptionKey: 'tip_gesture_speech_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_gesture_speech_1_2.webp',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'open_hands_1_2',
      titleKey: 'tip_open_hands_1_2_title',
      descriptionKey: 'tip_open_hands_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_open_hands_1_2.webp',
      minMonth: 2,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'side_by_side_bonding_1_2',
      titleKey: 'tip_side_by_side_bonding_1_2_title',
      descriptionKey: 'tip_side_by_side_bonding_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_side_by_side_bonding_1_2.webp',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'sound_hunter_listening',
      titleKey: 'tip_sound_hunter_listening_title',
      descriptionKey: 'tip_sound_hunter_listening_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.webp',
      minMonth: 2,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'sound_hunter_level2_1_2',
      titleKey: 'tip_sound_hunter_level2_1_2_title',
      descriptionKey: 'tip_sound_hunter_level2_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_sound_hunter_level2_1_2.webp',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'texture_discovery_1_2',
      titleKey: 'tip_texture_discovery_1_2_title',
      descriptionKey: 'tip_texture_discovery_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_texture_discovery_1_2.webp',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'outdoor_explorer_4_5',
      titleKey: 'tip_outdoor_explorer_4_5_title',
      descriptionKey: 'tip_outdoor_explorer_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_outdoor_explorer_4_5.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'reaching_exercise_1_2',
      titleKey: 'tip_reaching_exercise_1_2_title',
      descriptionKey: 'tip_reaching_exercise_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_reaching_exercise_1_2.webp',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'supported_bounce_1_2',
      titleKey: 'tip_supported_bounce_1_2_title',
      descriptionKey: 'tip_supported_bounce_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_supported_bounce_1_2.webp',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'visual_tracking_1_2',
      titleKey: 'tip_visual_tracking_1_2_title',
      descriptionKey: 'tip_visual_tracking_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_visual_tracking_1_2.webp',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'face_play_1_2',
      titleKey: 'tip_face_play_1_2_title',
      descriptionKey: 'tip_face_play_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_face_play_1_2.webp',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'emotion_labeling_1_2',
      titleKey: 'tip_emotion_labeling_1_2_title',
      descriptionKey: 'tip_emotion_labeling_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_emotion_labeling_1_2.webp',
      minMonth: 1,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'first_meal',
      titleKey: 'tip_first_meal_title',
      descriptionKey: 'tip_first_meal_desc',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.webp',
      minMonth: 5,
      maxMonth: 8,
    ),
    DailyTip(
      id: 'hand_to_hand_transfer_4_5',
      titleKey: 'tip_hand_to_hand_transfer_4_5_title',
      descriptionKey: 'tip_hand_to_hand_transfer_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_hand_to_hand_transfer_4_5.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'supported_sitting_4_5',
      titleKey: 'tip_supported_sitting_4_5_title',
      descriptionKey: 'tip_supported_sitting_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_supported_sitting_4_5.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'feet_discovery_4_5',
      titleKey: 'tip_feet_discovery_4_5_title',
      descriptionKey: 'tip_feet_discovery_4_5_desc',
      illustrationPath: 'assets/illustrations/tips/tip_feet_discovery_4_5.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'independent_play_4_5',
      titleKey: 'tip_independent_play_4_5_title',
      descriptionKey: 'tip_independent_play_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_independent_play_4_5.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'engelli_kosu',
      titleKey: 'tip_engelli_kosu_title',
      descriptionKey: 'tip_engelli_kosu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_engelli_kosu.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'hafif_agir',
      titleKey: 'tip_hafif_agir_title',
      descriptionKey: 'tip_hafif_agir_desc',
      illustrationPath: 'assets/illustrations/tips/tip_hafif_agir.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'beni_ismimle_cagir',
      titleKey: 'tip_beni_ismimle_cagir_title',
      descriptionKey: 'tip_beni_ismimle_cagir_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_beni_ismimle_cagir.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'su_ne',
      titleKey: 'tip_su_ne_title',
      descriptionKey: 'tip_su_ne_desc',
      illustrationPath: 'assets/illustrations/tips/tip_su_ne.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'komut_dinlemece',
      titleKey: 'tip_komut_dinlemece_title',
      descriptionKey: 'tip_komut_dinlemece_desc',
      illustrationPath: 'assets/illustrations/tips/tip_komut_dinlemece.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'buyuk_yuruyus',
      titleKey: 'tip_buyuk_yuruyus_title',
      descriptionKey: 'tip_buyuk_yuruyus_desc',
      illustrationPath: 'assets/illustrations/tips/tip_buyuk_yuruyus.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'duzenleme_saati',
      titleKey: 'tip_duzenleme_saati_title',
      descriptionKey: 'tip_duzenleme_saati_desc',
      illustrationPath: 'assets/illustrations/tips/tip_duzenleme_saati.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'emekleme_parkuru',
      titleKey: 'tip_emekleme_parkuru_title',
      descriptionKey: 'tip_emekleme_parkuru_desc',
      illustrationPath: 'assets/illustrations/tips/tip_emekleme_parkuru.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'aynadaki_bebek',
      titleKey: 'tip_aynadaki_bebek_title',
      descriptionKey: 'tip_aynadaki_bebek_desc',
      illustrationPath: 'assets/illustrations/tips/tip_aynadaki_bebek.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'yuvarla_bakalim',
      titleKey: 'tip_yuvarla_bakalim_title',
      descriptionKey: 'tip_yuvarla_bakalim_desc',
      illustrationPath: 'assets/illustrations/tips/tip_yuvarla_bakalim.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'nesne_karsilastirma',
      titleKey: 'tip_nesne_karsilastirma_title',
      descriptionKey: 'tip_nesne_karsilastirma_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_nesne_karsilastirma.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'kucuk_okuyucu',
      titleKey: 'tip_kucuk_okuyucu_title',
      descriptionKey: 'tip_kucuk_okuyucu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_kucuk_okuyucu.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'yercekimi_deneyi',
      titleKey: 'tip_yercekimi_deneyi_title',
      descriptionKey: 'tip_yercekimi_deneyi_desc',
      illustrationPath: 'assets/illustrations/tips/tip_yercekimi_deneyi.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'adimadim_macera',
      titleKey: 'tip_adimadim_macera_title',
      descriptionKey: 'tip_adimadim_macera_desc',
      illustrationPath: 'assets/illustrations/tips/tip_adimadim_macera.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'comert_bebek',
      titleKey: 'tip_comert_bebek_title',
      descriptionKey: 'tip_comert_bebek_desc',
      illustrationPath: 'assets/illustrations/tips/tip_comert_bebek.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'yemek_zamani',
      titleKey: 'tip_yemek_zamani_title',
      descriptionKey: 'tip_yemek_zamani_desc',
      illustrationPath: 'assets/illustrations/tips/tip_yemek_zamani.webp',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'alkis_zamani',
      titleKey: 'tip_alkis_zamani_title',
      descriptionKey: 'tip_alkis_zamani_desc',
      illustrationPath: 'assets/illustrations/tips/tip_alkis_zamani.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'alo_kim_o',
      titleKey: 'tip_alo_kim_o_title',
      descriptionKey: 'tip_alo_kim_o_desc',
      illustrationPath: 'assets/illustrations/tips/tip_alo_kim_o.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'baybay_partisi',
      titleKey: 'tip_baybay_partisi_title',
      descriptionKey: 'tip_baybay_partisi_desc',
      illustrationPath: 'assets/illustrations/tips/tip_baybay_partisi.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'birak_izle',
      titleKey: 'tip_birak_izle_title',
      descriptionKey: 'tip_birak_izle_desc',
      illustrationPath: 'assets/illustrations/tips/tip_birak_izle.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'goster_bakalim',
      titleKey: 'tip_goster_bakalim_title',
      descriptionKey: 'tip_goster_bakalim_desc',
      illustrationPath: 'assets/illustrations/tips/tip_goster_bakalim.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'hazine_kutusu',
      titleKey: 'tip_hazine_kutusu_title',
      descriptionKey: 'tip_hazine_kutusu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_hazine_kutusu.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'minik_kitap_kurdu',
      titleKey: 'tip_minik_kitap_kurdu_title',
      descriptionKey: 'tip_minik_kitap_kurdu_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_minik_kitap_kurdu.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'mobilya_dagcilari',
      titleKey: 'tip_mobilya_dagcilari_title',
      descriptionKey: 'tip_mobilya_dagcilari_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_mobilya_dagcilari.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'saksak_alkis',
      titleKey: 'tip_saksak_alkis_title',
      descriptionKey: 'tip_saksak_alkis_desc',
      illustrationPath: 'assets/illustrations/tips/tip_saksak_alkis.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'sira_sende',
      titleKey: 'tip_sira_sende_title',
      descriptionKey: 'tip_sira_sende_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sira_sende.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'veral_oyunu',
      titleKey: 'tip_veral_oyunu_title',
      descriptionKey: 'tip_veral_oyunu_desc',
      illustrationPath: 'assets/illustrations/tips/tip_veral_oyunu.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
    DailyTip(
      id: 'yuvarla_bekle',
      titleKey: 'tip_yuvarla_bekle_title',
      descriptionKey: 'tip_yuvarla_bekle_desc',
      illustrationPath: 'assets/illustrations/tips/tip_yuvarla_bekle.webp',
      minMonth: 6,
      maxMonth: 9,
    ),
  ];

  /// Returns the tip of the day based on the current date.
  static DailyTip todayForBaby(int babyAgeInMonths) {
    final availableTips = tips.where((tip) {
      return babyAgeInMonths >= tip.minMonth && babyAgeInMonths < tip.maxMonth;
    }).toList();

    if (availableTips.isEmpty) {
      return tips.first; // fallback (normalde buraya düşmez)
    }

    final index = DateTime.now().day % availableTips.length;
    return availableTips[index];
  }
}
