import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/veri_yonetici.dart';
import 'invitation_inbox_screen.dart';
import 'login_entry_screen.dart';
import 'premium_screen.dart';
import 'sent_invitations_screen.dart';
import '../services/premium_service.dart';
import '../services/shared_parenting_service.dart';

class SharedParentingScreen extends StatefulWidget {
  const SharedParentingScreen({super.key});

  @override
  State<SharedParentingScreen> createState() => _SharedParentingScreenState();
}

class _SharedParentingScreenState extends State<SharedParentingScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enforceAccess();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enforceAccess() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginEntryScreen()),
      );
      return;
    }
    if (!PremiumService.instance.isPremium) {
      await _SharedParentingGateSheet.show(context);
      // Pop the screen after the sheet is dismissed — user is still free.
      if (mounted && !PremiumService.instance.isPremium) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _sendInvite() async {
    // Last-line premium guard — should not normally be reached because the
    // gate sheet prevents non-premium users from seeing this form.
    if (!PremiumService.instance.isPremium) {
      await _SharedParentingGateSheet.show(context);
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter an email address.');
      return;
    }

    final baby = VeriYonetici.getActiveBabyOrNull();
    if (baby == null) {
      setState(() => _errorMessage = 'No active baby selected.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await SharedParentingService.instance.sendInvitation(
        babyId: baby.id,
        inviteeEmail: email,
      );
      if (!mounted) return;
      _emailController.clear();
      setState(() {
        _successMessage = result.existingInvitation
            ? 'Invitation already pending for $email.'
            : 'Invitation sent to $email.';
        _loading = false;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyError(e.code);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You need a premium subscription to invite co-parents.';
      case 'not-found':
        return 'Baby not found. Please try again.';
      case 'invalid-argument':
        return 'Please enter a valid email address.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final baby = VeriYonetici.getActiveBabyOrNull();

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
          'Shared Parenting',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active baby context
              if (baby != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E0F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.child_care_rounded,
                        color: Color(0xFF9C88CC),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        baby.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A3E39),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Description
              const Text(
                'Invite another parent to follow the same baby journey together.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8A7C75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Members section
              if (baby != null) _MembersSection(babyId: baby.id),

              const SizedBox(height: 20),

              // Invitation center links
              Row(
                children: [
                  Expanded(
                    child: _NavButton(
                      label: 'Received',
                      icon: Icons.inbox_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InvitationInboxScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NavButton(
                      label: 'Sent',
                      icon: Icons.send_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SentInvitationsScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Invite form
              const Text(
                'Email address',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3E39),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _sendInvite(),
                decoration: InputDecoration(
                  hintText: 'partner@example.com',
                  hintStyle: const TextStyle(color: Color(0xFFBDB5B0)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8E0D8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8E0D8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFB4A2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Error / success feedback
              if (_errorMessage != null)
                _FeedbackBanner(
                  message: _errorMessage!,
                  isError: true,
                ),
              if (_successMessage != null)
                _FeedbackBanner(
                  message: _successMessage!,
                  isError: false,
                ),

              const SizedBox(height: 8),

              // Invite button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _loading ? null : _sendInvite,
                  child: AnimatedOpacity(
                    opacity: _loading ? 0.6 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3E39),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Invite Parent',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MembersSection extends StatelessWidget {
  const _MembersSection({required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('babies').doc(babyId).get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final members = <String, dynamic>{};
        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data() as Map<String, dynamic>?;
          final raw = data?['members'];
          if (raw is Map) {
            members.addAll(Map<String, dynamic>.from(raw));
          }
        }

        if (members.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Co-parents',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3E39),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E0D8)),
              ),
              child: Column(
                children: members.entries.map((entry) {
                  final info = entry.value as Map<String, dynamic>?;
                  final role = (info?['role'] as String?) ?? 'member';
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCEFF7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF6AADCF),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A3E39),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          role,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A7C75),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFFEDEB)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: isError ? const Color(0xFFB85C4A) : const Color(0xFF3A7D44),
          height: 1.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E0F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9C88CC)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3E39),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SharedParentingGateSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SharedParentingGateSheetContent(),
    );
  }
}

class _SharedParentingGateSheetContent extends StatelessWidget {
  const _SharedParentingGateSheetContent();

  static const _bullets = [
    'Invite another parent',
    'Stay in sync on the same baby',
    'Keep updates shared in one place',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        28,
        28,
        28,
        28 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0D8D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            "Share your baby's journey together",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A3E39),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),

          // Bullets
          for (final bullet in _bullets) ...[
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Color(0xFFFFB4A2),
                ),
                const SizedBox(width: 10),
                Text(
                  bullet,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4A3E39),
                    height: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 24),

          // CTA
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                PremiumScreen.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3E39),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Unlock with Premium',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Maybe later',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A7C75),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
