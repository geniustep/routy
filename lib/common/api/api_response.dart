/// استجابة API عامة
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final Map<String, dynamic>? errorData;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.errorData,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }

  factory ApiResponse.error(String error, [Map<String, dynamic>? errorData]) {
    return ApiResponse(success: false, error: error, errorData: errorData);
  }
}
