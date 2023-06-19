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
