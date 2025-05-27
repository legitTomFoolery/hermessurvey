import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import '../../../../app/config/app_constants.dart';
import '../../data/models/admin_user_extended.dart';
import '../../data/services/admin_management_service.dart';
import '../widgets/common/error_view.dart';
import '../widgets/cards/expandable_user_card.dart';
import '../widgets/common/loading_view.dart';
import '../widgets/modals/notification_modal.dart';

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
  bool _showFloatingButton = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Hide floating button when scrolling down (user swipes up)
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFloatingButton) {
          setState(() {
            _showFloatingButton = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFloatingButton) {
          setState(() {
            _showFloatingButton = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _showNotificationModal() {
    showDialog(
      context: context,
      builder: (context) => const NotificationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.tertiary,
      body: _buildContent(context),
      floatingActionButton: (!kIsWeb && _showFloatingButton)
          ? FloatingActionButton(
              onPressed: _showNotificationModal,
              backgroundColor: theme.colorScheme.primary,
              shape: const CircleBorder(),
              child: Icon(
                Icons.notifications,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : null,
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
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _users.length,
          itemBuilder: (context, index) => ExpandableUserCard(
            user: _users[index],
            onUpdate: _loadUsers,
            isExpanded: _expandedIndex == index,
            onExpanded: () => _onUserExpanded(index),
            onCollapsed: _onUserCollapsed,
          ),
        ),
      ),
    );
  }
}
