# 📊 تصنيف مفصل للبيانات في مشروع Routy

## 🎯 نظرة عامة

بناءً على تحليل المشروع الحالي، تم تصنيف البيانات إلى 4 فئات رئيسية حسب نمط التحديث والاستخدام:

---

## 🔄 **الفئة الأولى: البيانات الفورية (Real-time Data)**

### **الخصائص:**
- **التحديث**: فوري عند كل تغيير
- **التخزين**: SharedPreferences فقط
- **TTL**: لا يوجد (تحديث فوري)
- **الحجم**: صغير (< 1KB)

### **البيانات المدرجة:**

#### **1. بيانات الجلسة (Session Data)**
```dart
class SessionData {
  String userId;           // معرف المستخدم
  String sessionId;        // معرف الجلسة
  List<String> permissions; // الصلاحيات
  DateTime lastActivity;   // آخر نشاط
  String language;         // اللغة
  String theme;           // المظهر
  bool isOnline;         // حالة الاتصال
}
```

#### **2. بيانات المبيعات النشطة (Active Sales)**
```dart
class ActiveSalesData {
  List<int> currentOrderIds;  // معرفات الطلبات الحالية
  Map<int, int> stockLevels;   // مستويات المخزون
  Map<int, String> paymentStatus; // حالة الدفع
  Map<int, String> deliveryStatus; // حالة التسليم
}
```

#### **3. بيانات العمليات (Operations)**
```dart
class OperationsData {
  List<String> pendingTasks;    // المهام المعلقة
  String syncStatus;           // حالة المزامنة
  int offlineQueueSize;        // حجم طابور العمل دون انترنت
  DateTime lastSync;           // آخر مزامنة
}
```

---

## ⏰ **الفئة الثانية: البيانات الدورية (Periodic Data)**

### **الخصائص:**
- **التحديث**: دوري (كل ساعة إلى 24 ساعة)
- **التخزين**: Hive Cache + SQLite
- **TTL**: متغير حسب النوع
- **الحجم**: متوسط (1KB - 1MB)

### **البيانات المدرجة:**

#### **1. بيانات العملاء (Partners)**
```dart
class PartnersData {
  // TTL: 24 ساعة
  List<PartnerModel> partners;
  Map<int, String> partnerNames;
  Map<int, String> partnerEmails;
  Map<int, String> partnerPhones;
  
  // TTL: 12 ساعة
  Map<int, double> creditLimits;
  Map<int, String> paymentTerms;
  Map<int, int> pricelistIds;
}
```

#### **2. بيانات المنتجات (Products)**
```dart
class ProductsData {
  // TTL: 12 ساعة
  List<ProductModel> products;
  Map<int, String> productNames;
  Map<int, String> productCodes;
  Map<int, double> productPrices;
  
  // TTL: 2 ساعة
  Map<int, int> stockLevels;
  Map<int, String> stockStatus;
  
  // TTL: 24 ساعة
  Map<int, String> categories;
  Map<int, String> productTypes;
}
```

#### **3. بيانات قوائم الأسعار (Pricelists)**
```dart
class PricelistsData {
  // TTL: 6 ساعات
  List<PricelistModel> pricelists;
  Map<int, String> pricelistNames;
  Map<int, List<PricelistItemModel>> pricelistItems;
  
  // TTL: 6 ساعات
  Map<int, List<DiscountRule>> discountRules;
  Map<int, List<Condition>> conditions;
}
```

---

## 📦 **الفئة الثالثة: البيانات الكاملة (Full Load Data)**

### **الخصائص:**
- **التحديث**: عند التطبيق الأول أو التحديث اليدوي
- **التخزين**: SQLite فقط
- **TTL**: لا يوجد (تخزين دائم)
- **الحجم**: كبير (> 1MB)

### **البيانات المدرجة:**

#### **1. البيانات الأساسية (Master Data)**
```dart
class MasterData {
  // جميع العملاء النشطين
  List<PartnerModel> allPartners;
  
  // جميع المنتجات النشطة
  List<ProductModel> allProducts;
  
  // جميع قوائم الأسعار
  List<PricelistModel> allPricelists;
  
  // جميع شروط الدفع
  List<PaymentTermModel> allPaymentTerms;
  
  // جميع الفئات
  List<CategoryModel> allCategories;
  
  // جميع الوحدات
  List<UnitModel> allUnits;
}
```

