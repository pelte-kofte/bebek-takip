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
      case 'tip_tip_agu_conversation_1_2_title':
        return l10n.tip_tip_agu_conversation_1_2_title;
      case 'tip_tip_agu_conversation_1_2_desc':
        return l10n.tip_tip_agu_conversation_1_2_desc;
      case 'tip_tip_tummy_time_strength_1_2_title':
        return l10n.tip_tip_tummy_time_strength_1_2_title;
      case 'tip_tip_tummy_time_strength_1_2_desc':
        return l10n.tip_tip_tummy_time_strength_1_2_desc;
      case 'tip_tip_baby_massage_1_2_title':
        return l10n.tip_tip_baby_massage_1_2_title;
      case 'tip_tip_baby_massage_1_2_desc':
        return l10n.tip_tip_baby_massage_1_2_desc;
      case 'tip_tip_gesture_speech_1_2_title':
        return l10n.tip_tip_gesture_speech_1_2_title;
      case 'tip_tip_gesture_speech_1_2_desc':
        return l10n.tip_tip_gesture_speech_1_2_desc;
      case 'tip_tip_open_hands_1_2_title':
        return l10n.tip_tip_open_hands_1_2_title;
      case 'tip_tip_open_hands_1_2_desc':
        return l10n.tip_tip_open_hands_1_2_desc;
      case 'tip_tip_side_by_side_bonding_1_2_title':
        return l10n.tip_tip_side_by_side_bonding_1_2_title;
      case 'tip_tip_side_by_side_bonding_1_2_desc':
        return l10n.tip_tip_side_by_side_bonding_1_2_desc;
      case 'tip_tip_sound_hunter_title':
        return l10n.tip_tip_sound_hunter_title;
      case 'tip_tip_sound_hunter_desc':
        return l10n.tip_tip_sound_hunter_desc;
      case 'tip_tip_sound_hunter_level2_1_2_title':
        return l10n.tip_tip_sound_hunter_level2_1_2_title;
      case 'tip_tip_sound_hunter_level2_1_2_desc':
        return l10n.tip_tip_sound_hunter_level2_1_2_desc;
      case 'tip_tip_texture_discovery_1_2_title':
        return l10n.tip_tip_texture_discovery_1_2_title;
      case 'tip_tip_texture_discovery_1_2_desc':
        return l10n.tip_tip_texture_discovery_1_2_desc;
      case 'tip_tip_outdoor_explorer_4_5_title':
        return l10n.tip_tip_outdoor_explorer_4_5_title;
      case 'tip_tip_outdoor_explorer_4_5_desc':
        return l10n.tip_tip_outdoor_explorer_4_5_desc;
      case 'tip_tip_reaching_exercise_1_2_title':
        return l10n.tip_tip_reaching_exercise_1_2_title;
      case 'tip_tip_reaching_exercise_1_2_desc':
        return l10n.tip_tip_reaching_exercise_1_2_desc;
      case 'tip_tip_supported_bounce_1_2_title':
        return l10n.tip_tip_supported_bounce_1_2_title;
      case 'tip_tip_supported_bounce_1_2_desc':
        return l10n.tip_tip_supported_bounce_1_2_desc;
      case 'tip_tip_visual_tracking_1_2_title':
        return l10n.tip_tip_visual_tracking_1_2_title;
      case 'tip_tip_visual_tracking_1_2_desc':
        return l10n.tip_tip_visual_tracking_1_2_desc;
      case 'tip_tip_face_play_1_2_title':
        return l10n.tip_tip_face_play_1_2_title;
      case 'tip_tip_face_play_1_2_desc':
        return l10n.tip_tip_face_play_1_2_desc;
      case 'tip_tip_emotion_labeling_1_2_title':
        return l10n.tip_tip_emotion_labeling_1_2_title;
      case 'tip_tip_emotion_labeling_1_2_desc':
        return l10n.tip_tip_emotion_labeling_1_2_desc;
      case 'tip_tip_first_meal_title':
        return l10n.tip_tip_first_meal_title;
      case 'tip_tip_first_meal_desc':
        return l10n.tip_tip_first_meal_desc;
      case 'tip_tip_hand_to_hand_transfer_4_5_title':
        return l10n.tip_tip_hand_to_hand_transfer_4_5_title;
      case 'tip_tip_hand_to_hand_transfer_4_5_desc':
        return l10n.tip_tip_hand_to_hand_transfer_4_5_desc;
      case 'tip_tip_supported_sitting_4_5_title':
        return l10n.tip_tip_supported_sitting_4_5_title;
      case 'tip_tip_supported_sitting_4_5_desc':
        return l10n.tip_tip_supported_sitting_4_5_desc;
      case 'tip_tip_feet_discovery_4_5_title':
        return l10n.tip_tip_feet_discovery_4_5_title;
      case 'tip_tip_feet_discovery_4_5_desc':
        return l10n.tip_tip_feet_discovery_4_5_desc;
      case 'tip_tip_independent_play_4_5_title':
        return l10n.tip_tip_independent_play_4_5_title;
      case 'tip_tip_independent_play_4_5_desc':
        return l10n.tip_tip_independent_play_4_5_desc;
      default:
        return key;
    }
  }

  static const List<DailyTip> tips = [
    DailyTip(
      id: 'siyah_mekonyum',
      titleKey: 'tip_siyah_mekonyum_title',
      descriptionKey: 'tip_siyah_mekonyum_desc',
      illustrationPath: 'assets/illustrations/tips/tip_mekonyum.png',
      minMonth: 0,
      maxMonth: 1,
    ),
    DailyTip(
      id: 'eye_tracking',
      titleKey: 'tip_eye_tracking_title',
      descriptionKey: 'tip_eye_tracking_desc',
      illustrationPath: 'assets/illustrations/tips/tip_eye_tracking.png',
      minMonth: 1,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'neck_support',
      titleKey: 'tip_neck_support_title',
      descriptionKey: 'tip_neck_support_desc',
      illustrationPath: 'assets/illustrations/tips/tip_neck_support.png',
      minMonth: 0,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'reflex_stepping',
      titleKey: 'tip_reflex_stepping_title',
      descriptionKey: 'tip_reflex_stepping_desc',
      illustrationPath: 'assets/illustrations/tips/tip_reflex_stepping.png',
      minMonth: 1,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'sound_interest',
      titleKey: 'tip_sound_interest_title',
      descriptionKey: 'tip_sound_interest_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sound_interest.png',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'parent_interaction',
      titleKey: 'tip_parent_interaction_title',
      descriptionKey: 'tip_parent_interaction_desc',
      illustrationPath: 'assets/illustrations/tips/tip_parent_interaction.png',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'color_worlds',
      titleKey: 'tip_color_worlds_title',
      descriptionKey: 'tip_color_worlds_desc',
      illustrationPath: 'assets/illustrations/tips/tip_color_worlds.png',
      minMonth: 0,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'mini_athlete',
      titleKey: 'tip_mini_athlete_title',
      descriptionKey: 'tip_mini_athlete_desc',
      illustrationPath: 'assets/illustrations/tips/tip_mini_athlete.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'sound_hunter',
      titleKey: 'tip_sound_hunter_title',
      descriptionKey: 'tip_sound_hunter_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.png',
      minMonth: 0,
      maxMonth: 2,
    ),
    DailyTip(
      id: 'touch_explore',
      titleKey: 'tip_touch_explore_title',
      descriptionKey: 'tip_touch_explore_desc',
      illustrationPath: 'assets/illustrations/tips/tip_touch_explore.png',
      minMonth: 0,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tip_agu_conversation_1_2',
      titleKey: 'tip_tip_agu_conversation_1_2_title',
      descriptionKey: 'tip_tip_agu_conversation_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_agu_conversation_1_2.png',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tip_tummy_time_strength_1_2',
      titleKey: 'tip_tip_tummy_time_strength_1_2_title',
      descriptionKey: 'tip_tip_tummy_time_strength_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_tummy_time_strength_1_2.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_baby_massage_1_2',
      titleKey: 'tip_tip_baby_massage_1_2_title',
      descriptionKey: 'tip_tip_baby_massage_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_baby_massage_1_2.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_gesture_speech_1_2',
      titleKey: 'tip_tip_gesture_speech_1_2_title',
      descriptionKey: 'tip_tip_gesture_speech_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_gesture_speech_1_2.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_open_hands_1_2',
      titleKey: 'tip_tip_open_hands_1_2_title',
      descriptionKey: 'tip_tip_open_hands_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_open_hands_1_2.png',
      minMonth: 2,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_side_by_side_bonding_1_2',
      titleKey: 'tip_tip_side_by_side_bonding_1_2_title',
      descriptionKey: 'tip_tip_side_by_side_bonding_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_side_by_side_bonding_1_2.png',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tip_sound_hunter',
      titleKey: 'tip_tip_sound_hunter_title',
      descriptionKey: 'tip_tip_sound_hunter_desc',
      illustrationPath: 'assets/illustrations/tips/tip_sound_hunter.png',
      minMonth: 2,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_sound_hunter_level2_1_2',
      titleKey: 'tip_tip_sound_hunter_level2_1_2_title',
      descriptionKey: 'tip_tip_sound_hunter_level2_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_sound_hunter_level2_1_2.png',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_texture_discovery_1_2',
      titleKey: 'tip_tip_texture_discovery_1_2_title',
      descriptionKey: 'tip_tip_texture_discovery_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_texture_discovery_1_2.png',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_outdoor_explorer_4_5',
      titleKey: 'tip_tip_outdoor_explorer_4_5_title',
      descriptionKey: 'tip_tip_outdoor_explorer_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_outdoor_explorer_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'tip_reaching_exercise_1_2',
      titleKey: 'tip_tip_reaching_exercise_1_2_title',
      descriptionKey: 'tip_tip_reaching_exercise_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_reaching_exercise_1_2.png',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_supported_bounce_1_2',
      titleKey: 'tip_tip_supported_bounce_1_2_title',
      descriptionKey: 'tip_tip_supported_bounce_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_supported_bounce_1_2.png',
      minMonth: 2,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_visual_tracking_1_2',
      titleKey: 'tip_tip_visual_tracking_1_2_title',
      descriptionKey: 'tip_tip_visual_tracking_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_visual_tracking_1_2.png',
      minMonth: 1,
      maxMonth: 4,
    ),
    DailyTip(
      id: 'tip_face_play_1_2',
      titleKey: 'tip_tip_face_play_1_2_title',
      descriptionKey: 'tip_tip_face_play_1_2_desc',
      illustrationPath: 'assets/illustrations/tips/tip_face_play_1_2.png',
      minMonth: 1,
      maxMonth: 3,
    ),
    DailyTip(
      id: 'tip_emotion_labeling_1_2',
      titleKey: 'tip_tip_emotion_labeling_1_2_title',
      descriptionKey: 'tip_tip_emotion_labeling_1_2_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_emotion_labeling_1_2.png',
      minMonth: 1,
      maxMonth: 5,
    ),
    DailyTip(
      id: 'tip_first_meal',
      titleKey: 'tip_tip_first_meal_title',
      descriptionKey: 'tip_tip_first_meal_desc',
      illustrationPath: 'assets/illustrations/tips/tip_first_meal.png',
      minMonth: 5,
      maxMonth: 8,
    ),
    DailyTip(
      id: 'tip_hand_to_hand_transfer_4_5',
      titleKey: 'tip_tip_hand_to_hand_transfer_4_5_title',
      descriptionKey: 'tip_tip_hand_to_hand_transfer_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_hand_to_hand_transfer_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'tip_supported_sitting_4_5',
      titleKey: 'tip_tip_supported_sitting_4_5_title',
      descriptionKey: 'tip_tip_supported_sitting_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_supported_sitting_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'tip_feet_discovery_4_5',
      titleKey: 'tip_tip_feet_discovery_4_5_title',
      descriptionKey: 'tip_tip_feet_discovery_4_5_desc',
      illustrationPath: 'assets/illustrations/tips/tip_feet_discovery_4_5.png',
      minMonth: 4,
      maxMonth: 7,
    ),
    DailyTip(
      id: 'tip_independent_play_4_5',
      titleKey: 'tip_tip_independent_play_4_5_title',
      descriptionKey: 'tip_tip_independent_play_4_5_desc',
      illustrationPath:
          'assets/illustrations/tips/tip_independent_play_4_5.png',
      minMonth: 4,
      maxMonth: 7,
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
