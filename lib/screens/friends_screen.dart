import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ FIXED: Simple stream — no asyncMap, no nested awaits
  Stream<QuerySnapshot> get _requestsStream =>
      FirebaseFirestore.instance
          .collection('friend_requests')
          .where('toUid', isEqualTo: myUid)
          .where('status', isEqualTo: 'pending')
          .snapshots();

  Future<void> _confirm(DocumentReference ref, String name) async {
    await ref.update({'status': 'accepted'});
    if (mounted) _showToast("You are now friends with $name");
  }

  Future<void> _delete(DocumentReference ref) async {
    await ref.update({'status': 'rejected'});
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snap) {
            final count = snap.data?.docs.length ?? 0;
            return Row(
              children: [
                const Text(
                  'Activity',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                          color: kTerracotta,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorWeight: 1.5,
          labelStyle:
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Follow requests'),
            Tab(text: 'Suggestions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ Tab 1: Requests
          _RequestsTab(
            stream: _requestsStream,
            onConfirm: _confirm,
            onDelete: _delete,
            timeAgo: _timeAgo,
          ),
          // ✅ Tab 2: Suggestions
          _SuggestionsTab(myUid: myUid),
        ],
      ),
    );
  }
}

// ─── Requests Tab ─────────────────────────────────────────────
class _RequestsTab extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final Future<void> Function(DocumentReference, String) onConfirm;
  final Future<void> Function(DocumentReference) onDelete;
  final String Function(Timestamp?) timeAgo;

  const _RequestsTab({
    required this.stream,
    required this.onConfirm,
    required this.onDelete,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline,
                    size: 72, color: kGrey),
                const SizedBox(height: 12),
                const Text('No follow requests',
                    style: TextStyle(color: kDarkBrown, fontSize: 15)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final fromUid = data['fromUid'] as String;
            final ts = data['createdAt'] as Timestamp?;

            // ✅ Fetch sender email with StreamBuilder — real-time
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(fromUid)
                  .snapshots(),
              builder: (context, userSnap) {
                final userData =
                userSnap.data?.data() as Map<String, dynamic>?;
                final email = userData?['email'] ?? fromUid;
                final initials = email.length >= 2
                    ? email.substring(0, 2).toUpperCase()
                    : '??';

                return _RequestTile(
                  initials: initials,
                  email: email,
                  timeAgo: timeAgo(ts),
                  onConfirm: () => onConfirm(doc.reference, email),
                  onDelete: () => onDelete(doc.reference),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─── Request Tile with animation ──────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: kGold,
                child: Text(widget.initials,
                    style: const TextStyle(
                        color: kDarkBrown,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
              const SizedBox(width: 12),
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
                    Text('Wants to follow you',
                        style: TextStyle(
                            fontSize: 12, color: kDarkBrown)),
                    Text(widget.timeAgo,
                        style: TextStyle(
                            fontSize: 11, color: kDarkBrown)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InstaButton(
                    label: 'Confirm',
                    isPrimary: true,
                    onTap: () => _animateThen(widget.onConfirm),
                  ),
                  const SizedBox(width: 6),
                  _InstaButton(
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

// ─── Suggestions Tab ──────────────────────────────────────────
class _SuggestionsTab extends StatefulWidget {
  final String myUid;
  const _SuggestionsTab({required this.myUid});

  @override
  State<_SuggestionsTab> createState() => _SuggestionsTabState();
}

class _SuggestionsTabState extends State<_SuggestionsTab> {
  // ✅ FIXED: connectedUids loaded as Future — no asyncMap in stream
  Future<Set<String>> _loadConnectedUids() async {
    final db = FirebaseFirestore.instance;
    final results = await Future.wait([
      db.collection('friend_requests')
          .where('fromUid', isEqualTo: widget.myUid)
          .get(),
      db.collection('friend_requests')
          .where('toUid', isEqualTo: widget.myUid)
          .get(),
    ]);

    final Set<String> connected = {widget.myUid};
    for (var doc in results[0].docs) {
      connected.add(doc['toUid'] as String);
    }
    for (var doc in results[1].docs) {
      connected.add(doc['fromUid'] as String);
    }
    return connected;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<String>>(
      // ✅ Step 1: get connected UIDs once
      future: _loadConnectedUids(),
      builder: (context, connSnap) {
        if (!connSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final connectedUids = connSnap.data!;

        // ✅ Step 2: stream users — filter locally, no Firestore query inside stream
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .snapshots(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter out self + already connected users
            final suggestions = userSnap.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = data['uid'] ?? doc.id;
              return !connectedUids.contains(uid);
            }).toList();

            if (suggestions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search,
                        size: 72, color: kGrey),
                    const SizedBox(height: 12),
                    const Text('No suggestions right now',
                        style:
                        TextStyle(color: kDarkBrown, fontSize: 15)),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, i) {
                final doc = suggestions[i];
                final data = doc.data() as Map<String, dynamic>;
                final uid = data['uid'] ?? doc.id;
                final email = data['email'] as String? ?? '';
                final initials = email.length >= 2
                    ? email.substring(0, 2).toUpperCase()
                    : '??';

                return _SuggestionTile(
                  uid: uid,
                  email: email,
                  initials: initials,
                  myUid: widget.myUid,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─── Suggestion Tile ──────────────────────────────────────────
class _SuggestionTile extends StatefulWidget {
  final String uid, email, initials, myUid;

  const _SuggestionTile({
    required this.uid,
    required this.email,
    required this.initials,
    required this.myUid,
  });

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _following = false;
  bool _loading = false;

  Future<void> _toggle() async {
    setState(() => _loading = true);
    try {
      if (_following) {
        // Unfollow — delete pending request
        final snap = await FirebaseFirestore.instance
            .collection('friend_requests')
            .where('fromUid', isEqualTo: widget.myUid)
            .where('toUid', isEqualTo: widget.uid)
            .where('status', isEqualTo: 'pending')
            .get();
        for (var doc in snap.docs) {
          await doc.reference.delete();
        }
        if (mounted) setState(() => _following = false);
      } else {
        // Follow — send request
        await FirebaseFirestore.instance
            .collection('friend_requests')
            .add({
          'fromUid': widget.myUid,
          'toUid': widget.uid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) setState(() => _following = true);
      }
    } catch (e) {
      debugPrint('Follow toggle error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: kGold,
            child: Text(widget.initials,
                style: const TextStyle(
                    color: kTerracotta,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.email,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('Suggested for you',
                    style: TextStyle(
                        fontSize: 12, color: kDarkBrown)),
              ],
            ),
          ),
          // ✅ Loading spinner while toggling
          _loading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : _following
              ? OutlinedButton(
            onPressed: _toggle,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              side: const BorderSide(color: kGrey),
            ),
            child: const Text('Following',
                style: TextStyle(
                    color: kBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          )
              : ElevatedButton(
            onPressed: _toggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 6),
            ),
            child: const Text('Follow',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Button ────────────────────────────────────────────
class _InstaButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _InstaButton({
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
            color: isPrimary ? kGold : kTerracotta,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}