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
    required DateTime startTime,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('startSleepLiveActivity', {
        'babyId': babyId,
        'startEpochSeconds': startTime.millisecondsSinceEpoch ~/ 1000,
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> stopSleepActivity({required String babyId}) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('stopSleepLiveActivity', {
        'babyId': babyId,
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> startNursingActivity({
    required String babyId,
    required DateTime startTime,
    required String side,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('startNursingLiveActivity', {
        'babyId': babyId,
        'startEpochSeconds': startTime.millisecondsSinceEpoch ~/ 1000,
        'side': side,
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> updateNursingSide({
    required String babyId,
    required String side,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('updateNursingSide', {
        'babyId': babyId,
        'side': side,
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> stopNursingActivity({required String babyId}) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod('stopNursingLiveActivity', {
        'babyId': babyId,
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }
}
