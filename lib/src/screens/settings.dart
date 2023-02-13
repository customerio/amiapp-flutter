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

  CustomerIOSDK get _customerIOSDK => CustomerIOSDKInstance.get();

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _deviceTokenValueController;
  late final TextEditingController _trackingURLValueController;
  late final TextEditingController _siteIDValueController;
  late final TextEditingController _apiKeyValueController;
  late final TextEditingController _bqSecondsDelayValueController;
  late final TextEditingController _bqMinNumberOfTasksValueController;

  late bool _featureTrackScreens;
  late bool _featureEnableInApp;
  late bool _featureTrackDeviceAttributes;
  late bool _featureDebugMode;

  @override
  void initState() {
    widget._customerIOSDK.getDeviceToken().then((value) =>
        setState(() => _deviceTokenValueController.text = value ?? ''));

    final cioConfig = widget._customerIOSDK.configurations;
    _deviceTokenValueController = TextEditingController();
    _trackingURLValueController =
        TextEditingController(text: cioConfig?.trackingUrl);
    _siteIDValueController = TextEditingController(text: cioConfig?.siteId);
    _apiKeyValueController = TextEditingController(text: cioConfig?.apiKey);
    _bqSecondsDelayValueController = TextEditingController(
        text: cioConfig?.backgroundQueueSecondsDelay?.toString());
    _bqMinNumberOfTasksValueController = TextEditingController(
        text: cioConfig?.backgroundQueueMinNumberOfTasks?.toString());
    _featureTrackScreens = cioConfig?.featureTrackScreens ?? true;
    _featureTrackDeviceAttributes =
        cioConfig?.featureTrackDeviceAttributes ?? true;
    _featureEnableInApp = cioConfig?.enableInApp ?? true;
    _featureDebugMode = cioConfig?.featureDebugMode ?? true;

    super.initState();
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _saveSettings() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentConfig = widget._customerIOSDK.configurations;
    final newConfig = CustomerIOConfigurations(
      siteId: _siteIDValueController.text,
      apiKey: _apiKeyValueController.text,
      enableInApp: _featureEnableInApp,
      region: currentConfig?.region,
      trackingUrl: _trackingURLValueController.text,
      gistEnvironment: currentConfig?.gistEnvironment,
      backgroundQueueSecondsDelay:
          _bqSecondsDelayValueController.text.toDoubleOrNull(),
      backgroundQueueMinNumberOfTasks:
          _bqMinNumberOfTasksValueController.text.toIntOrNull(),
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

  void _restoreDefaultSettings() {
    final defaultConfig = widget._customerIOSDK.getDefaultConfigurations();
    if (defaultConfig == null) {
      _showSnackBar(context, 'No default values found');
      return;
    }

    setState(() {
      _siteIDValueController.text = defaultConfig.siteId;
      _apiKeyValueController.text = defaultConfig.apiKey;
      _featureEnableInApp = defaultConfig.enableInApp;
      _trackingURLValueController.text = defaultConfig.trackingUrl ?? '';
      _bqSecondsDelayValueController.text =
          defaultConfig.backgroundQueueSecondsDelay?.toString() ?? '';
      _bqMinNumberOfTasksValueController.text =
          defaultConfig.backgroundQueueMinNumberOfTasks?.toString() ?? '';
      _featureTrackScreens = defaultConfig.featureTrackScreens;
      _featureTrackDeviceAttributes =
          defaultConfig.featureTrackDeviceAttributes;
      _featureDebugMode = defaultConfig.featureDebugMode;
    });
    _showSnackBar(context, 'Restored default values');
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
                        SwitchSettingsFormField(
                          labelText: 'Enable In-app',
                          value: _featureEnableInApp,
                          updateState: ((value) =>
                              setState(() => _featureEnableInApp = value)),
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
              onPressed: () => _saveSettings(),
              child: Text(
                'Save'.toUpperCase(),
              ),
            ),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
              minimumSize: sizes.buttonDefault(),
            ),
            onPressed: () => _restoreDefaultSettings(),
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
