import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? collegeName,
    String? collegeDomain,
    String? personalEmail,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Send verification email
        try {
          await credential.user!.sendEmailVerification();
        } catch (_) {}
        // Determine approval status
        ApprovalStatus approvalStatus = ApprovalStatus.approved;
        if (role == UserRole.coordinator && personalEmail != null) {
          approvalStatus = ApprovalStatus.pending;
        } else if ((role == UserRole.driver || role == UserRole.teacher) && personalEmail != null) {
          approvalStatus = ApprovalStatus.pending;
        } else if (role == UserRole.student && personalEmail != null) {
          approvalStatus = ApprovalStatus.pending;
        }

        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          approvalStatus: approvalStatus,
          collegeName: collegeName,
          collegeDomain: collegeDomain,
          personalEmail: personalEmail,
          createdAt: DateTime.now(),
        );

        try {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(credential.user!.uid)
              .set(userModel.toFirestore());
        } catch (e) {
          // Roll back auth user to avoid orphaned account
          try { await credential.user!.delete(); } catch (_) {}
          return 'Registration failed while saving profile. Please try again.';
        }

        return null; // Success
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred during registration';
    }
    return 'Unknown error occurred';
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (_auth.currentUser != null && _auth.currentUser!.emailVerified == false) {
        await _auth.signOut();
        return 'Please verify your email before logging in. Check your inbox.';
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred during login';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred while sending reset email';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> approveUser(String userId, String approverId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'approvalStatus': ApprovalStatus.approved.toString(),
        'approvedBy': approverId,
        'approvedAt': Timestamp.fromDate(DateTime.now()),
      });
      return null; // Success
    } catch (e) {
      return 'Error approving user: $e';
    }
  }

  Future<String?> rejectUser(String userId, String approverId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'approvalStatus': ApprovalStatus.rejected.toString(),
        'approvedBy': approverId,
        'approvedAt': Timestamp.fromDate(DateTime.now()),
      });
      return null; // Success
    } catch (e) {
      return 'Error rejecting user: $e';
    }
  }
}