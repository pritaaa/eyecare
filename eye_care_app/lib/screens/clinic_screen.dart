import 'package:flutter/material.dart';

class ClinicFinderScreen extends StatelessWidget {
  const ClinicFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clinics = [
      {
        'name': 'VisionCare Center',
        'address': '123 Main Street, Downtown',
        'distance': '0.5 miles',
        'rating': 4.8,
        'reviews': 124,
        'hours': 'Open until 6:00 PM',
        'phone': '(555) 123-4567',
        'isOpen': true,
      },
      {
        'name': 'Clear Sight Clinic',
        'address': '456 Oak Avenue, Westside',
        'distance': '1.2 miles',
        'rating': 4.6,
        'reviews': 89,
        'hours': 'Open until 7:00 PM',
        'phone': '(555) 234-5678',
        'isOpen': true,
      },
      {
        'name': 'Eye Health Associates',
        'address': '789 Pine Road, East District',
        'distance': '2.1 miles',
        'rating': 4.9,
        'reviews': 203,
        'hours': 'Closed • Opens at 9:00 AM',
        'phone': '(555) 345-6789',
        'isOpen': false,
      },
      {
        'name': 'Premier Eye Clinic',
        'address': '321 Elm Street, Northside',
        'distance': '2.8 miles',
        'rating': 4.7,
        'reviews': 156,
        'hours': 'Open until 8:00 PM',
        'phone': '(555) 456-7890',
        'isOpen': true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Find Clinics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= HEADER =================
            const Text(
              'Eye care centers near you',
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 20),

            /// ================= SEARCH =================
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

            const SizedBox(height: 12),

            /// ================= CURRENT LOCATION =================
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.blue),
              ),
              onPressed: () {},
              icon: const Icon(Icons.navigation, color: Colors.blue),
              label: const Text(
                'Use Current Location',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= LIST HEADER =================
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

            /// ================= CLINIC LIST =================
            ...clinics.map((clinic) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _iconBox(Icons.location_on, Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clinic['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  clinic['address'] as String,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
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
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${clinic['distance']}',
                                      style: const TextStyle(
                                          color: Colors.black54),
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

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          shape: const StadiumBorder(),
                                        ),
                                        onPressed: () {},
                                        icon: const Icon(Icons.phone, size: 16),
                                        label: const Text('Call'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: const StadiumBorder(),
                                        ),
                                        onPressed: () {},
                                        icon: const Icon(Icons.navigation,
                                            size: 16),
                                        label: const Text('Directions'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

            /// ================= INFO CARD =================
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
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }
}