#### **2. البيانات المرجعية (Reference Data)**
```dart
class ReferenceData {
  // العملات
  List<CurrencyModel> currencies;
  
  // الضرائب
  List<TaxModel> taxes;
  
  // البلدان
  List<CountryModel> countries;
  
  // المحافظات
  List<StateModel> states;
  
  // المدن
  List<CityModel> cities;
}
```

---

## 🔍 **الفئة الرابعة: البيانات الجزئية (Partial Load Data)**

### **الخصائص:**
- **التحديث**: عند الطلب (On-demand)
- **التخزين**: Hive Cache + SQLite
- **TTL**: قصير (30 دقيقة - 2 ساعة)
- **الحجم**: متغير (100KB - 10MB)

### **البيانات المدرجة:**

#### **1. بيانات المبيعات (Sales Data)**
```dart
class SalesData {
  // آخر 100 طلب (20 في الصفحة)
  List<SaleOrderModel> recentOrders;
  
  // تفاصيل الطلب عند الطلب
  Map<int, SaleOrderModel> orderDetails;
  
  // سطور الطلب عند الطلب
  Map<int, List<SaleOrderLineModel>> orderLines;
  
  // تاريخ الطلبات (50 في الصفحة)
  List<SaleOrderModel> orderHistory;
}
```

#### **2. بيانات التحليلات (Analytics)**
```dart
class AnalyticsData {
  // ملخص المبيعات (آخر 30 يوم)
  SalesSummaryModel salesSummary;
  
  // رؤى العملاء (آخر 90 يوم)
  CustomerInsightsModel customerInsights;
  
  // أداء المنتجات (آخر 60 يوم)
  ProductPerformanceModel productPerformance;
  
  // إحصائيات لوحة التحكم (آخر 7 أيام)
  DashboardStatsModel dashboardStats;
}
```

---

## 🗄️ استراتيجية التخزين المؤقت المفصلة

### **الطبقة الأولى: SharedPreferences (إعدادات فورية)**
```dart
class ImmediateStorage {
  // بيانات الجلسة
  static const String userSession = 'user_session';
  static const String appSettings = 'app_settings';
  static const String lastSync = 'last_sync';
  static const String cacheVersion = 'cache_version';
  
  // إعدادات التطبيق
  static const String language = 'language';
  static const String theme = 'theme';
  static const String fontSize = 'font_size';
  static const String notifications = 'notifications';
}
```

### **الطبقة الثانية: Hive Cache (تخزين مؤقت ذكي)**
```dart
class SmartCache {
  // بيانات العملاء (TTL: 24 ساعة)
  static const String partnersCache = 'partners_cache';
  static const int partnersTTL = 24 * 60 * 60;
  
  // بيانات المنتجات (TTL: 12 ساعة)
  static const String productsCache = 'products_cache';
  static const int productsTTL = 12 * 60 * 60;
  
  // قوائم الأسعار (TTL: 6 ساعات)
  static const String pricelistsCache = 'pricelists_cache';
  static const int pricelistsTTL = 6 * 60 * 60;
  
  // لوحة التحكم (TTL: 1 ساعة)
  static const String dashboardCache = 'dashboard_cache';
  static const int dashboardTTL = 60 * 60;
  
  // بيانات المبيعات (TTL: 30 دقيقة)
  static const String salesCache = 'sales_cache';
  static const int salesTTL = 30 * 60;
}
```

### **الطبقة الثالثة: SQLite (تخزين دائم)**
```dart
class PersistentStorage {
  // جداول البيانات الأساسية
  static const String partnersTable = 'partners';
  static const String productsTable = 'products';
  static const String pricelistsTable = 'pricelists';
  static const String paymentTermsTable = 'payment_terms';
  
  // جداول البيانات التشغيلية
  static const String salesOrdersTable = 'sales_orders';
  static const String saleLinesTable = 'sale_lines';
  static const String syncQueueTable = 'sync_queue';
  
  // جداول البيانات المرجعية
  static const String categoriesTable = 'categories';
  static const String unitsTable = 'units';
  static const String currenciesTable = 'currencies';
  static const String taxesTable = 'taxes';
}
```

