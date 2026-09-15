import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/app_notification_provider.dart';
import 'package:capstone/core/shared/providers/connectivity_stream_provider.dart';
import 'package:capstone/core/shared/providers/locale_provider.dart';
import 'package:capstone/core/shared/widgets/app_notification_overlay.dart';
import 'package:capstone/core/shared/widgets/auth_wrapper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityStreamProvider, (previous, next) {
      next.whenData((result) {
        debugPrint('connectivity event: $result');
        final isOffline = result.isEmpty || result.every((r) => r == ConnectivityResult.none);
        final wasOffline = previous?.value?.every((r) => r == ConnectivityResult.none) ?? false;

        if (isOffline && !wasOffline) {
          ref
              .read(appNotificationProvider.notifier)
              .show(
                'No internet connection. Some features may be limited.',
              );
        } else if (!isOffline && wasOffline) {
          ref
              .read(appNotificationProvider.notifier)
              .show(
                'Back online.',
              );
        }
      });
    });

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      locale: locale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],

      supportedLocales: AppLocalizations.supportedLocales,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            overlayColor: Colors.transparent,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F0F0),
        fontFamily: 'Inter',
      ),
      builder: (context, child) => AppNotificationOverlay(child: child!),
      home: AuthWrapper(),
    );
  }
}
