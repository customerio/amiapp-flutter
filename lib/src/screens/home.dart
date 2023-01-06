import 'package:customer_io/customer_io.dart';
import 'package:flutter/material.dart';

import '../auth.dart';
import '../components/container.dart';
import '../customer_io.dart';
import '../theme/sizes.dart';
import '../widgets/app_footer.dart';
import 'attributes.dart';
import 'events.dart';
import 'logs.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userAgent;

  @override
  void initState() {
    CustomerIOSDKScope.instance()
        .sdk
        .getUserAgent()
        .then((value) => setState(() => _userAgent = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Open SDK Configurations',
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Spacer(),
                Center(
                  child: Text(
                    'What would you like to test?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const _ActionList(),
                const Spacer(),
                TextFooter(text: _userAgent ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList();

  void sendRandomEvent() {
    CustomerIO.track(name: "ButtonClick", attributes: {
      'stringType': 'message',
      'numberType': 123,
      'booleanType': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = AmiAppAuthScope.of(context);
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;
    const actionItems = _ActionItem.values;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actionItems
            .map((item) => Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: sizes.buttonDefault(),
                    ),
                    onPressed: () {
                      late Route<dynamic>? route;
                      switch (item) {
                        case _ActionItem.randomEvent:
                          sendRandomEvent();
                          route = null;
                          break;
                        case _ActionItem.customEvent:
                          route = MaterialPageRoute<void>(
                            builder: (context) => const CustomEventScreen(),
                          );
                          break;
                        case _ActionItem.deviceAttributes:
                          route = MaterialPageRoute<void>(
                            builder: (context) =>
                                const DeviceAttributesScreen(),
                          );
                          break;
                        case _ActionItem.profileAttributes:
                          route = MaterialPageRoute<void>(
                            builder: (context) =>
                                const ProfileAttributesScreen(),
                          );
                          break;
                        case _ActionItem.viewLogs:
                          route = MaterialPageRoute<void>(
                            builder: (context) => const ViewLogsScreen(),
                          );
                          break;
                        case _ActionItem.signOut:
                          authState.signOut();
                          route = null;
                          break;
                      }
                      if (route != null) {
                        Navigator.of(context).push<void>(route);
                      }
                    },
                    child: Text(
                      item.buildText(),
                    ),
                  ),
                ))
            .toList(growable: false),
      ),
    );
  }
}

/// Enum that contains actions to perform on SDK.
enum _ActionItem {
  randomEvent,
  customEvent,
  deviceAttributes,
  profileAttributes,
  viewLogs,
  signOut,
}

extension _ActionNames on _ActionItem {
  String buildText() {
    switch (this) {
      case _ActionItem.randomEvent:
        return "Send Random Event";
      case _ActionItem.customEvent:
        return "Send Custom Event";
      case _ActionItem.deviceAttributes:
        return "Set Device Attributes";
      case _ActionItem.profileAttributes:
        return "Set Profile Attributes";
      case _ActionItem.viewLogs:
        return "View Logs";
      case _ActionItem.signOut:
        return "Log Out";
    }
  }
}