---

## 🚀 خطة التنفيذ المرحلية

### **المرحلة الأولى: تحسين التخزين المؤقت (أسبوع 1-2)**

#### **1. تحسين StorageService**
```dart
class EnhancedStorageService {
  // TTL Management
  Future<void> setCacheWithTTL(String key, dynamic value, int ttlSeconds);
  dynamic getCacheWithTTL(String key);
  Future<void> invalidateCache(String key);
  Future<void> clearExpiredCache();
  
  // Smart Cache
  Future<void> setSmartCache(String key, dynamic value, CacheType type);
  dynamic getSmartCache(String key, CacheType type);
  Future<void> updateCacheTTL(String key, int newTTL);
}
```

#### **2. تحسين Controllers**
```dart
class EnhancedPartnerController {
  // Cache Management
  Future<void> loadPartnersFromCache();
  Future<void> savePartnersToCache();
  Future<void> invalidatePartnersCache();
  
  // Smart Loading
  Future<void> loadPartnersSmart({bool forceRefresh = false});
  Future<void> loadPartnersPartial({int limit = 50, int offset = 0});
}
```

### **المرحلة الثانية: تحسين جلب البيانات (أسبوع 3-4)**

#### **1. تحسين API Calls**
```dart
class SmartDataFetcher {
  Future<List<T>> fetchDataWithPagination<T>({
    required String model,
    int pageSize = 50,
    int page = 1,
    bool useCache = true,
    int? cacheTTL,
  });
  
  // Background Sync
  Future<void> syncDataInBackground();
  Future<void> syncCriticalData();
  Future<void> syncNonCriticalData();
}
```

#### **2. تحسين Database Queries**
```dart
class OptimizedDatabaseService {
  // Indexes للأداء
  Future<void> createPerformanceIndexes();
  Future<void> optimizeQueries();
  
  // Full-text Search
  Future<List<T>> searchData<T>(String query, String table);
  Future<List<T>> searchDataAdvanced<T>(SearchCriteria criteria);
}
```

### **المرحلة الثالثة: تحسين المزامنة (أسبوع 5-6)**

#### **1. مزامنة ذكية**
```dart
class SmartSyncManager {
  // Sync Strategy
  Future<void> syncCriticalData(); // فوري
  Future<void> syncImportantData(); // كل ساعة
  Future<void> syncRegularData(); // كل 6 ساعات
  Future<void> syncBackgroundData(); // كل 24 ساعة
  
  // Conflict Resolution
  Future<void> resolveDataConflicts();
  Future<void> mergeDataChanges();
}
```

#### **2. Offline Support**
```dart
class OfflineManager {
  // Offline Queue
  Future<void> addToOfflineQueue(Operation operation);
  Future<void> processOfflineQueue();
  Future<void> syncOfflineChanges();
  
  // Data Validation
  Future<bool> validateOfflineData();
  Future<void> cleanInvalidData();
}
```

---

## 📈 النتائج المتوقعة

### **تحسين الأداء**
- **سرعة التحميل**: 50% أسرع
- **استهلاك الذاكرة**: 30% أقل
- **استهلاك البيانات**: 40% أقل
- **وقت الاستجابة**: أقل من ثانية

### **تحسين تجربة المستخدم**
- **التوفر**: 99% بدون انترنت
- **المزامنة**: تلقائية وذكية
- **البحث**: فوري ومتقدم
- **التحديث**: ذكي ومتدرج

---

## 🔧 التوصيات الفورية

### **1. إصلاحات سريعة (هذا الأسبوع)**
- ✅ إضافة TTL للـ Cache الحالي
- ✅ تحسين Pagination في Controllers
- ✅ إضافة Error Handling أفضل

### **2. تحسينات متوسطة (الشهر القادم)**
- 🔄 إعادة هيكلة StorageService
- 🔄 تحسين Database Queries
- 🔄 إضافة Background Sync

### **3. تحسينات متقدمة (الشهرين القادمين)**
- ⏳ إضافة Full-text Search
- ⏳ تحسين Offline Support
- ⏳ إضافة Advanced Analytics

---

*تم إنشاء هذا التصنيف في: ${DateTime.now().toIso8601String()}*
