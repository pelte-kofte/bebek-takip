import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages cross-device shared-baby activity notifications.
///
/// Flow:
///   1. [reportActivity] calls the `notifySharedActivity` Cloud Function,
///      which writes an inbox document for each co-parent.
///   2. [_startListening] streams users/{uid}/inboxNotifications, shows
///      a local notification for any new (read=false) doc created after the
///      current session started, and marks it read immediately.
///
/// Notification IDs: 40000–40099 (does not collide with ReminderService range).
class ActivityNotificationService {
  ActivityNotificationService._();
  static final ActivityNotificationService instance =
      ActivityNotificationService._();

  // ── Notification config ──────────────────────────────────────────────────
  static const int _baseId = 40000;
  static const String _channelId = 'shared_activity_updates';
  static const String _channelName = 'Shared Activity Updates';

  // ── Internal state ───────────────────────────────────────────────────────
  final _plugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _inboxSub;
  StreamSubscription<User?>? _authSub;
  DateTime? _sessionStart;
  int _notifSeq = 0;
  bool _initialized = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  /// Call once (e.g., in main after Firebase init).
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Initialize the local notifications plugin.
      // If ReminderService already called initialize(), this is idempotent.
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      // Create the Android notification channel.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              importance: Importance.defaultImportance,
            ),
          );
    } catch (e) {
      _log('init plugin error: $e');
    }

    // Start/stop listening whenever auth state changes.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !user.isAnonymous) {
        _startListening(user.uid);
      } else {
        _stopListening();
      }
    });
  }

  void _startListening(String uid) {
    _stopListening();
    _sessionStart = DateTime.now();
    _log('listening uid=$uid');

    _inboxSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inboxNotifications')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen(
          (snap) {
            for (final change in snap.docChanges) {
              if (change.type != DocumentChangeType.added) continue;
              final data = change.doc.data();
              if (data == null || data['read'] == true) continue;

              // Skip docs that existed before this session (app restart).
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final start = _sessionStart;
              if (createdAt == null || (start != null && createdAt.isBefore(start))) {
                continue;
              }

              _showNotification(data);
              // Best-effort mark as read so the next session skips it.
              change.doc.reference.update({'read': true}).ignore();
            }
          },
          onError: (Object e) => _log('stream error: $e'),
        );
  }

  void _stopListening() {
    _inboxSub?.cancel();
    _inboxSub = null;
  }

  /// Call to shut down completely (e.g., on sign-out from a top-level handler).
  void dispose() {
    _stopListening();
    _authSub?.cancel();
    _authSub = null;
  }

  // ── Local notification display ───────────────────────────────────────────

  Future<void> _showNotification(Map<String, dynamic> data) async {
    final body =
        (data['body'] as String?)?.trim().isNotEmpty == true
        ? data['body'] as String
        : 'A co-parent logged an activity.';
    try {
      await _plugin.show(
        _baseId + (_notifSeq++ % 100),
        'Shared Baby Update',
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      _log('show notification error: $e');
    }
  }

  // ── Cloud Function call ──────────────────────────────────────────────────

  /// Fire-and-forget: asks the backend to notify co-parents of a logged activity.
  ///
  /// Safe to call for ANY baby — the Cloud Function returns early with
  /// {notified: 0} if the baby has no co-parents, so there is no wasted work
  /// on non-shared babies beyond a single cheap callable invocation.
  ///
  /// Supported [activityType] values: `feeding`, `sleep`, `diaper`, `medication`.
  Future<void> reportActivity({
    required String babyId,
    required String activityType,
    required String babyName,
  }) async {
    if (babyId.isEmpty) return;
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('notifySharedActivity');
      await callable.call<void>({
        'babyId': babyId,
        'activityType': activityType,
        'babyName': babyName,
      });
      _log('reported activityType=$activityType babyId=$babyId');
    } catch (e) {
      // Best-effort — notifications are non-critical; never surface to user.
      _log('reportActivity error: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _log(String message) {
    if (kDebugMode) debugPrint('[ActivityNotificationService] $message');
  }
}
