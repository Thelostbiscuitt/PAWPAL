import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../constants/api_endpoints.dart';
import '../utils/validators.dart';
import '../models/api_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Logger _logger = Logger();
  late String _baseUrl;
  late String _accessToken;
  late String _refreshToken;
  
  // Initialize API service
  static Future<void> initialize() async {
    _instance._baseUrl = ApiEndpoints.baseUrl;
    // Load tokens from secure storage
    await _instance._loadTokens();
  }

  // Load tokens from secure storage
  Future<void> _loadTokens() async {
    // TODO: Implement secure storage loading
    // final storage = FlutterSecureStorage();
    // _accessToken = await storage.read(key: 'access_token');
    // _refreshToken = await storage.read(key: 'refresh_token');
  }

  // Save tokens to secure storage
  Future<void> _saveTokens() async {
    // TODO: Implement secure storage saving
    // final storage = FlutterSecureStorage();
    // await storage.write(key: 'access_token', value: _accessToken);
    // await storage.write(key: 'refresh_token', value: _refreshToken);
  }

  // Set authentication tokens
  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _saveTokens();
  }

  // Clear authentication tokens
  void clearTokens() {
    _accessToken = '';
    _refreshToken = '';
    // TODO: Clear from secure storage
    // final storage = FlutterSecureStorage();
    // await storage.delete(key: 'access_token');
    // await storage.delete(key: 'refresh_token');
  }

  // Get authorization header
  Map<String, String> _getAuthHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  // Generic GET request
  Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final requestUri = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;

      _logger.d('GET: $requestUri');

      final response = await http.get(
        requestUri,
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _logger.e('GET request failed: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic POST request
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      _logger.d('POST: $uri');
      if (data != null) {
        _logger.d('Data: ${jsonEncode(data)}');
      }

      final response = await http.post(
        uri,
        headers: _getAuthHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _logger.e('POST request failed: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic PUT request
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      _logger.d('PUT: $uri');
      if (data != null) {
        _logger.d('Data: ${jsonEncode(data)}');
      }

      final response = await http.put(
        uri,
        headers: _getAuthHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _logger.e('PUT request failed: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic DELETE request
  Future<ApiResponse> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      _logger.d('DELETE: $uri');

      final response = await http.delete(
        uri,
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // File upload (multipart/form-data)
  Future<ApiResponse> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? fields,
    ProgressCallback? onProgress,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      _logger.d('UPLOAD: $uri');

      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      if (_accessToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      // Add form fields
      if (fields != null) {
        fields.forEach((key, value) {
          request.fields[key] = value;
        });
      }

      // Add file
      final fileStream = file.openRead();
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request with progress tracking
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      _logger.e('File upload failed: $e');
      return ApiResponse.error('Upload error: ${e.toString()}');
    }
  }

  // Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    try {
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(responseData);
      } else {
        String errorMessage = 'Request failed';
        
        if (responseData is Map && responseData.containsKey('error')) {
          errorMessage = responseData['error'];
        } else if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        // Handle specific error cases
        switch (response.statusCode) {
          case 401:
            _handleUnauthorized();
            break;
          case 403:
            errorMessage = 'Access forbidden';
            break;
          case 404:
            errorMessage = 'Resource not found';
            break;
          case 409:
            errorMessage = 'Resource conflict';
            break;
          case 500:
            errorMessage = 'Server error';
            break;
        }

        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      _logger.e('Response parsing failed: $e');
      return ApiResponse.error('Invalid response format');
    }
  }

  // Handle unauthorized response (token expired)
  Future<void> _handleUnauthorized() async {
    _logger.w('Token expired, attempting refresh...');
    
    // Try to refresh the token
    final refreshResponse = await post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': _refreshToken},
    );

    if (refreshResponse.success && refreshResponse.data != null) {
      final tokens = refreshResponse.data['tokens'];
      setTokens(tokens['accessToken'], tokens['refreshToken']);
      _logger.i('Token refreshed successfully');
    } else {
      // Refresh failed, clear tokens and redirect to login
      clearTokens();
      _logger.e('Token refresh failed, user needs to login again');
      // TODO: Navigate to login screen
    }
  }

  // Authentication specific methods
  Future<ApiResponse> login(String email, String password) async {
    return post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<ApiResponse> register(Map<String, dynamic> userData) async {
    return post(
      ApiEndpoints.register,
      data: userData,
    );
  }

  Future<ApiResponse> refreshToken() async {
    return post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': _refreshToken},
    );
  }

  Future<ApiResponse> logout() async {
    final response = await post(ApiEndpoints.logout);
    clearTokens();
    return response;
  }

  Future<ApiResponse> getProfile() async {
    return get(ApiEndpoints.getProfile);
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> profileData) async {
    return put(
      ApiEndpoints.updateProfile,
      data: profileData,
    );
  }

  // Pet specific methods
  Future<ApiResponse> getPets() async {
    return get(ApiEndpoints.getPets);
  }

  Future<ApiResponse> addPet(Map<String, dynamic> petData) async {
    return post(
      ApiEndpoints.addPet,
      data: petData,
    );
  }

  Future<ApiResponse> updatePet(String petId, Map<String, dynamic> petData) async {
    return put(
      '${ApiEndpoints.updatePet}/$petId',
      data: petData,
    );
  }

  Future<ApiResponse> deletePet(String petId) async {
    return delete('${ApiEndpoints.deletePet}/$petId');
  }

  // Health tracking methods
  Future<ApiResponse> getHealthRecords(String petId) async {
    return get('${ApiEndpoints.getHealthRecords}/$petId');
  }

  Future<ApiResponse> addHealthRecord(String petId, Map<String, dynamic> recordData) async {
    return post(
      '${ApiEndpoints.addHealthRecord}/$petId',
      data: recordData,
    );
  }

  // AI Chat methods
  Future<ApiResponse> sendMessage(Map<String, dynamic> messageData) async {
    return post(
      ApiEndpoints.sendMessage,
      data: messageData,
    );
  }

  Future<ApiResponse> analyzeImage(String imageUrl, String analysisType) async {
    return post(
      ApiEndpoints.analyzeImage,
      data: {
        'imageUrl': imageUrl,
        'analysisType': analysisType,
      },
    );
  }

  // Emergency triage
  Future<ApiResponse> emergencyTriage(Map<String, dynamic> triageData) async {
    return post(
      ApiEndpoints.emergencyTriage,
      data: triageData,
    );
  }

  // Resource finder
  Future<ApiResponse> findNearbyResources(Map<String, dynamic> params) async {
    return get(
      ApiEndpoints.findNearbyResources,
      queryParams: params.cast<String, String>(),
    );
  }

  Future<ApiResponse> searchResources(Map<String, dynamic> params) async {
    return get(
      ApiEndpoints.searchResources,
      queryParams: params.cast<String, String>(),
    );
  }

  // Reminders
  Future<ApiResponse> getReminders() async {
    return get(ApiEndpoints.getReminders);
  }

  Future<ApiResponse> addReminder(Map<String, dynamic> reminderData) async {
    return post(
      ApiEndpoints.addReminder,
      data: reminderData,
    );
  }

  Future<ApiResponse> updateReminder(String reminderId, Map<String, dynamic> reminderData) async {
    return put(
      '${ApiEndpoints.updateReminder}/$reminderId',
      data: reminderData,
    );
  }

  Future<ApiResponse> deleteReminder(String reminderId) async {
    return delete('${ApiEndpoints.deleteReminder}/$reminderId');
  }
}

// Progress callback for file uploads
typedef ProgressCallback = void Function(double progress);