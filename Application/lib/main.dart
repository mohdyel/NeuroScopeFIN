import 'dart:io';
import 'app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

// ← Add this import so we can register the same RouteObserver:
import './fitness_app/history/history_screen.dart';

import './providers/server_status_provider.dart';
import 'providers/storage_provider.dart';
import 'fitness_app/fitness_app_home_screen.dart';
import 'ServerOfflineScreen.dart';
import 'services/server_monitor_service.dart';
import 'introduction_animation/introduction_animation_screen.dart';
import 'providers/server_config_provider.dart';

/// Accept all SSL certificates (necessary for ngrok-free.app)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void main() async {
  // ← register override before any http calls
  HttpOverrides.global = MyHttpOverrides();

  try {
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint('Initializing Firebase...');
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ServerStatusProvider()..initializeStatus(),
          ),
          ChangeNotifierProvider(
            create: (_) => StorageProvider(),
          ),
        ],
        child: Phoenix(child: MyApp()),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Error in main: $e\n$stackTrace');
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Consumer<ServerStatusProvider>(
      builder: (context, serverStatus, _) => MaterialApp(
        title: 'Neuroscope',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: AppTheme.textTheme,
          platform: TargetPlatform.iOS,
        ),
        navigatorObservers: [routeObserver],
        home: !serverStatus.isServerOnline
            ? const ServerOfflineScreen()
            : StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return FitnessAppHomeScreen();
                  }
                  return const IntroductionAnimationScreen();
                },
              ),
      ),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}

class ServerStatusProvider with ChangeNotifier {
  bool _isServerOnline = false;

  bool get isServerOnline => _isServerOnline;

  Future<void> initializeStatus() async {
    // Add your server status check logic here
    _isServerOnline = true;
    notifyListeners();
  }

  void updateServerStatus(bool status) {
    _isServerOnline = status;
    notifyListeners();
  }
}
