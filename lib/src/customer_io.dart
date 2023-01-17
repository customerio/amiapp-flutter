import 'dart:async' show Future;
import 'dart:developer' as developer;

import 'package:customer_io/customer_io.dart';
import 'package:customer_io/customer_io_config.dart';
import 'package:customer_io/customer_io_enums.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is only for sample app
/// Please feel free to place sdk related code wherever suits best for your app architecture
/// But make sure to initialize Customer.io SDK only once from your app

extension CustomerIOStringExtensions on String {
  bool equalsIgnoreCase(String? other) => toLowerCase() == other?.toLowerCase();

  Region? toRegion() => equalsIgnoreCase('eu')
      ? Region.eu
      : equalsIgnoreCase('us')
          ? Region.us
          : null;

  String? toGistEnvironment() => this;

  int? toIntOrNull() {
    if (isNotEmpty) {
      return int.tryParse(this);
    } else {
      return null;
    }
  }

  double? toDoubleOrNull() {
    if (isNotEmpty) {
      return double.tryParse(this);
    } else {
      return null;
    }
  }

  bool? toBoolOrNull() {
    if (equalsIgnoreCase('true')) {
      return true;
    } else if (equalsIgnoreCase('false')) {
      return false;
    } else {
      return null;
    }
  }
}

extension CustomerIOSharedPreferencesExtensions on SharedPreferences {
  Future<bool> setOrRemoveString(String key, String? value) {
    return value != null && value.isNotEmpty
        ? setString(key, value)
        : remove(key);
  }

  Future<bool> setOrRemoveInt(String key, int? value) {
    return value != null ? setInt(key, value) : remove(key);
  }

  Future<bool> setOrRemoveDouble(String key, double? value) {
    return value != null ? setDouble(key, value) : remove(key);
  }

  Future<bool> setOrRemoveBool(String key, bool? value) {
    return value != null ? setBool(key, value) : remove(key);
  }
}

const _customerIOChannelName = 'io.customer.amiapp_flutter/customer_io';

class CustomerIOSDK {
  static const _platform = MethodChannel(_customerIOChannelName);

  late CustomerIOConfigurations _configurations;

  CustomerIOConfigurations get configurations => _configurations;

  CustomerIOConfigurations? _getEnvironmentConfigurations() {
    CustomerIOConfigurations? config;
    try {
      if (dotenv.env.isNotEmpty) {
        config = CustomerIOConfigurations.fromEnv();
      }
      developer.log(
          'No environment file found for Customer.io, dotenv initialization: ${dotenv.isInitialized}');
    } catch (ex, s) {
      developer.log(
        'Unable to load Customer.io environment',
        error: ex,
        stackTrace: s,
      );
    }
    return config;
  }

  Future<CustomerIOConfigurations?> _loadConfigurationsFromPreferences() async {
    return SharedPreferences.getInstance().then((prefs) async {
      try {
        return CustomerIOConfigurations.fromPrefs(prefs);
      } catch (ex) {
        if (ex is! ArgumentError) {
          developer.log("Error loading configurations from preferences: '$ex'",
              error: ex);
        }
        return null;
      }
    });
  }

  Future<bool> saveConfigurationsToPreferences(
    CustomerIOConfigurations configurations,
  ) =>
      SharedPreferences.getInstance().then((prefs) async {
        await prefs.setOrRemoveString(
            _ConfigurationKey.siteId, configurations.siteId);
        await prefs.setOrRemoveString(
            _ConfigurationKey.apiKey, configurations.apiKey);
        await prefs.setOrRemoveString(
            _ConfigurationKey.organizationId, configurations.organizationId);
        await prefs.setOrRemoveString(
            _ConfigurationKey.region, configurations.region?.toString());
        await prefs.setOrRemoveString(
            _ConfigurationKey.trackingUrl, configurations.trackingUrl);
        await prefs.setOrRemoveString(
            _ConfigurationKey.gistEnvironment, configurations.gistEnvironment);
        await prefs.setOrRemoveDouble(
            _ConfigurationKey.backgroundQueueSecondsDelay,
            configurations.backgroundQueueSecondsDelay);
        await prefs.setOrRemoveInt(
            _ConfigurationKey.backgroundQueueMinNumberOfTasks,
            configurations.backgroundQueueMinNumberOfTasks);
        await prefs.setOrRemoveBool(_ConfigurationKey.featureEnablePush,
            configurations.featureEnablePush);
        await prefs.setOrRemoveBool(_ConfigurationKey.featureTrackScreens,
            configurations.featureTrackScreens);
        await prefs.setOrRemoveBool(
            _ConfigurationKey.featureTrackDeviceAttributes,
            configurations.featureTrackDeviceAttributes);
        return prefs.setOrRemoveBool(_ConfigurationKey.featureDebugMode,
            configurations.featureDebugMode);
      });

