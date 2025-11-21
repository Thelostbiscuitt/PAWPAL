import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Logger _logger = Logger();
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _isFirstTimeKey = 'is_first_time';

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isFirstTime = true;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isFirstTime => _isFirstTime;

  // Initialize auth service
  Future<void> initialize() async {
    await _loadAuthData();
  }

  // Load authentication data from secure storage
  Future<void> _loadAuthData() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      final userData = await _secureStorage.read(key: _userKey);
      final isFirstTime = await _secureStorage.read(key: _isFirstTimeKey);

      if (accessToken != null && refreshToken != null) {
        _apiService.setTokens(accessToken, refreshToken);
        _isAuthenticated = true;

        if (userData != null) {
          _currentUser = User.fromJson(jsonDecode(userData));
        }
      }

      _isFirstTime = isFirstTime != 'false';
      _logger.i('Auth data loaded. Is authenticated: $_isAuthenticated');
    } catch (e) {
      _logger.e('Failed to load auth data: $e');
    }
  }

  // Save authentication data to secure storage
  Future<void> _saveAuthData({
    String? accessToken,
    String? refreshToken,
    User? user,
    bool? isFirstTime,
  }) async {
    try {
      if (accessToken != null) {
        await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      }
      if (refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }
      if (user != null) {
        await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
      }
      if (isFirstTime != null) {
        await _secureStorage.write(key: _isFirstTimeKey, value: isFirstTime.toString());
      }
    } catch (e) {
      _logger.e('Failed to save auth data: $e');
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userKey);
      _currentUser = null;
      _isAuthenticated = false;
      _apiService.clearTokens();
    } catch (e) {
      _logger.e('Failed to clear auth data: $e');
    }
  }

  // User registration
  Future<ApiResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final response = await _apiService.register({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      });

      if (response.success && response.data != null) {
        final userData = response.data['user'];
        final tokens = response.data['tokens'];
        
        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;
        _isFirstTime = true;

        // Save tokens and user data
        await _saveAuthData(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
          user: _currentUser,
          isFirstTime: _isFirstTime,
        );

        _apiService.setTokens(tokens['accessToken'], tokens['refreshToken']);
      }

      return response;
    } catch (e) {
      _logger.e('Registration failed: $e');
      return ApiResponse.error('Registration failed: ${e.toString()}');
    }
  }

  // User login
  Future<ApiResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiService.login(email, password);

      if (response.success && response.data != null) {
        final userData = response.data['user'];
        final tokens = response.data['tokens'];
        
        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;

        // Save tokens and user data
        await _saveAuthData(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
          user: _currentUser,
        );

        _apiService.setTokens(tokens['accessToken'], tokens['refreshToken']);
      }

      return response;
    } catch (e) {
      _logger.e('Login failed: $e');
      return ApiResponse.error('Login failed: ${e.toString()}');
    }
  }

  // User logout
  Future<ApiResponse> logout() async {
    try {
      final response = await _apiService.logout();
      await _clearAuthData();
      return response;
    } catch (e) {
      _logger.e('Logout failed: $e');
      // Even if API call fails, clear local data
      await _clearAuthData();
      return ApiResponse.error('Logout failed: ${e.toString()}');
    }
  }

  // Refresh access token
  Future<ApiResponse> refreshAccessToken() async {
    try {
      final response = await _apiService.refreshToken();

      if (response.success && response.data != null) {
        final tokens = response.data['tokens'];
        
        // Save new tokens
        await _saveAuthData(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );

        _apiService.setTokens(tokens['accessToken'], tokens['refreshToken']);
      }

      return response;
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      return ApiResponse.error('Token refresh failed: ${e.toString()}');
    }
  }

  // Update user profile
  Future<ApiResponse> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? country,
    Map<String, double>? location,
  }) async {
    try {
      final profileData = <String, dynamic>{};
      
      if (firstName != null) profileData['firstName'] = firstName;
      if (lastName != null) profileData['lastName'] = lastName;
      if (phone != null) profileData['phone'] = phone;
      if (city != null) profileData['city'] = city;
      if (country != null) profileData['country'] = country;
      if (location != null) profileData['location'] = location;

      final response = await _apiService.updateProfile(profileData);

      if (response.success && response.data != null) {
        final userData = response.data['user'];
        _currentUser = User.fromJson(userData);
        
        // Save updated user data
        await _saveAuthData(user: _currentUser);
      }

      return response;
    } catch (e) {
      _logger.e('Profile update failed: $e');
      return ApiResponse.error('Profile update failed: ${e.toString()}');
    }
  }

  // Change password
  Future<ApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await _apiService.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      _logger.e('Password change failed: $e');
      return ApiResponse.error('Password change failed: ${e.toString()}');
    }
  }

  // Forgot password
  Future<ApiResponse> forgotPassword(String email) async {
    try {
      return await _apiService.post('/auth/forgot-password', data: {
        'email': email,
      });
    } catch (e) {
      _logger.e('Forgot password failed: $e');
      return ApiResponse.error('Forgot password failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<ApiResponse> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      return await _apiService.post('/auth/reset-password', data: {
        'token': token,
        'password': password,
      });
    } catch (e) {
      _logger.e('Password reset failed: $e');
      return ApiResponse.error('Password reset failed: ${e.toString()}');
    }
  }

  // Verify email
  Future<ApiResponse> verifyEmail(String token) async {
    try {
      final response = await _apiService.post('/auth/verify-email', data: {
        'token': token,
      });

      if (response.success && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(isVerified: true);
        await _saveAuthData(user: _currentUser);
      }

      return response;
    } catch (e) {
      _logger.e('Email verification failed: $e');
      return ApiResponse.error('Email verification failed: ${e.toString()}');
    }
  }

  // Send email verification
  Future<ApiResponse> sendEmailVerification() async {
    try {
      return await _apiService.post('/auth/send-verification');
    } catch (e) {
      _logger.e('Send verification failed: $e');
      return ApiResponse.error('Send verification failed: ${e.toString()}');
    }
  }

  // Biometric authentication
  Future<bool> canUseBiometrics() async {
    try {
      final localAuth = LocalAuthentication();
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      return canCheckBiometrics;
    } catch (e) {
      _logger.e('Biometric check failed: $e');
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final localAuth = LocalAuthentication();
      final isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Authenticate to access Pet Support',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      _logger.e('Biometric authentication failed: $e');
      return false;
    }
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    _isFirstTime = false;
    await _saveAuthData(isFirstTime: false);
  }
}