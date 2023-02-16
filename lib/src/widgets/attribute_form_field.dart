import 'package:flutter/material.dart';

class TextAttributeFormField extends StatelessWidget {
  TextAttributeFormField({
    super.key,
    required this.onRemovePress,
  });

  final void Function(TextAttributeFormField field) onRemovePress;
  final _attributeNameController = TextEditingController();
  final _attributeValueController = TextEditingController();

  String get name => _attributeNameController.text;

  String get value => _attributeValueController.text;

  @override
  Widget build(BuildContext context) {
    return UnmanagedRestorationScope(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 35,
            child: TextFormField(
              controller: _attributeNameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Name',
              ),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value?.isNotEmpty == true ? null : 'Name cannot be empty',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 65,
            child: TextFormField(
              controller: _attributeValueController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Value',
              ),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value?.isNotEmpty == true ? null : 'Value cannot be empty',
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.remove),
            tooltip: 'Remove Property',
            onPressed: () {
              onRemovePress(this);
            },
          )
        ],
      ),
    );
  }
}
