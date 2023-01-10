import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../components/container.dart';
import '../customer_io.dart';

class ViewLogsScreen extends StatefulWidget {
  const ViewLogsScreen({super.key});

  @override
  State<ViewLogsScreen> createState() => _ViewLogsScreenState();
}

class _ViewLogsScreenState extends State<ViewLogsScreen> {
  List<String> _logs = [];

  void _fetchLogs() {
    developer.log('Fetching logs from SDK');
    CustomerIOSDKScope.instance()
        .sdk
        .getLogs()
        .then((logs) => setState(() => _logs = logs ?? []));
  }

  @override
  void initState() {
    // fetch initial logs
    _fetchLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      appBar: AppBar(
        title: const Text('View Logs'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Reverse order',
            onPressed: () =>
                setState(() => _logs = _logs.reversed.toList(growable: false)),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Logs',
            onPressed: () => _fetchLogs(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Logs',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        // Let the ListView know how many items it needs to build.
        itemCount: _logs.length,
        // Provide a builder function. This is where the magic happens.
        // Convert each item into a widget based on the type of item it is.
        itemBuilder: (context, index) {
          final log = _logs[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(log),
          );
        },
      ),
    );
  }
}
