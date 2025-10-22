import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Logger محسّن لتطبيق Routy
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;

  /// تهيئة Logger
  void initialize({Level level = Level.debug, bool enabled = true}) {
    _logger = Logger(
      filter: _AppLogFilter(enabled: enabled),
      printer: _AppLogPrinter(),
      output: _AppLogOutput(),
      level: level,
    );
  }

  /// Get logger instance
  Logger get logger => _logger;

  // ==================== Logging Methods ====================

  /// Log معلومات عادية (للتتبع العام)
  void trace(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log معلومات Debug (للتطوير)
  void debug(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log معلومات عامة
  void info(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log تحذيرات
  void warning(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log أخطاء
  void error(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log أخطاء خطيرة (Fatal)
  void fatal(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // ==================== Specialized Logging ====================

  /// Log API Request
  void apiRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
  }) {
    info('🌐 API Request: $method $endpoint', error: data);
  }

  /// Log API Response
  void apiResponse(String endpoint, {int? statusCode, dynamic data}) {
    info('✅ API Response: $endpoint [$statusCode]', error: data);
  }

  /// Log API Error
  void apiError(String endpoint, {dynamic error, StackTrace? stackTrace}) {
    this.error('❌ API Error: $endpoint', error: error, stackTrace: stackTrace);
  }

  /// Log Navigation
  void navigation(String route, {String? from}) {
    debug('🧭 Navigation: ${from != null ? "$from → " : ""}$route');
  }

  /// Log User Action
  void userAction(String action, {Map<String, dynamic>? details}) {
    info('👤 User Action: $action', error: details);
  }

  /// Log Storage Operation
  void storage(String operation, {String? key, dynamic value}) {
    debug(
      '💾 Storage: $operation${key != null ? " [$key]" : ""}',
      error: value,
    );
  }

  /// Log Authentication
  void auth(String action, {String? userId}) {
    info('🔐 Auth: $action${userId != null ? " [User: $userId]" : ""}');
  }

  /// Log Performance
  void performance(String operation, Duration duration) {
    debug('⚡ Performance: $operation took ${duration.inMilliseconds}ms');
  }

  /// Log GetX Controller
  void controller(String controllerName, String action, {dynamic data}) {
    debug('🎮 Controller: $controllerName.$action', error: data);
  }

  /// Log Database Operation
  void database(String operation, {String? table, dynamic data}) {
    debug(
      '🗄️ Database: $operation${table != null ? " [$table]" : ""}',
      error: data,
    );
  }
}

// ==================== Custom Log Filter ====================

class _AppLogFilter extends LogFilter {
  final bool enabled;

  _AppLogFilter({this.enabled = true});

  @override
  bool shouldLog(LogEvent event) {
    if (!enabled) return false;

    // في production، نعرض فقط Warning وما فوق
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }

    // في debug، نعرض كل شيء
    return true;
  }
}

// ==================== Custom Log Printer ====================

class _AppLogPrinter extends LogPrinter {
  static final Map<Level, String> _levelEmojis = {
    Level.trace: '📍',
    Level.debug: '🐛',
    Level.info: 'ℹ️',
    Level.warning: '⚠️',
    Level.error: '❌',
    Level.fatal: '💀',
  };

  static final Map<Level, String> _levelNames = {
    Level.trace: 'TRACE',
    Level.debug: 'DEBUG',
    Level.info: 'INFO',
    Level.warning: 'WARN',
    Level.error: 'ERROR',
    Level.fatal: 'FATAL',
  };

  @override
  List<String> log(LogEvent event) {
    final emoji = _levelEmojis[event.level] ?? '';
    final levelName = _levelNames[event.level] ?? '';
    final time = DateTime.now().toString().split(' ')[1].substring(0, 12);
    final message = event.message;
    final error = event.error;
    final stackTrace = event.stackTrace;

    final List<String> output = [];

    // سطر الرسالة الرئيسي
    output.add('$emoji [$levelName] [$time] $message');

    // إذا كان هناك error
    if (error != null) {
      output.add('└─ Error: $error');
    }

    // إذا كان هناك stackTrace
    if (stackTrace != null) {
      final traces = stackTrace.toString().split('\n');
      for (var i = 0; i < traces.length && i < 5; i++) {
        output.add('  ${traces[i]}');
      }
    }

    return output;
  }
}

// ==================== Custom Log Output ====================

class _AppLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      // في debug mode، نطبع في Console
      if (kDebugMode) {
        // ignore: avoid_print
        print(line);
      }

      // يمكن إضافة هنا: حفظ في ملف، إرسال إلى Analytics، إلخ
    }
  }
}

// ==================== Global Instance ====================

/// Global logger instance
final appLogger = AppLogger();

/// Shorthand methods
void logTrace(dynamic message, {dynamic error, StackTrace? stackTrace}) {
  appLogger.trace(message, error: error, stackTrace: stackTrace);
}

void logDebug(dynamic message, {dynamic error, StackTrace? stackTrace}) {
  appLogger.debug(message, error: error, stackTrace: stackTrace);
}

void logInfo(dynamic message, {dynamic error, StackTrace? stackTrace}) {
  appLogger.info(message, error: error, stackTrace: stackTrace);
}

void logWarning(dynamic message, {dynamic error, StackTrace? stackTrace}) {
  appLogger.warning(message, error: error, stackTrace: stackTrace);
}

void logError(dynamic message, {dynamic error, StackTrace? stackTrace}) {
  appLogger.error(message, error: error, stackTrace: stackTrace);
}

void logFatal(dynamic message, {dynamic error, StackTrace? stackTrace}) {
  appLogger.fatal(message, error: error, stackTrace: stackTrace);
}
