import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Stream<List<UserModel>> getUsers({UserRole? role, String? collegeName}) {
    Query query = _firestore.collection(AppConstants.usersCollection);
    
    if (role != null) {
      query = query.where('role', isEqualTo: role.toString());
    }
    
    if (collegeName != null) {
      query = query.where('collegeName', isEqualTo: collegeName);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Stream<List<UserModel>> getPendingApprovals({
    required String approverId,
    required UserRole approverRole,
  }) {
    Query query = _firestore
        .collection(AppConstants.usersCollection)
        .where('approvalStatus', isEqualTo: ApprovalStatus.pending.toString());

    // Filter based on approver role
    if (approverRole == UserRole.coordinator) {
      // Coordinators approve drivers and teachers from their college
      query = query.where('collegeName', isEqualTo: approverId);
    } else if (approverRole == UserRole.teacher) {
      // Teachers approve students from their college
      query = query
          .where('role', isEqualTo: UserRole.student.toString())
          .where('collegeName', isEqualTo: approverId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Future<String?> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data);
      return null;
    } catch (e) {
      return 'Error updating user: $e';
    }
  }

  Future<String?> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();
      return null;
    } catch (e) {
      return 'Error deleting user: $e';
    }
  }

  // Bus operations
  Stream<List<BusModel>> getBuses({String? collegeName, String? coordinatorId}) {
    Query query = _firestore.collection(AppConstants.busesCollection);
    
    if (collegeName != null) {
      query = query.where('collegeName', isEqualTo: collegeName);
    }
    
    if (coordinatorId != null) {
      query = query.where('coordinatorId', isEqualTo: coordinatorId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BusModel.fromFirestore(doc)).toList());
  }

  Future<String?> createBus(BusModel bus) async {
    try {
      await _firestore
          .collection(AppConstants.busesCollection)
          .add(bus.toFirestore());
      return null;
    } catch (e) {
      return 'Error creating bus: $e';
    }
  }

  Future<String?> updateBus(String busId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.busesCollection)
          .doc(busId)
          .update(data);
      return null;
    } catch (e) {
      return 'Error updating bus: $e';
    }
  }

  Future<String?> deleteBus(String busId) async {
    try {
      await _firestore
          .collection(AppConstants.busesCollection)
          .doc(busId)
          .delete();
      return null;
    } catch (e) {
      return 'Error deleting bus: $e';
    }
  }

  // Route operations
  Stream<List<RouteModel>> getRoutes({String? collegeName, String? coordinatorId}) {
    Query query = _firestore.collection(AppConstants.routesCollection);
    
    if (collegeName != null) {
      query = query.where('collegeName', isEqualTo: collegeName);
    }
    
    if (coordinatorId != null) {
      query = query.where('coordinatorId', isEqualTo: coordinatorId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RouteModel.fromFirestore(doc)).toList());
  }

  Future<String?> createRoute(RouteModel route) async {
    try {
      await _firestore
          .collection(AppConstants.routesCollection)
          .add(route.toFirestore());
      return null;
    } catch (e) {
      return 'Error creating route: $e';
    }
  }

  Future<String?> updateRoute(String routeId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.routesCollection)
          .doc(routeId)
          .update(data);
      return null;
    } catch (e) {
      return 'Error updating route: $e';
    }
  }

  Future<String?> deleteRoute(String routeId) async {
    try {
      await _firestore
          .collection(AppConstants.routesCollection)
          .doc(routeId)
          .delete();
      return null;
    } catch (e) {
      return 'Error deleting route: $e';
    }
  }

  // Get available drivers for a college
  Stream<List<UserModel>> getAvailableDrivers(String collegeName) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: UserRole.driver.toString())
        .where('collegeName', isEqualTo: collegeName)
        .where('approvalStatus', isEqualTo: ApprovalStatus.approved.toString())
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }
}