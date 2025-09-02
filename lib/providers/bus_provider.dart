import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class BusProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<BusModel> _buses = [];
  List<UserModel> _availableDrivers = [];
  bool _isLoading = false;

  List<BusModel> get buses => _buses;
  List<UserModel> get availableDrivers => _availableDrivers;
  bool get isLoading => _isLoading;

  void loadBuses({String? collegeName, String? coordinatorId}) {
    _databaseService.getBuses(
      collegeName: collegeName,
      coordinatorId: coordinatorId,
    ).listen((buses) {
      _buses = buses;
      notifyListeners();
    });
  }

  void loadAvailableDrivers(String collegeName) {
    _databaseService.getAvailableDrivers(collegeName).listen((drivers) {
      _availableDrivers = drivers;
      notifyListeners();
    });
  }

  Future<String?> createBus({
    required String busNumber,
    required String collegeName,
    required String coordinatorId,
    String? driverId,
    String? driverName,
    int capacity = 50,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    final bus = BusModel(
      id: '',
      busNumber: busNumber,
      driverId: driverId,
      driverName: driverName,
      collegeName: collegeName,
      coordinatorId: coordinatorId,
      capacity: capacity,
      description: description,
      createdAt: DateTime.now(),
    );

    final error = await _databaseService.createBus(bus);

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> updateBus(String busId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    data['updatedAt'] = DateTime.now();
    final error = await _databaseService.updateBus(busId, data);

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> deleteBus(String busId) async {
    _isLoading = true;
    notifyListeners();

    final error = await _databaseService.deleteBus(busId);

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> assignDriver(String busId, String driverId, String driverName) async {
    return await updateBus(busId, {
      'driverId': driverId,
      'driverName': driverName,
    });
  }

  Future<String?> removeDriver(String busId) async {
    return await updateBus(busId, {
      'driverId': null,
      'driverName': null,
    });
  }
}