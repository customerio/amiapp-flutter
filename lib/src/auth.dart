import 'package:flutter/widgets.dart';

/// Dummy authentication service as we only need login details to identify user
class AmiAppAuth extends ChangeNotifier {
  bool _signedIn = false;

  bool get signedIn => _signedIn;

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
    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is AmiAppAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
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
