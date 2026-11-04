import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'material.dart';

import '../app/providers.dart';
import '../core/time.dart';
import 'common.dart';
import 'export/export_screen.dart';
import 'plan/plan_screen.dart';
import 'today/today_screen.dart';

/// The three tabs: Heute, Plan, Export.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  var _tab = 0;
  var _planWeek = weekStart(DateTime.now());

  /// Counts visits to the Export tab. Each visit starts a fresh Export
  /// screen, so it always opens on the current month.
  var _exportVisits = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back in the app: catch up on reminders and the calendar
    // (e.g. events deleted in Google Calendar meanwhile).
    if (state == AppLifecycleState.resumed) ref.services.syncAll();
  }

  void _openPlan(DateTime week) => setState(() {
    _planWeek = weekStart(week);
    _tab = 1;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            TodayScreen(onOpenPlan: _openPlan),
            PlanScreen(
              week: _planWeek,
              onWeekChanged: (week) => setState(() => _planWeek = week),
            ),
            ExportScreen(key: ValueKey(_exportVisits)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (tab) => setState(() {
          if (tab == 2 && _tab != 2) _exportVisits++;
          _tab = tab;
        }),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.tabToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.tabPlan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.send_outlined),
            selectedIcon: const Icon(Icons.send),
            label: l10n.tabExport,
          ),
        ],
      ),
    );
  }
}
