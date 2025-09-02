import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/location_model.dart';

class LocationService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<Position>? _positionStream;
  bool _isSharing = false;

  bool get isSharing => _isSharing;

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<String?> startLocationSharing({
    required String busId,
    required String driverId,
  }) async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return 'Location permission denied';
      }

      _isSharing = true;

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _updateLocationInDatabase(
          busId: busId,
          driverId: driverId,
          position: position,
        );
      });

      return null; // Success
    } catch (e) {
      _isSharing = false;
      return 'Error starting location sharing: $e';
    }
  }

  Future<void> stopLocationSharing(String busId) async {
    _isSharing = false;
    await _positionStream?.cancel();
    _positionStream = null;

    // Update sharing status in database
    await _database
        .ref('locations/$busId')
        .update({'isSharing': false});
  }

  Future<void> _updateLocationInDatabase({
    required String busId,
    required String driverId,
    required Position position,
  }) async {
    try {
      final locationData = {
        'busId': busId,
        'driverId': driverId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': position.speed,
        'heading': position.heading,
        'timestamp': ServerValue.timestamp,
        'isSharing': true,
      };

      await _database
          .ref('locations/$busId')
          .set(locationData);
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Stream<Map<String, dynamic>?> getBusLocation(String busId) {
    return _database
        .ref('locations/$busId')
        .onValue
        .map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  void dispose() {
    _positionStream?.cancel();
  }
}