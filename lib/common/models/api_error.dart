import 'package:routy/common/api/error_handler.dart';

/// API Error model with additional functionality
class ApiErrorModel extends ApiError {
  final String? field;
  final List<String>? details;
  final bool isRetryable;

  ApiErrorModel({
    required super.type,
    required super.code,
    required super.message,
    super.data,
    super.timestamp,
    this.field,
    this.details,
    this.isRetryable = false,
  });

  /// Create from ApiError
  factory ApiErrorModel.fromApiError(
    ApiError error, {
    String? field,
    List<String>? details,
    bool isRetryable = false,
  }) {
    return ApiErrorModel(
      type: error.type,
      code: error.code,
      message: error.message,
      data: error.data,
      timestamp: error.timestamp,
      field: field,
      details: details,
      isRetryable: isRetryable,
    );
  }

  /// Create network error
  factory ApiErrorModel.network(String message) {
    return ApiErrorModel(
      type: ErrorType.network,
      code: 'NETWORK_ERROR',
      message: message,
      isRetryable: true,
    );
  }

  /// Create authentication error
  factory ApiErrorModel.authentication(String message) {
    return ApiErrorModel(
      type: ErrorType.authentication,
      code: 'AUTH_ERROR',
      message: message,
      isRetryable: false,
    );
  }

  /// Create validation error
  factory ApiErrorModel.validation(
    String message, {
    String? field,
    List<String>? details,
  }) {
    return ApiErrorModel(
      type: ErrorType.validation,
      code: 'VALIDATION_ERROR',
      message: message,
      field: field,
      details: details,
      isRetryable: false,
    );
  }

  /// Create server error
  factory ApiErrorModel.server(String message) {
    return ApiErrorModel(
      type: ErrorType.server,
      code: 'SERVER_ERROR',
      message: message,
      isRetryable: true,
    );
  }

  /// Create timeout error
  factory ApiErrorModel.timeout(String message) {
    return ApiErrorModel(
      type: ErrorType.timeout,
      code: 'TIMEOUT_ERROR',
      message: message,
      isRetryable: true,
    );
  }

  /// Create unknown error
  factory ApiErrorModel.unknown(String message) {
    return ApiErrorModel(
      type: ErrorType.unknown,
      code: 'UNKNOWN_ERROR',
      message: message,
      isRetryable: false,
    );
  }

  /// Check if error is retryable
  bool get canRetry => isRetryable;

  /// Get error details as string
  String get detailsString {
    if (details == null || details!.isEmpty) return '';
    return details!.join(', ');
  }

  /// Get full error message with details
  String get fullMessage {
    String message = this.message;
    if (field != null) {
      message = '$message (Field: $field)';
    }
    if (detailsString.isNotEmpty) {
      message = '$message (Details: $detailsString)';
    }
    return message;
  }

  @override
  String toString() {
    return 'ApiErrorModel(type: $type, code: $code, message: $message, field: $field, isRetryable: $isRetryable)';
  }
}