  CustomerIOConfigurations? getDefaultConfigurations() =>
      _getEnvironmentConfigurations();

  Future<void> initialize() async {
    final prefsConfig = await _loadConfigurationsFromPreferences();
    if (prefsConfig != null) {
      _configurations = prefsConfig;
      developer.log(
          'Customer.io SDK configurations loaded from preferences successfully');
    } else {
      final envConfig = _getEnvironmentConfigurations();
      if (envConfig != null) {
        _configurations = envConfig;
        developer.log(
            'Customer.io SDK configurations loaded from environment successfully');
      } else {
        // initializing with dummy values to avoid unwanted runtime exceptions
        // on configurations
        _configurations =
            CustomerIOConfigurations(siteId: 'siteId', apiKey: 'apiKey');
        developer.log('Customer.io SDK configurations could not be fetched');
        return Future.error(Exception(
            'No values found for Customer.io SDK in preferences or environment'));
      }
    }

    return CustomerIO.initialize(
      config: CustomerIOConfig(
        siteId: _configurations.siteId,
        apiKey: _configurations.apiKey,
        organizationId: _configurations.organizationId ?? '',
        region: _configurations.region ?? Region.us,
        //config options go here
        autoTrackDeviceAttributes:
            _configurations.featureTrackDeviceAttributes ?? true,
        autoTrackPushEvents: true,
        backgroundQueueMinNumberOfTasks:
            _configurations.backgroundQueueMinNumberOfTasks ?? 10,
        backgroundQueueSecondsDelay:
            _configurations.backgroundQueueSecondsDelay ?? 30.0,
        logLevel: CioLogLevel.debug,
      ),
    ).then((value) => _platform.invokeMethod('onSDKInitialized'));
  }

  /// Saves profile identifier locally to identify login state and triggers
  /// SDK call for profile identification
  Future<bool> saveProfileIdentifier(String identifier) =>
      SharedPreferences.getInstance().then((prefs) {
        return prefs.setString(_profileIdentifier, identifier);
      });

  Future<String?> fetchProfileIdentifier() =>
      SharedPreferences.getInstance().then((prefs) {
        return prefs.getString(_profileIdentifier);
      });

  Future<bool> clearProfileIdentifier() =>
      SharedPreferences.getInstance().then((prefs) {
        return prefs.remove(_profileIdentifier);
      });

  Future<List<String>?> getLogs() async {
    try {
      final List<Object?> result = await _platform.invokeMethod('getLogs');
      return result
          .map((log) => log?.toString() ?? 'NULL')
          .toList(growable: false);
    } on PlatformException catch (ex) {
      developer.log("Failed to get logs from SDK: '${ex.message}'", error: ex);
      return null;
    }
  }

  Future<String?> getUserAgent() async {
    try {
      final result = await _platform.invokeMethod('getUserAgent');
      return result?.toString();
    } on PlatformException catch (ex) {
      developer.log("Failed to get user agent from SDK: '${ex.message}'",
          error: ex);
      return null;
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      final result = await _platform.invokeMethod('getDeviceToken');
      return result?.toString();
    } on PlatformException catch (ex) {
      developer.log("Failed to get device token from SDK: '${ex.message}'",
          error: ex);
      return null;
    }
  }
}

