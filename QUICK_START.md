# 🚀 Quick Start - Dashboard V2

## خطوات التشغيل السريعة

### 1️⃣ تثبيت المكتبات
```bash
flutter pub get
```

### 2️⃣ إعادة توليد ملفات الترجمة (اختياري)
```bash
flutter gen-l10n
```

### 3️⃣ تشغيل التطبيق
```bash
flutter run
```

### 4️⃣ الوصول إلى Dashboard V2

#### من Settings:
أضف هذا الكود في `settings_screen.dart`:
```dart
ListTile(
  leading: Icon(Icons.dashboard_customize, color: Colors.blue),
  title: Text('Enhanced Dashboard V2'),
  subtitle: Text('Try the new dashboard'),
  trailing: Chip(
    label: Text('NEW', style: TextStyle(fontSize: 10)),
    backgroundColor: Colors.green,
    labelStyle: TextStyle(color: Colors.white),
  ),
  onTap: () => Get.toNamed(AppRouter.dashboardV2),
)
```

#### من Dashboard الحالي:
أضف FloatingActionButton:
```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => Get.toNamed(AppRouter.dashboardV2),
  icon: Icon(Icons.auto_awesome),
  label: Text('Try V2'),
),
```

#### جعله الافتراضي:
في `splash_controller.dart`، غيّر:
```dart
// من:
Get.offAllNamed(AppRouter.dashboard);

// إلى:
Get.offAllNamed(AppRouter.dashboardV2);
```

---

## 🎨 معاينة المزايا

### KPI Cards
عرض 3 بطاقات رئيسية:
- مبيعات اليوم
- مبيعات الأسبوع
- مبيعات الشهر

### Sales Chart
رسم بياني تفاعلي لآخر 7 أيام

### Quick Actions
8 إجراءات سريعة بتصميم Grid

### Recent Activity
آخر 5 أنشطة بتصميم Timeline

---

## 🔧 التخصيص السريع

### تغيير عدد الأيام في Chart:
```dart
// في DashboardController._generateMockStats()
salesTrend: List.generate(14, (index) {  // بدلاً من 7
  // ...
});
```

### تغيير عدد Quick Actions:
```dart
// في DashboardController.quickActions
// احذف أو أضف QuickActionData حسب الحاجة
```

### تغيير الألوان:
```dart
// في DashboardController.kpiCards
KpiCardData(
  color: Colors.purple,  // غيّر اللون
)
```

---

## 📱 الاختبار

### على Mobile:
```bash
flutter run -d <device-id>
```

### على Web:
```bash
flutter run -d chrome
```

### على Desktop:
```bash
flutter run -d windows  # أو macos أو linux
```

---

## ✅ التحقق من التثبيت

### 1. تحقق من المكتبات:
```bash
flutter pub deps | grep -E "fl_chart|shimmer"
```

يجب أن ترى:
```
├── fl_chart 0.69.0
├── shimmer 3.0.0
```

### 2. تحقق من الملفات:
```bash
ls -la lib/screens/dashboard/dashboard_v2_screen.dart
ls -la lib/controllers/dashboard_controller.dart
ls -la lib/bindings/dashboard_binding.dart
ls -la lib/screens/dashboard/widgets/dashboard_widgets.dart
```

### 3. تحقق من Routes:
افتح `lib/app/app_router.dart` وتأكد من وجود:
```dart
static const String dashboardV2 = '/dashboard/v2';
```

---

## 🐛 حل المشاكل الشائعة

### خطأ: "DashboardController not found"
```dart
// تأكد من إضافة Binding في Routes:
GetPage(
  name: dashboardV2,
  page: () => const DashboardV2Screen(),
  binding: DashboardBinding(),  // مهم!
)
```

### خطأ: "Translation key not found"
```bash
# أعد توليد ملفات الترجمة:
flutter gen-l10n
```

### خطأ: "Package not found"
```bash
# نظف وأعد التثبيت:
flutter clean
flutter pub get
```

### Chart لا يظهر:
```bash
# تأكد من إضافة fl_chart:
flutter pub add fl_chart
```

---

## 📚 المراجع

- [fl_chart Documentation](https://pub.dev/packages/fl_chart)
- [shimmer Documentation](https://pub.dev/packages/shimmer)
- [GetX Documentation](https://pub.dev/packages/get)

---

**Ready to go! 🚀**
