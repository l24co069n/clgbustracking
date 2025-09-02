import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class RouteProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<RouteModel> _routes = [];
  bool _isLoading = false;

  List<RouteModel> get routes => _routes;
  bool get isLoading => _isLoading;

  void loadRoutes({String? collegeName, String? coordinatorId}) {
    _databaseService.getRoutes(
      collegeName: collegeName,
      coordinatorId: coordinatorId,
    ).listen((routes) {
      _routes = routes;
      notifyListeners();
    });
  }

  Future<String?> createRoute({
    required String routeName,
    required RouteType type,
    required String startPoint,
    required String endPoint,
    required List<RouteStop> stops,
    required String collegeName,
    required String coordinatorId,
    String? busId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final route = RouteModel(
      id: '',
      routeName: routeName,
      type: type,
      startPoint: startPoint,
      endPoint: endPoint,
      stops: stops,
      collegeName: collegeName,
      coordinatorId: coordinatorId,
      busId: busId,
      createdAt: DateTime.now(),
    );

    final error = await _databaseService.createRoute(route);

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> updateRoute(String routeId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    data['updatedAt'] = DateTime.now();
    final error = await _databaseService.updateRoute(routeId, data);

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> deleteRoute(String routeId) async {
    _isLoading = true;
    notifyListeners();

    final error = await _databaseService.deleteRoute(routeId);

    _isLoading = false;
    notifyListeners();
    return error;
  }

  List<RouteModel> getRoutesByBusId(String busId) {
    return _routes.where((route) => route.busId == busId).toList();
  }
}