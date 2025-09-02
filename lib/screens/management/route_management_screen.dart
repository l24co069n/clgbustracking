import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/route_provider.dart';
import '../../models/route_model.dart';
import '../../widgets/custom_button.dart';
import 'create_route_screen.dart';

class RouteManagementScreen extends StatefulWidget {
  const RouteManagementScreen({super.key});

  @override
  State<RouteManagementScreen> createState() => _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          if (routeProvider.routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.route,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No routes created yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Create First Route',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateRouteScreen(),
                        ),
                      );
                    },
                    width: 200,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Add Route Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: 'Add New Route',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateRouteScreen(),
                      ),
                    );
                  },
                ),
              ),
              
              // Route List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: routeProvider.routes.length,
                  itemBuilder: (context, index) {
                    final route = routeProvider.routes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: route.type == RouteType.pickup 
                              ? Colors.green.shade100 
                              : Colors.orange.shade100,
                          child: Icon(
                            route.type == RouteType.pickup 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward,
                            color: route.type == RouteType.pickup 
                                ? Colors.green.shade600 
                                : Colors.orange.shade600,
                          ),
                        ),
                        title: Text(
                          route.routeName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${route.type.toString().split('.').last.toUpperCase()} • ${route.stops.length} stops',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRouteInfo('Start', route.startPoint),
                                ...route.stops.map((stop) => 
                                    _buildRouteInfo('Stop ${stop.order}', stop.name)),
                                _buildRouteInfo('End', route.endPoint),
                                
                                const SizedBox(height: 16),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _editRoute(route),
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _deleteRoute(route.id),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRouteInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  void _editRoute(RouteModel route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRouteScreen(route: route),
      ),
    );
  }

  Future<void> _deleteRoute(String routeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final routeProvider = Provider.of<RouteProvider>(context, listen: false);
      final error = await routeProvider.deleteRoute(routeId);
      
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}