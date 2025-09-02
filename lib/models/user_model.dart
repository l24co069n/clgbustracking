import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final ApprovalStatus approvalStatus;
  final String? collegeName;
  final String? collegeDomain;
  final String? personalEmail;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.approvalStatus = ApprovalStatus.pending,
    this.collegeName,
    this.collegeDomain,
    this.personalEmail,
    this.approvedBy,
    required this.createdAt,
    this.approvedAt,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == data['role'],
        orElse: () => UserRole.student,
      ),
      approvalStatus: ApprovalStatus.values.firstWhere(
        (e) => e.toString() == data['approvalStatus'],
        orElse: () => ApprovalStatus.pending,
      ),
      collegeName: data['collegeName'],
      collegeDomain: data['collegeDomain'],
      personalEmail: data['personalEmail'],
      approvedBy: data['approvedBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null 
          ? (data['approvedAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.toString(),
      'approvalStatus': approvalStatus.toString(),
      'collegeName': collegeName,
      'collegeDomain': collegeDomain,
      'personalEmail': personalEmail,
      'approvedBy': approvedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    ApprovalStatus? approvalStatus,
    String? collegeName,
    String? collegeDomain,
    String? personalEmail,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? approvedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      collegeName: collegeName ?? this.collegeName,
      collegeDomain: collegeDomain ?? this.collegeDomain,
      personalEmail: personalEmail ?? this.personalEmail,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}