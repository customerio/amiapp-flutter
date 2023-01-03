import 'package:flutter/material.dart';

import 'auth.dart';
import 'components/navigator.dart';
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

/// App state that holds states for authentication and navigation
class _AmiAppState extends State<AmiApp> {
  final _auth = AmiAppAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();

  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/signin',
        '/settings',
        '/home',
        '/logs',
        '/events/custom',
        '/events/device',
        '/events/profile',
      ],
      guard: _guard,
      initialRoute: '/signin',
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
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    // Go to /signin if the user is not signed in
    if (!signedIn && from != signInRoute) {
      return signInRoute;
    }
    // Go to /home if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/home', '/home', {}, {});
    }
    return from;
  }

  void _handleAuthStateChanged() {
    if (!_auth.signedIn) {
      _routeState.go('/signin');
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
