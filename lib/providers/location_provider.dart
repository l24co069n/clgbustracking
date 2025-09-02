import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isSharing = false;
  String? _currentBusId;
  String? _currentDriverId;

  Position? get currentPosition => _currentPosition;
  bool get isSharing => _isSharing;
  String? get currentBusId => _currentBusId;

  Future<String?> startLocationSharing({
    required String busId,
    required String driverId,
  }) async {
    final error = await _locationService.startLocationSharing(
      busId: busId,
      driverId: driverId,
    );

    if (error == null) {
      _isSharing = true;
      _currentBusId = busId;
      _currentDriverId = driverId;
      notifyListeners();
    }

    return error;
  }

  Future<void> stopLocationSharing() async {
    if (_currentBusId != null) {
      await _locationService.stopLocationSharing(_currentBusId!);
      _isSharing = false;
      _currentBusId = null;
      _currentDriverId = null;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    _currentPosition = await _locationService.getCurrentLocation();
    notifyListeners();
  }

  Stream<Map<String, dynamic>?> getBusLocation(String busId) {
    return _locationService.getBusLocation(busId);
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}