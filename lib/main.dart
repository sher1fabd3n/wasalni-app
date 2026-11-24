import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/pages/force_update_page.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/l10n/locale_controller.dart';
import 'package:users_app/services/rider_notification_service.dart';
import 'package:users_app/services/remote_pricing.dart';
import 'package:users_app/services/version_gate_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _earlyFirebaseInit();
  _attachCrashlyticsHandlers();
  try {
    if (Firebase.apps.isNotEmpty) {
      // عطّل السطر التالي لو أردت إيقاف التقارير في Debug وتقليل الضجيج.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  } catch (e, st) {
    debugPrint('Crashlytics setCrashlyticsCollectionEnabled: $e\n$st');
  }

  try {
    await RiderNotificationService.init();
  } catch (e, st) {
    debugPrint('RiderNotificationService.init: $e\n$st');
  }

  final localeController = LocaleController();
  try {
    await localeController.loadSaved();
  } catch (e, st) {
    debugPrint('LocaleController.loadSaved failed: $e\n$st');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeController),
        ChangeNotifierProvider(create: (_) => AppInfo()),
      ],
      child: const MyApp(),
    ),
  );
}

/// تهيئة Firebase مبكراً حتى يعمل Crashlytics قبل أول إطار من الواجهة.
Future<void> _earlyFirebaseInit() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e, st) {
    debugPrint('Firebase.initializeApp (early): $e\n$st');
  }
}

void _attachCrashlyticsHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught async error: $error\n$stack');
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };
}

enum _FirebaseInitStatus { loading, ready, failed }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleController>(
      builder: (context, localeCtrl, _) {
        return MaterialApp(
          onGenerateTitle: (ctx) =>
              AppLocalizations.of(ctx)?.appTitle ?? AppConfig.appName,
          debugShowCheckedModeBanner: false,
          locale: localeCtrl.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supported) {
            if (localeCtrl.locale != null) return localeCtrl.locale!;
            if (deviceLocale != null) {
              for (final s in supported) {
                if (s.languageCode == deviceLocale.languageCode) return s;
              }
            }
            return const Locale('ar');
          },
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: const Color(0xFFD32F2F),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F),
              onPrimary: Colors.white,
              secondary: Color(0xFFD32F2F),
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          darkTheme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: const Color(0xFFD32F2F),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F),
              onPrimary: Colors.white,
              secondary: Color(0xFFD32F2F),
              surface: Colors.white,
            ),
          ),
          themeMode: ThemeMode.light,
          home: const _FirebaseBootstrap(),
        );
      },
    );
  }
}

class _FirebaseBootstrap extends StatefulWidget {
  const _FirebaseBootstrap();

  @override
  State<_FirebaseBootstrap> createState() => _FirebaseBootstrapState();
}

class _FirebaseBootstrapState extends State<_FirebaseBootstrap> {
  _FirebaseInitStatus _status = _FirebaseInitStatus.loading;
  String? _errorDetail;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    if (!mounted) return;
    setState(() {
      _status = _FirebaseInitStatus.loading;
      _errorDetail = null;
    });

    const attempts = 3;
    const timeoutPerAttempt = Duration(seconds: 30);

    for (var i = 0; i < attempts; i++) {
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp().timeout(timeoutPerAttempt);
        }
        RemotePricing.instance.startListening();
        if (Firebase.apps.isNotEmpty) {
          unawaited(FirebaseAnalytics.instance.logAppOpen());
        }
        if (!mounted) return;
        setState(() => _status = _FirebaseInitStatus.ready);

        Future.microtask(() async {
          try {
            if (await Permission.locationWhenInUse.isDenied) {
              await Permission.locationWhenInUse.request();
            }
          } catch (_) {}
        });
        return;
      } catch (e, st) {
        debugPrint('Firebase init attempt ${i + 1}/$attempts: $e\n$st');
        if (i < attempts - 1) {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }
    }

    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    setState(() {
      _status = _FirebaseInitStatus.failed;
      _errorDetail = loc?.firebaseInitFailed ??
          'Could not initialize Firebase. Check connection and google-services.json.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (_status == _FirebaseInitStatus.loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD32F2F)),
              const SizedBox(height: 24),
              Text(
                loc?.loadingFirebase ?? 'Loading...',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_status == _FirebaseInitStatus.failed) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 56, color: Colors.orange),
                const SizedBox(height: 20),
                Text(
                  _errorDetail ?? (loc?.firebaseInitFailed ?? 'Error'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _initializeFirebase,
                  icon: const Icon(Icons.refresh),
                  label: Text(loc?.retry ?? 'Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _VersionGateBootstrap(
      child: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const HomePage(),
    );
  }
}

class _VersionGateBootstrap extends StatefulWidget {
  final Widget child;

  const _VersionGateBootstrap({required this.child});

  @override
  State<_VersionGateBootstrap> createState() => _VersionGateBootstrapState();
}

class _VersionGateBootstrapState extends State<_VersionGateBootstrap> {
  Future<VersionGateResult>? _gateFuture;
  bool _optionalDialogShown = false;

  @override
  void initState() {
    super.initState();
    _gateFuture = VersionGateService.check();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VersionGateResult>(
      future: _gateFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
            ),
          );
        }
        if (snap.hasData && snap.data!.mustUpdate) {
          return ForceUpdatePage(gate: snap.data!);
        }
        if (snap.hasData &&
            snap.data!.hasOptionalUpdate &&
            !_optionalDialogShown) {
          _optionalDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showOptionalUpdateDialog(snap.data!);
          });
        }
        return widget.child;
      },
    );
  }

  Future<void> _showOptionalUpdateDialog(VersionGateResult gate) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(gate.title),
        content: Text(gate.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'later'),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'update'),
            child: const Text('Update now'),
          ),
        ],
      ),
    );
    if (action != 'update') return;
    final url = Platform.isIOS ? gate.iosStoreUrl : gate.androidStoreUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
