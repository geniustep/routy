import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:routy/app/app_router.dart';
import 'package:routy/common/services/api_service.dart';
import 'package:routy/services/storage_service.dart';
import 'package:routy/config/core/design_tokens.dart';
import 'package:routy/controllers/user_controller.dart';
import 'package:routy/controllers/partner_controller.dart';
import 'package:routy/utils/app_logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _particlesController;

  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _particlesAnimation;

  // Progress tracking
  late ValueNotifier<int> _progressNotifier;
  late ValueNotifier<String> _statusNotifier;
  late ValueNotifier<int> _modelProgressNotifier;
  late ValueNotifier<String> _modelStatusNotifier;

  // State variables
  String currentStatus = 'جاري التهيئة...';
  String currentModel = '';
  int progress = 0;
  int modelProgress = 0;
  bool isReady = false;

  // Retry mechanism
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const List<int> _retryDelays = [1000, 2000, 4000];

  // Progress weights for different steps
  static final Map<String, int> _progressWeights = {
    'initial': 2,
    'version_info': 3,
    'databases': 4,
    'settings': 3,
    'finalizing': 2,
  };

  // Status messages
  static final Map<String, String> _statusMessages = {
    'initial': 'جاري التهيئة...',
    'version_info': 'جاري تحميل معلومات الإصدار...',
    'databases': 'جاري تحميل قواعد البيانات...',
    'settings': 'جاري تحميل الإعدادات...',
    'finalizing': 'جاري إنهاء التحميل...',
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupProgressTracking();
    _setupGlobalErrorHandler();
    _initializeData();
  }

  void _setupAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _logoController.repeat(reverse: true);

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Particles animation
    _particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _particlesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particlesController);
  }

  void _setupProgressTracking() {
    _progressNotifier = ValueNotifier<int>(0);
    _statusNotifier = ValueNotifier<String>('جاري التهيئة...');
    _modelProgressNotifier = ValueNotifier<int>(0);
    _modelStatusNotifier = ValueNotifier<String>('');
  }

  void _setupGlobalErrorHandler() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        debugPrint('🚨 Flutter Error: ${details.exception}');
        debugPrint('📍 Stack: ${details.stack}');
      }
      if (mounted) {
        _handleUnexpectedError(details.exception, details.stack);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        debugPrint('🚨 Platform Error: $error');
        debugPrint('📍 Stack: $stack');
      }
      if (mounted) {
        _handleUnexpectedError(error, stack);
      }
      return true;
    };
  }

  Future<void> _initializeData() async {
    try {
      if (kDebugMode) {
        debugPrint('🚀 Starting data initialization...');
      }

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateProgress('initial', 5);
          }
        });
        await _loadVersionInfo();
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateProgress('version_info', 30);
            }
          });
        }
        await _loadAvailableDatabases();
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateProgress('databases', 60);
            }
          });
        }
        await _loadSettings();
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateProgress('settings', 80);
            }
          });
        }
        await _loadPartners();
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateProgress('partners', 90);
            }
          });
        }
        await _finishLoading();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error in _initializeData: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      await _handleRetry('$e\nDetails: ${_analyzeError(e)}');
    }
  }

  Future<void> _loadVersionInfo() async {
    try {
      if (!mounted) return;

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress(
              'معلومات الإصدار',
              0,
              'جاري تحميل معلومات الإصدار...',
            );
          }
        });
      }

      final response = await ApiService.instance.getVersionInfo();

      if (kDebugMode) {
        debugPrint(
          '🔍 Version Info Response: success=${response.success}, data=${response.data}, error=${response.error}',
        );
      }

      if (response.success) {
        if (mounted) {
          // Use SchedulerBinding to avoid build during frame
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateModelProgress(
                'معلومات الإصدار',
                100,
                'تم تحميل معلومات الإصدار بنجاح',
              );
            }
          });
        }
        if (kDebugMode) {
          debugPrint('✅ Version Info: ${response.data}');
        }
      } else {
        throw Exception('Failed to load version info');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading version info: $e');
      }
      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress(
              'معلومات الإصدار',
              0,
              'فشل في تحميل معلومات الإصدار',
            );
          }
        });
      }
      rethrow;
    }
  }

  Future<void> _loadAvailableDatabases() async {
    try {
      if (!mounted) return;

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress(
              'قواعد البيانات',
              0,
              'جاري تحميل قواعد البيانات...',
            );
          }
        });
      }

      final response = await ApiService.instance.getDatabases();

      if (response.success && response.data != null) {
        if (mounted) {
          // Use SchedulerBinding to avoid build during frame
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateModelProgress(
                'قواعد البيانات',
                80,
                'جاري حفظ قواعد البيانات...',
              );
            }
          });

          // حفظ قواعد البيانات
          await StorageService.instance.setString(
            'available_databases',
            jsonEncode(response.data!),
          );

          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateModelProgress(
                  'قواعد البيانات',
                  100,
                  'تم تحميل قواعد البيانات بنجاح',
                );
              }
            });
          }
        }
        if (kDebugMode) {
          debugPrint('✅ Available Databases: ${response.data}');
        }
      } else {
        throw Exception('Failed to load databases');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading databases: $e');
      }
      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress(
              'قواعد البيانات',
              0,
              'فشل في تحميل قواعد البيانات',
            );
          }
        });
      }
      rethrow;
    }
  }

  Future<void> _loadSettings() async {
    try {
      if (!mounted) return;

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress('الإعدادات', 0, 'جاري تحميل الإعدادات...');
          }
        });
      }

      // تحميل الإعدادات المحفوظة
      final isLoggedIn = StorageService.instance.getIsLoggedIn();
      final user = StorageService.instance.getUser();

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress('الإعدادات', 50, 'جاري معالجة الإعدادات...');
          }
        });

        if (isLoggedIn && user != null) {
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateModelProgress(
                  'الإعدادات',
                  100,
                  'تم تحميل الإعدادات بنجاح',
                );
              }
            });
          }
          if (kDebugMode) {
            debugPrint('✅ User is logged in: ${user['name']}');
          }
        } else {
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateModelProgress(
                  'الإعدادات',
                  100,
                  'تم تحميل الإعدادات بنجاح',
                );
              }
            });
          }
          if (kDebugMode) {
            debugPrint('ℹ️ User is not logged in');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading settings: $e');
      }
      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress('الإعدادات', 0, 'فشل في تحميل الإعدادات');
          }
        });
      }
      rethrow;
    }
  }

  Future<void> _loadPartners() async {
    try {
      if (!mounted) return;

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress('العملاء', 0, 'جاري تحميل العملاء...');
          }
        });
      }

      // تهيئة PartnerController
      final partnerController = Get.put(PartnerController());

      // تحميل العملاء من التخزين المحلي أولاً
      await partnerController.loadPartnersFromStorage();

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress(
              'العملاء',
              50,
              'تم تحميل العملاء من التخزين المحلي',
            );
          }
        });
      }

      // جلب العملاء الجدد من الخادم إذا لزم الأمر
      // TODO: تعطيل مؤقتاً حتى حل مشكلة endpoint
      // if (partnerController.shouldRefreshData()) {
      //   if (mounted) {
      //     SchedulerBinding.instance.addPostFrameCallback((_) {
      //       if (mounted) {
      //         _updateModelProgress(
      //           'العملاء',
      //           70,
      //           'جاري تحديث العملاء من الخادم...',
      //         );
      //       }
      //     });
      //   }

      //   await partnerController.fetchPartners(
      //     page: 1,
      //     pageSize: 50,
      //     showLoading: false,
      //   );
      // }

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress('العملاء', 100, 'تم تحميل العملاء بنجاح');
          }
        });
      }

      if (kDebugMode) {
        debugPrint(
          '✅ Partners loaded: ${partnerController.partners.length} items',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading partners: $e');
      }
      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateModelProgress('العملاء', 0, 'فشل في تحميل العملاء');
          }
        });
      }
      // لا نعيد رمي الخطأ هنا لأن تحميل العملاء ليس ضرورياً للبدء
      appLogger.warning(
        'Partners loading failed, continuing without partners: $e',
      );
    }
  }

  Future<void> _finishLoading() async {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        debugPrint('🏁 Finalizing loading process...');
      }

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateProgress('finalizing', 100);
          }
        });
      }

      // طباعة إحصائيات التحميل
      if (kDebugMode) {
        debugPrint('\n═══════════════════════════════════════════');
        debugPrint('📊 Loading Statistics:');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('✅ Version Info: Loaded');
        debugPrint('✅ Databases: Loaded');
        debugPrint('✅ Settings: Loaded');
        debugPrint('✅ Partners: Loaded');
        debugPrint('═══════════════════════════════════════════\n');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (kDebugMode) {
        debugPrint('🎉 Loading completed successfully!');
      }

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              isReady = true;
            });
          }
        });

        // الانتقال للصفحة التالية
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          final userController = Get.find<UserController>();

          // التحقق من حالة تسجيل الدخول
          if (userController.isLoggedIn && userController.user != null) {
            appLogger.navigation(AppRouter.dashboard, from: AppRouter.splash);
            Get.offAllNamed(AppRouter.dashboard);
          } else {
            appLogger.navigation(AppRouter.login, from: AppRouter.splash);
            Get.offAllNamed(AppRouter.login);
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error in _finishLoading: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  void _updateModelProgress(String modelName, int progress, String status) {
    if (!mounted) return;

    try {
      currentModel = modelName;
      modelProgress = progress.clamp(0, 100);

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _modelProgressNotifier.value = modelProgress;
            _modelStatusNotifier.value = status;
          }
        });
      }

      if (kDebugMode) {
        debugPrint('📊 Model Progress: $modelName - $modelProgress% - $status');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating model progress: $e');
      }
    }
  }

  void _updateProgress(String step, [dynamic customProgress]) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        debugPrint('🔄 Updating progress for step: $step');
      }

      int totalWeight = _progressWeights.values.isNotEmpty
          ? _progressWeights.values.reduce((a, b) => a + b)
          : 100;
      int completedWeight = 0;

      final progressKeys = _progressWeights.keys.toList();
      final stepIndex = progressKeys.indexOf(step);

      _progressWeights.forEach((key, weight) {
        final keyIndex = progressKeys.indexOf(key);
        if (keyIndex != -1 && keyIndex <= stepIndex) {
          completedWeight += weight;
        }
      });

      if (step != 'finalizing') {
        final stepWeight = _progressWeights[step];
        if (stepWeight != null) {
          completedWeight += stepWeight;
        }
      }

      if (customProgress != null) {
        progress = customProgress;
      } else {
        if (totalWeight > 0) {
          progress = ((completedWeight / totalWeight) * 100).round();
        } else {
          progress = 0;
        }
      }

      progress = progress.clamp(0, 100);

      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _progressNotifier.value = progress;
            currentStatus = _statusMessages[step] ?? 'جاري المعالجة...';
            _statusNotifier.value = currentStatus;
          }
        });
      }

      if (kDebugMode) {
        debugPrint('📊 Progress: $progress% - $currentStatus');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error in _updateProgress: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }

      progress = customProgress ?? 0;
      progress = progress.clamp(0, 100);
      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _progressNotifier.value = progress;
            currentStatus = 'جاري المعالجة...';
            _statusNotifier.value = currentStatus;
          }
        });
      }
    }
  }

  Future<void> _handleRetry(String error) async {
    if (!mounted) return;

    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = _retryDelays[_retryCount - 1];

      if (kDebugMode) {
        debugPrint('🔄 Retry attempt $_retryCount/$_maxRetries');
        debugPrint('⏱️  Waiting ${delay ~/ 1000} seconds before retry...');
        debugPrint('🔍 Previous error: $error');
      }

      currentStatus =
          'إعادة المحاولة ($_retryCount/$_maxRetries) خلال ${delay ~/ 1000} ثانية...';
      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _statusNotifier.value = currentStatus;
          }
        });
      }

      await Future.delayed(Duration(milliseconds: delay));

      try {
        if (kDebugMode) {
          debugPrint('🔄 Starting retry attempt $_retryCount...');
        }
        await _initializeData();
        if (kDebugMode) {
          debugPrint('✅ Retry successful!');
        }
        _retryCount = 0;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ Retry $_retryCount failed: $e');
          debugPrint('📍 Stack trace: $stackTrace');
        }
        await _handleRetry('$e\nDetails: ${_analyzeError(e)}');
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          '❌ Max retries reached ($_maxRetries). Showing error dialog.',
        );
      }
      if (mounted) {
        _showErrorDialog(error);
      }
    }
  }

  void _handleUnexpectedError(dynamic error, StackTrace? stackTrace) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        debugPrint('🚨 Unexpected Error Caught: $error');
        debugPrint('📍 Stack Trace: $stackTrace');
      }

      // محاولة استعادة التطبيق
      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateProgress('recovery', 50);
            _continueWithBasicData();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error in error handler: $e');
      }
      if (mounted) {
        // Use SchedulerBinding to avoid build during frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showSimpleErrorDialog();
          }
        });
      }
    }
  }

  void _continueWithBasicData() {
    if (!mounted) return;

    if (kDebugMode) {
      debugPrint('🚀 Continuing with basic data only...');
    }
    if (mounted) {
      // Use SchedulerBinding to avoid build during frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateProgress('basic_data', 20);
        }
      });
    }

    Future(() async {
      try {
        if (mounted) {
          await _loadVersionInfo();
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateProgress('basic_data', 40);
              }
            });
          }
          await _loadAvailableDatabases();
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateProgress('basic_data', 60);
              }
            });
          }
          await _loadSettings();
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateProgress('basic_data', 100);
              }
            });
          }
        }

        if (kDebugMode) {
          debugPrint('✅ Basic data loaded successfully');
        }
        if (mounted) {
          appLogger.navigation(AppRouter.login, from: AppRouter.splash);
          Get.offAllNamed(AppRouter.login);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to load basic data: $e');
        }
        if (mounted) {
          _showSimpleErrorDialog();
        }
      }
    });
  }

  String _analyzeError(dynamic error) {
    String errorStr = error.toString();

    if (errorStr.contains('Null check operator used on a null value')) {
      return 'Null Safety Error: محاولة الوصول لقيمة null';
    } else if (errorStr.contains('Failed to load version info')) {
      return 'Version Info Error: فشل في تحميل معلومات الإصدار';
    } else if (errorStr.contains('Failed to load databases')) {
      return 'Databases Error: فشل في تحميل قواعد البيانات';
    } else if (errorStr.contains('Failed to load settings')) {
      return 'Settings Error: فشل في تحميل الإعدادات';
    } else if (errorStr.contains('SocketException')) {
      return 'Network Error: مشكلة في الاتصال بالشبكة';
    } else if (errorStr.contains('TimeoutException')) {
      return 'Timeout Error: انتهت مهلة الاتصال';
    } else {
      return 'Unknown Error: خطأ غير معروف - ${error.runtimeType}';
    }
  }

  void _showErrorDialog(String error) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('خطأ في التحميل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('فشل تحميل البيانات بعد عدة محاولات.'),
            const SizedBox(height: 10),
            Text(
              'التفاصيل: $error',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _retryCount = 0;
              _initializeData();
            },
            child: const Text('إعادة المحاولة'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              appLogger.navigation(AppRouter.login, from: AppRouter.splash);
              Get.offAllNamed(AppRouter.login);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showSimpleErrorDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ في التطبيق'),
        content: const Text(
          'حدث خطأ غير متوقع في التطبيق.\nيرجى إعادة تشغيل التطبيق.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _initializeData();
            },
            child: const Text('إعادة المحاولة'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              appLogger.navigation(AppRouter.login, from: AppRouter.splash);
              Get.offAllNamed(AppRouter.login);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    DesignTokens.darkBackgroundColor,
                    DesignTokens.darkPrimaryColor,
                    DesignTokens.darkSecondaryColor,
                  ]
                : [
                    DesignTokens.backgroundColor,
                    DesignTokens.primaryColor,
                    DesignTokens.secondaryColor,
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particlesAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BackgroundPainter(_particlesAnimation.value),
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Animated Logo
                  Center(
                    child: AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _logoRotationAnimation.value,
                            child: Opacity(
                              opacity: _logoOpacityAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isDark ? Colors.white : Colors.black)
                                              .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                    BoxShadow(
                                      color:
                                          (isDark
                                                  ? DesignTokens
                                                        .darkPrimaryColor
                                                  : DesignTokens.primaryColor)
                                              .withValues(alpha: 0.2),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundColor: isDark
                                      ? DesignTokens.darkSurfaceColor
                                      : Colors.white,
                                  radius:
                                      MediaQuery.of(context).size.width * 0.12,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      "assets/logo/logo_routy.png",
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.route_rounded,
                                              size: 50,
                                              color: isDark
                                                  ? DesignTokens
                                                        .darkPrimaryColor
                                                  : DesignTokens.primaryColor,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Progress section - Fixed layout to prevent overflow
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // Main progress bar
                          ValueListenableBuilder<int>(
                            valueListenable: _progressNotifier,
                            builder: (context, progressValue, child) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                child: LinearProgressIndicator(
                                  value: progressValue / 100,
                                  backgroundColor:
                                      (isDark ? Colors.white : Colors.black)
                                          .withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progressValue == 100
                                        ? Colors.green
                                        : (isDark
                                              ? DesignTokens.darkPrimaryColor
                                              : DesignTokens.primaryColor),
                                  ),
                                  minHeight: 6,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          // Progress percentage
                          ValueListenableBuilder<int>(
                            valueListenable: _progressNotifier,
                            builder: (context, progressValue, child) {
                              return AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: progressValue == 100
                                      ? Colors.green
                                      : (isDark ? Colors.white : Colors.black),
                                  fontSize: progressValue == 100 ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                child: Text("$progressValue %"),
                              );
                            },
                          ),

                          const SizedBox(height: 6),

                          // Status message
                          ValueListenableBuilder<String>(
                            valueListenable: _statusNotifier,
                            builder: (context, status, child) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.3),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  status,
                                  key: ValueKey(status),
                                  style: TextStyle(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),

                          // Model progress section
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String>(
                            valueListenable: _modelStatusNotifier,
                            builder: (context, modelStatus, child) {
                              if (modelStatus.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                children: [
                                  // Model title
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (isDark ? Colors.white : Colors.black)
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            (isDark
                                                    ? Colors.white
                                                    : Colors.black)
                                                .withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      currentModel,
                                      style: TextStyle(
                                        color:
                                            (isDark
                                                    ? Colors.white
                                                    : Colors.black)
                                                .withValues(alpha: 0.9),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // Model progress bar
                                  ValueListenableBuilder<int>(
                                    valueListenable: _modelProgressNotifier,
                                    builder:
                                        (context, modelProgressValue, child) {
                                          return AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: LinearProgressIndicator(
                                              value: modelProgressValue / 100,
                                              backgroundColor:
                                                  (isDark
                                                          ? Colors.white
                                                          : Colors.black)
                                                      .withValues(alpha: 0.2),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    modelProgressValue == 100
                                                        ? Colors.blue
                                                        : Colors.cyan,
                                                  ),
                                              minHeight: 3,
                                            ),
                                          );
                                        },
                                  ),

                                  const SizedBox(height: 4),

                                  // Model progress percentage
                                  ValueListenableBuilder<int>(
                                    valueListenable: _modelProgressNotifier,
                                    builder:
                                        (context, modelProgressValue, child) {
                                          return AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            style: TextStyle(
                                              color: modelProgressValue == 100
                                                  ? Colors.blue
                                                  : Colors.cyan,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            child: Text(
                                              "$modelProgressValue %",
                                            ),
                                          );
                                        },
                                  ),

                                  const SizedBox(height: 3),

                                  // Model status
                                  ValueListenableBuilder<String>(
                                    valueListenable: _modelStatusNotifier,
                                    builder: (context, modelStatus, child) {
                                      return AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 0.2),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          modelStatus,
                                          key: ValueKey(modelStatus),
                                          style: TextStyle(
                                            color:
                                                (isDark
                                                        ? Colors.white
                                                        : Colors.black)
                                                    .withValues(alpha: 0.8),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // App info - Reduced font sizes to prevent overflow
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      "Powered By Routy",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 1500),
                    child: Text(
                      "V 1.0.0",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _particlesController.dispose();

    // Dispose ValueNotifiers safely
    _progressNotifier.dispose();
    _statusNotifier.dispose();
    _modelProgressNotifier.dispose();
    _modelStatusNotifier.dispose();

    super.dispose();
  }
}

// Background Painter for animated particles
class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // رسم دوائر متحركة في الخلفية
    final offset1 = (animationValue * 2 * 3.14159) % (2 * 3.14159);
    final offset2 = ((animationValue * 2 * 3.14159) + 2.094) % (2 * 3.14159);
    final offset3 = ((animationValue * 2 * 3.14159) + 4.188) % (2 * 3.14159);

    canvas.drawCircle(
      Offset(
        size.width * 0.2 + 20 * sin(offset1),
        size.height * 0.3 + 20 * cos(offset1),
      ),
      100,
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.8 + 30 * sin(offset2),
        size.height * 0.7 + 30 * cos(offset2),
      ),
      150,
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.5 + 15 * sin(offset3),
        size.height * 0.1 + 15 * cos(offset3),
      ),
      80,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
