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
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
          
        ],
      ),
    );
  }
}
