import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  final String id;
  final String busNumber;
  final String? driverId;
  final String? driverName;
  final String collegeName;
  final String coordinatorId;
  final int capacity;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  BusModel({
    required this.id,
    required this.busNumber,
    this.driverId,
    this.driverName,
    required this.collegeName,
    required this.coordinatorId,
    this.capacity = 50,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory BusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusModel(
      id: doc.id,
      busNumber: data['busNumber'] ?? '',
      driverId: data['driverId'],
      driverName: data['driverName'],
      collegeName: data['collegeName'] ?? '',
      coordinatorId: data['coordinatorId'] ?? '',
      capacity: data['capacity'] ?? 50,
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'busNumber': busNumber,
      'driverId': driverId,
      'driverName': driverName,
      'collegeName': collegeName,
      'coordinatorId': coordinatorId,
      'capacity': capacity,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }

  BusModel copyWith({
    String? id,
    String? busNumber,
    String? driverId,
    String? driverName,
    String? collegeName,
    String? coordinatorId,
    int? capacity,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return BusModel(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      collegeName: collegeName ?? this.collegeName,
      coordinatorId: coordinatorId ?? this.coordinatorId,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}