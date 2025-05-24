import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/admin_user.dart';
import 'package:gsecsurvey/screens/admin/utils/admin_utils.dart';
import 'package:gsecsurvey/screens/admin/widgets/error_view.dart';
import 'package:gsecsurvey/screens/admin/widgets/loading_view.dart';
import 'package:gsecsurvey/services/admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<AdminUser> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await AdminService.getAllUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading users: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAdminStatus(AdminUser user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success =
          await AdminService.toggleAdminStatus(user.uid, !user.isAdmin);

      if (success) {
        // Refresh the user list
        await _loadUsers();

        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Admin status updated successfully',
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to update admin status';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating admin status: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_errorMessage != null) {
      return ErrorView(
        errorMessage: _errorMessage!,
        onRetry: _loadUsers,
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) => _buildUserCard(_users[index]),
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        title: Text(user.email ?? 'No email'),
        subtitle: Text('UID: ${user.uid}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: user.isAdmin,
              onChanged: (value) => _toggleAdminStatus(user),
            ),
            const SizedBox(width: 8),
            Text(
              user.isAdmin ? 'Admin' : 'User',
              style: TextStyle(
                color: user.isAdmin ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
