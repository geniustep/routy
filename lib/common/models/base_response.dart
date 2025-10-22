/// Base response model for API calls
class BaseResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  BaseResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
    this.metadata,
  });

  /// Create success response
  factory BaseResponse.success({
    required T data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return BaseResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
      metadata: metadata,
    );
  }

  /// Create error response
  factory BaseResponse.error({
    required String error,
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return BaseResponse<T>(
      success: false,
      error: error,
      message: message,
      statusCode: statusCode ?? 400,
      metadata: metadata,
    );
  }

  /// Create from JSON
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson([dynamic Function(T)? toJsonT]) {
    return {
      'success': success,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'message': message,
      'error': error,
      'statusCode': statusCode,
      'metadata': metadata,
    };
  }

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response has error
  bool get hasError => error != null;

  /// Get data or throw exception if null
  T get dataOrThrow {
    if (data == null) {
      throw Exception('Data is null');
    }
    return data!;
  }

  /// Get data or return default value
  T dataOr(T defaultValue) {
    return data ?? defaultValue;
  }

  @override
  String toString() {
    return 'BaseResponse(success: $success, data: $data, message: $message, error: $error)';
  }
}
