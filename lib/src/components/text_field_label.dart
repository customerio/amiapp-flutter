import 'package:flutter/material.dart';

/// Text field label with semantic label for accessibility
/// If semantic label is not provided, it will use the text as semantic label
class TextFieldLabel extends StatelessWidget {
  final String text;
  final String? semanticLabel;

  const TextFieldLabel({
    super.key,
    required this.text,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          children: <InlineSpan>[
            WidgetSpan(
              child: Text(
                text,
                semanticsLabel: semanticLabel ?? text,
              ),
            ),
          ],
        ),
      );
}
