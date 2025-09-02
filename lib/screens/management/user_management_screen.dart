import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';

class UserManagementScreen extends StatefulWidget {
  final UserRole? filterRole;
  final bool showPendingOnly;

  const UserManagementScreen({
    super.key,
    this.filterRole,
    this.showPendingOnly = false,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final DatabaseService _databaseService = DatabaseService();

  String _getTitle() {
    if (widget.showPendingOnly) return 'Pending Approvals';
    if (widget.filterRole != null) {
      return '${widget.filterRole.toString().split('.').last.toUpperCase()}S';
    }
    return 'All Users';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: widget.showPendingOnly
            ? _databaseService.getPendingApprovals(
                approverId: authProvider.user!.id,
                approverRole: authProvider.user!.role,
              )
            : _databaseService.getUsers(role: widget.filterRole),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                    child: Icon(
                      _getRoleIcon(user.role),
                      color: _getRoleColor(user.role),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user.email}'),
                      Text('Role: ${user.role.toString().split('.').last.toUpperCase()}'),
                      Text('College: ${user.collegeName ?? 'N/A'}'),
                      Text('Status: ${user.approvalStatus.toString().split('.').last.toUpperCase()}'),
                    ],
                  ),
                  trailing: widget.showPendingOnly
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _approveUser(user.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejectUser(user.id),
                            ),
                          ],
                        )
                      : PopupMenuButton(
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
                              _editUser(user);
                            } else if (value == 'delete') {
                              _deleteUser(user.id);
                            }
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.coordinator:
        return Colors.orange;
      case UserRole.driver:
        return Colors.purple;
      case UserRole.teacher:
        return Colors.teal;
      case UserRole.student:
        return Colors.indigo;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.coordinator:
        return Icons.manage_accounts;
      case UserRole.driver:
        return Icons.drive_eta;
      case UserRole.teacher:
        return Icons.school;
      case UserRole.student:
        return Icons.person;
    }
  }

  Future<void> _approveUser(String userId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.approveUser(userId);

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
          content: Text('User approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectUser(String userId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.rejectUser(userId);

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
          content: Text('User rejected successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _editUser(UserModel user) {
    // TODO: Implement edit user functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit user functionality coming soon'),
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
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
      final error = await _databaseService.deleteUser(userId);
      
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
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}