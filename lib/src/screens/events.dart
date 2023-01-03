import 'package:customer_io/customer_io.dart';
import 'package:flutter/material.dart';

import '../components/container.dart';
import '../theme/sizes.dart';
import '../widgets/attribute_form_field.dart';

class CustomEventScreen extends StatefulWidget {
  const CustomEventScreen({super.key});

  @override
  State<CustomEventScreen> createState() => _CustomEventScreenState();
}

class _CustomEventScreenState extends State<CustomEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
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
        title: const Text('Custom Event'),
        backgroundColor: null,
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
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Event Name',
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                validator: (value) => value?.isNotEmpty == true
                    ? null
                    : 'Event name cannot be empty',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Properties',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add New Property',
                    onPressed: () {
                      _addNewAttribute();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                    CustomerIO.track(
                        name: _eventNameController.text,
                        attributes: attributes);
                  }
                },
                child: const Text(
                  'Send Event',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
