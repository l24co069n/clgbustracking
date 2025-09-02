import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/location_provider.dart';
import '../../providers/route_provider.dart';
import '../../models/bus_model.dart';
import '../../models/route_model.dart';

class BusTrackingScreen extends StatefulWidget {
  final BusModel bus;

  const BusTrackingScreen({super.key, required this.bus});

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _busLocation;

  @override
  void initState() {
    super.initState();
    _loadRouteData();
    _listenToBusLocation();
  }

  void _loadRouteData() {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final routes = routeProvider.getRoutesByBusId(widget.bus.id);
    
    if (routes.isNotEmpty) {
      _createRouteMarkers(routes.first);
    }
  }

  void _createRouteMarkers(RouteModel route) {
    final markers = <Marker>{};
    final polylinePoints = <LatLng>[];

    // Add start point marker
    final startLatLng = LatLng(0.0, 0.0); // Default coordinates
    markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: startLatLng,
        infoWindow: InfoWindow(title: 'Start: ${route.startPoint}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    polylinePoints.add(startLatLng);

    // Add stop markers
    for (final stop in route.stops) {
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
        infoWindow: InfoWindow(title: 'End: ${route.endPoint}'),
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

  void _listenToBusLocation() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    locationProvider.getBusLocation(widget.bus.id).listen((locationData) {
      if (locationData != null && mounted) {
        final lat = locationData['latitude']?.toDouble() ?? 0.0;
        final lng = locationData['longitude']?.toDouble() ?? 0.0;
        final isSharing = locationData['isSharing'] ?? false;

        if (isSharing) {
          final busLatLng = LatLng(lat, lng);
          
          setState(() {
            _busLocation = busLatLng;
            _markers.removeWhere((marker) => marker.markerId.value == 'bus');
            _markers.add(
              Marker(
                markerId: const MarkerId('bus'),
                position: busLatLng,
                infoWindow: InfoWindow(title: 'Bus ${widget.bus.busNumber}'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              ),
            );
          });

          // Move camera to bus location
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(busLatLng),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus ${widget.bus.busNumber}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bus Info Card
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Driver', widget.bus.driverName ?? 'Not assigned'),
                _buildInfoRow('Capacity', '${widget.bus.capacity} seats'),
                _buildInfoRow('College', widget.bus.collegeName),
                if (widget.bus.description != null)
                  _buildInfoRow('Description', widget.bus.description!),
                
                const SizedBox(height: 12),
                
                // Location Status
                StreamBuilder<Map<String, dynamic>?>(
                  stream: Provider.of<LocationProvider>(context, listen: false)
                      .getBusLocation(widget.bus.id),
                  builder: (context, snapshot) {
                    final isSharing = snapshot.data?['isSharing'] ?? false;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSharing ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSharing ? Icons.location_on : Icons.location_off,
                            size: 16,
                            color: isSharing ? Colors.green.shade600 : Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSharing ? 'Live Tracking' : 'Not Tracking',
                            style: TextStyle(
                              color: isSharing ? Colors.green.shade600 : Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                    zoom: 12,
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
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}