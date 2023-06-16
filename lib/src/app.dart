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
    _initCustomerIO().then((value) {
      // Initial route will not be tracked if user is logged in as there is no
      // route change, tracking initial screen manually for this case.
      // Events/screens can only be tracked after SDK has been initialized.
      if (_router.location == Screen.dashboard.location) {
        _onRouteChanged();
      }
      return value;
    });
    _customerIOSDK.addListener(_handleSDKConfigurationsChanged);

    // Listen to screen changes for observing screens
    _router.addListener(() => _onRouteChanged());

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
          theme: _createTheme(false),
          darkTheme: _createTheme(true),
        ),
      ),
    );
  }

  ThemeData _createTheme(bool isDark) {
    final ThemeData theme;
    final ColorScheme colorScheme;
    final SystemUiOverlayStyle systemOverlayStyle;
    if (isDark) {
      theme = ThemeData.dark();
      colorScheme = darkColorScheme;
      systemOverlayStyle = SystemUiOverlayStyle.light;
    } else {
      theme = ThemeData.light();
      colorScheme = lightColorScheme;
      systemOverlayStyle = SystemUiOverlayStyle.dark;
    }

    return theme.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: theme.appBarTheme.copyWith(
        systemOverlayStyle: systemOverlayStyle,
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

    return null;
  }

  void _onRouteChanged() {
    String location = _router.location;
    if (_customerIOSDK.sdkConfig?.screenTrackingEnabled == true) {
      final screen = _getNameFromLocation(location);
      if (screen != null) {
        CustomerIO.screen(name: screen.name);
      }
    }
  }

  Screen? _getNameFromLocation(String location) {
    for (final screen in Screen.values) {
      if (screen.location == location) {
        return screen;
      }
    }

    // No screen matched (unlikely to happen in this app)
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
