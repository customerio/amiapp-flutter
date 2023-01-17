import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/container.dart';
import '../customer_io.dart';
import '../theme/sizes.dart';
import '../widgets/app_footer.dart';
import '../widgets/header.dart';
import '../widgets/settings_form_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  CustomerIOSDK get _customerIOSDK => CustomerIOSDKScope.instance().sdk;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _deviceTokenValueController;
  late final TextEditingController _trackingURLValueController;
  late final TextEditingController _siteIDValueController;
  late final TextEditingController _apiKeyValueController;
  late final TextEditingController _organizationIDValueController;
  late final TextEditingController _bqSecondsDelayValueController;
  late final TextEditingController _bqMinNumberOfTasksValueController;

  late bool _featureEnablePush;
  late bool _featureTrackScreens;
  late bool _featureTrackDeviceAttributes;
  late bool _featureDebugMode;

  @override
  void initState() {
    widget._customerIOSDK.getDeviceToken().then((value) =>
        setState(() => _deviceTokenValueController.text = value ?? ''));

    final cioConfig = widget._customerIOSDK.configurations;
    _deviceTokenValueController = TextEditingController();
    _trackingURLValueController =
        TextEditingController(text: cioConfig.trackingUrl);
    _siteIDValueController = TextEditingController(text: cioConfig.siteId);
    _apiKeyValueController = TextEditingController(text: cioConfig.apiKey);
    _organizationIDValueController =
        TextEditingController(text: cioConfig.organizationId);
    _bqSecondsDelayValueController = TextEditingController(
        text: cioConfig.backgroundQueueSecondsDelay?.toString());
    _bqMinNumberOfTasksValueController = TextEditingController(
        text: cioConfig.backgroundQueueMinNumberOfTasks?.toString());
    _featureEnablePush = cioConfig.featureEnablePush ?? false;
    _featureTrackScreens = cioConfig.featureTrackScreens ?? false;
    _featureTrackDeviceAttributes =
        cioConfig.featureTrackDeviceAttributes ?? false;
    _featureDebugMode = cioConfig.featureDebugMode ?? false;

    super.initState();
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;

    return AppContainer(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Container(
                    constraints:
                        BoxConstraints.loose(sizes.inputFieldDefault()),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        TextSettingsFormField(
                          labelText: 'Device Token',
                          valueController: _deviceTokenValueController,
                          readOnly: true,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy Token',
                            onPressed: () {
                              final clipboardData = ClipboardData(
                                  text: _deviceTokenValueController.text);
                              Clipboard.setData(clipboardData).then((_) =>
                                  _showSnackBar(context,
                                      'Device Token copied to clipboard'));
                            },
                          ),
                        ),
                        TextSettingsFormField(
                          labelText: 'Tracking URL',
                          valueController: _trackingURLValueController,
                        ),
                        const SizedBox(height: 32),
                        TextSettingsFormField(
                          labelText: 'Site ID',
                          valueController: _siteIDValueController,
                          validator: (value) => value?.isNotEmpty == true
                              ? null
                              : 'Site ID cannot be empty',
                        ),
                        TextSettingsFormField(
                          labelText: 'API Key',
                          valueController: _apiKeyValueController,
                          validator: (value) => value?.isNotEmpty == true
                              ? null
                              : 'API Key cannot be empty',
                        ),
                        TextSettingsFormField(
                          labelText: 'Organization ID',
                          valueController: _organizationIDValueController,
                        ),
                        const SizedBox(height: 32),
                        TextSettingsFormField(
                          labelText: 'backgroundQueueSecondsDelay',
                          valueController: _bqSecondsDelayValueController,
                          keyboardType: TextInputType.number,
                        ),
                        TextSettingsFormField(
                          labelText: 'backgroundQueueMinNumberOfTasks',
                          hintText: '10',
                          valueController: _bqMinNumberOfTasksValueController,
                        ),
                        const SizedBox(height: 32),
                        const TextSectionHeader(
                          text: 'Features',
                        ),
                        SwitchSettingsFormField(
                          labelText: 'Enable Push Notifications',
                          value: _featureEnablePush,
                          updateState: ((value) =>
                              setState(() => _featureEnablePush = value)),
                        ),
                        SwitchSettingsFormField(
                          labelText: 'Track Screens',
                          value: _featureTrackScreens,
                          updateState: ((value) =>
                              setState(() => _featureTrackScreens = value)),
                        ),
                        SwitchSettingsFormField(
                          labelText: 'Track Device Attributes',
                          value: _featureTrackDeviceAttributes,
                          updateState: ((value) => setState(
                              () => _featureTrackDeviceAttributes = value)),
                        ),
                        SwitchSettingsFormField(
                          labelText: 'Debug Mode',
                          value: _featureDebugMode,
                          updateState: ((value) =>
                              setState(() => _featureDebugMode = value)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: sizes.buttonDefault(),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final currentConfig = widget._customerIOSDK.configurations;
                  final newConfig = CustomerIOConfigurations(
                    siteId: _siteIDValueController.text,
                    apiKey: _apiKeyValueController.text,
                    organizationId: _organizationIDValueController.text,
                    region: currentConfig.region,
                    trackingUrl: _trackingURLValueController.text,
                    gistEnvironment: currentConfig.gistEnvironment,
                    backgroundQueueSecondsDelay:
                        _bqSecondsDelayValueController.text.toDoubleOrNull(),
                    backgroundQueueMinNumberOfTasks:
                        _bqMinNumberOfTasksValueController.text.toIntOrNull(),
                    featureEnablePush: _featureEnablePush,
                    featureTrackScreens: _featureTrackScreens,
                    featureTrackDeviceAttributes: _featureTrackDeviceAttributes,
                    featureDebugMode: _featureDebugMode,
                  );
                  widget._customerIOSDK
                      .saveConfigurationsToPreferences(newConfig)
                      .then((success) {
                    if (success) {
                      _showSnackBar(context, 'Settings saved successfully');
                      Navigator.of(context).pop();
                      // Restart app here
                    } else {
                      _showSnackBar(context, 'Could not save settings');
                    }
                    return null;
                  });
                }
              },
              child: Text(
                'Save'.toUpperCase(),
              ),
            ),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
              minimumSize: sizes.buttonDefault(),
            ),
            onPressed: () async {
              final defaultConfig =
                  widget._customerIOSDK.getDefaultConfigurations();
              if (defaultConfig != null) {
                setState(() {
                  _siteIDValueController.text = defaultConfig.siteId;
                  _apiKeyValueController.text = defaultConfig.apiKey;
                  _organizationIDValueController.text =
                      defaultConfig.organizationId ?? '';
                  _trackingURLValueController.text =
                      defaultConfig.trackingUrl ?? '';
                  _bqSecondsDelayValueController.text =
                      defaultConfig.backgroundQueueSecondsDelay?.toString() ??
                          '';
                  _bqMinNumberOfTasksValueController.text = defaultConfig
                          .backgroundQueueMinNumberOfTasks
                          ?.toString() ??
                      '';
                  _featureEnablePush = defaultConfig.featureEnablePush == true;
                  _featureTrackScreens =
                      defaultConfig.featureTrackScreens == true;
                  _featureTrackDeviceAttributes =
                      defaultConfig.featureTrackDeviceAttributes == true;
                  _featureDebugMode = defaultConfig.featureDebugMode == true;
                });
                _showSnackBar(context, 'Restored default values');
              } else {
                _showSnackBar(context, 'No default values found');
              }
            },
            child: const Text(
              'Restore Defaults',
            ),
          ),
          const SizedBox(height: 8),
          const TextFooter(
              text: 'Please restart app after saving any modifications'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
