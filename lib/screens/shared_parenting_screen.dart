import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
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
  final _joinCodeController = TextEditingController();
  bool _creatingCode = false;
  bool _joiningCode = false;
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
    _joinCodeController.dispose();
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
      final wantsUpgrade = await _SharedParentingGateSheet.show(context);
      // If the user tapped "Unlock with Premium", run the paywall here (awaited)
      // so SharedParentingScreen stays on the route stack during the purchase.
      if (mounted && wantsUpgrade == true) {
        await PremiumScreen.show(context);
      }
      // Pop the screen only after the full premium flow has resolved.
      if (mounted && !PremiumService.instance.isPremium) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _createInviteCode() async {
    if (!PremiumService.instance.isPremium) {
      await _SharedParentingGateSheet.show(context);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final baby = VeriYonetici.getActiveBabyOrNull();
    if (baby == null) {
      setState(() => _errorMessage = l10n.spNoActiveBaby);
      return;
    }

    setState(() {
      _creatingCode = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await SharedParentingService.instance.createInviteCode(
        babyId: baby.id,
      );
      if (!mounted) return;
      final l10nAfter = AppLocalizations.of(context)!;
      setState(() {
        _successMessage = result.existingInvitation
            ? l10nAfter.spInviteCodeReady(result.inviteCode)
            : l10nAfter.spInviteCodeCreated(result.inviteCode);
        _creatingCode = false;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      final l10nErr = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = _friendlyCreateError(e.code, l10nErr);
        _creatingCode = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.genericErrorRetry;
        _creatingCode = false;
      });
    }
  }

  Future<void> _joinWithCode() async {
    final l10n = AppLocalizations.of(context)!;
    final inviteCode = _joinCodeController.text.trim().toUpperCase();
    if (inviteCode.isEmpty) {
      setState(() => _errorMessage = l10n.spEnterInviteCode);
      return;
    }

    setState(() {
      _joiningCode = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final babyId = await SharedParentingService.instance.acceptInvitationCode(
        inviteCode: inviteCode,
      );
      await VeriYonetici.refreshForCurrentUser();
      await VeriYonetici.setActiveBaby(babyId);
      if (!mounted) return;
      _joinCodeController.clear();
      setState(() {
        _successMessage = l10n.spInviteCodeAccepted;
        _joiningCode = false;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyJoinError(e.code, l10n);
        _joiningCode = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = l10n.genericErrorRetry;
        _joiningCode = false;
      });
    }
  }

  Future<void> _copyInviteCode(String inviteCode) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.spInviteCodeCopied)),
    );
  }

  Future<void> _shareInviteCode(String inviteCode, String babyName) async {
    final l10n = AppLocalizations.of(context)!;
    await SharePlus.instance.share(
      ShareParams(text: l10n.spInviteCodeShareMessage(babyName, inviteCode)),
    );
  }

  String _friendlyCreateError(String code, AppLocalizations l10n) {
    switch (code) {
      case 'permission-denied':
        return l10n.spPremiumRequired;
      case 'not-found':
        return l10n.spBabyNotFound;
      case 'invalid-argument':
        return l10n.spNoActiveBaby;
      default:
        return l10n.genericErrorRetry;
    }
  }

  String _friendlyJoinError(String code, AppLocalizations l10n) {
    switch (code) {
      case 'not-found':
        return l10n.spInviteCodeNotFound;
      case 'deadline-exceeded':
        return l10n.spInviteCodeExpired;
      case 'failed-precondition':
        return l10n.spInviteCodeUnavailable;
      default:
        return l10n.genericErrorRetry;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(
          l10n.spTitle,
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
              Text(
                l10n.spInviteDesc,
                style: const TextStyle(
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
                      label: l10n.spSentLabel,
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

              Text(
                l10n.spJoinWithCodeTitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3E39),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _joinCodeController,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _joinWithCode(),
                decoration: InputDecoration(
                  hintText: l10n.spInviteCodeHint,
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _joiningCode ? null : _joinWithCode,
                  child: AnimatedOpacity(
                    opacity: _joiningCode ? 0.6 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3E39),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _joiningCode
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.spJoinWithCodeBtn,
                                style: const TextStyle(
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

              const SizedBox(height: 28),

              Text(
                l10n.spInviteCodeTitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3E39),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.spInviteCodeDesc,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A7C75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              if (baby != null)
                StreamBuilder<List<InvitationItem>>(
                  stream: SharedParentingService.instance.watchSentInvitations(),
                  builder: (context, snap) {
                    InvitationItem? currentCode;
                    for (final item in snap.data ?? const <InvitationItem>[]) {
                      if (item.babyId == baby.id &&
                          item.status == 'pending' &&
                          item.inviteType == 'code' &&
                          (item.inviteCode ?? '').isNotEmpty) {
                        currentCode = item;
                        break;
                      }
                    }

                    if (currentCode == null) {
                      return const SizedBox.shrink();
                    }
                    final inviteCode = currentCode.inviteCode!;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8E0D8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inviteCode,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: Color(0xFF4A3E39),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentCode.expiresAt != null
                                ? l10n.spInviteCodeExpires(
                                    MaterialLocalizations.of(context)
                                        .formatShortDate(currentCode.expiresAt!),
                                  )
                                : l10n.spInviteCodeActive,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A7C75),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _copyInviteCode(inviteCode),
                                  child: Text(l10n.spCopyCode),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () =>
                                      _shareInviteCode(inviteCode, baby.name),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A3E39),
                                  ),
                                  child: Text(l10n.spShareCode),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

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
                  onTap: _creatingCode ? null : _createInviteCode,
                  child: AnimatedOpacity(
                    opacity: _creatingCode ? 0.6 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3E39),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _creatingCode
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.spCreateInviteCodeBtn,
                                style: const TextStyle(
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

class _MembersSection extends StatefulWidget {
  const _MembersSection({required this.babyId});

  final String babyId;

  @override
  State<_MembersSection> createState() => _MembersSectionState();
}

class _MembersSectionState extends State<_MembersSection> {
  // Tracks which memberUid is currently being removed (shows inline spinner).
  String? _removingUid;

  // Cache of uid → human-readable label fetched from users/{uid}.
  // Populated lazily for members whose entry predates the displayName/email stamp.
  final Map<String, String> _profileLabelCache = {};

  /// Returns the best available label for a member in priority order:
  ///   1. displayName from the members map (stored on accept since latest backend)
  ///   2. email from the members map
  ///   3. cached Firestore profile lookup (for pre-existing members)
  ///   4. "Co-parent" fallback
  String _labelFor(String uid, Map<String, dynamic>? info, AppLocalizations l10n) {
    final displayName = (info?['displayName'] as String?)?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;
    final email = (info?['email'] as String?)?.trim() ?? '';
    if (email.isNotEmpty) return email;
    return _profileLabelCache[uid] ?? l10n.spCoparent;
  }

  /// Fetches users/{uid} from Firestore for any UID not already in the cache
  /// and updates state so the UI re-renders with the resolved label.
  Future<void> _fetchMissingLabels(
    Set<String> uids, {
    required String fallback,
  }) async {
    final missing = uids.where((u) => !_profileLabelCache.containsKey(u)).toList();
    if (missing.isEmpty) return;
    for (final uid in missing) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final data = snap.data();
        final name = (data?['displayName'] as String?)?.trim() ?? '';
        final email = (data?['email'] as String?)?.trim() ?? '';
        final label = name.isNotEmpty
            ? name
            : email.isNotEmpty
                ? email
                : fallback;
        if (mounted) {
          setState(() => _profileLabelCache[uid] = label);
        }
      } catch (_) {
        // Best-effort — fallback label is already shown.
      }
    }
  }

  Future<void> _confirmAndRemove(
    String memberUid,
    String displayLabel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.spRemoveDialog,
          style: const TextStyle(
            color: Color(0xFF4A3E39),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n.spRemoveContent(displayLabel),
          style: const TextStyle(color: Color(0xFF8A7C75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.remove,
              style: const TextStyle(color: Color(0xFFB85C4A)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _removingUid = memberUid);
    try {
      await SharedParentingService.instance.removeMember(
        babyId: widget.babyId,
        memberUid: memberUid,
      );
      // Stream auto-updates the member list — no manual setState required.
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? l10n.spCouldNotRemove),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.spCouldNotRemove)),
      );
    } finally {
      if (mounted) setState(() => _removingUid = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // StreamBuilder keeps the list live — removing a member auto-refreshes.
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('babies')
          .doc(widget.babyId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting &&
            !snap.hasData) {
          return const SizedBox.shrink();
        }

        final members = <String, dynamic>{};
        if (snap.hasData && snap.data!.exists) {
          final raw = snap.data!.data()?['members'];
          if (raw is Map) {
            members.addAll(Map<String, dynamic>.from(raw));
          }
        }

        // Exclude the owner's own entry if present in the map.
        members.remove(currentUid);
        if (members.isEmpty) return const SizedBox.shrink();

        // Lazily resolve human-readable labels for members whose entry
        // predates the displayName/email stamp (joined before latest deploy).
        final uidsNeedingFetch = members.keys
            .where((uid) {
              final info = members[uid] as Map<String, dynamic>?;
              final hasName =
                  (info?['displayName'] as String?)?.trim().isNotEmpty == true;
              final hasEmail =
                  (info?['email'] as String?)?.trim().isNotEmpty == true;
              return !hasName && !hasEmail;
            })
            .toSet();
        if (uidsNeedingFetch.isNotEmpty) {
          _fetchMissingLabels(uidsNeedingFetch, fallback: l10n.spCoparent);
        }

        final isOwner = snap.data?.data()?['ownerId'] == currentUid;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.spCoparents,
              style: const TextStyle(
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
                  final memberUid = entry.key;
                  final info = entry.value as Map<String, dynamic>?;
                  final role = (info?['role'] as String?) ?? 'member';
                  final isRemoving = _removingUid == memberUid;

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
                            _labelFor(memberUid, info, l10n),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A3E39),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 8),
                          if (isRemoving)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF8A7C75),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _removingUid != null
                                  ? null
                                  : () => _confirmAndRemove(
                                        memberUid,
                                        _labelFor(memberUid, info, l10n),
                                      ),
                              child: const Icon(
                                Icons.person_remove_rounded,
                                size: 20,
                                color: Color(0xFFB85C4A),
                              ),
                            ),
                        ] else ...[
                          const SizedBox(width: 8),
                          Text(
                            role,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A7C75),
                            ),
                          ),
                        ],
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
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
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
              onTap: () => Navigator.pop(context, true),
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
