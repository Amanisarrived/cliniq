import 'package:cliniq/providers/ad_provider.dart';
import 'package:cliniq/providers/app_config_provider.dart';
import 'package:cliniq/providers/diary_provider.dart';
import 'package:cliniq/providers/news_provider.dart';
import 'package:cliniq/providers/prescription_provider.dart';
import 'package:cliniq/providers/purchase_provider.dart';
import 'package:cliniq/providers/reminders_provider.dart';
import 'package:cliniq/providers/scanner_provider.dart';
import 'package:cliniq/providers/sickeness_guide_provider.dart';
import 'package:cliniq/services/ad_service.dart';
import 'package:cliniq/services/notification_service.dart';
import 'package:cliniq/services/purchase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/router.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ✅ RevenueCat — Remote Config se key aayegi
  // Double init nahi hoga
  final user = FirebaseAuth.instance.currentUser;
  await PurchaseService.instance.initialize(user?.uid);

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool(AppConstants.keyThemeMode) ?? false;

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  await NotificationService.instance.initialize();
  await AdService.instance.initialize();

  runApp(CliniqApp(isDark: isDark));
}

class CliniqApp extends StatefulWidget {
  final bool isDark;
  const CliniqApp({super.key, required this.isDark});

  // ignore: library_private_types_in_public_api
  static _CliniqAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_CliniqAppState>();

  @override
  State<CliniqApp> createState() => _CliniqAppState();
}

class _CliniqAppState extends State<CliniqApp> {
  late ThemeMode _themeMode;

  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() async {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      AppConstants.keyThemeMode,
      _themeMode == ThemeMode.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ─── Services ─────────────────────────
        Provider<AuthService>(create: (_) => _authService),
        Provider<FirestoreService>(create: (_) => _firestoreService),

        // ─── Providers ────────────────────────
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: _authService),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(firestoreService: _firestoreService),
        ),
        ChangeNotifierProvider<ScannerProvider>(
          create: (_) => ScannerProvider(),
        ),
        ChangeNotifierProvider<RemindersProvider>(
          create: (_) => RemindersProvider(),
        ),
        ChangeNotifierProvider(create: (_) => PrescriptionProvider()),
        ChangeNotifierProvider(create: (_) => SicknessGuideProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(
          create: (context) => AdProvider(
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => AppConfigProvider()),
      ],
      child: MaterialApp.router(
        title: 'Cliniq',
        debugShowCheckedModeBanner: false,
        theme: CliniqTheme.lightTheme,
        darkTheme: CliniqTheme.darkTheme,
        themeMode: _themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
