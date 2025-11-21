import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isFirstTime = true;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isFirstTime => _isFirstTime;
  String? get errorMessage => _errorMessage;

  // Initialize auth provider
  Future<void> initialize() async {
    await _authService.initialize();
    _user = _authService.currentUser;
    _isFirstTime = _authService.isFirstTime;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // User registration
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (response.success) {
        _user = _authService.currentUser;
        _isFirstTime = _authService.isFirstTime;
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // User login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (response.success) {
        _user = _authService.currentUser;
        _isFirstTime = _authService.isFirstTime;
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // User logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _isFirstTime = true;
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? country,
    Map<String, double>? location,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        city: city,
        country: country,
        location: location,
      );

      if (response.success) {
        _user = _authService.currentUser;
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        _setError(null);
        return true;
      } else {
        _setError(response.error ?? 'Password change failed');
        return false;
      }
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.forgotPassword(email);

      if (response.success) {
        _setError(null);
        return true;
      } else {
        _setError(response.error ?? 'Failed to send reset email');
        return false;
      }
    } catch (e) {
      _setError('Failed to send reset email: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.resetPassword(
        token: token,
        password: password,
      );

      if (response.success) {
        _setError(null);
        return true;
      } else {
        _setError(response.error ?? 'Password reset failed');
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify email
  Future<bool> verifyEmail(String token) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.verifyEmail(token);

      if (response.success) {
        _user = _authService.currentUser;
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Email verification failed');
        return false;
      }
    } catch (e) {
      _setError('Email verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.sendEmailVerification();

      if (response.success) {
        _setError(null);
        return true;
      } else {
        _setError(response.error ?? 'Failed to send verification email');
        return false;
      }
    } catch (e) {
      _setError('Failed to send verification email: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canUseBiometrics = await _authService.canUseBiometrics();
      if (!canUseBiometrics) {
        _setError('Biometric authentication is not available on this device');
        return false;
      }

      final isAuthenticated = await _authService.authenticateWithBiometrics();
      if (isAuthenticated) {
        _setError(null);
        return true;
      } else {
        _setError('Biometric authentication failed');
        return false;
      }
    } catch (e) {
      _setError('Biometric authentication failed: ${e.toString()}');
      return false;
    }
  }

  // Complete onboarding
  void completeOnboarding() {
    _authService.completeOnboarding();
    _isFirstTime = false;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_user == null) return;

    try {
      // Re-initialize auth service to get fresh data
      await _authService.initialize();
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh user data: ${e.toString()}');
    }
  }

  // Update user locally (without API call)
  void updateUserLocally(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}