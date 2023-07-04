enum Screen {
  login(name: 'Login', path: '/login'),
  // For GoRouter, initial path must be `/`
  dashboard(name: 'Dashboard', path: '/'),
  // Used for supporting dashboard path in deep links
  dashboardRedirect(name: 'DashboardRedirect', path: 'dashboard'),
  settings(name: 'Settings', path: 'settings'),
  customEvents(name: 'Custom Event', path: 'events/custom'),
  deviceAttributes(name: 'Custom Device Attribute', path: 'attributes/device'),
  profileAttributes(
      name: 'Custom Profile Attribute', path: 'attributes/profile');

  const Screen({
    required this.name,
    required this.path,
  });

  // Required by GoRouter, should be unique and non-empty
  final String name;

  // Required by GoRouter, should be unique and non-empty
  final String path;

  String get location {
    // Since login is not configured inside dashboard, we not need to modify its path
    if (this == Screen.dashboard || this == Screen.login) {
      return path;
    } else {
      // Since all other screens are configured inside dashboard, we need to
      // prepend dashboard path to them
      return '${dashboard.path}$path';
    }
  }

  // Static map to get screen using location without looping everytime
  // Helps tracking screens without delays
  static Map<String, Screen> locationToScreenMap = {
    for (final screen in Screen.values) screen.location: screen
  };
}

extension ScreenProperties on Screen {
  /// Returns true if screen requires user to be authenticated to view it.
  bool get isAuthenticatedViewOnly =>
      !isUnauthenticatedViewOnly && this != Screen.settings;

  /// Returns true if screen can be viewed without authentication.
  bool get isUnauthenticatedViewOnly => this == Screen.login;
}

extension ScreenFactory on Screen {
  /// Creates a screen from router location.
  /// Falls back to [fallback] screen if no screen is found.
  /// Defaults to [Screen.dashboard] as fallback.
  static Screen fromRouterLocation(String location,
      {Screen fallback = Screen.dashboard}) {
    return Screen.values.firstWhere(
        (screen) => location.startsWith(screen.location) && screen != fallback,
        orElse: () => fallback);
  }
}
