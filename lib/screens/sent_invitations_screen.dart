import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/shared_parenting_service.dart';

class SentInvitationsScreen extends StatefulWidget {
  const SentInvitationsScreen({super.key});

  @override
  State<SentInvitationsScreen> createState() => _SentInvitationsScreenState();
}

class _SentInvitationsScreenState extends State<SentInvitationsScreen> {
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

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
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
          'Sent Invitations',
          style: TextStyle(
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
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB4A2),
                ),
              );
            }

            if (snap.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Could not load sent invitations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8A7C75),
                    ),
                  ),
                ),
              );
            }

            final items = snap.data ?? [];

            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 48,
                        color: Color(0xFFBDB5B0),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No invitations sent yet',
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
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = items[i];
                final babyName = item.babyName ?? 'Baby';
                final label = _statusLabel(item.status);
                final color = _statusColor(item.status);
                final dateStr = item.createdAt != null
                    ? DateFormat('MMM d, yyyy').format(item.createdAt!)
                    : null;
                final expiryStr = item.expiresAt != null
                    ? 'Expires ${DateFormat('MMM d').format(item.expiresAt!)}'
                    : null;

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
                              item.inviteeEmail,
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
