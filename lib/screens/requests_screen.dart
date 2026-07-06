import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Friend Requests',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ),
      // ✅ Stream directly on friend_requests collection
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('toUid', isEqualTo: myUid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline,
                      size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('No pending requests',
                      style:
                      TextStyle(color: kDarkBrown, fontSize: 15)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final fromUid = data['fromUid'] as String;
              final ts = data['createdAt'] as Timestamp?;

              // ✅ StreamBuilder per tile — fetches sender email in real-time
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(fromUid)
                    .snapshots(),
                builder: (context, userSnap) {
                  final userData =
                  userSnap.data?.data() as Map<String, dynamic>?;
                  final email = userData?['email'] as String? ?? fromUid;
                  final initials = email.length >= 2
                      ? email.substring(0, 2).toUpperCase()
                      : '??';

                  return _RequestTile(
                    initials: initials,
                    email: email,
                    timeAgo: _timeAgo(ts),
                    onConfirm: () async {
                      await doc.reference.update({'status': 'accepted'});
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text('You are now friends with $email'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            margin: const EdgeInsets.fromLTRB(
                                16, 0, 16, 24),
                            backgroundColor: Colors.black87,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    onDelete: () async {
                      await doc.reference.update({'status': 'rejected'});
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Request Tile with slide+fade animation ────────────────────
class _RequestTile extends StatefulWidget {
  final String initials, email, timeAgo;
  final VoidCallback onConfirm, onDelete;

  const _RequestTile({
    required this.initials,
    required this.email,
    required this.timeAgo,
    required this.onConfirm,
    required this.onDelete,
  });

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: Offset.zero, end: const Offset(0.3, 0))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _animateThen(VoidCallback cb) async {
    await _ctrl.forward();
    cb();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: kWhite,
                child: Text(widget.initials,
                    style: const TextStyle(
                        color: kDarkBrown,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.email,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('Wants to be your friend',
                        style: TextStyle(
                            fontSize: 12, color: kWhite)),
                    Text(widget.timeAgo,
                        style: TextStyle(
                            fontSize: 11, color: kWhite)),
                  ],
                ),
              ),

              // Confirm + Delete buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    label: 'Confirm',
                    isPrimary: true,
                    onTap: () => _animateThen(widget.onConfirm),
                  ),
                  const SizedBox(width: 6),
                  _ActionButton(
                    label: 'Delete',
                    isPrimary: false,
                    onTap: () => _animateThen(widget.onDelete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary ? kTerracotta : kGold,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? kBrown : kBlack,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}