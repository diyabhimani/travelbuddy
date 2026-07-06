import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelbuddy2/screens/trip_details_screen.dart';
import 'package:travelbuddy2/services/auth_service.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Trips"),
        backgroundColor: kDarkBrown,
        foregroundColor: kWhite,
      ),

      body: currentUser == null
          ? const Center(child: Text("User not logged in ❌"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .where('members', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No trips yet. Create one!"),
            );
          }

          var trips = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              var trip = trips[index];

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kDarkBrown, kBrown],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

                  title: Text(
                    trip['name'],
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    "Members: ${trip['members'].length}",
                    style: const TextStyle(color: kWhite),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: kWhite,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailsScreen(
                          tripId: trip.id,
                          tripName: trip['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // ➕ ADD TRIP BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: kDarkBrown,
        foregroundColor: kWhite,
        child: const Icon(Icons.add),
        onPressed: () {
          final TextEditingController tripNameController =
          TextEditingController();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Create Trip"),
                content: TextField(
                  controller: tripNameController,
                  decoration: const InputDecoration(
                    hintText: "Trip Name (e.g. Goa Trip)",
                  ),
                ),
                actions: [

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      try {
                        if (tripNameController.text.trim().isEmpty) return;

                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("User not logged in ❌"),
                            ),
                          );
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection('trips')
                            .add({
                          'name': tripNameController.text.trim(),
                          'createdBy': currentUser.uid,
                          'members': [currentUser.uid],
                          'createdAt': DateTime.now(),
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Trip Created Successfully ✅"),
                          ),
                        );

                        Navigator.pop(context);

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e ❌"),
                          ),
                        );
                        print("Error: $e");
                      }
                    },
                    child: const Text("Create"),
                  ),

                ],
              );
            },
          );
        },
      ),
    );
  }
}