import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/secure_config_service.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'core/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Push Notifications
    await NotificationService().initialize();
    
    // Initialize Secure Config (Remote Config for API keys)
    await SecureConfigService().initialize();
  } catch (e) {
    // Log the error but continue app execution
    // This prevents white screen on iOS if Firebase initialization fails
    debugPrint('❌ Initialization Error: $e');
  }
  
  // Request App Tracking Transparency permission (iOS)
  // We do this after initialization to ensure the app is ready to show the dialog
  // A small delay helps avoiding conflicts with splash screen
  Future.delayed(const Duration(seconds: 1), () async {
    try {
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('📊 ATT Status: $status');
    } catch (e) {
      debugPrint('❌ ATT Error: $e');
    }
  });

  runApp(
    const ProviderScope(
      child: HaliYikamaciApp(),
    ),
  );
}


class HaliYikamaciApp extends ConsumerWidget {
  const HaliYikamaciApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Halı Yıkamacı',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      
      // Localization Configuration
      locale: locale,
      supportedLocales: const [
        Locale('tr'), // Türkçe
        Locale('en'), // İngilizce
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
