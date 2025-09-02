import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;

      if (isLoggedIn && _authService.currentUser != null) {
        _user = await _authService.getCurrentUserData();
      }
    } catch (e) {
      print('Error checking auth state: $e');
    }

    _isLoading = false;
    notifyListeners();
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
    _isLoading = true;
    notifyListeners();

    final error = await _authService.signUp(
      email: email,
      password: password,
      name: name,
      role: role,
      collegeName: collegeName,
      collegeDomain: collegeDomain,
      personalEmail: personalEmail,
    );

    if (error == null) {
      _user = await _authService.getCurrentUserData();
      await _saveLoginState();
    }

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final error = await _authService.signIn(
      email: email,
      password: password,
    );

    if (error == null) {
      _user = await _authService.getCurrentUserData();
      
      // Check if user is approved
      if (_user?.approvalStatus != ApprovalStatus.approved) {
        await signOut();
        _isLoading = false;
        notifyListeners();
        return 'Your account is pending approval';
      }
      
      await _saveLoginState();
    }

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    await _clearLoginState();
    notifyListeners();
  }

  Future<String?> approveUser(String userId) async {
    if (_user == null) return 'Not authenticated';
    
    return await _authService.approveUser(userId, _user!.id);
  }

  Future<String?> rejectUser(String userId) async {
    if (_user == null) return 'Not authenticated';
    
    return await _authService.rejectUser(userId, _user!.id);
  }

  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, true);
    if (_user != null) {
      await prefs.setString(AppConstants.userIdKey, _user!.id);
      await prefs.setString(AppConstants.userRoleKey, _user!.role.toString());
    }
  }

  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.isLoggedInKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userRoleKey);
  }
}