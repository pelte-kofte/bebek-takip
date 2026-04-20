import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A baby invitation (received or sent).
class InvitationItem {
  final String id;
  final String babyId;
  final String? babyName;
  final String? ownerDisplayName;
  final String? inviteeEmail;
  final String? inviteCode;
  final String inviteType;
  final DateTime? expiresAt;
  final String status;
  final DateTime? createdAt;

  const InvitationItem({
    required this.id,
    required this.babyId,
    this.babyName,
    this.ownerDisplayName,
    this.inviteeEmail,
    this.inviteCode,
    this.inviteType = 'email',
    this.expiresAt,
    this.status = 'pending',
    this.createdAt,
  });

  factory InvitationItem.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return InvitationItem(
      id: doc.id,
      babyId: (d['babyId'] as String?) ?? '',
      babyName: d['babyName'] as String?,
      ownerDisplayName: d['ownerDisplayName'] as String?,
      inviteeEmail: d['inviteeEmail'] as String?,
      inviteCode: d['inviteCode'] as String?,
      inviteType: (d['inviteType'] as String?) ?? 'email',
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate(),
      status: (d['status'] as String?) ?? 'pending',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class CreateInviteCodeResult {
  final String invitationId;
  final String inviteCode;
  final bool existingInvitation;
  final DateTime? expiresAt;

  const CreateInviteCodeResult({
    required this.invitationId,
    required this.inviteCode,
    required this.existingInvitation,
    this.expiresAt,
  });
}

/// Result returned by [SharedParentingService.sendInvitation].
class SendInvitationResult {
  final String invitationId;
  final bool existingInvitation;
  const SendInvitationResult({
    required this.invitationId,
    required this.existingInvitation,
  });
}

/// Service for Shared Parenting / Multiuser features.
///
/// Step 2A: sendInvitation — backend callable implemented.
/// Step 2B: acceptInvitation / declineInvitation — backend callable implemented.
/// Step 3:  watchPendingInvitations — live stream for invitation inbox UI.
class SharedParentingService {
  SharedParentingService._();
  static final SharedParentingService instance = SharedParentingService._();

  DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Sends an invitation to [inviteeEmail] to co-parent baby [babyId].
  ///
  /// Throws [FirebaseFunctionsException] on validation, ownership, or premium
  /// errors. If a pending invitation already exists the function returns it
  /// rather than throwing.
  Future<SendInvitationResult> sendInvitation({
    required String babyId,
    required String inviteeEmail,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('sendInvitation');
    final result = await callable.call<Map<String, dynamic>>({
      'babyId': babyId,
      'inviteeEmail': inviteeEmail,
    });
    final data = result.data;
    return SendInvitationResult(
      invitationId: data['invitationId'] as String,
      existingInvitation: data['existingInvitation'] as bool? ?? false,
    );
  }

  Future<CreateInviteCodeResult> createInviteCode({
    required String babyId,
  }) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('createInviteCode');
    final result = await callable.call<Map<String, dynamic>>({
      'babyId': babyId,
    });
    final data = result.data;
    return CreateInviteCodeResult(
      invitationId: data['invitationId'] as String,
      inviteCode: data['inviteCode'] as String,
      existingInvitation: data['existingInvitation'] as bool? ?? false,
      expiresAt: _toDate(data['expiresAt']),
    );
  }

  Future<String> acceptInvitationCode({required String inviteCode}) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('acceptInvitationCode');
    final result = await callable.call<Map<String, dynamic>>({
      'inviteCode': inviteCode,
    });
    return result.data['babyId'] as String;
  }

  /// Accepts a pending invitation by its [invitationId].
  ///
  /// The caller's Firebase Auth email must match the invitation's inviteeEmail.
  /// Throws [FirebaseFunctionsException] on invalid/expired/mismatched invitation.
  ///
  /// Returns the [babyId] that was shared on success.
  Future<String> acceptInvitation({required String invitationId}) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('acceptInvitation');
    final result = await callable.call<Map<String, dynamic>>({
      'invitationId': invitationId,
    });
    return result.data['babyId'] as String;
  }

  /// Declines a pending invitation by its [invitationId].
  ///
  /// The caller's Firebase Auth email must match the invitation's inviteeEmail.
  /// Throws [FirebaseFunctionsException] on invalid/expired/mismatched invitation.
  Future<void> declineInvitation({required String invitationId}) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('declineInvitation');
    await callable.call<Map<String, dynamic>>({
      'invitationId': invitationId,
    });
  }

  /// Removes an accepted member from a shared baby.
  ///
  /// Only the baby owner may call this. The callable atomically removes the
  /// member from [babies/{babyId}/members] and deletes their
  /// [users/{memberUid}/sharedBabies/{babyId}] document so their next sync
  /// drops access immediately.
  Future<void> removeMember({
    required String babyId,
    required String memberUid,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('removeMember');
    await callable.call<Map<String, dynamic>>({
      'babyId': babyId,
      'memberUid': memberUid,
    });
  }

  /// Cancels a pending invitation that the current user sent.
  ///
  /// Only the invitation owner can cancel, and only while status is 'pending'.
  /// The Firestore stream in [watchSentInvitations] will auto-update the UI.
  Future<void> cancelInvitation({required String invitationId}) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('cancelInvitation');
    await callable.call<Map<String, dynamic>>({
      'invitationId': invitationId,
    });
  }

  /// Live stream of pending invitations addressed to the current user.
  Stream<List<InvitationItem>> watchPendingInvitations() {
    final email =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('babyInvitations')
        .where('inviteeEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map(InvitationItem.fromDoc).toList());
  }

  /// Live stream of ALL invitations addressed to the current user (all
  /// statuses). Sorted newest-first client-side to avoid a composite index.
  Stream<List<InvitationItem>> watchAllReceivedInvitations() {
    final email =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('babyInvitations')
        .where('inviteeEmail', isEqualTo: email)
        .snapshots()
        .map((snap) {
          final items = snap.docs.map(InvitationItem.fromDoc).toList();
          items.sort(
            (a, b) => (b.createdAt ?? DateTime(0))
                .compareTo(a.createdAt ?? DateTime(0)),
          );
          return items;
        });
  }

  /// Live stream of invitations sent by the current user (all statuses).
  /// Sorted newest-first client-side to avoid a composite index.
  Stream<List<InvitationItem>> watchSentInvitations() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('babyInvitations')
        .where('ownerUid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final items = snap.docs.map(InvitationItem.fromDoc).toList();
          items.sort(
            (a, b) => (b.createdAt ?? DateTime(0))
                .compareTo(a.createdAt ?? DateTime(0)),
          );
          return items;
        });
  }
}
