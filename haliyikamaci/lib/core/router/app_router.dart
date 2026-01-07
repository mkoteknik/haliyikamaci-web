import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/splash/splash_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/firm_register_screen.dart';
import '../../presentation/auth/customer_register_screen.dart';
import '../../presentation/firm/firm_home_screen.dart';
import '../../presentation/customer/customer_home_screen.dart';
import '../../presentation/customer/customer_orders_screen.dart'; // [NEW]
import '../../presentation/chat/order_chat_screen.dart'; // [NEW]
import '../../presentation/auth/forgot_password_screen.dart'; // [NEW] Password Reset


/// App Router Configuration with Security Guards
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    
    // ==========================================
    // SECURITY REDIRECT - Route Guard
    // ==========================================
    redirect: (context, state) async {
      final currentPath = state.uri.path;
      
      // Splash ve login/register sayfalarına erişim serbest
      if (currentPath == '/' || 
          currentPath == '/login' || 
          currentPath == '/forgot-password' ||
          currentPath.startsWith('/register')) {
        return null;
      }
      
      // Demo mod kontrolü - SharedPreferences'tan oku
      try {
        final prefs = await SharedPreferences.getInstance();
        final isDemoMode = prefs.getBool('demo_mode') ?? false;
        final demoUserType = prefs.getString('demo_user_type');
        
        if (isDemoMode && demoUserType != null) {
          debugPrint('🎮 Router: Demo mod aktif - userType: $demoUserType');
          
          // Demo modda doğru panele erişim kontrolü
          if (currentPath.startsWith('/firm') && demoUserType == 'firm') {
            return null; // İzin ver
          }
          if (currentPath.startsWith('/customer') && demoUserType == 'customer') {
            return null; // İzin ver
          }
          
          // Yanlış panele erişim
          return demoUserType == 'firm' ? '/firm' : '/customer';
        }
      } catch (e) {
        debugPrint('Demo mode check error: $e');
      }
      
      // Diğer tüm rotalar için auth kontrolü
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        // Giriş yapmamış kullanıcı, login'e yönlendir
        return '/login';
      }
      
      try {
        // Kullanıcı tipini al
        final firestore = FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'haliyikamacimmbldatabase',
        );
        
        final userDoc = await firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (!userDoc.exists) {
          return '/login';
        }
        
        final userType = (userDoc.data()?['userType'] as String?) ?? 'customer';
        

        
        // Firma rotası kontrolü
        if (currentPath.startsWith('/firm')) {
          if (userType != 'firm' && userType != 'admin') {
            return '/customer';
          }
        }
        
        // Müşteri rotası kontrolü
        if (currentPath.startsWith('/customer')) {
          if (userType != 'customer' && userType != 'admin') {
            return '/firm';
          }
        }
        
      } catch (e) {
        // Hata durumunda login'e yönlendir
        debugPrint('Router Guard Error: $e');
        return '/login';
      }
      
      return null; // Erişime izin ver
    },
    
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register/firm',
        name: 'firmRegister',
        builder: (context, state) => const FirmRegisterScreen(),
      ),
      GoRoute(
        path: '/register/customer',
        name: 'customerRegister',
        builder: (context, state) => const CustomerRegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Firm Routes
      GoRoute(
        path: '/firm',
        name: 'firmHome',
        builder: (context, state) => const FirmHomeScreen(),
      ),

      // Customer Routes
      GoRoute(
        path: '/customer',
        name: 'customerHome',
        builder: (context, state) => const CustomerHomeScreen(),
        routes: [
          GoRoute(
            path: 'orders',
            name: 'customerOrders',
            builder: (context, state) => const CustomerOrdersScreen(),
          ),
        ],
      ),

      // Order Chat Route
      GoRoute(
        path: '/order-chat/:orderId',
        name: 'orderChat',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return OrderChatScreen(
            orderId: orderId,
            firmId: extra?['firmId'] ?? '',
            firmName: extra?['firmName'] ?? 'Firma',
          );
        },
      ),

    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.uri}'),
      ),
    ),
  );
}
