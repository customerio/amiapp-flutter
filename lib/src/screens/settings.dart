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
  String? _deviceToken;

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
    widget._customerIOSDK
        .getDeviceToken()
        .then((value) => setState(() => _deviceToken = value));

    final cioConfig = widget._customerIOSDK.configurations;
    _deviceTokenValueController = TextEditingController(text: _deviceToken);
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
                              Clipboard.setData(
                                      ClipboardData(text: _deviceToken))
                                  .then((_) => _showSnackBar(context,
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
                        ),
                        TextSettingsFormField(
                          labelText: 'API Key',
                          valueController: _apiKeyValueController,
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
                        const TextHeaderSection(
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
                final currentConfig = widget._customerIOSDK.configurations;
                final newConfig = CustomerIOConfigurations(
                  siteId: _siteIDValueController.text,
                  apiKey: _apiKeyValueController.text,
                  organizationId: _organizationIDValueController.text,
                  region: currentConfig.region,
                  trackingUrl: _trackingURLValueController.text,
                  gistEnvironment: currentConfig.gistEnvironment,
                  backgroundQueueSecondsDelay:
                      _bqSecondsDelayValueController.text.toIntOrNull(),
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
                    Navigator.of(context).pop();
                    // Restart app here
                  } else {
                    _showSnackBar(context, 'Could not save settings');
                  }
                  return null;
                });
              },
              child: Text(
                'Save'.toUpperCase(),
              ),
            ),
          ),
          const TextFooter(
              text: 'Editing settings will require an app restart'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
