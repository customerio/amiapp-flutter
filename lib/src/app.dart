import 'package:customer_io/customer_io.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth.dart';
import 'color_schemes.g.dart';
import 'constants.dart';
import 'customer_io.dart';
import 'screens/attributes.dart';
import 'screens/events.dart';
import 'screens/home.dart';
import 'screens/logs.dart';
import 'screens/settings.dart';
import 'screens/sign_in.dart';
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

  void _initCustomerIO() async {
    _customerIOSDK
        .initialize()
        .whenComplete(
            () => debugLog('Customer.io SDK initialization successful'))
        .catchError((error) {
      debugLog('Customer.io SDK could not be initialized:  $error');
    });
  }

  @override
  void initState() {
    // GoRouter configurations.
    _router = GoRouter(
      debugLogDiagnostics:
          _customerIOSDK.configurations?.featureDebugMode != false,
      initialLocation: URLPath.home,
      refreshListenable: _auth,
      redirect: (BuildContext context, GoRouterState state) => _guard(state),
      routes: [
        GoRoute(
          name: 'SignIn',
          path: URLPath.signIn,
          builder: (context, state) => SignInScreen(
            onSignIn: (credentials) {
              _auth
                  .signIn(credentials.email, credentials.fullName)
                  .then((signedIn) {
                if (signedIn) {
                  CustomerIO.identify(
                      identifier: credentials.email,
                      attributes: {
                        "name": credentials.fullName,
                        "email": credentials.email
                      });
                  _customerIOSDK.saveProfileIdentifier(credentials.email);
                  context.go(URLPath.home);
                }
                return signedIn;
              });
            },
          ),
        ),
        GoRoute(
          name: 'Settings',
          path: URLPath.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          name: 'View Logs',
          path: URLPath.viewLogs,
          builder: (context, state) => const ViewLogsScreen(),
        ),
        GoRoute(
          name: 'Home',
          path: URLPath.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          name: 'CustomEvent',
          path: URLPath.customEvents,
          builder: (context, state) => const CustomEventScreen(),
        ),
        GoRoute(
          name: 'DeviceAttributes',
          path: URLPath.deviceAttributes,
          builder: (context, state) => const DeviceAttributesScreen(),
        ),
        GoRoute(
          name: 'ProfileAttributes',
          path: URLPath.profileAttributes,
          builder: (context, state) => const ProfileAttributesScreen(),
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
      appBarTheme: const AppBarTheme(
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
    if (signedIn && target == URLPath.signIn) {
      return Future.value(URLPath.home);
    } else if (!signedIn &&
        target != URLPath.signIn &&
        target != URLPath.settings &&
        target != URLPath.viewLogs) {
      return Future.value(URLPath.signIn);
    }

    if (_customerIOSDK.configurations?.featureTrackScreens != false) {
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
      _customerIOSDK.clearProfileIdentifier();
      _router.go(URLPath.signIn);
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
