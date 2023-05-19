import 'package:customer_io/customer_io.dart';
import 'package:flutter/material.dart';

import '../components/container.dart';
import '../components/scroll_view.dart';
import '../theme/sizes.dart';
import '../utils/extensions.dart';

class CustomEventScreen extends StatefulWidget {
  const CustomEventScreen({super.key});

  @override
  State<CustomEventScreen> createState() => _CustomEventScreenState();
}

class _CustomEventScreenState extends State<CustomEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _attributeNameController = TextEditingController();
  final _attributeValueController = TextEditingController();

  /// Shows success message and navigates up when event tracking is complete
  void _onEventTracked() {
    context.showSnackBar('Event tracked successfully');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;

    return AppContainer(
      appBar: AppBar(
        title: const Text('Custom Event'),
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
                  controller: _eventNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Event Name',
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value?.isNotEmpty == true
                      ? null
                      : 'Event name cannot be empty',
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 8),
                TextFormField(
                  controller: _attributeValueController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Property Value',
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value?.isNotEmpty == true
                      ? null
                      : 'Property value cannot be empty',
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
                      CustomerIO.track(
                          name: _eventNameController.text,
                          attributes: attributes);
                      _onEventTracked();
                    }
                  },
                  child: const Text(
                    'Send Event',
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
