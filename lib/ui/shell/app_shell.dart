import 'package:flutter/material.dart';
import 'package:medication_tracker/ui/edit_profile/edit_profile_view.dart';
import 'package:medication_tracker/ui/home/home_view.dart';
import 'package:medication_tracker/ui/search/fda_search_view.dart';
import 'package:medication_tracker/ui/select_profile/select_profile_view.dart';

/// Root shell with a persistent [NavigationBar].
///
/// Each tab has its own nested [Navigator] so that pushes within a tab
/// (e.g. Edit Medication, Create Medication) stay inside the tab and the
/// bottom bar remains visible at all times.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// One navigator key per tab — keeps each tab's back-stack independent.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // 0 Home
    GlobalKey<NavigatorState>(), // 1 Add Med
    GlobalKey<NavigatorState>(), // 2 Profile
    GlobalKey<NavigatorState>(), // 3 Switch
  ];

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) {
      // Tapping the active tab pops to its root (like iOS tab bar behaviour).
      _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _switchToHome() {
    // Use the GlobalKey directly so this is race-proof — the context of
    // CreateMedicationPage may already be gone after the async save.
    _navigatorKeys[1].currentState?.popUntil((r) => r.isFirst);
    setState(() => _selectedIndex = 0);
  }

  /// Wraps [child] in a per-tab [Navigator] so sub-page pushes stay in-tab.
  Widget _tabNavigator(int index, Widget root) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => root),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSecondary = theme.colorScheme.onSecondary;

    return PopScope(
      // Let the active tab's navigator handle back presses first.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _navigatorKeys[_selectedIndex].currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        }
      },
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            theme.textTheme.labelSmall?.copyWith(color: onSecondary),
          ),
          iconTheme: WidgetStateProperty.all(
            IconThemeData(color: onSecondary),
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                _tabNavigator(0, const HomeScreen()),
                _tabNavigator(1, FDASearchPage(onMedicationAdded: _switchToHome)),
                _tabNavigator(2, const EditProfilePage()),
                _tabNavigator(
                    3, SelectProfilePage(onProfileSelected: _switchToHome)),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: theme.colorScheme.secondary,
              indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.25),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: onSecondary),
                  selectedIcon: Icon(Icons.home, color: onSecondary),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline, color: onSecondary),
                  selectedIcon: Icon(Icons.add_circle, color: onSecondary),
                  label: 'Add Med',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: onSecondary),
                  selectedIcon: Icon(Icons.person, color: onSecondary),
                  label: 'Profile',
                ),
                NavigationDestination(
                  icon: Icon(Icons.switch_account_outlined, color: onSecondary),
                  selectedIcon: Icon(Icons.switch_account, color: onSecondary),
                  label: 'Switch',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
