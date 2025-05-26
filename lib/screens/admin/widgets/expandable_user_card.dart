import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/enhanced_admin_user.dart';
import 'package:gsecsurvey/screens/admin/utils/admin_utils.dart';
import 'package:gsecsurvey/services/enhanced_admin_service.dart';

class ExpandableUserCard extends StatefulWidget {
  final EnhancedAdminUser user;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final VoidCallback onExpanded;
  final VoidCallback onCollapsed;

  const ExpandableUserCard({
    Key? key,
    required this.user,
    required this.onUpdate,
    this.isExpanded = false,
    required this.onExpanded,
    required this.onCollapsed,
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 300),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Collapsed view
          ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.user.isAdmin ? Colors.green : Colors.grey,
              child: Icon(
                widget.user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(widget.user.email ?? 'No email'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.user.displayName != null)
                  Text('Name: ${widget.user.displayName}'),
                Text('Status: ${widget.user.statusText}'),
                Text('UID: ${widget.user.uid}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.user.isAdmin ? Colors.green : Colors.grey,
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
                    child: const Icon(Icons.expand_more),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'User Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
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
          _buildDetailRow('Data Sources', _getDataSourcesText()),
          const SizedBox(height: 16),
          const Text(
            'Admin Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
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
                    backgroundColor:
                        widget.user.isAdmin ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (widget.user.email != null && widget.user.email!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _resetPassword,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Reset Password'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _deleteUser,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  String _getDataSourcesText() {
    final sources = <String>[];
    if (widget.user.isFromFirebaseAuth) sources.add('Firebase Auth');
    if (widget.user.isFromCustomCollection) sources.add('Custom Collection');
    return sources.isEmpty ? 'Unknown' : sources.join(', ');
  }
}
