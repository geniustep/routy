import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/services/storage_service.dart';
import 'package:routy/common/services/api_service.dart';
import 'package:routy/controllers/user_controller.dart';
import 'package:routy/app/app_router.dart';
import 'package:routy/utils/app_logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = StorageService.instance.getUser();
      setState(() {
        _userName = user?['name'] ?? 'Utilisateur';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final userController = Get.find<UserController>();

    // عرض dialog للتأكيد
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // 1. إنهاء الجلسة من الخادم
        await ApiService.instance.logout();

        // 2. مسح جميع البيانات المحلية باستخدام UserController
        final success = await userController.logout();

        // 3. الانتقال لصفحة تسجيل الدخول
        if (success) {
          appLogger.navigation(AppRouter.login, from: AppRouter.home);
          Get.offAllNamed(AppRouter.login);
        } else {
          Get.snackbar(
            'خطأ',
            'حدث خطأ أثناء تسجيل الخروج',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e, stackTrace) {
        appLogger.error('Logout error', error: e, stackTrace: stackTrace);

        // في حالة فشل API، نمسح البيانات المحلية فقط
        final success = await userController.logout();

        if (success) {
          appLogger.navigation(AppRouter.login, from: AppRouter.home);
          Get.offAllNamed(AppRouter.login);
        } else {
          Get.snackbar(
            'خطأ',
            'حدث خطأ أثناء تسجيل الخروج',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Routy',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AppRouter.settings);
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userName ?? 'Utilisateur',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Application de gestion des ventes, livraison et facturation',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Features Section
              const Text(
                'Fonctionnalités',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Feature Cards
              _buildFeatureCard(
                icon: Icons.shopping_cart,
                title: 'Gestion des Ventes',
                description: 'Enregistrer et suivre les ventes',
                color: Colors.green,
              ),

              const SizedBox(height: 12),

              _buildFeatureCard(
                icon: Icons.local_shipping,
                title: 'Livraisons',
                description: 'Gérer les livraisons et expéditions',
                color: Colors.orange,
              ),

              const SizedBox(height: 12),

              _buildFeatureCard(
                icon: Icons.receipt,
                title: 'Facturation',
                description: 'Créer et gérer les factures',
                color: Colors.purple,
              ),

              const SizedBox(height: 30),

              // Status Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statut de l\'application',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Connecté au serveur',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
