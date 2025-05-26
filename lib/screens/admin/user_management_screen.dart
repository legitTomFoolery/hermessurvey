import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/models/enhanced_admin_user.dart';
import 'package:gsecsurvey/screens/admin/widgets/error_view.dart';
import 'package:gsecsurvey/screens/admin/widgets/expandable_user_card.dart';
import 'package:gsecsurvey/screens/admin/widgets/loading_view.dart';
import 'package:gsecsurvey/services/enhanced_admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<EnhancedAdminUser> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _expandedIndex;

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
      final users = await EnhancedAdminService.getAllEnhancedUsers();
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

  void _onUserExpanded(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  void _onUserCollapsed() {
    setState(() {
      _expandedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      color: theme.colorScheme.tertiary,
      child: _buildContent(context),
    );
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
      final theme = AdaptiveTheme.of(context).theme;

      return Center(
        child: Text(
          'No users found',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 18,
            color: theme.colorScheme.shadow,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) => ExpandableUserCard(
          user: _users[index],
          onUpdate: _loadUsers,
          isExpanded: _expandedIndex == index,
          onExpanded: () => _onUserExpanded(index),
          onCollapsed: _onUserCollapsed,
        ),
      ),
    );
  }
}
