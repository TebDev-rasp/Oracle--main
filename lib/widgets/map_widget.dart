import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:oracle/widgets/heat_index_leaflet.dart';

class CachingTileProvider extends TileProvider {
  final BaseCacheManager cacheManager;

  CachingTileProvider({BaseCacheManager? cacheManager}) 
      : cacheManager = cacheManager ?? DefaultCacheManager();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return NetworkImage(url);
  }
}

// Rename class to MapWidget
class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  // Remove preloadMapData method as it's no longer needed for OSM

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  // Updated coordinates for San Nicolas, Castillejos
  final castillejosLocation = LatLng(14.9320671, 120.2005402);
  bool isLoading = true;

  @override
  void dispose() {
    _mapController.dispose();
    // Cancel any active subscriptions if you have any
    // _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: castillejosLocation,
            initialZoom: 9,      // Start at zoom level 13
            minZoom: 9,          // Minimum zoom unchanged
            maxZoom: 16,         // Increased max zoom to 17
            onMapReady: () {
              setState(() {
                isLoading = false;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=U1ZGZGT5WX7HvfCaRryf',
              userAgentPackageName: 'com.example.app',
              tileProvider: CachingTileProvider(),
              maxZoom: 16,       // Match MapOptions maxZoom
              minZoom: 9,        // Match MapOptions minZoom
              additionalOptions: const {
                'attribution': '\u003ca href="https://www.maptiler.com/copyright/" target="_blank"\u003e\u0026copy; MapTiler\u003c/a\u003e',
              },
            ),
            HeatIndexLeaflet(
              heatIndex: 32.2,
              markerColor: Colors.orange,
              heatIndexLevel: 'Extreme Caution',
            ),
          ],
        ),
        if (isLoading)
          Container(
            color: Colors.white.withAlpha(204), // 0.8 * 255 = 204
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              _buildMinimalButton(
                icon: Icons.add,
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                },
                heroTag: "zoomIn",
              ),
              const SizedBox(height: 8),
              _buildMinimalButton(
                icon: Icons.remove,
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                },
                heroTag: "zoomOut",
              ),
              const SizedBox(height: 8),
              _buildMinimalButton(
                icon: Icons.my_location,
                onPressed: () {
                  _mapController.move(castillejosLocation, 9);
                },
                heroTag: "resetLocation",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: () {
          if (heroTag == "zoomIn") {
            final newZoom = _mapController.camera.zoom + 1;
            if (newZoom <= 17) {  // Updated max zoom check
              _mapController.move(_mapController.camera.center, newZoom);
            }
          } else if (heroTag == "zoomOut") {
            final newZoom = _mapController.camera.zoom - 1;
            if (newZoom >= 9) {   // Min zoom check unchanged
              _mapController.move(_mapController.camera.center, newZoom);
            }
          } else {
            onPressed();
          }
        },
        mini: true,
        elevation: 2,
        backgroundColor: const Color(0xFFE0E0E0),
        foregroundColor: const Color(0xFF424242),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}