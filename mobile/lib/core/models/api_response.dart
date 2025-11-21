// API Response Model
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int? statusCode;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.message,
  });

  factory ApiResponse.success(dynamic data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode, String? message}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
      message: message,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, error: $error, statusCode: $statusCode)';
  }
}

// Pagination Response Model
class PaginatedResponse {
  final List<dynamic> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      data: json['data'] ?? [],
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
}

// API Error Model
class ApiError {
  final String error;
  final String? message;
  final int? statusCode;
  final List<String>? details;

  ApiError({
    required this.error,
    this.message,
    this.statusCode,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      error: json['error'] ?? 'Unknown error',
      message: json['message'],
      statusCode: json['statusCode'],
      details: json['details']?.cast<String>(),
    );
  }

  @override
  String toString() {
    return 'ApiError(error: $error, message: $message, statusCode: $statusCode)';
  }
}

// Validation Error Model
class ValidationError {
  final String field;
  final String message;
  final String? value;

  ValidationError({
    required this.field,
    required this.message,
    this.value,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      value: json['value'],
    );
  }
}