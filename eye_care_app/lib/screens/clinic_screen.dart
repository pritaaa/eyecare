import 'dart:math';

import 'package:eye_care_app/clinic/clinic_data.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ClinicFinderScreen extends StatefulWidget {
  const ClinicFinderScreen({super.key});
  @override
  State<ClinicFinderScreen> createState() => _ClinicFinderScreenState();
}

class _ClinicFinderScreenState extends State<ClinicFinderScreen> {
  bool _isLoading = false;
  late List<Map<String, dynamic>> _clinics;

  @override
  void initState() {
    super.initState();
    // Konversi ClinicModel ke Map agar bisa diedit (misal: update jarak/alamat)
    _clinics = clinics
        .map(
          (c) => {
            'name': c.name,
            'lat': c.lat,
            'lng': c.lng,
            'distance': c.distance,
            'address': c.address,
            'distanceValue': 0.0,
          },
        )
        .toList();
    _getCurrentLocation();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;

    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // 1. Cek apakah GPS/Layanan Lokasi aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // 2. Cek dan Request Izin
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // 3. Ambil posisi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userLat = position.latitude;
      final userLng = position.longitude;

      for (var clinic in _clinics) {
        final dist = calculateDistance(
          userLat,
          userLng,
          clinic['lat'],
          clinic['lng'],
        );
        clinic['distanceValue'] = dist;
        clinic['distance'] = dist;
      }

      _clinics.sort((a, b) => a['distanceValue'].compareTo(b['distanceValue']));
    } catch (e) {
      debugPrint("Error getting location: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return "${p.street}, ${p.locality}";
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }

    return "Address not available";
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.navigation, color: Colors.blue),
              label: Text(
                _isLoading ? 'Locating...' : 'Use Current Location',
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
            ..._clinics.map(
              (clinic) => Padding(
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
                                clinic['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              clinic['address'] != null
                                  ? Text(
                                      clinic['address'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : FutureBuilder<String>(
                                      future:
                                          _getAddressFromLatLng(
                                            clinic['lat'],
                                            clinic['lng'],
                                          ).then((val) {
                                            clinic['address'] = val;
                                            return val;
                                          }),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? "Loading address...",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        );
                                      },
                                    ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• ${(clinic['distance'] as double?)?.toStringAsFixed(1) ?? '-'} km',
                                    style: const TextStyle(
                                      color: Colors.black54,
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
                                      icon: const Icon(
                                        Icons.navigation,
                                        size: 16,
                                      ),
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
              ),
            ),

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
