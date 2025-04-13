import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:oracle/services/heat_index_leaflet_service.dart';
import 'package:oracle/models/heat_index_marker.dart';

class HeatIndexLeaflet extends StatefulWidget {
  final double heatIndex;
  final Color markerColor;
  final String heatIndexLevel;

  const HeatIndexLeaflet({
    super.key,
    required this.heatIndex,
    required this.markerColor,
    required this.heatIndexLevel,
  });

  @override
  State<HeatIndexLeaflet> createState() => _HeatIndexLeafletState();
}

class _HeatIndexLeafletState extends State<HeatIndexLeaflet> with SingleTickerProviderStateMixin {
  final HeatIndexLeafletService _service = HeatIndexLeafletService();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HeatIndexMarker>(
      stream: _service.getHeatIndexStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final marker = snapshot.data!;
        final location = LatLng(marker.latitude, marker.longitude);

        return MarkerLayer(
          rotate: false,
          markers: [
            Marker(
              point: location,
              width: 250,  // Increased overall size
              height: 250,
              rotate: false,
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulsing circle
                      Container(
                        width: 250 * _animation.value,
                        height: 250 * _animation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: marker.markerColor.withAlpha(50),  // Reduced opacity
                        ),
                      ),
                      // Middle circle
                      Container(
                        width: 100,  // Increased middle circle
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: marker.markerColor.withAlpha(100),  // Reduced opacity
                          boxShadow: [
                            BoxShadow(
                              color: marker.markerColor.withAlpha(40),  // Reduced shadow opacity
                              blurRadius: 20,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Inner circle
                      Container(
                        width: 50,  // Added inner circle
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: marker.markerColor.withAlpha(150),
                          boxShadow: [
                            BoxShadow(
                              color: marker.markerColor.withAlpha(60),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      // Center dot
                      Container(
                        width: 15,  // Small center dot
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: marker.markerColor,  // Full opacity for center dot
                          boxShadow: [
                            BoxShadow(
                              color: marker.markerColor.withAlpha(200),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}