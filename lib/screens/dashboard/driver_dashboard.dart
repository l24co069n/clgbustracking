import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/route_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/bus_model.dart';
import '../../models/route_model.dart';
import '../../widgets/custom_button.dart';
import '../tracking/driver_map_screen.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  BusModel? _selectedBus;
  RouteModel? _selectedRoute;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    if (authProvider.user != null) {
      busProvider.loadBuses(collegeName: authProvider.user!.collegeName);
      routeProvider.loadRoutes(collegeName: authProvider.user!.collegeName);
    }
  }

  Future<void> _startLocationSharing() async {
    if (_selectedBus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bus first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    final error = await locationProvider.startLocationSharing(
      busId: _selectedBus!.id,
      driverId: authProvider.user!.id,
    );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverMapScreen(
            bus: _selectedBus!,
            route: _selectedRoute,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${authProvider.user?.name ?? 'Driver'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'College: ${authProvider.user?.collegeName ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bus Selection
              Consumer<BusProvider>(
                builder: (context, busProvider, child) {
                  final availableBuses = busProvider.buses
                      .where((bus) => bus.driverId == authProvider.user?.id || bus.driverId == null)
                      .toList();

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Bus',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<BusModel>(
                            value: _selectedBus,
                            decoration: const InputDecoration(
                              labelText: 'Choose Bus',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.directions_bus),
                            ),
                            items: availableBuses.map((bus) {
                              return DropdownMenuItem(
                                value: bus,
                                child: Text('${bus.busNumber} - ${bus.collegeName}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBus = value;
                                _selectedRoute = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Route Selection
              if (_selectedBus != null)
                Consumer<RouteProvider>(
                  builder: (context, routeProvider, child) {
                    final availableRoutes = routeProvider.routes
                        .where((route) => route.busId == _selectedBus!.id || route.busId == null)
                        .toList();

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Route',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<RouteModel>(
                              value: _selectedRoute,
                              decoration: const InputDecoration(
                                labelText: 'Choose Route',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.route),
                              ),
                              items: availableRoutes.map((route) {
                                return DropdownMenuItem(
                                  value: route,
                                  child: Text('${route.routeName} (${route.type.toString().split('.').last})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoute = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Start Button
              Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  return Center(
                    child: Container(
                      width: 200,
                      height: 80,
                      child: CustomButton(
                        text: locationProvider.isSharing ? 'STOP' : 'START',
                        onPressed: _selectedBus == null 
                            ? null 
                            : locationProvider.isSharing
                                ? () async {
                                    await locationProvider.stopLocationSharing();
                                  }
                                : _startLocationSharing,
                        backgroundColor: locationProvider.isSharing ? Colors.red : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Status Info
              if (_selectedBus != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Assignment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Bus Number', _selectedBus!.busNumber),
                        _buildInfoRow('College', _selectedBus!.collegeName),
                        if (_selectedRoute != null) ...[
                          _buildInfoRow('Route', _selectedRoute!.routeName),
                          _buildInfoRow('Type', _selectedRoute!.type.toString().split('.').last.toUpperCase()),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}