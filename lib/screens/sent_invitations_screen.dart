import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/shared_parenting_service.dart';

class SentInvitationsScreen extends StatefulWidget {
  const SentInvitationsScreen({super.key});

  @override
  State<SentInvitationsScreen> createState() => _SentInvitationsScreenState();
}

class _SentInvitationsScreenState extends State<SentInvitationsScreen> {
  // Tracks which invitation IDs are currently being cancelled.
  final Set<String> _cancelling = {};

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

  Future<void> _cancelInvitation(InvitationItem item) async {
    if (_cancelling.contains(item.id)) return;
    setState(() => _cancelling.add(item.id));
    try {
      await SharedParentingService.instance.cancelInvitation(
        invitationId: item.id,
      );
      // Stream auto-removes the row — no manual setState needed.
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.sentInvCancelError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling.remove(item.id));
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return l10n.sentInvStatusPending;
      case 'accepted':
        return l10n.sentInvStatusAccepted;
      case 'declined':
        return l10n.sentInvStatusDeclined;
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF3A7D44);
      case 'declined':
        return const Color(0xFFB85C4A);
      default:
        return const Color(0xFF8A7C75);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3E39)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.sentInvTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<InvitationItem>>(
          stream: SharedParentingService.instance.watchSentInvitations(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB4A2)),
              );
            }

            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.sentInvLoadError,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF8A7C75)),
                  ),
                ),
              );
            }

            final items = snap.data ?? [];

            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.send_rounded,
                        size: 48,
                        color: Color(0xFFBDB5B0),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.sentInvNone,
                        style: const TextStyle(
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
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = items[i];
                final babyName = item.babyName ?? l10n.babyFallbackName;
                final label = _statusLabel(item.status, l10n);
                final color = _statusColor(item.status);
                final dateStr = item.createdAt != null
                    ? MaterialLocalizations.of(
                        context,
                      ).formatShortDate(item.createdAt!)
                    : null;
                final expiryStr = item.expiresAt != null
                    ? l10n.sentInvExpires(
                        MaterialLocalizations.of(
                          context,
                        ).formatShortDate(item.expiresAt!),
                      )
                    : null;
                final destinationLabel = item.inviteType == 'code'
                    ? (item.inviteCode ?? '')
                    : (item.inviteeEmail ?? '');

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8E0D8)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCEFF7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.child_care_rounded,
                          color: Color(0xFF6AADCF),
                          size: 20,
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A3E39),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              destinationLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8A7C75),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (dateStr != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.status == 'pending' && expiryStr != null
                                    ? expiryStr
                                    : dateStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFBDB5B0),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.status == 'pending')
                        _cancelling.contains(item.id)
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF8A7C75),
                                ),
                              )
                            : GestureDetector(
                                onTap: () => _cancelInvitation(item),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: Color(0xFFB85C4A),
                                ),
                              )
                      else
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
