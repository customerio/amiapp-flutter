import 'dart:async' show Future;

import 'package:customer_io/customer_io.dart';
import 'package:customer_io/customer_io_config.dart';
import 'package:customer_io/customer_io_enums.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/config.dart';
import 'utils/logs.dart';

/// This is only for sample app
/// Please feel free to place sdk related code wherever suits best for your app architecture
/// But make sure to initialize Customer.io SDK only once from your app

const _customerIOChannelName = 'io.customer.amiapp_flutter/customer_io';

class CustomerIOSDK extends ChangeNotifier {
  static const _platform = MethodChannel(_customerIOChannelName);

  CustomerIOSDKConfiguration? _configurations;

  CustomerIOSDKConfiguration? get configurations => _configurations;

  @override
  bool operator ==(Object other) =>
      other is CustomerIOSDK && other._configurations == _configurations;

  @override
  int get hashCode => _configurations?.hashCode ?? 0;

  @override
  void dispose() {
    CustomerIOSDKInstance.dispose();
    super.dispose();
  }

  CustomerIOSDKConfiguration? _getEnvironmentConfigurations() {
    CustomerIOSDKConfiguration? config;
    try {
      if (dotenv.env.isNotEmpty) {
        config = CustomerIOSDKConfiguration.fromEnv();
      } else {
        debugLog(
            'No env file found, dotenv initialization: ${dotenv.isInitialized}');
      }
    } catch (ex, s) {
      debugError(
        'Unable to load Customer.io configurations from env',
        error: ex,
        stackTrace: s,
      );
    }
    return config;
  }

  Future<CustomerIOSDKConfiguration?>
      _loadConfigurationsFromPreferences() async {
    return SharedPreferences.getInstance().then((prefs) async {
      try {
        return CustomerIOSDKConfiguration.fromPrefs(prefs);
      } catch (ex) {
        if (ex is! ArgumentError) {
          debugError("Error loading configurations from preferences: '$ex'",
              error: ex);
        }
        return null;
      }
    });
  }

  Future<bool> saveConfigurationsToPreferences(
    CustomerIOSDKConfiguration config,
  ) =>
      SharedPreferences.getInstance()
          .then((prefs) => prefs.saveConfigurationState(config))
          .then((value) {
        notifyListeners();
        return value;
      });

  CustomerIOSDKConfiguration? getDefaultConfigurations() =>
      _getEnvironmentConfigurations();

  Future<void> initialize() async {
    if (_configurations == null) {
      final prefsConfig = await _loadConfigurationsFromPreferences();
      if (prefsConfig != null) {
        _configurations = prefsConfig;
        debugLog(
            'Customer.io SDK configurations loaded from preferences successfully');
      } else {
        final envConfig = _getEnvironmentConfigurations();
        if (envConfig != null) {
          _configurations = envConfig;
          debugLog(
              'Customer.io SDK configurations loaded from environment successfully');
        } else {
          debugLog('Customer.io SDK configurations could not be fetched');
          return Future.error(Exception(
              'No values found for Customer.io SDK in preferences or environment'));
        }
      }
    } else {
      _platform.invokeMethod('clearLogs');
      debugLog('Customer.io SDK configurations already initialized');
    }

    final CioLogLevel logLevel;
    if (_configurations?.debugModeEnabled == false) {
      logLevel = CioLogLevel.error;
    } else {
      logLevel = CioLogLevel.debug;
    }
    return CustomerIO.initialize(
      config: CustomerIOConfig(
        siteId: _configurations?.siteId ?? '',
        apiKey: _configurations?.apiKey ?? '',
        enableInApp: true,
        region: Region.us,
        //config options go here
        autoTrackDeviceAttributes:
            _configurations?.deviceAttributesTrackingEnabled ?? true,
        autoTrackPushEvents: true,
        backgroundQueueMinNumberOfTasks:
            _configurations?.backgroundQueueMinNumOfTasks ?? 10,
        backgroundQueueSecondsDelay:
            _configurations?.backgroundQueueSecondsDelay ?? 30.0,
        logLevel: logLevel,
      ),
    ).then((value) => _platform.invokeMethod('onSDKInitialized'));
  }

  Future<List<String>?> getLogs() async {
    try {
      final List<Object?> result = await _platform.invokeMethod('getLogs');
      return result
          .map((log) => log?.toString() ?? 'NULL')
          .toList(growable: false);
    } on PlatformException catch (ex) {
      debugError("Failed to get logs from SDK: '${ex.message}'", error: ex);
      return null;
    }
  }

  Future<String?> getUserAgent() async {
    try {
      final result = await _platform.invokeMethod('getUserAgent');
      return result?.toString();
    } on PlatformException catch (ex) {
      debugError("Failed to get user agent from SDK: '${ex.message}'",
          error: ex);
      return null;
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      final result = await _platform.invokeMethod('getDeviceToken');
      return result?.toString();
    } on PlatformException catch (ex) {
      debugError("Failed to get device token from SDK: '${ex.message}'",
          error: ex);
      return null;
    }
  }
}

class CustomerIOSDKScope extends InheritedNotifier<CustomerIOSDK> {
  const CustomerIOSDKScope({
    required super.notifier,
    required super.child,
    super.key,
  });
}

class CustomerIOSDKInstance {
  final CustomerIOSDK sdk;

  CustomerIOSDKInstance._newInstance(this.sdk) {
    _instance = this;
  }

  factory CustomerIOSDKInstance._get() {
    return _instance ?? CustomerIOSDKInstance._newInstance(CustomerIOSDK());
  }

  static CustomerIOSDKInstance? _instance;

  static CustomerIOSDK get() {
    return CustomerIOSDKInstance._get().sdk;
  }

  static dispose() => _instance = null;
}
