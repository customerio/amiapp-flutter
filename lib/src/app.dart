import 'package:customer_io/customer_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'auth.dart';
import 'color_schemes.g.dart';
import 'customer_io.dart';
import 'data/screen.dart';
import 'screens/attributes.dart';
import 'screens/dashboard.dart';
import 'screens/events.dart';
import 'screens/login.dart';
import 'screens/settings.dart';
import 'theme/sizes.dart';
import 'utils/logs.dart';

/// Main entry point of AmiApp
class AmiApp extends StatefulWidget {
  const AmiApp({Key? key}) : super(key: key);

  @override
  State<AmiApp> createState() => _AmiAppState();
}

/// App state that holds states for authentication, navigation and Customer.io SDK
class _AmiAppState extends State<AmiApp> {
  final CustomerIOSDK _customerIOSDK = CustomerIOSDKInstance.get();
  final AmiAppAuth _auth = AmiAppAuth();
  late final GoRouter _router;

  final PageTransitionsTheme _pageTransitionsTheme = const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    },
  );
  final List<ThemeExtension<dynamic>> _themeExtensions = [
    const Sizes.defaults(),
  ];

  Future<void> _initCustomerIO() => _customerIOSDK
          .initialize()
          .whenComplete(
              () => debugLog('Customer.io SDK initialization successful'))
          .catchError((error) {
        debugLog('Customer.io SDK could not be initialized:  $error');
      });

  @override
  void initState() {
    // GoRouter configurations.
    _router = GoRouter(
      debugLogDiagnostics: _customerIOSDK.sdkConfig?.debugModeEnabled != false,
      initialLocation: Screen.dashboard.routerPath,
      refreshListenable: _auth,
      redirect: (BuildContext context, GoRouterState state) => _guard(state),
      routes: [
        GoRoute(
          name: Screen.login.name,
          path: Screen.login.routerPath,
          builder: (context, state) => LoginScreen(
            onLogin: (user) {
              _auth.login(user).then((signedIn) {
                if (signedIn) {
                  CustomerIO.identify(identifier: user.email, attributes: {
                    "first_name": user.displayName,
                    "email": user.email,
                    "is_guest": user.isGuest,
                  });
                }
                return signedIn;
              });
            },
          ),
        ),
        GoRoute(
          name: Screen.dashboard.name,
          path: Screen.dashboard.routerPath,
          builder: (context, state) => DashboardScreen(auth: _auth),
          routes: [
            GoRoute(
              name: Screen.settings.name,
              path: Screen.settings.routerPath,
              builder: (context, state) => SettingsScreen(
                siteIdInitialValue: state.queryParameters['site_id'],
                apiKeyInitialValue: state.queryParameters['api_key'],
              ),
            ),
            GoRoute(
              name: Screen.customEvents.name,
              path: Screen.customEvents.routerPath,
              builder: (context, state) => const CustomEventScreen(),
            ),
            GoRoute(
              name: Screen.deviceAttributes.name,
              path: Screen.deviceAttributes.routerPath,
              builder: (context, state) => AttributesScreen.device(),
            ),
            GoRoute(
              name: Screen.profileAttributes.name,
              path: Screen.profileAttributes.routerPath,
              builder: (context, state) => AttributesScreen.profile(),
            ),
          ],
        ),
      ],
    );

    // Listen for user login state and display the sign in screen when logged out.
    _auth.addListener(_handleAuthStateChanged);
    // Initialize Customer.io SDK once when app modules are initialized.
    _initCustomerIO();
    _customerIOSDK.addListener(_handleSDKConfigurationsChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomerIOSDKScope(
      notifier: _customerIOSDK,
      child: AmiAppAuthScope(
        notifier: _auth,
        child: MaterialApp.router(
          routerConfig: _router,
          themeMode: ThemeMode.system,
          theme: _createTheme(ThemeData.light(), lightColorScheme),
          darkTheme: _createTheme(ThemeData.dark(), darkColorScheme),
        ),
      ),
    );
  }

  ThemeData _createTheme(ThemeData base, ColorScheme colorScheme) {
    return base.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: base.appBarTheme.copyWith(
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          ),
        ),
      ),
      pageTransitionsTheme: _pageTransitionsTheme,
      extensions: _themeExtensions,
    );
  }

  Future<String?> _guard(GoRouterState state) async {
    final signedIn = _auth.signedIn ?? await _auth.updateState();

    final target = state.path ?? state.location;
    if (signedIn && target == Screen.login.location) {
      return Future.value(Screen.dashboard.location);
    } else if (!signedIn &&
        target != Screen.login.location &&
        target != Screen.settings.location) {
      return Future.value(Screen.login.location);
    } else if (target == Screen.dashboard.urlPath) {
      return Future.value(Screen.dashboard.location);
    }

    if (_customerIOSDK.sdkConfig?.screenTrackingEnabled == true) {
      final screenName = _getNameFromLocation(target);
      if (screenName?.isNotEmpty == true) {
        CustomerIO.screen(name: screenName!);
      }
    }

    return null;
  }

  String? _getNameFromLocation(String location) {
    for (final route in _router.routeInformationParser.configuration.routes) {
      final goRoute = route as GoRoute;
      if (goRoute.path == location) {
        return goRoute.name;
      }
    }
    return null;
  }

  void _handleAuthStateChanged() {
    if (_auth.signedIn == false) {
      CustomerIO.clearIdentify();
      _auth.clearUserState();
      _router.go(Screen.login.location);
    }
  }

  void _handleSDKConfigurationsChanged() {
    _initCustomerIO();
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _customerIOSDK.removeListener(_handleSDKConfigurationsChanged);

    _auth.dispose();
    _customerIOSDK.dispose();
    _router.dispose();

    super.dispose();
  }
}
