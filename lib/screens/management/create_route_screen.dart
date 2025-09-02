import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/route_provider.dart';
import '../../models/route_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CreateRouteScreen extends StatefulWidget {
  final RouteModel? route;

  const CreateRouteScreen({super.key, this.route});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _routeNameController = TextEditingController();
  final _startPointController = TextEditingController();
  final _endPointController = TextEditingController();

  RouteType _selectedType = RouteType.pickup;
  List<RouteStop> _stops = [];

  bool get isEditing => widget.route != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _routeNameController.text = widget.route!.routeName;
      _startPointController.text = widget.route!.startPoint;
      _endPointController.text = widget.route!.endPoint;
      _selectedType = widget.route!.type;
      _stops = List.from(widget.route!.stops);
    }
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _startPointController.dispose();
    _endPointController.dispose();
    super.dispose();
  }

  void _addStop() {
    showDialog(
      context: context,
      builder: (context) => _AddStopDialog(
        onAdd: (stop) {
          setState(() {
            _stops.add(stop);
            _stops.sort((a, b) => a.order.compareTo(b.order));
          });
        },
        existingOrders: _stops.map((s) => s.order).toList(),
      ),
    );
  }

  void _editStop(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddStopDialog(
        stop: _stops[index],
        onAdd: (stop) {
          setState(() {
            _stops[index] = stop;
            _stops.sort((a, b) => a.order.compareTo(b.order));
          });
        },
        existingOrders: _stops.where((s) => s != _stops[index]).map((s) => s.order).toList(),
      ),
    );
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  Future<void> _saveRoute() async {
    if (!_formKey.currentState!.validate()) return;

    if (_stops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one stop'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    String? error;

    if (isEditing) {
      error = await routeProvider.updateRoute(widget.route!.id, {
        'routeName': _routeNameController.text.trim(),
        'type': _selectedType.toString(),
        'startPoint': _startPointController.text.trim(),
        'endPoint': _endPointController.text.trim(),
        'stops': _stops.map((stop) => stop.toMap()).toList(),
      });
    } else {
      error = await routeProvider.createRoute(
        routeName: _routeNameController.text.trim(),
        type: _selectedType,
        startPoint: _startPointController.text.trim(),
        endPoint: _endPointController.text.trim(),
        stops: _stops,
        collegeName: authProvider.user!.collegeName!,
        coordinatorId: authProvider.user!.id,
      );
    }

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Route updated successfully' : 'Route created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Route' : 'Create Route'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Route Name
                CustomTextField(
                  controller: _routeNameController,
                  label: 'Route Name',
                  prefixIcon: Icons.route,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter route name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Route Type
                DropdownButtonFormField<RouteType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Route Type',
                    prefixIcon: Icon(Icons.swap_vert),
                    border: OutlineInputBorder(),
                  ),
                  items: RouteType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Start Point
                CustomTextField(
                  controller: _startPointController,
                  label: 'Start Point',
                  prefixIcon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter start point';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // End Point
                CustomTextField(
                  controller: _endPointController,
                  label: 'End Point',
                  prefixIcon: Icons.flag,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter end point';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Stops Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Route Stops',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _addStop,
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Stops List
                if (_stops.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Text(
                        'No stops added yet\nTap + to add stops',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...List.generate(_stops.length, (index) {
                    final stop = _stops[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            stop.order.toString(),
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(stop.name),
                        subtitle: Text('Lat: ${stop.latitude}, Lng: ${stop.longitude}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _editStop(index),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => _removeStop(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                
                const SizedBox(height: 32),
                
                // Save Button
                Consumer<RouteProvider>(
                  builder: (context, routeProvider, child) {
                    return CustomButton(
                      text: isEditing ? 'Update Route' : 'Create Route',
                      onPressed: routeProvider.isLoading ? null : _saveRoute,
                      isLoading: routeProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddStopDialog extends StatefulWidget {
  final RouteStop? stop;
  final Function(RouteStop) onAdd;
  final List<int> existingOrders;

  const _AddStopDialog({
    this.stop,
    required this.onAdd,
    required this.existingOrders,
  });

  @override
  State<_AddStopDialog> createState() => _AddStopDialogState();
}

class _AddStopDialogState extends State<_AddStopDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _orderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.stop != null) {
      _nameController.text = widget.stop!.name;
      _latController.text = widget.stop!.latitude.toString();
      _lngController.text = widget.stop!.longitude.toString();
      _orderController.text = widget.stop!.order.toString();
    } else {
      _orderController.text = (widget.existingOrders.isEmpty 
          ? 1 
          : widget.existingOrders.reduce((a, b) => a > b ? a : b) + 1).toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _saveStop() {
    if (!_formKey.currentState!.validate()) return;

    final stop = RouteStop(
      name: _nameController.text.trim(),
      latitude: double.parse(_latController.text),
      longitude: double.parse(_lngController.text),
      order: int.parse(_orderController.text),
    );

    widget.onAdd(stop);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.stop != null ? 'Edit Stop' : 'Add Stop'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Stop Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter stop name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _orderController,
              label: 'Stop Order',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter stop order';
                }
                final order = int.tryParse(value);
                if (order == null || order <= 0) {
                  return 'Please enter a valid order';
                }
                if (widget.existingOrders.contains(order)) {
                  return 'This order already exists';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _latController,
              label: 'Latitude',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter latitude';
                }
                final lat = double.tryParse(value);
                if (lat == null) {
                  return 'Please enter a valid latitude';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _lngController,
              label: 'Longitude',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter longitude';
                }
                final lng = double.tryParse(value);
                if (lng == null) {
                  return 'Please enter a valid longitude';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveStop,
          child: Text(widget.stop != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}