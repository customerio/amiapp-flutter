import 'package:flutter/material.dart';

import '../components/container.dart';

class CustomEventScreen extends StatelessWidget {
  const CustomEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Custom event',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
