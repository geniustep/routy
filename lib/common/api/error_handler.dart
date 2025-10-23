import 'package:dio/dio.dart';
import 'package:routy/services/translation_service.dart';
import 'package:routy/utils/app_logger.dart';

/// Error types for API responses
enum ErrorType { network, authentication, validation, server, timeout, unknown }

/// API Error model
class ApiError {
  final ErrorType type;
  final String code;
  final String message;
  final dynamic data;
  final DateTime timestamp;

  ApiError({
    required this.type,
    required this.code,
    required this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'ApiError(type: $type, code: $code, message: $message)';
  }
}

/// Error Handler for API responses
class ErrorHandler {
  ErrorHandler._();

  // Error messages in different languages
  static final Map<String, Map<String, String>> _errorMessages = {
    'fr': {
      'NO_INTERNET': 'Aucune connexion Internet',
      'CONNECTION_FAILED': 'Échec de la connexion au serveur',
      'CONNECTION_TIMEOUT': 'Délai de connexion dépassé',
      'SEND_TIMEOUT': 'Délai d\'envoi dépassé',
      'RECEIVE_TIMEOUT': 'Délai de réception dépassé',
      'BAD_RESPONSE': 'Réponse du serveur invalide',
      'SERVER_ERROR': 'Erreur du serveur',
      'SESSION_EXPIRED': 'Session expirée',
      'REQUEST_CANCELLED': 'Requête annulée',
      'UNKNOWN_ERROR': 'Erreur inconnue',
      'VALIDATION_ERROR': 'Erreur de validation',
      'AUTHENTICATION_ERROR': 'Erreur d\'authentification',
    },
    'ar': {
      'NO_INTERNET': 'لا يوجد اتصال بالإنترنت',
      'CONNECTION_FAILED': 'فشل في الاتصال بالخادم',
      'CONNECTION_TIMEOUT': 'انتهت مهلة الاتصال',
      'SEND_TIMEOUT': 'انتهت مهلة الإرسال',
      'RECEIVE_TIMEOUT': 'انتهت مهلة الاستقبال',
      'BAD_RESPONSE': 'استجابة خادم غير صالحة',
      'SERVER_ERROR': 'خطأ في الخادم',
      'SESSION_EXPIRED': 'انتهت صلاحية الجلسة',
      'REQUEST_CANCELLED': 'تم إلغاء الطلب',
      'UNKNOWN_ERROR': 'خطأ غير معروف',
      'VALIDATION_ERROR': 'خطأ في التحقق',
      'AUTHENTICATION_ERROR': 'خطأ في المصادقة',
    },
    'en': {
      'NO_INTERNET': 'No internet connection',
      'CONNECTION_FAILED': 'Connection to server failed',
      'CONNECTION_TIMEOUT': 'Connection timeout',
      'SEND_TIMEOUT': 'Send timeout',
      'RECEIVE_TIMEOUT': 'Receive timeout',
      'BAD_RESPONSE': 'Invalid server response',
      'SERVER_ERROR': 'Server error',
      'SESSION_EXPIRED': 'Session expired',
      'REQUEST_CANCELLED': 'Request cancelled',
      'UNKNOWN_ERROR': 'Unknown error',
      'VALIDATION_ERROR': 'Validation error',
      'AUTHENTICATION_ERROR': 'Authentication error',
    },
    'es': {
      'NO_INTERNET': 'Sin conexión a Internet',
      'CONNECTION_FAILED': 'Error de conexión al servidor',
      'CONNECTION_TIMEOUT': 'Tiempo de conexión agotado',
      'SEND_TIMEOUT': 'Tiempo de envío agotado',
      'RECEIVE_TIMEOUT': 'Tiempo de recepción agotado',
      'BAD_RESPONSE': 'Respuesta del servidor inválida',
      'SERVER_ERROR': 'Error del servidor',
      'SESSION_EXPIRED': 'Sesión expirada',
      'REQUEST_CANCELLED': 'Solicitud cancelada',
      'UNKNOWN_ERROR': 'Error desconocido',
      'VALIDATION_ERROR': 'Error de validación',
      'AUTHENTICATION_ERROR': 'Error de autenticación',
    },
  };

