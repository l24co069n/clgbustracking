import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../models/bus_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'create_bus_screen.dart';

class BusManagementScreen extends StatefulWidget {
  const BusManagementScreen({super.key});

  @override
  State<BusManagementScreen> createState() => _BusManagementScreenState();
}

class _BusManagementScreenState extends State<BusManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Buses'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BusProvider>(
        builder: (context, busProvider, child) {
          if (busProvider.buses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_bus,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No buses created yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Create First Bus',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateBusScreen(),
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
              // Add Bus Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: 'Add New Bus',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateBusScreen(),
                      ),
                    );
                  },
                ),
              ),
              
              // Bus List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: busProvider.buses.length,
                  itemBuilder: (context, index) {
                    final bus = busProvider.buses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.directions_bus,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        title: Text(
                          'Bus ${bus.busNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driver: ${bus.driverName ?? 'Not assigned'}'),
                            Text('Capacity: ${bus.capacity} seats'),
                            if (bus.description != null)
                              Text('Description: ${bus.description}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'assign_driver',
                              child: Row(
                                children: [
                                  Icon(Icons.person_add),
                                  SizedBox(width: 8),
                                  Text('Assign Driver'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editBus(bus);
                            } else if (value == 'assign_driver') {
                              _assignDriver(bus);
                            } else if (value == 'delete') {
                              _deleteBus(bus.id);
                            }
                          },
                        ),
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

  void _editBus(BusModel bus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBusScreen(bus: bus),
      ),
    );
  }

  void _assignDriver(BusModel bus) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    busProvider.loadAvailableDrivers(authProvider.user!.collegeName!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Driver to Bus ${bus.busNumber}'),
        content: Consumer<BusProvider>(
          builder: (context, busProvider, child) {
            if (busProvider.availableDrivers.isEmpty) {
              return const Text('No available drivers found');
            }

            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Driver',
                border: OutlineInputBorder(),
              ),
              items: busProvider.availableDrivers.map((driver) {
                return DropdownMenuItem(
                  value: driver.id,
                  child: Text(driver.name),
                );
              }).toList(),
              onChanged: (driverId) {
                if (driverId != null) {
                  final driver = busProvider.availableDrivers
                      .firstWhere((d) => d.id == driverId);
                  
                  busProvider.assignDriver(bus.id, driverId, driver.name);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Driver assigned successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBus(String busId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: const Text('Are you sure you want to delete this bus?'),
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
      final busProvider = Provider.of<BusProvider>(context, listen: false);
      final error = await busProvider.deleteBus(busId);
      
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
            content: Text('Bus deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}