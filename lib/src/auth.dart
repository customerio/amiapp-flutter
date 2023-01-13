import 'package:flutter/widgets.dart';

import 'customer_io.dart';

/// Dummy authentication service as we only need login details to identify user
class AmiAppAuth extends ChangeNotifier {
  bool? _signedIn;

  bool? get signedIn => _signedIn;

  AmiAppAuth() {
    // Update authentication state at earliest.
    updateState();
  }

  // Validates current signed in state
  Future<bool> updateState() =>
      CustomerIOSDKScope.instance().sdk.fetchProfileIdentifier().then((value) {
        _signedIn = value != null && value.isNotEmpty;
        notifyListeners();
        return _signedIn == true;
      });

  Future<void> signOut() async {
    // Sign out after short delay
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _signedIn = false;
    notifyListeners();
  }

  Future<bool> signIn(String emailAddress, String fullName) async {
    // Sign in after short delay
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _signedIn = true;
    notifyListeners();
    return _signedIn == true;
  }

  @override
  bool operator ==(Object other) =>
      other is AmiAppAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn?.hashCode ?? 0;
}

class AmiAppAuthScope extends InheritedNotifier<AmiAppAuth> {
  const AmiAppAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AmiAppAuth of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AmiAppAuthScope>()!.notifier!;
}
