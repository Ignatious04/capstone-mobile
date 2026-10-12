import 'package:capstone/core/enums/notification_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/services/local_notification_service.dart';
import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/models/notification_model.dart';
import 'package:capstone/core/shared/providers/app_notification_provider.dart';
import 'package:capstone/core/shared/providers/connectivity_stream_provider.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/locale_provider.dart';
import 'package:capstone/core/shared/providers/navigator_key_provider.dart';
import 'package:capstone/core/shared/providers/notification_history_provider.dart';
import 'package:capstone/core/shared/widgets/app_notification_overlay.dart';
import 'package:capstone/features/auth_wrapper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler); // register before runApp
  await LocalNotificationService.instance.init();
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
          const message = 'No internet connection. Some features may be limited.';
          ref.read(appNotificationProvider.notifier).show(message);
          ref
              .read(notificationHistoryProvider.notifier)
              .add(
                NotificationModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: NotificationTypeEnum.connectivity,
                  title: 'Offline',
                  message: message,
                  createdAt: DateTime.now(),
                ),
              );
        } else if (!isOffline && wasOffline) {
          const message = 'Back online.';
          ref.read(appNotificationProvider.notifier).show(message);
          ref
              .read(notificationHistoryProvider.notifier)
              .add(
                NotificationModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: NotificationTypeEnum.connectivity,
                  title: 'Back online',
                  message: message,
                  createdAt: DateTime.now(),
                ),
              );
        }
      });
    });

    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      next.whenData((authUser) {
        final push = ref.read(pushNotificationServiceProvider);
        if (authUser != null && authUser.emailVerified) {
          push.init();
          push.registerToken(authUser.uid); 
        }
      });
    });

    return MaterialApp(
      navigatorKey: ref.watch(navigatorKeyProvider),
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
