

import 'package:flutter/material.dart';
import 'package:travelbuddy2/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PlacesScreen extends StatelessWidget {
  final String category;

  const PlacesScreen({super.key, required this.category});

  /// 📍 Open Google Maps
  void openMap(String placeName) async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$placeName",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not open map";
    }
  }

  @override
  Widget build(BuildContext context) {

    /// 🔥 Static Data (can move to Firebase later)
    final places = {

      "Heritage": [
        {"name": "Taj Mahal", "image": "https://t4.ftcdn.net/jpg/16/53/89/87/360_F_1653898795_d3J9MaDPrmD89IlXk06JrVImc2jesuqF.jpg"},
        {"name": "Hampi", "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlnJ0Y9DE257lwyI1umRoU9MEHp5KiCtVdTQ&s"},
        {"name": "Red Fort", "image": "https://www.shutterstock.com/image-photo/red-fort-unesco-world-heritage-260nw-2292943221.jpg"},
        {"name": "Qutub Minar", "image": "https://s7ap1.scene7.com/is/image/incredibleindia/qutab-minar-delhi-attr-hero?qlt=82&ts=1742169673469"},
        {"name": "Ajanta Caves", "image": "https://travel-blog.happyeasygo.com/wp-content/uploads/2020/06/Ajanta-Caves-Monument.jpg"},
        {"name": "Ellora Caves", "image": "https://s7ap1.scene7.com/is/image/incredibleindia/ellora-caves-chhatrapati-sambhaji-nagar-maharashtra-attr-hero-5?qlt=82&ts=1727010646173"},
        {"name": "Mysore Palace", "image": "https://media.istockphoto.com/id/172124032/photo/mysore-palace-at-dusk.jpg?s=612x612&w=0&k=20&c=paO74C_dVsY14IbK0RNqs0TD-lSteQy-AW5CnQFEb_4="},
        {"name": "Konark Sun Temple", "image": "https://suryainn.in/wp-content/uploads/2023/09/konark-time-table.jpg"},
      ],

      "Beach": [
        {"name": "Goa Beach", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Maldives", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Bondi Beach", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Baga Beach", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Varkala Beach", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Kovalam Beach", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Juhu Beach", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Radhanagar Beach", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
      ],

      "Temple": [
        {"name": "Somnath Temple", "image": "https://images.unsplash.com/photo-1582550945154-66ea8fff25e1"},
        {"name": "Kashi Vishwanath", "image": "https://images.unsplash.com/photo-1582550945154-66ea8fff25e1"},
        {"name": "Tirupati Temple", "image": "https://images.unsplash.com/photo-1582550945154-66ea8fff25e1"},
        {"name": "Kedarnath Temple", "image": "https://images.unsplash.com/photo-1582550945154-66ea8fff25e1"},
        {"name": "Badrinath Temple", "image": "https://images.unsplash.com/photo-1582550945154-66ea8fff25e1"},
        {"name": "Meenakshi Temple", "image": "https://images.unsplash.com/photo-1582550945154-66ea8fff25e1"},
        {"name": "Jagannath Temple", "image": "https://images.unsplash.com/photo-1582550945154-66ea8fff25e1"},
        {"name": "Golden Temple", "image": "https://images.unsplash.com/photo-1582550945154-66ea8fff25e1"},
      ],

      "Mountain": [
        {"name": "Manali", "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"},
        {"name": "Kedarnath", "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"},
        {"name": "Leh Ladakh", "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"},
        {"name": "Spiti Valley", "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"},
        {"name": "Nainital", "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"},
        {"name": "Mussoorie", "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"},
        {"name": "Shimla", "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"},
        {"name": "Auli", "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"},
      ],

      "Hill Station": [
        {"name": "Ooty", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee"},
        {"name": "Darjeeling", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee"},
        {"name": "Munnar", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee"},
        {"name": "Kodaikanal", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee"},
        {"name": "Coorg", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee"},
        {"name": "Mount Abu", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee"},
        {"name": "Lonavala", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee"},
        {"name": "Mahabaleshwar", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee"},
      ],

      "Waterfall": [
        {"name": "Jog Falls", "image": "https://images.unsplash.com/photo-1502082553048-f009c37129b9"},
        {"name": "Athirappilly Falls", "image": "https://images.unsplash.com/photo-1502082553048-f009c37129b9"},
        {"name": "Dudhsagar Falls", "image": "https://images.unsplash.com/photo-1502082553048-f009c37129b9"},
        {"name": "Nohkalikai Falls", "image": "https://images.unsplash.com/photo-1502082553048-f009c37129b9"},
        {"name": "Bhagsu Falls", "image": "https://images.unsplash.com/photo-1502082553048-f009c37129b9"},
        {"name": "Hogenakkal Falls", "image": "https://images.unsplash.com/photo-1502082553048-f009c37129b9"},
        {"name": "Kempty Falls", "image": "https://images.unsplash.com/photo-1502082553048-f009c37129b9"},
        {"name": "Shivanasamudra Falls", "image": "https://images.unsplash.com/photo-1502082553048-f009c37129b9"},
      ],

      "Camping": [
        {"name": "Spiti Valley Camp", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Rann of Kutch Camp", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Kasol Camp", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Manali Camp", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Jaisalmer Desert Camp", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Rishikesh Camp", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Coorg Camp", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Ladakh Camp", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
      ],

      "Wildlife": [
        {"name": "Gir National Park", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Kaziranga", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Jim Corbett", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Ranthambore", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Bandipur", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Periyar", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Sundarbans", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
        {"name": "Kanha National Park", "image": "https://images.unsplash.com/photo-1500534623283-312aade485b7"},
      ],

      "Lake": [
        {"name": "Dal Lake", "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"},
        {"name": "Pangong Lake", "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"},
        {"name": "Naini Lake", "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"},
        {"name": "Loktak Lake", "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"},
        {"name": "Chilika Lake", "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"},
        {"name": "Wular Lake", "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"},
        {"name": "Vembanad Lake", "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"},
        {"name": "Pushkar Lake", "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"},
      ],

      "Island": [
        {"name": "Andaman", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Lakshadweep", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Bali", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Phuket", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Santorini", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Mauritius", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Seychelles", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Maldives", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
      ],

      "Snow": [
        {"name": "Gulmarg", "image": "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66"},
        {"name": "Auli", "image": "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66"},
        {"name": "Manali Snow", "image": "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66"},
        {"name": "Shimla Snow", "image": "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66"},
        {"name": "Sonmarg", "image": "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66"},
        {"name": "Pahalgam", "image": "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66"},
        {"name": "Leh Snow", "image": "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66"},
        {"name": "Spiti Snow", "image": "https://images.unsplash.com/photo-1482192596544-9eb780fc7f66"},
      ],

      "Trending": [
        {"name": "Dubai", "image": "https://images.unsplash.com/photo-1508057198894-247b23fe5ade"},
        {"name": "Singapore", "image": "https://images.unsplash.com/photo-1508057198894-247b23fe5ade"},
        {"name": "Paris", "image": "https://images.unsplash.com/photo-1502602898657-3e91760cbb34"},
        {"name": "New York", "image": "https://images.unsplash.com/photo-1490578474895-699cd4e2cf59"},
        {"name": "London", "image": "https://images.unsplash.com/photo-1473959383416-c8dfc8a9a2e0"},
        {"name": "Tokyo", "image": "https://images.unsplash.com/photo-1549693578-d683be217e58"},
        {"name": "Bali", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
        {"name": "Maldives", "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"},
      ],

    };

    final selectedPlaces = places[category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: kDarkBrown,
        foregroundColor: kWhite,
      ),

      body: ListView.builder(
        itemCount: selectedPlaces.length,
        itemBuilder: (context, index) {

          var place = selectedPlaces[index];

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🖼 IMAGE
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    place["image"]!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                /// 📍 PLACE INFO
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        place["name"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 📍 BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => openMap(place["name"]!),
                          icon: const Icon(Icons.map),
                          label: const Text("View on Map"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kDarkBrown,
                            foregroundColor: kWhite
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}