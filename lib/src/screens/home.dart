import 'dart:async';

import 'package:amiapp_flutter/src/random.dart';
import 'package:customer_io/customer_io.dart';
import 'package:customer_io/customer_io_inapp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth.dart';
import '../components/container.dart';
import '../components/scroll_view.dart';
import '../constants.dart';
import '../customer_io.dart';
import '../theme/sizes.dart';
import '../widgets/app_footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _email;
  String? _userAgent;
  late StreamSubscription inAppMessageStreamSubscription;

  @override
  void dispose() {
    /// Stop listening to streams
    inAppMessageStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    final customerIOSDK = CustomerIOSDKInstance.get();
    customerIOSDK
        .fetchProfileIdentifier()
        .then((value) => setState(() => _email = value));
    customerIOSDK
        .getUserAgent()
        .then((value) => setState(() => _userAgent = value));

    if (customerIOSDK.isInAppEnabled()) {
      inAppMessageStreamSubscription =
          CustomerIO.subscribeToInAppEventListener(handleInAppEvent);
    }
    super.initState();
  }

  void handleInAppEvent(InAppEvent event) {
    switch (event.eventType) {
      case EventType.messageShown:
        trackInAppEvent('message_shown', event.message);
        debugPrint("messageShown: ${event.message}");
        break;
      case EventType.messageDismissed:
        trackInAppEvent('message_dismissed', event.message);
        debugPrint("messageDismissed: ${event.message}");
        break;
      case EventType.errorWithMessage:
        trackInAppEvent('errorWithMessage', event.message);
        debugPrint("errorWithMessage: ${event.message}");
        break;
      case EventType.messageActionTaken:
        trackInAppEvent('messageActionTaken', event.message, arguments: {
          'actionName': event.actionName,
          'actionValue': event.actionValue,
        });
        debugPrint("messageActionTaken: ${event.message}");
        break;
    }
  }

  void trackInAppEvent(String eventName, InAppMessage message,
      {Map<String, dynamic> arguments = const {}}) {
    Map<String, dynamic> attributes = {
      'event_name': eventName,
      'message_id': message.messageId,
      'delivery_id': message.deliveryId ?? 'NULL',
    };
    attributes.addAll(arguments);

    CustomerIO.track(
      name: 'In-App Event',
      attributes: attributes,
    );
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
              context.push(URLPath.settings);
            },
          ),
        ],
      ),
      body: FullScreenScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hi, $_email',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
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
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList();

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _sendRandomEvent(BuildContext context) {
    final randomValues = RandomValues();
    final eventName = randomValues.getEventName();
    CustomerIO.track(
        name: eventName, attributes: randomValues.getEventAttributes());
    _showSnackBar(context, 'Event tracked with name: $eventName');
  }

  @override
  Widget build(BuildContext context) {
    final authState = AmiAppAuthScope.of(context);
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;
    const actionItems = _ActionItem.values;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 32.0),
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
                      switch (item) {
                        case _ActionItem.randomEvent:
                          _sendRandomEvent(context);
                          break;
                        case _ActionItem.signOut:
                          authState.signOut();
                          break;
                        default:
                          final String? location = item.targetLocation();
                          if (location != null) {
                            context.push(location);
                          }
                          break;
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

  String? targetLocation() {
    switch (this) {
      case _ActionItem.randomEvent:
        return null;
      case _ActionItem.customEvent:
        return URLPath.customEvents;
      case _ActionItem.deviceAttributes:
        return URLPath.deviceAttributes;
      case _ActionItem.profileAttributes:
        return URLPath.profileAttributes;
      case _ActionItem.viewLogs:
        return URLPath.viewLogs;
      case _ActionItem.signOut:
        return null;
    }
  }
}
