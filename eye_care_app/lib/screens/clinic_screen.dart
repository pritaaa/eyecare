import 'dart:math';

import 'package:eye_care_app/clinic/clinic_data.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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
        return "${p.subLocality}, ${p.locality}";
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }

    return "Address not available";
  }

  Future<void> openMaps(double lat, double lng) async {
    final googleMapsUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Klinik Terdekat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

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
                  _isLoading ? 'Locating...' : 'Refresh lokasi',
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 12),
              ..._clinics.map(
                (clinic) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinic['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            clinic['address'] != null
                                ? Text(
                                    clinic['address'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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

                            Text(
                              'Jarak: ${(clinic['distance'] as double?)?.toStringAsFixed(1) ?? '-'} km',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: const StadiumBorder(),
                                    ),
                                    onPressed: () =>
                                        openMaps(clinic['lat'], clinic['lng']),
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
            ],
          ),
        ],
      ),
    );
  }
}
