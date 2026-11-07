import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../platform/device_setup.dart';
import '../common.dart';

/// Things that make reminders reliable. Autostart only exists on Xiaomi.
enum ReliabilityItem { notifications, exactAlarms, battery, autostart }

class _Status {
  const _Status(this.done, this.xiaomi);
  final Map<ReliabilityItem, bool> done;
  final bool xiaomi;
}

/// A list of permission rows with "Allow"/"Open" buttons. Checks again
/// whenever the user comes back from Android's settings.
class ReliabilityChecklist extends ConsumerStatefulWidget {
  const ReliabilityChecklist({
    super.key,
    required this.items,
    this.onlyMissing = false,
    this.onStatus,
  });

  final List<ReliabilityItem> items;

  /// Hide rows that are already fine (used in Settings).
  final bool onlyMissing;

  /// Tells the parent whether everything is fine.
  final ValueChanged<bool>? onStatus;

  @override
  ConsumerState<ReliabilityChecklist> createState() =>
      _ReliabilityChecklistState();
}

class _ReliabilityChecklistState extends ConsumerState<ReliabilityChecklist>
    with WidgetsBindingObserver {
  _Status? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_check());
  }

  Future<void> _check() async {
    final xiaomi = await DeviceSetup.isXiaomi();
    final settings = await ref.services.settings.load();
    final status = _Status({
      ReliabilityItem.notifications: await DeviceSetup.notificationsAllowed(),
      ReliabilityItem.exactAlarms: await DeviceSetup.exactAlarmsAllowed(),
      ReliabilityItem.battery: await DeviceSetup.batteryUnrestricted(),
      ReliabilityItem.autostart: !xiaomi || settings.autostartConfirmed,
    }, xiaomi);
    if (!mounted) return;
    setState(() => _status = status);
    widget.onStatus?.call(
      widget.items.every((item) => status.done[item] ?? true),
    );
  }

  Future<void> _fix(ReliabilityItem item) async {
    switch (item) {
      case ReliabilityItem.notifications:
        await DeviceSetup.requestNotifications();
      case ReliabilityItem.exactAlarms:
        await DeviceSetup.requestExactAlarms();
      case ReliabilityItem.battery:
        // Xiaomi's own battery saver is in the app's settings page.
        if (_status?.xiaomi ?? false) {
          await DeviceSetup.openAppSettingsPage();
        } else {
          await DeviceSetup.requestBatteryUnrestricted();
        }
      case ReliabilityItem.autostart:
        await DeviceSetup.openAutostartSettings();
    }
    await _check();
    await ref.services.syncAll(); // reschedule with the new permissions
  }

  Future<void> _confirmAutostart(bool done) async {
    await ref.services.settings.update(
      (s) => s.copyWith(autostartConfirmed: done),
    );
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final rows = widget.items.where(
      (item) =>
          (item != ReliabilityItem.autostart || status.xiaomi) &&
          !(widget.onlyMissing && status.done[item]!),
    );

    return Column(
      spacing: 2,
      children: [
        for (final item in rows)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            tileColor: context.colors.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(switch (item) {
              ReliabilityItem.notifications => l10n.permNotifications,
              ReliabilityItem.exactAlarms => l10n.permExact,
              ReliabilityItem.battery => l10n.permBattery,
              ReliabilityItem.autostart => l10n.permAutostart,
            }),
            subtitle: Text(switch (item) {
              ReliabilityItem.notifications => l10n.permNotificationsHint,
              ReliabilityItem.exactAlarms => l10n.permExactHint,
              ReliabilityItem.battery => l10n.permBatteryHint,
              ReliabilityItem.autostart => l10n.permAutostartHint,
            }),
            trailing: item == ReliabilityItem.autostart
                // Android can't tell whether Autostart is on, so the user
                // opens the setting and then ticks it off by hand.
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      M3EIconButton(
                        variant: M3EIconButtonVariant.standard,
                        tooltip: l10n.open,
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => _fix(item),
                      ),
                      Checkbox(
                        value: status.done[item],
                        onChanged: (v) => _confirmAutostart(v ?? false),
                      ),
                    ],
                  )
                : status.done[item]!
                ? Icon(Icons.check_circle, color: context.colors.primary)
                : M3EButton(
                    onPressed: () => _fix(item),
                    child: Text(l10n.allow),
                  ),
          ),
      ],
    );
  }
}
