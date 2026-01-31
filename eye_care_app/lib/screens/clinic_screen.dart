import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClinicScreen extends StatelessWidget {
  const ClinicScreen({super.key});

  Future<void> _openMaps(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinics = [
      {
        'name': 'VisionCare Center',
        'address': 'Jl. Contoh No. 1, Kediri',
        'distance': '0.5 km',
        'rating': 4.8,
        'reviews': 124,
        'hours': 'Open until 18:00',
        'isOpen': true,
        // 🔁 GANTI LINK MAPS DI SINI
        'mapsUrl': 'https://share.google/3BNcIgqutX1I0IRlF',
      },
      {
        'name': 'Clear Sight Clinic',
        'address': 'Jl. Mawar No. 10, Kediri',
        'distance': '1.2 km',
        'rating': 4.6,
        'reviews': 89,
        'hours': 'Open until 19:00',
        'isOpen': true,
        'mapsUrl': 'https://maps.google.com/?q=Clear+Sight+Clinic+Kediri',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Find Clinics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Eye care centers near you',
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 16),

          /// SEARCH (UI ONLY)
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by location...',
              prefixIcon: const Icon(Icons.location_on_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// LIST HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby Clinics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${clinics.length} found',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// CLINIC LIST
          ...clinics.map((clinic) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on, color: Colors.blue),
                    ),

                    const SizedBox(width: 12),

                    /// INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinic['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            clinic['address'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${clinic['rating']}'),
                              const SizedBox(width: 4),
                              Text(
                                '(${clinic['reviews']})',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${clinic['distance']}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text(
                                clinic['hours'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: clinic['isOpen'] == true
                                      ? Colors.green
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// ACTION BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () => _openMaps(
                                clinic['mapsUrl'] as String,
                                context,
                              ),
                              icon: const Icon(Icons.navigation, size: 16),
                              label: const Text('Directions'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          /// INFO CARD
          Card(
            color: const Color(0xFFEFF6FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '💡 Tip: Call ahead to confirm availability and insurance coverage.',
                style: TextStyle(color: Color(0xFF1E3A8A)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
