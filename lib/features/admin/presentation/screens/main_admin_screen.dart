import 'package:flutter/material.dart';

import 'admin_screen.dart';
import 'submission_summary_screen.dart';
import 'user_management_screen.dart';
import '../widgets/layout/admin_layout.dart';

class MainAdminScreen extends StatefulWidget {
  const MainAdminScreen({super.key});

  @override
  State<MainAdminScreen> createState() => _MainAdminScreenState();
}

class _MainAdminScreenState extends State<MainAdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminScreen(),
    const UserManagementScreen(),
    const SubmissionSummaryScreen(),
  ];

  final List<String> _titles = [
    'Question Management',
    'User Management',
    'Submission Summary',
  ];

  final List<IconData> _icons = [
    Icons.question_answer,
    Icons.people,
    Icons.summarize,
  ];

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Admin Dashboard',
      body: _screens[_selectedIndex],
      actions: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.menu),
          onSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          itemBuilder: (context) {
            return List.generate(
              _titles.length,
              (index) => PopupMenuItem(
                value: index,
                child: Row(
                  children: [
                    Icon(_icons[index], color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(_titles[index]),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
