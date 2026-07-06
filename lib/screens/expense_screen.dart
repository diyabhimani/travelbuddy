import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelbuddy2/services/auth_service.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class ExpenseScreen extends StatefulWidget {
  final String tripId;

  const ExpenseScreen({super.key, required this.tripId});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {

  void addExpense(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    final currentUser = AuthService().getCurrentUser();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  hintText: "Description",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Amount",
                ),
              ),
            ],
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not logged in")),
                  );
                  return;
                }

                double amount =
                    double.tryParse(amountController.text.trim()) ?? 0;

                if (amount <= 0) return;

                // Get trip members
                var tripDoc = await FirebaseFirestore.instance
                    .collection('trips')
                    .doc(widget.tripId)
                    .get();

                if (!tripDoc.exists) return;

                List members = tripDoc['members'] ?? [];

                if (members.isEmpty) return;

                double splitAmount = amount / members.length;

                // Save expense
                await FirebaseFirestore.instance
                    .collection('expenses')
                    .add({
                  'tripId': widget.tripId,
                  'amount': amount,
                  'paidBy': currentUser.uid,
                  'description': descController.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });

                // Save splits
                for (var userId in members) {
                  await FirebaseFirestore.instance
                      .collection('splits')
                      .add({
                    'expenseId': widget.tripId,
                    'userId': userId,
                    'amount': splitAmount,
                  });
                }

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// 🔥 Get user name from Firestore
  Future<String> getUserName(String uid) async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      return doc['name'] ?? 'Unknown';
    }
    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('expenses')
              .where('tripId', isEqualTo: widget.tripId)
              .snapshots(),

          builder: (context, snapshot) {

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No expenses yet"));
            }

            var expenses = snapshot.data!.docs;

            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {

                var exp = expenses[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.money, color: kDarkBrown),

                    title: Text(exp['description'] ?? "No description"),

                    // ✅ FIXED: Show user name instead of UID
                    subtitle: FutureBuilder<String>(
                      future: getUserName(exp['paidBy']),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Text("Paid by: loading...");
                        }
                        return Text("Paid by: ${snap.data}");
                      },
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Text(
                          "₹${exp['amount']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: kBlack),
                          onPressed: () async {

                            await FirebaseFirestore.instance
                                .collection('expenses')
                                .doc(exp.id)
                                .delete();

                            var splits = await FirebaseFirestore.instance
                                .collection('splits')
                                .where('expenseId', isEqualTo: exp.id)
                                .get();

                            for (var doc in splits.docs) {
                              await doc.reference.delete();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kDarkBrown,
        foregroundColor: kWhite,
        child: const Icon(Icons.add),
        onPressed: () => addExpense(context),
      ),
    );
  }
}