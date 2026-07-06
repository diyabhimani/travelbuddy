

import 'package:flutter/material.dart';
import 'package:travelbuddy2/screens/places_screen.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final categories = [
      {
        "title": "Heritage",
        "icon": Icons.account_balance,
      },
      {
        "title": "Beach",
        "icon": Icons.beach_access,
      },
      {
        "title": "Temple",
        "icon": Icons.temple_hindu,
      },
      {
        "title": "Mountain",
        "icon": Icons.terrain,
      },
      {
        "title": "Hill Station",
        "icon": Icons.landscape,
      },
      {
        "title": "Waterfall",
        "icon": Icons.water,
      },
      {
        "title": "Desert",
        "icon": Icons.wb_sunny,
      },
      {
        "title": "Forest",
        "icon": Icons.park,
      },
      {
        "title": "City",
        "icon": Icons.location_city,
      },
      {
        "title": "Adventure",
        "icon": Icons.hiking,
      },
      {
        "title": "Camping",
        "icon": Icons.local_fire_department,
      },
      {
        "title": "Wildlife",
        "icon": Icons.pets,
      },
      {
        "title": "Lake",
        "icon": Icons.water_outlined,
      },
      {
        "title": "Island",
        "icon": Icons.public,
      },
      {
        "title": "Snow",
        "icon": Icons.ac_unit,
      },
      {
        "title": "Trending",
        "icon": Icons.trending_up,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Places 🌍"),
        backgroundColor: kDarkBrown,
        foregroundColor: kWhite,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {

            var cat = categories[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlacesScreen(
                      category: cat["title"].toString(),
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ kDarkBrown, kBrown],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(
                      cat["icon"] as IconData,
                      size: 50,
                      color: kGrey,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      cat["title"].toString(),
                      style: const TextStyle(
                        color: kGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}