import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for SystemNavigator
import '../services/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class RetryConnectionOverlay extends StatefulWidget {
  final Widget child;

  const RetryConnectionOverlay({
    super.key,
    required this.child,
  });

  @override
  State<RetryConnectionOverlay> createState() => _RetryConnectionOverlayState();
}

class _RetryConnectionOverlayState extends State<RetryConnectionOverlay>
    with SingleTickerProviderStateMixin {
  bool _showDialog = false;
  Timer? _checkTimer;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startConnectionCheck(ConnectivityService service) {
    _checkTimer?.cancel();
    _checkTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && service.lastStatus == ConnectionStatus.offline) {
        setState(() => _showDialog = true);
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry(ConnectivityService service) async {
    setState(() => _showDialog = false);
    await service.checkConnection();
    if (service.hasConnection) {
      _animationController.reverse();
    } else {
      _startConnectionCheck(service);
    }
  }

  // Method for "Exit" button - exits the app
  void _handleExit() {
    SystemNavigator.pop(); // This will close the app
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, service, _) {
        if (!service.isInitialized) {
          return widget.child;
        }

        // Only check if we should show alerts based on user preference
        if (!service.hasConnection &&
            !_showDialog &&
            service.showConnectionAlerts) {
          _startConnectionCheck(service);
        } else if (service.hasConnection && _showDialog) {
          // Auto dismiss when connection is restored
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _showDialog = false);
            _animationController.reverse();
          });
        }

        return Stack(
          children: [
            widget.child,
            if (!service.hasConnection && service.showConnectionAlerts)
              AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: GestureDetector(
                      // Changed to retry connection when tapping outside
                      onTap: () => _handleRetry(service),
                      child: Container(
                        color: Colors.black.withAlpha(153),
                        child: Center(
                          child: !_showDialog
                              ? const CircularProgressIndicator()
                              : GestureDetector(
                                  // Add this nested GestureDetector to prevent taps on the card
                                  // from dismissing the overlay
                                  onTap:
                                      () {}, // Empty callback to absorb the tap
                                  child: Card(
                                    elevation: 8,
                                    margin: const EdgeInsets.all(16),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 16,
                                        top: 24,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'No Internet Connection',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Please check your connection and try again.',
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: _handleExit,
                                                  child: const Text('Exit'),
                                                ),
                                                const SizedBox(width: 8),
                                                FilledButton.icon(
                                                  onPressed: () =>
                                                      _handleRetry(service),
                                                  icon:
                                                      const Icon(Icons.refresh),
                                                  label: const Text('Retry'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
