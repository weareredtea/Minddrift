// lib/main.dart

// import 'package:animations/animations.dart'; // Not used in main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:minddrift/services/audio_service.dart';
import 'package:minddrift/widgets/auth_gate.dart';
import 'firebase_options.dart';
import 'screens/settings_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/store_screen.dart';
import 'screens/campaign_level_screen.dart';
import 'screens/gem_store_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/wave_spectrum_test.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'providers/purchase_provider_new.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_profile_provider.dart';
import 'services/analytics_service.dart';
import 'services/navigation_service.dart';
import 'services/room_service.dart';
import 'services/player_service.dart';
import 'services/game_service.dart';
import 'services/user_service.dart';
import 'services/profile_service.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // REFACTORED: Centralized service initialization here.
  _initializeServicesInBackground();

  runApp(const MyApp());
}

void _initializeServicesInBackground() async {
  try {
    await AudioService().preloadSounds();
    await AnalyticsService.initialize();
  } catch (e) {
    if (kDebugMode) {
      print('Background initialization error: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // REFACTORED: Cleaned up the provider list.
    // AuthProvider is the single source of truth for auth state.
    // FirebaseService now depends on AuthProvider.
    return MultiProvider(
      providers: [
        // 1. NavigationService for centralized navigation logic
        Provider<NavigationService>(create: (_) => NavigationService()),
        
        // 2. ProfileService (no dependencies)
        Provider<ProfileService>(create: (_) => ProfileService()),
        
        // 3. AuthProvider depends on ProfileService
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            profileService: context.read<ProfileService>(),
          ),
        ),
        
        // 4. UserProfileProvider depends on AuthProvider and ProfileService
        ChangeNotifierProxyProvider<AuthProvider, UserProfileProvider>(
          create: (context) => UserProfileProvider(
            profileService: context.read<ProfileService>(),
          ),
          update: (context, authProvider, previousProvider) {
            // When the user logs in or out, tell the provider to listen to the new UID.
            previousProvider?.listenToProfile(authProvider.uid);
            return previousProvider!;
          },
        ),
        
        // 5. RoomService for room creation and management
        ProxyProvider<AuthProvider, RoomService>(
          update: (_, authProvider, __) => RoomService(authProvider),
        ),
        
        // 6. PlayerService for player management
        ProxyProvider<AuthProvider, PlayerService>(
          update: (_, authProvider, __) => PlayerService(authProvider),
        ),
        
        // 7. GameService for game flow management
        ProxyProvider<AuthProvider, GameService>(
          update: (_, authProvider, __) => GameService(authProvider),
        ),
        
        // 8. UserService for user settings and current room tracking
        ProxyProvider<AuthProvider, UserService>(
          update: (_, authProvider, __) => UserService(authProvider),
        ),
        
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProviderNew()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Mind Drift',
            // Use static theme here - dynamic theme will be applied by Builder below
            theme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            
            // --- CORRECTED HOME ---
            home: Builder(
              builder: (context) {
                // This 'context' is now a descendant of MaterialApp
                // and has the required Localizations.
                return Theme(
                  data: AppTheme.getDarkTheme(context),
                  child: const AuthGate(),
                );
              },
            ),
            routes: {
              // --- CORRECTED ROUTES ---
              // Apply the same Builder pattern to all routes
              SettingsScreen.routeName: (context) => Builder(
                builder: (builderContext) => Theme(
                  data: AppTheme.getDarkTheme(builderContext),
                  child: const SettingsScreen(),
                ),
              ),
              TutorialScreen.routeName: (context) => Builder(
                builder: (builderContext) => Theme(
                  data: AppTheme.getDarkTheme(builderContext),
                  child: const TutorialScreen(),
                ),
              ),
              StoreScreen.routeName: (context) => Builder(
                builder: (builderContext) => Theme(
                  data: AppTheme.getDarkTheme(builderContext),
                  child: const StoreScreen(),
                ),
              ),
              CampaignLevelScreen.routeName: (context) => Builder(
                builder: (builderContext) => Theme(
                  data: AppTheme.getDarkTheme(builderContext),
                  child: const CampaignLevelScreen(),
                ),
              ),
              GemStoreScreen.routeName: (context) => Builder(
                builder: (builderContext) => Theme(
                  data: AppTheme.getDarkTheme(builderContext),
                  child: const GemStoreScreen(),
                ),
              ),
              QuestScreen.routeName: (context) => Builder(
                builder: (builderContext) => Theme(
                  data: AppTheme.getDarkTheme(builderContext),
                  child: const QuestScreen(),
                ),
              ),
              AnalyticsDashboardScreen.routeName: (context) => Builder(
                builder: (builderContext) => Theme(
                  data: AppTheme.getDarkTheme(builderContext),
                  child: const AnalyticsDashboardScreen(),
                ),
              ),
              if (kDebugMode)
                WaveSpectrumTestScreen.routeName: (context) => Builder(
                  builder: (builderContext) => Theme(
                    data: AppTheme.getDarkTheme(builderContext),
                    child: const WaveSpectrumTestScreen(),
                  ),
                ),
            },
          );
        },
      ),
    );
  }
}