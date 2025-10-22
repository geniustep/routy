import 'package:get/get.dart';
import '../common/models/user_model.dart';
import '../services/storage_service.dart';
import '../utils/app_logger.dart';
import '../utils/pref_utils.dart';

/// User Controller using GetX
class UserController extends GetxController {
  // Observable user model
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);

  // Observable login status
  final RxBool _isLoggedIn = false.obs;

  // Observable loading state
  final RxBool _isLoading = false.obs;

  // Getters
  UserModel? get user {
    appLogger.debug('Getting user: ${_userModel.value?.name ?? "null"}');
    return _userModel.value;
  }

  bool get isLoggedIn {
    appLogger.debug('Getting isLoggedIn: ${_isLoggedIn.value}');
    return _isLoggedIn.value;
  }

  bool get isLoading => _isLoading.value;

  String get userName {
    final name = _userModel.value?.name ?? _userModel.value?.username ?? 'User';
    appLogger.debug('Getting userName: $name');
    return name;
  }

  @override
  void onInit() {
    super.onInit();
    appLogger.controller('UserController', 'onInit');
    _loadUserData();
  }

  /// تحميل بيانات المستخدم من التخزين
  void _loadUserData() {
    _isLoading.value = true;
    appLogger.controller(
      'UserController',
      '_loadUserData',
      data: 'Loading user data...',
    );

    try {
      // محاولة جلب من PrefUtils أولاً
      final prefUser = PrefUtils.user.value;
      if (prefUser != null) {
        _userModel.value = prefUser;
        _isLoggedIn.value = true;
        appLogger.controller(
          'UserController',
          '_loadUserData',
          data: {'source': 'PrefUtils', 'hasUser': true},
        );
        return;
      }

      // Fallback إلى StorageService
      final isLoggedIn = StorageService.instance.getIsLoggedIn();
      final userModel = StorageService.instance.getUser();

      _isLoggedIn.value = isLoggedIn;
      if (userModel != null) {
        _userModel.value = UserModel.fromJson(userModel);
      }

      appLogger.controller(
        'UserController',
        '_loadUserData',
        data: {
          'source': 'StorageService',
          'isLoggedIn': isLoggedIn,
          'hasUser': userModel != null,
        },
      );
    } catch (e, stackTrace) {
      appLogger.error(
        'Error loading user data',
        error: e,
        stackTrace: stackTrace,
      );
      _isLoggedIn.value = false;
      _userModel.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> setUser(UserModel user) async {
    appLogger.debug('📥 setUser called with user: ${user.toJson()}');
    appLogger.auth('Login', userId: user.uid?.toString() ?? 'null');

    _userModel.value = user;
    _isLoggedIn.value = true;

    appLogger.debug('💾 Saving user to storage...');

    // حفظ في PrefUtils + StorageService
    await PrefUtils.setUser(user);
    await StorageService.instance.saveUser(user.toJson());
    await StorageService.instance.saveIsLoggedIn(true);

    appLogger.debug(
      '✅ User saved. Current _userModel: ${_userModel.value?.toJson()}',
    );

    appLogger.controller(
      'UserController',
      'setUser',
      data: {
        'userId': user.uid,
        'userName': user.name,
        'username': user.username,
      },
    );
  }

  /// تسجيل الخروج
  Future<bool> logout() async {
    _isLoading.value = true;
    appLogger.auth('Logout', userId: _userModel.value?.uid.toString());

    try {
      // مسح من PrefUtils + StorageService
      await PrefUtils.clearAll();

      await StorageService.instance.clearUserData();

      _userModel.value = null;
      _isLoggedIn.value = false;
      appLogger.info('✅ User logged out successfully');

      return true;
    } catch (e, stackTrace) {
      appLogger.error('Error during logout', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// إعادة تحميل بيانات المستخدم
  @override
  void refresh() {
    appLogger.controller('UserController', 'refresh');
    _loadUserData();
  }

  /// مسح البيانات
  void clear() {
    appLogger.controller('UserController', 'clear');
    _userModel.value = null;
    _isLoggedIn.value = false;
  }
}
