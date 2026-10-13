import 'package:flutter/material.dart';
import '../../core/responsive/adaptive_scaffold.dart';
import '../bible/bible_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../library/sermon_library_screen.dart';
import '../profile/profile_screen.dart';
import '../templates/sermon_templates_screen.dart';

class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({super.key});

  @override
  State<AdaptiveNavigationShell> createState() => _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  int _currentIndex = 0;

  static const List<NavigationDestinationItem> _destinations = [
    NavigationDestinationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    NavigationDestinationItem(
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories,
      label: 'Sermões',
    ),
    NavigationDestinationItem(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Bíblia',
    ),
    NavigationDestinationItem(
      icon: Icons.folder_copy_outlined,
      selectedIcon: Icons.folder_copy,
      label: 'Modelos',
    ),
    NavigationDestinationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onNavigationIndexChanged: (index) {
        setState(() => _currentIndex = index);
      },
      destinations: _destinations,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            onNavigateToTemplates: () => setState(() => _currentIndex = 3),
            onNavigateToLibrary: () => setState(() => _currentIndex = 1),
          ),
          const SermonLibraryScreen(),
          const BibleScreen(),
          const SermonTemplatesScreen(),
          const ProfileScreen(),
        ],
      ),
    );
  }
}
