import 'package:customer_io/customer_io.dart';
import 'package:flutter/material.dart';

import '../components/container.dart';
import '../components/scroll_view.dart';
import '../theme/sizes.dart';
import '../utils/extensions.dart';

class DeviceAttributesScreen extends StatefulWidget {
  const DeviceAttributesScreen({super.key});

  @override
  State<DeviceAttributesScreen> createState() => _DeviceAttributesScreenState();
}

class _DeviceAttributesScreenState extends State<DeviceAttributesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _attributeNameController = TextEditingController();
  final _attributeValueController = TextEditingController();

  /// Shows success message and navigates up when event tracking is complete
  void _onEventTracked() {
    context.showSnackBar('Device attributes tracked successfully');
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;

    return AppContainer(
      appBar: AppBar(
        title: const Text('Device Attributes'),
        backgroundColor: null,
      ),
      body: FullScreenScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(),
                TextFormField(
                  controller: _attributeNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Property Name',
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value?.isNotEmpty == true
                      ? null
                      : 'Property name cannot be empty',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _attributeValueController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Property Value',
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: sizes.buttonDefault(),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var attributes = {
                        _attributeNameController.text:
                            _attributeValueController.value,
                      };
                      CustomerIO.setDeviceAttributes(attributes: attributes);
                      _onEventTracked();
                    }
                  },
                  child: const Text(
                    'Send Device Attributes',
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileAttributesScreen extends StatefulWidget {
  const ProfileAttributesScreen({super.key});

  @override
  State<ProfileAttributesScreen> createState() =>
      _ProfileAttributesScreenState();
}

class _ProfileAttributesScreenState extends State<ProfileAttributesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _attributeNameController = TextEditingController();
  final _attributeValueController = TextEditingController();

  /// Shows success message and navigates up when event tracking is complete
  void _onEventTracked() {
    context.showSnackBar('Profile attributes tracked successfully');
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;

    return AppContainer(
        appBar: AppBar(
          title: const Text('Profile Attributes'),
          backgroundColor: null,
        ),
        body: FullScreenScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Spacer(),
                  TextFormField(
                    controller: _attributeNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Property Name',
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value?.isNotEmpty == true
                        ? null
                        : 'Property name cannot be empty',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _attributeValueController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Property Value',
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      minimumSize: sizes.buttonDefault(),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        var attributes = {
                          _attributeNameController.text:
                              _attributeValueController.value,
                        };
                        CustomerIO.setProfileAttributes(attributes: attributes);
                        _onEventTracked();
                      }
                    },
                    child: const Text(
                      'Send Profile Attributes',
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ));
  }
}
