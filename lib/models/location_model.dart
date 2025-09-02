import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String id;
  final String busId;
  final String driverId;
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final bool isSharing;

  LocationModel({
    required this.id,
    required this.busId,
    required this.driverId,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.isSharing = false,
  });

  factory LocationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LocationModel(
      id: doc.id,
      busId: data['busId'] ?? '',
      driverId: data['driverId'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      speed: data['speed']?.toDouble(),
      heading: data['heading']?.toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isSharing: data['isSharing'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'busId': busId,
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSharing': isSharing,
    };
  }
}