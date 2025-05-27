import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/app/config/app_constants.dart';
import 'package:gsecsurvey/features/admin/data/models/admin_user_extended_model.dart';
import 'package:gsecsurvey/features/admin/data/services/admin_management_service.dart';
import 'package:gsecsurvey/shared/utils/helpers/admin_utils.dart';

class ExpandableUserCard extends StatefulWidget {
  final EnhancedAdminUser user;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final VoidCallback onExpanded;
  final VoidCallback onCollapsed;

  const ExpandableUserCard({
    super.key,
    required this.user,
    required this.onUpdate,
    this.isExpanded = false,
    required this.onExpanded,
    required this.onCollapsed,
  });

  @override
  State<ExpandableUserCard> createState() => _ExpandableUserCardState();
}

class _ExpandableUserCardState extends State<ExpandableUserCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set initial animation state
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ExpandableUserCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes when parent updates
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (widget.isExpanded) {
      widget.onCollapsed();
      _animationController.reverse();
    } else {
      widget.onExpanded();
      _animationController.forward();
    }
  }

  Future<void> _toggleAdminStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await EnhancedAdminService.toggleAdminStatus(
        widget.user.uid,
        !widget.user.isAdmin,
      );

      if (success) {
        widget.onUpdate();
        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Admin status updated successfully',
        );
      } else {
        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Failed to update admin status',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AdminUtils.showSnackBar(
        context,
        'Error updating admin status: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${widget.user.email ?? 'this user'}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await EnhancedAdminService.deleteUserAccount(widget.user.uid);

      if (success) {
        widget.onUpdate();
        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'User deleted successfully',
        );
      } else {
        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Failed to delete user',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AdminUtils.showSnackBar(
        context,
        'Error deleting user: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (widget.user.email == null || widget.user.email!.isEmpty) {
      AdminUtils.showSnackBar(
        context,
        'Cannot reset password: No email address available',
        isError: true,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          'Send a password reset email to ${widget.user.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await EnhancedAdminService.resetUserPassword(widget.user.email!);

      if (success) {
        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Password reset email sent successfully',
        );
      } else {
        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Failed to send password reset email',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AdminUtils.showSnackBar(
        context,
        'Error sending password reset email: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: AppConstants.defaultSpacing / 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        children: [
          // Collapsed view
          ListTile(
            title: Text(
              widget.user.email ?? 'No email',
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onSecondary,
                fontSize: 16,
              ),
            ),
            subtitle: widget.user.displayName != null
                ? Text(
                    widget.user.displayName!,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.shadow,
                      fontSize: 14,
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.user.isAdmin
                        ? theme.colorScheme.primary
                        : theme.colorScheme.shadow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.user.isAdmin ? 'Admin' : 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onPressed: _toggleExpanded,
                ),
              ],
            ),
          ),

          // Expanded view
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: widget.isExpanded
                ? _buildExpandedContent()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    final theme = AdaptiveTheme.of(context).theme;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: theme.colorScheme.surface),
          Text(
            'User Details',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondary,
            ),
          ),
          const SizedBox(
              height: AppConstants.defaultSpacing +
                  AppConstants.defaultSpacing / 2),
          _buildDetailRow('Email', widget.user.email ?? 'Not available'),
          _buildDetailRow('Display Name', widget.user.displayName ?? 'Not set'),
          _buildDetailRow('UID', widget.user.uid),
          _buildDetailRow(
              'Email Verified', widget.user.emailVerified ? 'Yes' : 'No'),
          if (widget.user.createdAt != null)
            _buildDetailRow('Created', widget.user.createdAt!.toString()),
          if (widget.user.lastSignInTime != null)
            _buildDetailRow(
                'Last Sign In', widget.user.lastSignInTime!.toString()),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Admin Actions',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondary,
            ),
          ),
          const SizedBox(
              height: AppConstants.defaultSpacing +
                  AppConstants.defaultSpacing / 2),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleAdminStatus,
                  icon: Icon(widget.user.isAdmin
                      ? Icons.remove_moderator
                      : Icons.admin_panel_settings),
                  label:
                      Text(widget.user.isAdmin ? 'Remove Admin' : 'Make Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.user.isAdmin
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
                if (widget.user.email != null && widget.user.email!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _resetPassword,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Reset Password'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _deleteUser,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = AdaptiveTheme.of(context).theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.shadow,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