  /// Handle error code and return localized message
  static ApiError handleErrorCode(String code, {String? customMessage}) {
    final language = TranslationService.instance.currentLanguage;
    final messages = _errorMessages[language] ?? _errorMessages['en']!;

    String message =
        customMessage ?? messages[code] ?? messages['UNKNOWN_ERROR']!;

    ErrorType type;
    switch (code) {
      case 'NO_INTERNET':
      case 'CONNECTION_FAILED':
      case 'CONNECTION_TIMEOUT':
      case 'SEND_TIMEOUT':
      case 'RECEIVE_TIMEOUT':
        type = ErrorType.network;
        break;
      case 'SESSION_EXPIRED':
      case 'AUTHENTICATION_ERROR':
        type = ErrorType.authentication;
        break;
      case 'VALIDATION_ERROR':
        type = ErrorType.validation;
        break;
      case 'SERVER_ERROR':
      case 'BAD_RESPONSE':
        type = ErrorType.server;
        break;
      case 'REQUEST_CANCELLED':
        type = ErrorType.timeout;
        break;
      default:
        type = ErrorType.unknown;
    }

    return ApiError(type: type, code: code, message: message);
  }

  /// Handle DioException
  static ApiError handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        if (e.error.toString().contains('Failed host lookup')) {
          return handleErrorCode('NO_INTERNET');
        }
        return handleErrorCode('CONNECTION_FAILED');

      case DioExceptionType.connectionTimeout:
        return handleErrorCode('CONNECTION_TIMEOUT');

      case DioExceptionType.sendTimeout:
        return handleErrorCode('SEND_TIMEOUT');

      case DioExceptionType.receiveTimeout:
        return handleErrorCode('RECEIVE_TIMEOUT');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return handleErrorCode('SESSION_EXPIRED');
        } else if (statusCode == 422) {
          return handleErrorCode('VALIDATION_ERROR');
        } else if (statusCode != null && statusCode >= 500) {
          return handleErrorCode('SERVER_ERROR');
        }
        return handleErrorCode('BAD_RESPONSE');

      case DioExceptionType.cancel:
        return handleErrorCode('REQUEST_CANCELLED');

      case DioExceptionType.unknown:
      default:
        return handleErrorCode('UNKNOWN_ERROR');
    }
  }

  /// Handle Odoo specific errors
  static ApiError handleOdooError(dynamic error) {
    if (error is Map<String, dynamic>) {
      final code = error['code']?.toString();
      final message = error['message']?.toString();

      if (code == '100') {
        return handleErrorCode('SESSION_EXPIRED');
      } else if (code == '200') {
        return handleErrorCode('VALIDATION_ERROR', customMessage: message);
      } else if (code == '300') {
        return handleErrorCode('AUTHENTICATION_ERROR', customMessage: message);
      }
    }

    return handleErrorCode('SERVER_ERROR', customMessage: error.toString());
  }

  /// Show error to user
  static void showError(ApiError error) {
    // This would typically show a snackbar or dialog
    // For now, we'll just print the error
    appLogger.info('API Error: ${error.message}');
  }

  /// Log error for debugging
  static void logError(ApiError error) {
    appLogger.info('API Error Log: ${error.toString()}');
    appLogger.info('Error Data: ${error.data}');
    appLogger.info('Error Timestamp: ${error.timestamp}');
  }

  /// Get localized error message
  static String getLocalizedMessage(String code) {
    final language = TranslationService.instance.currentLanguage;
    final messages = _errorMessages[language] ?? _errorMessages['en']!;
    return messages[code] ?? messages['UNKNOWN_ERROR']!;
  }

  /// Check if error is network related
  static bool isNetworkError(ApiError error) {
    return error.type == ErrorType.network;
  }

  /// Check if error is authentication related
  static bool isAuthenticationError(ApiError error) {
    return error.type == ErrorType.authentication;
  }

  /// Check if error is validation related
  static bool isValidationError(ApiError error) {
    return error.type == ErrorType.validation;
  }

  /// Check if error is server related
  static bool isServerError(ApiError error) {
    return error.type == ErrorType.server;
  }
}
