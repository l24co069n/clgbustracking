import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/location_provider.dart';
import '../../models/bus_model.dart';
import '../../models/route_model.dart';

class DriverMapScreen extends StatefulWidget {
  final BusModel bus;
  final RouteModel? route;

  const DriverMapScreen({
    super.key,
    required this.bus,
    this.route,
  });

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _createRouteMarkers();
  }

  void _createRouteMarkers() {
    if (widget.route == null) return;

    final markers = <Marker>{};
    final polylinePoints = <LatLng>[];

    // Add start point marker
    final startLatLng = LatLng(0.0, 0.0); // Default coordinates
    markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: startLatLng,
        infoWindow: InfoWindow(title: 'Start: ${widget.route!.startPoint}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    polylinePoints.add(startLatLng);

    // Add stop markers
    for (final stop in widget.route!.stops) {
      final stopLatLng = LatLng(stop.latitude, stop.longitude);
      markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.order}'),
          position: stopLatLng,
          infoWindow: InfoWindow(title: 'Stop ${stop.order}: ${stop.name}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      polylinePoints.add(stopLatLng);
    }

    // Add end point marker
    final endLatLng = LatLng(0.0, 0.0); // Default coordinates
    markers.add(
      Marker(
        markerId: const MarkerId('end'),
        position: endLatLng,
        infoWindow: InfoWindow(title: 'End: ${widget.route!.endPoint}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    polylinePoints.add(endLatLng);

    // Create polyline
    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylinePoints,
        color: Colors.blue,
        width: 4,
      ),
    };

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driving Bus ${widget.bus.busNumber}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: locationProvider.isSharing ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      locationProvider.isSharing ? Icons.location_on : Icons.location_off,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locationProvider.isSharing ? 'LIVE' : 'OFFLINE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bus Info
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_bus, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Bus ${widget.bus.busNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (widget.route != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Route: ${widget.route!.routeName} (${widget.route!.type.toString().split('.').last.toUpperCase()})',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(28.6139, 77.2090), // Default to Delhi
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ),
          ),
          
          // Control Panel
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                return Column(
                  children: [
                    // Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          locationProvider.isSharing ? Icons.location_on : Icons.location_off,
                          color: locationProvider.isSharing ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          locationProvider.isSharing ? 'Location Sharing Active' : 'Location Sharing Stopped',
                          style: TextStyle(
                            color: locationProvider.isSharing ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stop Button
                    SizedBox(
                      width: 200,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          await locationProvider.stopLocationSharing();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'STOP SHARING',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}