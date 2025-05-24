import 'package:flutter/material.dart';
import 'package:gsecsurvey/screens/admin/admin_screen.dart';
import 'package:gsecsurvey/screens/admin/submission_summary_screen.dart';
import 'package:gsecsurvey/screens/admin/user_management_screen.dart';
import 'package:gsecsurvey/screens/admin/widgets/admin_layout.dart';

class MainAdminScreenWithBottomNav extends StatefulWidget {
  const MainAdminScreenWithBottomNav({Key? key}) : super(key: key);

  @override
  State<MainAdminScreenWithBottomNav> createState() =>
      _MainAdminScreenWithBottomNavState();
}

class _MainAdminScreenWithBottomNavState
    extends State<MainAdminScreenWithBottomNav> {
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
      icon: Icon(Icons.summarize),
      label: 'Summary',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