class CustomerIOConfigurations {
  String siteId;
  String apiKey;
  String? organizationId;
  Region? region;
  String? trackingUrl;
  String? gistEnvironment;
  double? backgroundQueueSecondsDelay;
  int? backgroundQueueMinNumberOfTasks;
  bool? featureEnablePush;
  bool? featureTrackScreens;
  bool? featureTrackDeviceAttributes;
  bool? featureDebugMode;

  CustomerIOConfigurations({
    required this.siteId,
    required this.apiKey,
    this.organizationId,
    this.region,
    this.trackingUrl,
    this.gistEnvironment,
    this.backgroundQueueSecondsDelay,
    this.backgroundQueueMinNumberOfTasks,
    this.featureEnablePush,
    this.featureTrackScreens,
    this.featureTrackDeviceAttributes,
    this.featureDebugMode,
  });

  factory CustomerIOConfigurations.fromEnv() => CustomerIOConfigurations(
        siteId: dotenv.env[_ConfigurationKey.siteId]!,
        apiKey: dotenv.env[_ConfigurationKey.apiKey]!,
        organizationId: dotenv.env[_ConfigurationKey.organizationId],
      );

  factory CustomerIOConfigurations.fromPrefs(SharedPreferences prefs) {
    final siteId = prefs.getString(_ConfigurationKey.siteId);
    final apiKey = prefs.getString(_ConfigurationKey.apiKey);

    if (siteId == null) {
      throw ArgumentError('siteId cannot be null');
    } else if (apiKey == null) {
      throw ArgumentError('apiKey cannot be null');
    }

    return CustomerIOConfigurations(
      siteId: siteId,
      apiKey: apiKey,
      organizationId: prefs.getString(_ConfigurationKey.organizationId),
      region: prefs.getString(_ConfigurationKey.region)?.toRegion(),
      trackingUrl: prefs.getString(_ConfigurationKey.trackingUrl),
      gistEnvironment: prefs.getString(_ConfigurationKey.gistEnvironment),
      backgroundQueueSecondsDelay:
          prefs.getDouble(_ConfigurationKey.backgroundQueueSecondsDelay),
      backgroundQueueMinNumberOfTasks:
          prefs.getInt(_ConfigurationKey.backgroundQueueMinNumberOfTasks),
      featureEnablePush: prefs.getBool(_ConfigurationKey.featureEnablePush),
      featureTrackScreens: prefs.getBool(_ConfigurationKey.featureTrackScreens),
      featureTrackDeviceAttributes:
          prefs.getBool(_ConfigurationKey.featureTrackDeviceAttributes),
      featureDebugMode: prefs.getBool(_ConfigurationKey.featureDebugMode),
    );
  }
}

const _profileIdentifier = 'profileIdentifier';

class _ConfigurationKey {
  static const siteId = 'SITE_ID';
  static const apiKey = 'API_KEY';
  static const organizationId = 'ORGANIZATION_ID';
  static const region = 'REGION';
  static const trackingUrl = 'TRACKING_URL';
  static const gistEnvironment = 'GIST_ENVIRONMENT';
  static const backgroundQueueSecondsDelay = 'BACKGROUND_QUEUE_SECONDS_DELAY';
  static const backgroundQueueMinNumberOfTasks =
      'BACKGROUND_QUEUE_MIN_NUMBER_OF_TASKS';
  static const featureDebugMode = 'DEBUG_MODE';
  static const featureEnablePush = 'ENABLE_PUSH';
  static const featureTrackScreens = 'TRACK_SCREENS';
  static const featureTrackDeviceAttributes = 'TRACK_DEVICE_ATTRIBUTES';
}

class CustomerIOSDKScope {
  static CustomerIOSDKScope? _instance;

  late final CustomerIOSDK sdk;

  CustomerIOSDKScope._newInstance() {
    _instance = this;
    sdk = CustomerIOSDK();
  }

  static clear() {
    return _instance = null;
  }

  /// Avoid holding instance on screens where possible as it may stale
  /// when sdk settings are changed at runtime
  factory CustomerIOSDKScope.instance() {
    return _instance ?? CustomerIOSDKScope._newInstance();
  }

  factory CustomerIOSDKScope.createNew() {
    _instance = null;
    return CustomerIOSDKScope._newInstance();
  }
}
