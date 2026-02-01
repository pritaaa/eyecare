import 'dart:math';

import 'package:eye_care_app/clinic/clinic_data.dart';
import 'package:eye_care_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eye_care_app/theme/app_colors.dart';
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
        .map((c) => {
              'name': c.name,
              'lat': c.lat,
              'lng': c.lng,
              'distance': c.distance,
              'address': c.address,
              'distanceValue': 0.0,
            })
        .toList();
    _getCurrentLocation();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permission permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      for (var clinic in _clinics) {
        final dist = calculateDistance(
          position.latitude,
          position.longitude,
          clinic['lat'],
          clinic['lng'],
        );
        clinic['distanceValue'] = dist;
        clinic['distance'] = dist;
      }

      _clinics.sort(
        (a, b) => a['distanceValue'].compareTo(b['distanceValue']),
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> openMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        elevation: 20,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Klinik Terdekat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// BUTTON REFRESH
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.birugelap),
              ),
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.navigation,
                      color: AppColors.birugelap),
              label: Text(
                _isLoading ? 'Locating...' : 'Refresh lokasi',
                style: const TextStyle(color: AppColors.birugelap),
              ),
            ),

            const SizedBox(height: 16),

            /// LIST KLINIK (NGISI SISA LAYAR)
            Expanded(
              child: ListView.builder(
                itemCount: _clinics.length,
                itemBuilder: (context, index) {
                  final clinic = _clinics[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.birugelap),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinic['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.biru,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                clinic['address'] ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jarak: ${clinic['distance']?.toStringAsFixed(1) ?? '-'} km',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.birugelap,
                                    shape: const StadiumBorder(),
                                  ),
                                  onPressed: () => openMaps(
                                    clinic['lat'],
                                    clinic['lng'],
                                  ),
                                  icon: const Icon(Icons.navigation, size: 16),
                                  label: const Text(
                                    'Buka Google Maps',
                                    style: TextStyle(color: Colors.white),
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
            ),
          ],
        ),
      ),
    );
  }
}
