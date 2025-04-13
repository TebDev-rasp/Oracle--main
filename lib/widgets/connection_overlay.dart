import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;

  const NetworkAwareWidget({
    super.key,
    required this.child,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  bool _showDialog = false;
  Timer? _checkTimer;

  void _startConnectionCheck(ConnectivityService service) {
    _checkTimer?.cancel();
    _checkTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && service.lastStatus == ConnectionStatus.offline) {
        setState(() => _showDialog = true);
      }
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRetry(ConnectivityService service) async {
    setState(() => _showDialog = false);
    await service.checkConnection();
    _startConnectionCheck(service);
  }

  void _handleCancel() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, service, _) {
        if (!service.isInitialized) {
          return widget.child;
        }

        if (!service.hasConnection && !_showDialog) {
          _startConnectionCheck(service);
        }

        return Stack(
          children: [
            widget.child,
            if (!service.hasConnection)
              Container(
                color: Colors.black.withAlpha(153), // More subtle overlay
                child: Center(
                  child: !_showDialog
                      ? const CircularProgressIndicator()
                      : AlertDialog(
                          content: const Text(
                            'Please check your internet connection.',
                            textAlign: TextAlign.center,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                          actions: [
                            TextButton(
                              onPressed: _handleCancel,
                              child: const Text('Exit'),
                            ),
                            FilledButton(
                              onPressed: () => _handleRetry(service),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}