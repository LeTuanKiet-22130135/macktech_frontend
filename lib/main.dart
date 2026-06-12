import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'providers/session_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/main_layout_screen.dart';
import 'screens/admin_main_layout_screen.dart';
import 'screens/agent_main_layout_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/order_success_screen.dart';
import 'widgets/global_chat_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isAndroid) {
    final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
      try {
        mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
      } catch (e) {
        // Ignored, initialization may have already occurred or is not supported
      }
    }
  }

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '213810667501-su1u45725lnd0gloi9ahos6bnj0disao.apps.googleusercontent.com',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // Handle the initial link (app opened via deep link while not running)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });

    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'macktech') {
      debugPrint('--- Deep Link Received: $uri ---');
      bool isSuccess = false;

      // Check VNPAY success
      if (uri.queryParameters.containsKey('vnp_ResponseCode')) {
        final responseCode = uri.queryParameters['vnp_ResponseCode'];
        debugPrint('VNPAY Payment Response Code: $responseCode');
        isSuccess = responseCode == '00';
      }
      // Check MoMo success
      else if (uri.queryParameters.containsKey('resultCode')) {
        final resultCode = uri.queryParameters['resultCode'];
        debugPrint('MoMo Payment Result Code: $resultCode');
        isSuccess = resultCode == '0';
      }

      if (isSuccess) {
        // Clear cart and send notification
        ref.read(cartProvider.notifier).clearCart();
        try {
          final enabled = ref.read(notificationEnabledProvider).value ?? false;
          if (enabled) {
            ref.read(notificationEnabledProvider.notifier).sendOrderNotification();
          }
        } catch (e) {
          debugPrint('Error sending notification: $e');
        }

        // Navigate to success screen
        appNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
          (route) => false,
        );
      } else {
        // Payment failed — pop back to checkout and show snackbar
        appNavigatorKey.currentState?.popUntil((route) => route.isFirst || route.settings.name == null);
        final ctx = appNavigatorKey.currentContext;
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Payment failed or cancelled.')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Determines the initial screen based on stored session.
  Widget _resolveBySession(SessionState session) {
    if (!session.isLoggedIn) {
      return const WelcomeScreen();
    }
    switch (session.role) {
      case 'admin':
        return const AdminMainLayoutScreen();
      case 'agent':
        return const AgentMainLayoutScreen();
      default:
        return const MainLayoutScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionProvider);

    return MaterialApp(
      title: 'Macktech Mobiles',
      theme: AppTheme.lightTheme,
      navigatorKey: appNavigatorKey,
      builder: (context, child) {
        return GlobalChatWrapper(child: child!);
      },
      home: sessionAsync.when(
        data: (session) {
          // Set chat FAB visibility based on role
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(chatFabVisibleProvider.notifier).set(
                session.isLoggedIn && session.role == 'user');
          });
          return _resolveBySession(session);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const WelcomeScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

