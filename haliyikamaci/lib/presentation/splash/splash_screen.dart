import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/otp_session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo animasyonları
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Preloader animasyonu
  late AnimationController _loaderController;

  // Shimmer efekti
  late AnimationController _shimmerController;
  
  final OtpSessionService _otpSessionService = OtpSessionService();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkAuthAndNavigate();
  }

  void _initAnimations() {
    // Logo animasyonu - scale ve fade in
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Preloader döngü animasyonu
    _loaderController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Shimmer efekti
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Animasyonları başlat
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loaderController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    debugPrint('🚀 Splash: _checkAuthAndNavigate başladı');
    
    // Animasyonların gösterilmesi için minimum bekleme
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) {
      debugPrint('❌ Splash: Widget artık mounted değil');
      return;
    }
    
    try {
      debugPrint('🔍 Splash: Firebase currentUser kontrol ediliyor...');
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('👤 Splash: User = ${user?.uid ?? "null"}');
      
      if (user != null) {
        // Kullanıcı oturum açmış, 12 saat kontrolü yap
        debugPrint('⏰ Splash: OTP bypass kontrolü yapılıyor...');
        final shouldBypass = await _otpSessionService.shouldBypassOtp();
        debugPrint('⏰ Splash: shouldBypass = $shouldBypass');
        
        if (shouldBypass) {
          // 12 saat dolmamış, direkt panele yönlendir
          debugPrint('➡️ Splash: Panel yönlendirmesi yapılıyor...');
          await _navigateToUserPanel(user.uid);
          return;
        }
      }
      
      // Oturum yok veya 12 saat dolmuş, login'e git
      debugPrint('🔐 Splash: Login ekranına yönlendiriliyor...');
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('❌ Splash: Hata oluştu: $e');
      // Hata durumunda login'e git
      if (mounted) {
        context.go('/login');
      }
    }
  }
  
  Future<void> _navigateToUserPanel(String uid) async {
    try {
      debugPrint('🔄 Splash: _navigateToUserPanel başladı, uid: $uid');
      
      // Kullanıcı tipini veritabanından al - DOĞRU database ID kullan
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'haliyikamacimmbldatabase',
      );
      
      final userDoc = await firestore
          .collection('users')
          .doc(uid)
          .get();
      
      debugPrint('📄 Splash: userDoc.exists = ${userDoc.exists}');
      
      if (!mounted) return;
      
      if (userDoc.exists) {
        final userType = userDoc.data()?['userType'] as String?;
        debugPrint('👤 Splash: userType = $userType');
        
        switch (userType) {
          case 'firm':
            context.go('/firm');
            break;
          case 'admin':
            debugPrint('🚫 Splash: Admin girişi engellendi (Web paneli kullanın)');
            await FirebaseAuth.instance.signOut();
            if (mounted) context.go('/login');
            break;
          default:
            context.go('/customer');
        }
      } else {
        // Kullanıcı kaydı yok, login'e git
        debugPrint('⚠️ Splash: Kullanıcı kaydı yok, login\'e yönlendiriliyor');
        context.go('/login');
      }
    } catch (e) {
      debugPrint('❌ Splash: _navigateToUserPanel hatası: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3867), // primaryBlue
              Color(0xFF0D1F3C), // Daha koyu mavi
              Color(0xFF061222), // En koyu
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Logo Container with Glow Effect
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A90D9).withValues(alpha: 0.5),
                              blurRadius: 50,
                              spreadRadius: 15,
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.1),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to icon if logo not found
                                return const Icon(
                                  Icons.local_laundry_service,
                                  size: 100,
                                  color: AppTheme.primaryBlue,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // App Name with Shimmer Effect
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: const [
                          Colors.white,
                          Color(0xFF4A90D9),
                          Colors.white,
                        ],
                        stops: [
                          _shimmerController.value - 0.3,
                          _shimmerController.value,
                          _shimmerController.value + 0.3,
                        ].map((s) => s.clamp(0.0, 1.0)).toList(),
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Halı Yıkamacı',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Subtitle
              FadeTransition(
                opacity: _logoOpacity,
                child: const Text(
                  'Firma Rehberi',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8BB8E8),
                    letterSpacing: 3,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Custom Animated Preloader
              _buildCustomLoader(),

              const SizedBox(height: 24),

              // Loading text
              FadeTransition(
                opacity: _logoOpacity,
                child: const Text(
                  'Yükleniyor...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6A9BD1),
                    letterSpacing: 2,
                  ),
                ),
              ),

              const Spacer(),

              // Bottom branding
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFF4A90D9),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A6B8A),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Turkey Map Animation Loader
  Widget _buildCustomLoader() {
    return SizedBox(
      width: 250, // Harita genişliği
      height: 120,
      child: AnimatedBuilder(
        animation: _loaderController,
        builder: (context, child) {
          return Stack(
            children: [
              // 1. Turkey Map Background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/images/turkey_map.png',
                    fit: BoxFit.contain,
                    color: Colors.white.withAlpha(150),
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
              ),

              // 2. Appearing Pins (East to West)
              ..._buildPins(),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPins() {
    final pins = <Widget>[];
    
    // Define pin positions (left %, top %)
    // Ordered from EAST (Right) to WEST (Left)
    final positions = [
      const Offset(0.85, 0.45), // Van (East)
      const Offset(0.70, 0.30), // Trabzon/Erzurum (North East)
      const Offset(0.60, 0.65), // Adana/Gaziantep (South East)
      const Offset(0.50, 0.40), // Ankara (Center)
      const Offset(0.35, 0.70), // Antalya (South)
      const Offset(0.25, 0.25), // Istanbul (North West)
      const Offset(0.15, 0.55), // Izmir (West)
    ];

    for (int i = 0; i < positions.length; i++) {
        // Show pin if progress is past a threshold
        final itemsCount = positions.length;
        final threshold = (i + 1) / (itemsCount + 2); // Spread out over animation time
        
        if (_loaderController.value > threshold) {
           final double relativeProgress = (_loaderController.value - threshold) * 5; // fast pop effect
           final double scale = relativeProgress.clamp(0.0, 1.0);
           
           if (scale > 0) {
             pins.add(
               Positioned(
                 left: positions[i].dx * 250 - 10, // Center the 20px icon
                 top: positions[i].dy * 120 - 20, // Pin tip at location approximately
                 child: Transform.scale(
                   scale: Curves.elasticOut.transform(scale),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Container(
                         width: 24, // Slightly larger for visibility
                         height: 24,
                         padding: const EdgeInsets.all(2),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black.withAlpha(50),
                               blurRadius: 4,
                               offset: const Offset(0, 2),
                             ),
                           ],
                         ),
                         child: ClipOval(
                           child: Image.asset(
                             'assets/images/icon.png',
                             fit: BoxFit.cover,
                           ),
                         ),
                       ),
                       // Pin Triangle Pointer
                       ClipPath(
                         clipper: _TriangleClipper(),
                         child: Container(
                           width: 8,
                           height: 6,
                           color: Colors.white,
                         ),
                       ),
                     ],
                   ),
                 ),
               )
             );
           }
        }
    }
    return pins;
  }
}

// Simple Triangle Clipper for the pin effect
class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
