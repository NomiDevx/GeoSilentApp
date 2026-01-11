import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Initialize auth state and listen for changes
  Future<void> initialize() async {
    if (_isInitialized) return; // Prevent multiple initializations

    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
      // Listen to auth state changes
      _authService.authStateChanges.listen((firebaseUser) async {
        if (firebaseUser != null) {
          _user = await _authService.getCurrentUser();
        } else {
          _user = null;
        }
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        // Give Flutter a moment to rebuild before the listener fires
        await Future.delayed(const Duration(milliseconds: 100));
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Sign in failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(updatedUser);
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
