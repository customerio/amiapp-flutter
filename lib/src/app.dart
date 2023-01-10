import 'dart:developer' as developer;

import 'package:amiapp_flutter/src/routing/url.dart';
import 'package:customer_io/customer_io.dart';
import 'package:flutter/material.dart';

import 'auth.dart';
import 'components/navigator.dart';
import 'customer_io.dart';
import 'routing/delegate.dart';
import 'routing/parsed_route.dart';
import 'routing/parser.dart';
import 'routing/route_state.dart';
import 'theme/sizes.dart';

/// Main entry point of AmiApp
class AmiApp extends StatefulWidget {
  const AmiApp({Key? key}) : super(key: key);

  @override
  State<AmiApp> createState() => _AmiAppState();
}

/// App state that holds states for authentication, navigation and Customer.io SDK
class _AmiAppState extends State<AmiApp> {
  final _auth = AmiAppAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();

  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  void _initCustomerIO() async {
    CustomerIOSDKScope.instance()
        .sdk
        .initialize()
        .whenComplete(
            () => developer.log('Customer.io SDK initialization successful'))
        .catchError((error) {
      developer.log('Customer.io SDK could not be initialized:  $error');
    });
  }

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        URLPath.home,
        URLPath.signIn,
        URLPath.settings,
        URLPath.logs,
        URLPath.customEvents,
        URLPath.deviceAttributes,
        URLPath.profileAttributes,
      ],
      guard: _guard,
      initialRoute: URLPath.signIn,
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => AmiAppNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    // Listen for user login state and display the sign in screen when logged out.
    _auth.addListener(_handleAuthStateChanged);
    // Initialize Customer.io SDK once when app is initialized
    _initCustomerIO();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    );
    const themeExtensions = <ThemeExtension<dynamic>>[
      Sizes.defaults(),
    ];
    ThemeData darkTheme = ThemeData.dark();

    return RouteStateScope(
      notifier: _routeState,
      child: AmiAppAuthScope(
        notifier: _auth,
        child: MaterialApp.router(
          routerDelegate: _routerDelegate,
          routeInformationParser: _routeParser,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            // This is the base theme of our application in light mode.
            primarySwatch: Colors.blueGrey,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            pageTransitionsTheme: pageTransitionsTheme,
            extensions: themeExtensions,
          ),
          darkTheme: darkTheme.copyWith(
            appBarTheme: darkTheme.appBarTheme.copyWith(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            pageTransitionsTheme: pageTransitionsTheme,
            extensions: themeExtensions,
          ),
        ),
      ),
    );
  }

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = _auth.signedIn;
    final signInRoute = ParsedRoute(URLPath.signIn, URLPath.signIn, {}, {});

    // Go to sign in screen if the user is not signed in
    if (!signedIn && from != signInRoute) {
      return signInRoute;
    }
    // Go to home if the user is signed in and tries to go to sign in.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute(URLPath.home, URLPath.home, {}, {});
    }
    return from;
  }

  void _handleAuthStateChanged() {
    if (!_auth.signedIn) {
      CustomerIO.clearIdentify();
      CustomerIOSDKScope.instance().sdk.clearProfileIdentifier();
      _routeState.go(URLPath.signIn);
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
