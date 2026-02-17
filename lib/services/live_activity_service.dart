import 'dart:io';
import 'package:flutter/services.dart';

/// Service for managing iOS Live Activities (Lock Screen / Dynamic Island timers).
/// Gracefully no-ops on Android and iOS < 16.1.
class LiveActivityService {
  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal();

  static const _channel = MethodChannel('com.Nilico.Baby/liveActivity');

  bool get _isSupported => Platform.isIOS;

  Future<void> startSleepActivity({
    required String babyId,
    required String babyName,
    required DateTime startTime,
    required String localizedTitle,
    String? localizedSubtitle,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('startSleepLiveActivity', {
        'babyId': babyId,
        'babyName': babyName,
        'startEpochSeconds': startTime.millisecondsSinceEpoch ~/ 1000,
        'localizedTitle': localizedTitle,
        'localizedSubtitle': localizedSubtitle ?? '',
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> updateSleepActivity({
    required String babyId,
    required String babyName,
    required String localizedTitle,
    String? localizedSubtitle,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('updateSleepLiveActivity', {
        'babyId': babyId,
        'babyName': babyName,
        'localizedTitle': localizedTitle,
        'localizedSubtitle': localizedSubtitle ?? '',
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> stopSleepActivity({
    required String babyId,
    String? localizedTitle,
    String? localizedSubtitle,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('stopSleepLiveActivity', {
        'babyId': babyId,
        'localizedTitle': localizedTitle ?? '',
        'localizedSubtitle': localizedSubtitle ?? '',
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> startNursingActivity({
    required String babyId,
    required String babyName,
    required DateTime startTime,
    required String side,
    required String localizedTitle,
    String? localizedSubtitle,
    String? localizedLeftLabel,
    String? localizedRightLabel,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('startNursingLiveActivity', {
        'babyId': babyId,
        'babyName': babyName,
        'startEpochSeconds': startTime.millisecondsSinceEpoch ~/ 1000,
        'side': side,
        'localizedTitle': localizedTitle,
        'localizedSubtitle': localizedSubtitle ?? '',
        'localizedLeftLabel': localizedLeftLabel ?? '',
        'localizedRightLabel': localizedRightLabel ?? '',
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> updateNursingSide({
    required String babyId,
    required String babyName,
    required String side,
    required String localizedTitle,
    String? localizedSubtitle,
    String? localizedLeftLabel,
    String? localizedRightLabel,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('updateNursingSide', {
        'babyId': babyId,
        'babyName': babyName,
        'side': side,
        'localizedTitle': localizedTitle,
        'localizedSubtitle': localizedSubtitle ?? '',
        'localizedLeftLabel': localizedLeftLabel ?? '',
        'localizedRightLabel': localizedRightLabel ?? '',
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> stopNursingActivity({
    required String babyId,
    String? localizedTitle,
    String? localizedSubtitle,
    String? localizedLeftLabel,
    String? localizedRightLabel,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('stopNursingLiveActivity', {
        'babyId': babyId,
        'localizedTitle': localizedTitle ?? '',
        'localizedSubtitle': localizedSubtitle ?? '',
        'localizedLeftLabel': localizedLeftLabel ?? '',
        'localizedRightLabel': localizedRightLabel ?? '',
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }
}
