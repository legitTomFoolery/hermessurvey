import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/features/admin/presentation/screens/question_management_screen.dart';
import 'response_management_screen.dart';
import 'submission_summary_screen.dart';
import 'user_management_screen.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/layout/admin_layout.dart';

class MainAdminScreenWithBottomNav extends StatefulWidget {
  const MainAdminScreenWithBottomNav({super.key});

  @override
  State<MainAdminScreenWithBottomNav> createState() =>
      _MainAdminScreenWithBottomNavState();
}

class _MainAdminScreenWithBottomNavState
    extends State<MainAdminScreenWithBottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const QuestionManagementScreen(),
    const UserManagementScreen(),
    const ResponseManagementScreen(),
    const SubmissionSummaryScreen(),
  ];

  final List<String> _titles = [
    'Question Management',
    'User Management',
    'Response Management',
    'Submission Summary',
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.question_answer),
      label: 'Questions',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Users',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: 'Responses',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.summarize),
      label: 'Summary',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return AdminLayout(
      title: _titles[_selectedIndex],
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _bottomNavItems,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.shadow,
        backgroundColor: theme.colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
