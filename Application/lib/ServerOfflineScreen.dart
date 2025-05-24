import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ServerOfflineScreen extends StatelessWidget {
  const ServerOfflineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.cloud_off, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Server is OFFLINE',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(''),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // Initial connectivity check
    Connectivity().checkConnectivity().then((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      setState(() => _isConnected = connected);
    });
    // Listen for connectivity changes
    _subscription = Connectivity()
      .onConnectivityChanged
      .listen((List<ConnectivityResult> results) {
        final connected = results.any((r) => r != ConnectivityResult.none);
        setState(() => _isConnected = connected);
      });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connection Status')),
      body: Center(
        child: Text(
          _isConnected
            ? 'Contact admin to open server'
            : 'Please connect to the internet',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
