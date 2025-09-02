import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class RouteStop {
  final String name;
  final double latitude;
  final double longitude;
  final int order;

  RouteStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  factory RouteStop.fromMap(Map<String, dynamic> data) {
    return RouteStop(
      name: data['name'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'order': order,
    };
  }
}

class RouteModel {
  final String id;
  final String routeName;
  final RouteType type;
  final String startPoint;
  final String endPoint;
  final List<RouteStop> stops;
  final String collegeName;
  final String coordinatorId;
  final String? busId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  RouteModel({
    required this.id,
    required this.routeName,
    required this.type,
    required this.startPoint,
    required this.endPoint,
    required this.stops,
    required this.collegeName,
    required this.coordinatorId,
    this.busId,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RouteModel(
      id: doc.id,
      routeName: data['routeName'] ?? '',
      type: RouteType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => RouteType.pickup,
      ),
      startPoint: data['startPoint'] ?? '',
      endPoint: data['endPoint'] ?? '',
      stops: (data['stops'] as List<dynamic>?)
          ?.map((stop) => RouteStop.fromMap(stop as Map<String, dynamic>))
          .toList() ?? [],
      collegeName: data['collegeName'] ?? '',
      coordinatorId: data['coordinatorId'] ?? '',
      busId: data['busId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'routeName': routeName,
      'type': type.toString(),
      'startPoint': startPoint,
      'endPoint': endPoint,
      'stops': stops.map((stop) => stop.toMap()).toList(),
      'collegeName': collegeName,
      'coordinatorId': coordinatorId,
      'busId': busId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }
}