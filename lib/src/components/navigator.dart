import 'package:amiapp_flutter/src/screens/home.dart';
import 'package:amiapp_flutter/src/screens/sign_in.dart';
import 'package:flutter/material.dart';

import '../auth.dart';
import '../routing/route_state.dart';
import 'fade_transition_page.dart';

/// Top-level navigator for the app to display pages based on the `routeState`
/// that were parsed by the TemplateRouteParser.
class AmiAppNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AmiAppNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<AmiAppNavigator> createState() => _AmiAppNavigatorState();
}

/// Navigator state to handle backstack and routing based on auth and links
class _AmiAppNavigatorState extends State<AmiAppNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _scaffoldKey = const ValueKey('App scaffold');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = AmiAppAuthScope.of(context);

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: const SignInScreen(),
          )
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const HomeScreen(),
          ),
        ],
      ],
    );
  }
}
