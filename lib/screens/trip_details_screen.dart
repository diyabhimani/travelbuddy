import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'expense_screen.dart';
import 'group_chat_screen.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;
  final String tripName;

  const TripDetailsScreen({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  int selectedIndex = 0;

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _membersScreen(),
      GroupChatScreen(
        tripId: widget.tripId,
        tripName: widget.tripName,
      ),
      ExpenseScreen(tripId: widget.tripId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tripName),
        backgroundColor: kDarkBrown,
        foregroundColor: kWhite,
      ),

      body: screens[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: kDarkBrown,
        onTap: (i) => setState(() => selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Members"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "Expenses"),
        ],
      ),

      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
        backgroundColor: kDarkBrown,
        foregroundColor: kWhite,
        child: const Icon(Icons.person_add),
        onPressed: () => _showAddMemberDialog(),
      )
          : null,
    );
  }

  // 👥 MEMBERS SCREEN
  Widget _membersScreen() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        List members = data['members'] ?? [];

        if (members.isEmpty) {
          return const Center(child: Text("No members"));
        }

        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];

            String uid = "";
            String name = "";

            // ✅ SUPPORT BOTH OLD + NEW FORMAT
            if (member is String) {
              uid = member;
              name = member;
            } else if (member is Map<String, dynamic>) {
              uid = member['uid'] ?? "";
              name = member['name'] ?? "";
            }

            if (uid.isEmpty) {
              return const SizedBox();
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (context, userSnap) {
                if (userSnap.hasData && userSnap.data!.exists) {
                  var user = userSnap.data!.data() as Map<String, dynamic>;
                  name = user['name'] ?? user['email'] ?? name;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kDarkBrown,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: const TextStyle(color: kWhite),
                    ),
                  ),
                  title: Text(name),

                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: kBlack),
                    onPressed: () => _removeMember(member),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ❌ REMOVE MEMBER
  void _removeMember(dynamic member) async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .update({
      'members': FieldValue.arrayRemove([member])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Member removed")),
    );
  }

  // ➕ ADD MEMBER (BY EMAIL OR UID)
  void _showAddMemberDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Member"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter email OR UID",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                String input = controller.text.trim();

                if (input.isEmpty) return;

                QuerySnapshot userSnap = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: input)
                    .get();

                DocumentSnapshot? userDoc;

                if (userSnap.docs.isNotEmpty) {
                  userDoc = userSnap.docs.first;
                } else {
                  userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(input)
                      .get();
                }

                if (!userDoc.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not found")),
                  );
                  return;
                }

                var user = userDoc.data() as Map<String, dynamic>;

                await FirebaseFirestore.instance
                    .collection('trips')
                    .doc(widget.tripId)
                    .update({
                  'members': FieldValue.arrayUnion([
                    {
                      "uid": user['uid'],
                      "name": user['name'] ?? user['email']
                    }
                  ])
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Member added")),
                );
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}