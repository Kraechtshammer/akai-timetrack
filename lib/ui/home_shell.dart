import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'material.dart';

import '../app/providers.dart';
import '../app/update_controller.dart';
import '../core/time.dart';
import 'common.dart';
import 'export/export_screen.dart';
import 'pay/pay_screen.dart';
import 'plan/plan_screen.dart';
import 'roster/team_screen.dart';
import 'settings/update_tiles.dart';
import 'today/today_screen.dart';

/// The tabs: Home, Plan, Pay, Export, and Team while the team planner is
/// switched on in Settings (docs/02-design.md §7).
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

  /// The same for the Pay tab: it always opens on the current week.
  var _payVisits = 0;

  /// The same for the Team tab: it always opens on next week.
  var _teamVisits = 0;

  var _updatePopupOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _lookForUpdate());
  }

  /// Shows "What's new" once after an update, then looks for an update (at
  /// most every 6 hours) and shows the popup once per new version. [resumed]: also continues an update that waited for
  /// the "install unknown apps" permission.
  Future<void> _lookForUpdate({bool resumed = false}) async {
    final update = ref.read(updateProvider.notifier);
    if (!_updatePopupOpen) {
      // First the changes of an update just installed, then a newer one.
      final whatsNew = await update.whatsNewOnStart();
      if (whatsNew != null && mounted) {
        _updatePopupOpen = true;
        await showWhatsNewDialog(context, Future.value(whatsNew));
        _updatePopupOpen = false;
      }
    }
    await (resumed ? update.resumed() : update.checkIfDue());
    if (!mounted || _updatePopupOpen || !await update.popupDue()) return;
    if (!mounted) return;
    _updatePopupOpen = true;
    await update.markPopupShown();
    if (mounted) await showUpdateDialog(context);
    _updatePopupOpen = false;
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
    if (state == AppLifecycleState.resumed) {
      ref.services.syncAll();
      _lookForUpdate(resumed: true);
    }
  }

  void _openPlan(DateTime week) => setState(() {
    _planWeek = weekStart(week);
    _tab = 1;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final team = ref.settings.teamPlanner;
    // The Team tab disappears when switched off in Settings.
    final tab = !team && _tab == 4 ? 0 : _tab;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tab,
          children: [
            TodayScreen(onOpenPlan: _openPlan),
            PlanScreen(
              week: _planWeek,
              onWeekChanged: (week) => setState(() => _planWeek = week),
            ),
            PayScreen(key: ValueKey(_payVisits)),
            ExportScreen(key: ValueKey(_exportVisits)),
            if (team) TeamScreen(key: ValueKey(_teamVisits)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (next) => setState(() {
          if (next == 2 && tab != 2) _payVisits++;
          if (next == 3 && tab != 3) _exportVisits++;
          if (next == 4 && tab != 4) _teamVisits++;
          _tab = next;
        }),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.tabPlan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.payments_outlined),
            selectedIcon: const Icon(Icons.payments),
            label: l10n.tabPay,
          ),
          NavigationDestination(
            icon: const Icon(Icons.send_outlined),
            selectedIcon: const Icon(Icons.send),
            label: l10n.tabExport,
          ),
          if (team)
            NavigationDestination(
              icon: const Icon(Icons.groups_outlined),
              selectedIcon: const Icon(Icons.groups),
              label: l10n.tabTeam,
            ),
        ],
      ),
    );
  }
}
