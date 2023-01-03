import 'package:customer_io/customer_io.dart';
import 'package:flutter/material.dart';

import '../components/container.dart';
import '../theme/sizes.dart';
import '../widgets/attribute_form_field.dart';

class DeviceAttributesScreen extends StatefulWidget {
  const DeviceAttributesScreen({super.key});

  @override
  State<DeviceAttributesScreen> createState() => _DeviceAttributesScreenState();
}

class _DeviceAttributesScreenState extends State<DeviceAttributesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customAttributes = <TextAttributeFormField>[];

  @override
  void initState() {
    // adds 1 attribute by default
    _addNewAttribute();
    super.initState();
  }

  void _addNewAttribute() {
    setState(() {
      _customAttributes.add(TextAttributeFormField(
        onRemovePress: _removeAttribute,
      ));
    });
  }

  void _removeAttribute(TextAttributeFormField formField) {
    setState(() {
      _customAttributes.remove(formField);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;

    return AppContainer(
      appBar: AppBar(
        title: const Text('Device Attributes'),
        backgroundColor: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Attribute',
            onPressed: () {
              _addNewAttribute();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: _customAttributes,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: sizes.buttonDefault(),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var attributes = {
                      for (var attribute in _customAttributes)
                        attribute.name: attribute.value
                    };
                    CustomerIO.setDeviceAttributes(attributes: attributes);
                  }
                },
                child: const Text(
                  'Send Device Attributes',
                ),
              ),
            ],
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
  final _customAttributes = <TextAttributeFormField>[];

  @override
  void initState() {
    // adds 1 attribute by default
    _addNewAttribute();
    super.initState();
  }

  void _addNewAttribute() {
    setState(() {
      _customAttributes.add(TextAttributeFormField(
        onRemovePress: _removeAttribute,
      ));
    });
  }

  void _removeAttribute(TextAttributeFormField formField) {
    setState(() {
      _customAttributes.remove(formField);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;

    return AppContainer(
      appBar: AppBar(
        title: const Text('Profile Attributes'),
        backgroundColor: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Attribute',
            onPressed: () {
              _addNewAttribute();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: _customAttributes,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: sizes.buttonDefault(),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var attributes = {
                      for (var attribute in _customAttributes)
                        attribute.name: attribute.value
                    };
                    CustomerIO.setProfileAttributes(attributes: attributes);
                  }
                },
                child: const Text(
                  'Send Profile Attributes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
