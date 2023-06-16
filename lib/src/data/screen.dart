enum Screen {
  login(name: 'Login', routerPath: '/login'),
  // For GoRouter, initial path must be `/`
  dashboard(name: 'Dashboard', routerPath: '/', urlPath: 'dashboard'),
  settings(name: 'Settings', routerPath: 'settings'),
  customEvents(name: 'Custom Event', routerPath: 'events/custom'),
  deviceAttributes(
      name: 'Custom Device Attribute', routerPath: 'attributes/device'),
  profileAttributes(
      name: 'Custom Profile Attribute', routerPath: 'attributes/profile');

  const Screen({
    required this.name,
    required this.routerPath,
    this.urlPath,
  });

  final String name;
  final String routerPath;

  // Used for supporting different paths in deep links e.g. dashboard
  // Make sure to modify `_guard` method in `app.dart` to support it
  final String? urlPath;

  String get location {
    // Since login is not configured inside dashboard, we not need to modify its path
    if (this == Screen.dashboard || this == Screen.login) {
      return routerPath;
    } else {
      // Since all other screens are configured inside dashboard, we need to
      // prepend dashboard path to them
      return '${dashboard.routerPath}$routerPath';
    }
  }

  // Static map to get screen using location without looping everytime
  // Helps tracking screens without delays
  static Map<String, Screen> locationToScreenMap = {
    for (final screen in Screen.values) screen.location: screen
  };
}
