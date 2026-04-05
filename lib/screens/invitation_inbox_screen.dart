import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/veri_yonetici.dart';
import '../services/shared_parenting_service.dart';

class InvitationInboxScreen extends StatefulWidget {
  const InvitationInboxScreen({super.key});

  @override
  State<InvitationInboxScreen> createState() => _InvitationInboxScreenState();
}

class _InvitationInboxScreenState extends State<InvitationInboxScreen> {
  // Track per-invitation loading state so buttons disable individually.
  final Set<String> _loadingIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _enforceAuth());
  }

  void _enforceAuth() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _accept(InvitationItem item) async {
    setState(() => _loadingIds.add(item.id));
    try {
      await SharedParentingService.instance
          .acceptInvitation(invitationId: item.id);
      await VeriYonetici.refreshForCurrentUser();
      if (!mounted) return;
      _showSuccess('Invitation accepted.');
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      _showError(_friendlyError(e.code));
    } catch (_) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingIds.remove(item.id));
    }
  }

  Future<void> _decline(InvitationItem item) async {
    setState(() => _loadingIds.add(item.id));
    try {
      await SharedParentingService.instance
          .declineInvitation(invitationId: item.id);
      if (!mounted) return;
      _showSuccess('Invitation declined.');
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      _showError(_friendlyError(e.code));
    } catch (_) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingIds.remove(item.id));
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF3A7D44),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB85C4A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'not-found':
        return 'Invitation not found.';
      case 'deadline-exceeded':
        return 'This invitation has expired.';
      case 'permission-denied':
        return 'This invitation is not addressed to you.';
      case 'failed-precondition':
        return 'This invitation is no longer pending.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3E39)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Received Invitations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<InvitationItem>>(
          stream:
              SharedParentingService.instance.watchAllReceivedInvitations(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB4A2),
                ),
              );
            }

            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Could not load invitations. Please try again.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8A7C75),
                    ),
                  ),
                ),
              );
            }

            final invitations = snap.data ?? [];

            if (invitations.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        size: 48,
                        color: Color(0xFFBDB5B0),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No invitations received',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8A7C75),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: invitations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = invitations[i];
                return _InvitationCard(
                  item: item,
                  isLoading: _loadingIds.contains(item.id),
                  onAccept: () => _accept(item),
                  onDecline: () => _decline(item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.item,
    required this.isLoading,
    required this.onAccept,
    required this.onDecline,
  });

  final InvitationItem item;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final babyName = item.babyName ?? 'Baby';
    final from = item.ownerDisplayName;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB4A2).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEFF7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.child_care_rounded,
                  color: Color(0xFF6AADCF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      babyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A3E39),
                      ),
                    ),
                    if (from != null && from.isNotEmpty)
                      Text(
                        'from $from',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A7C75),
                        ),
                      ),
                    if (item.createdAt != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(item.createdAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBDB5B0),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (item.status != 'pending')
            Text(
              item.status == 'accepted' ? 'Accepted' : 'Declined',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: item.status == 'accepted'
                    ? const Color(0xFF3A7D44)
                    : const Color(0xFFB85C4A),
              ),
            )
          else if (isLoading)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFFB4A2),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onDecline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Decline',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A7C75),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3E39),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
