import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../models/bus_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CreateBusScreen extends StatefulWidget {
  final BusModel? bus;

  const CreateBusScreen({super.key, this.bus});

  @override
  State<CreateBusScreen> createState() => _CreateBusScreenState();
}

class _CreateBusScreenState extends State<CreateBusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _busNumberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get isEditing => widget.bus != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _busNumberController.text = widget.bus!.busNumber;
      _capacityController.text = widget.bus!.capacity.toString();
      _descriptionController.text = widget.bus!.description ?? '';
    } else {
      _capacityController.text = '50'; // Default capacity
    }
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBus() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final busProvider = Provider.of<BusProvider>(context, listen: false);

    String? error;

    if (isEditing) {
      error = await busProvider.updateBus(widget.bus!.id, {
        'busNumber': _busNumberController.text.trim(),
        'capacity': int.parse(_capacityController.text),
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      });
    } else {
      error = await busProvider.createBus(
        busNumber: _busNumberController.text.trim(),
        collegeName: authProvider.user!.collegeName!,
        coordinatorId: authProvider.user!.id,
        capacity: int.parse(_capacityController.text),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
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
          content: Text(isEditing ? 'Bus updated successfully' : 'Bus created successfully'),
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
        title: Text(isEditing ? 'Edit Bus' : 'Create Bus'),
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
                // Bus Number
                CustomTextField(
                  controller: _busNumberController,
                  label: 'Bus Number',
                  prefixIcon: Icons.directions_bus,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bus number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Capacity
                CustomTextField(
                  controller: _capacityController,
                  label: 'Capacity',
                  prefixIcon: Icons.people,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter capacity';
                    }
                    final capacity = int.tryParse(value);
                    if (capacity == null || capacity <= 0) {
                      return 'Please enter a valid capacity';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
                
                const SizedBox(height: 32),
                
                // Save Button
                Consumer<BusProvider>(
                  builder: (context, busProvider, child) {
                    return CustomButton(
                      text: isEditing ? 'Update Bus' : 'Create Bus',
                      onPressed: busProvider.isLoading ? null : _saveBus,
                      isLoading: busProvider.isLoading,
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