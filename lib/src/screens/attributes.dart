import 'package:flutter/material.dart';

import '../components/container.dart';

class DeviceAttributesScreen extends StatelessWidget {
  const DeviceAttributesScreen({super.key});

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
                  'Device attribute',
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

class ProfileAttributesScreen extends StatelessWidget {
  const ProfileAttributesScreen({super.key});

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
                  'Profile attribute',
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
