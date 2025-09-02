import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../management/bus_management_screen.dart';
import '../management/route_management_screen.dart';
import '../management/approval_screen.dart';

class CoordinatorDashboard extends StatefulWidget {
  const CoordinatorDashboard({super.key});

  @override
  State<CoordinatorDashboard> createState() => _CoordinatorDashboardState();
}

class _CoordinatorDashboardState extends State<CoordinatorDashboard> {
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
      busProvider.loadBuses(
        collegeName: authProvider.user!.collegeName,
        coordinatorId: authProvider.user!.id,
      );
      routeProvider.loadRoutes(
        collegeName: authProvider.user!.collegeName,
        coordinatorId: authProvider.user!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Dashboard'),
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
                      'Welcome, ${authProvider.user?.name ?? 'Coordinator'}',
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
              
              // Quick Stats
              Consumer2<BusProvider, RouteProvider>(
                builder: (context, busProvider, routeProvider, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Buses',
                          busProvider.buses.length.toString(),
                          Icons.directions_bus,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Routes',
                          routeProvider.routes.length.toString(),
                          Icons.route,
                          Colors.orange,
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Management Options
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    DashboardCard(
                      title: 'Manage Buses',
                      icon: Icons.directions_bus,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BusManagementScreen(),
                          ),
                        );
                      },
                    ),
                    
                    DashboardCard(
                      title: 'Manage Routes',
                      icon: Icons.route,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RouteManagementScreen(),
                          ),
                        );
                      },
                    ),
                    
                    DashboardCard(
                      title: 'Approve Users',
                      icon: Icons.pending_actions,
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApprovalScreen(),
                          ),
                        );
                      },
                    ),
                    
                    DashboardCard(
                      title: 'View Drivers',
                      icon: Icons.drive_eta,
                      color: Colors.purple,
                      onTap: () {
                        // Navigate to drivers list
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}