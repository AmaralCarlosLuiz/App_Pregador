import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/adaptive_scaffold.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bible_tts_provider.dart';
import '../bible/bible_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../library/sermon_library_screen.dart';
import '../profile/profile_screen.dart';
import '../templates/sermon_templates_screen.dart';

class AdaptiveNavigationShell extends ConsumerStatefulWidget {
  const AdaptiveNavigationShell({super.key});

  @override
  ConsumerState<AdaptiveNavigationShell> createState() => _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends ConsumerState<AdaptiveNavigationShell> {
  int _currentIndex = 0;

  // Lazy-loading de abas: monta apenas a tela ativa no boot e preserva estado após visitada
  final Set<int> _visitedTabs = {0};

  static const List<NavigationDestinationItem> _destinations = [
    NavigationDestinationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    NavigationDestinationItem(
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books,
      label: 'Meus Sermões',
    ),
    NavigationDestinationItem(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Bíblia',
    ),
    NavigationDestinationItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'Acervo de Modelos',
    ),
    NavigationDestinationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  void _selectTab(int index) {
    if (_currentIndex == 2 && index != 2) {
      // Interrompe leitura em voz caso o usuário saia da aba Bíblia
      ref.read(bibleTtsProvider.notifier).stop();
    }
    setState(() {
      _currentIndex = index;
      _visitedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = authState.userProfile;

    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onNavigationIndexChanged: _selectTab,
      destinations: _destinations,
      userDisplayName: profile?.fullName ?? 'Pr. Carlos Luiz Amaral',
      isUserAdmin: profile?.isAdmin ?? true,
      onSignOut: () {
        ref.read(bibleTtsProvider.notifier).stop();
        ref.read(authProvider.notifier).signOut();
      },
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            onNavigateToTemplates: () => _selectTab(3),
            onNavigateToLibrary: () => _selectTab(1),
          ),
          _visitedTabs.contains(1)
              ? const SermonLibraryScreen()
              : const SizedBox.shrink(),
          _visitedTabs.contains(2)
              ? const BibleScreen()
              : const SizedBox.shrink(),
          _visitedTabs.contains(3)
              ? const SermonTemplatesScreen()
              : const SizedBox.shrink(),
          _visitedTabs.contains(4)
              ? const ProfileScreen()
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
