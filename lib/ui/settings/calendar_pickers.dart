import 'dart:async';

import 'package:calendar_bridge/calendar_bridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../data/app_settings.dart';
import '../../l10n/labels.dart';
import '../../platform/calendar_sync.dart';
import '../../platform/device_setup.dart';
import '../common.dart';

/// The phone's writable calendars, grouped by account. Asks for the
/// calendar permission first if needed. Calendars that aren't synced to the
/// phone yet are listed too; choosing one turns its sync on.
class CalendarChooser extends ConsumerStatefulWidget {
  const CalendarChooser({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final ValueChanged<CalendarInfo> onSelected;

  @override
  ConsumerState<CalendarChooser> createState() => _CalendarChooserState();
}

class _CalendarChooserState extends ConsumerState<CalendarChooser> {
  bool? _permission;
  List<CalendarInfo> _calendars = const [];
  var _refreshing = false;
  Timer? _reloadLater;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reloadLater?.cancel();
    super.dispose();
  }

  /// Asks Google to fetch the calendar list, then reads it again. A new
  /// calendar can take a few seconds, so it reads once more a bit later.
  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await ref.services.calendar.bridge.requestSync();
    } catch (_) {
      // Reading the list again still helps.
    }
    if (!mounted) return;
    await _load();
    _reloadLater?.cancel();
    _reloadLater = Timer(const Duration(seconds: 6), () async {
      await _load();
      if (mounted) setState(() => _refreshing = false);
    });
  }

  Future<void> _choose(CalendarInfo calendar) async {
    if (!calendar.synced) {
      final bridge = ref.services.calendar.bridge;
      try {
        await bridge.enableSync(calendar.id);
        await bridge.requestSync(calendar.id);
      } catch (_) {
        // Events are still written; they reach Google once sync is on.
      }
    }
    if (!mounted) return;
    widget.onSelected(calendar);
  }

  Future<void> _load() async {
    final permission = await CalendarSync.hasPermission();
    final calendars = permission
        ? await ref.services.calendar.bridge.writableCalendars()
        : const <CalendarInfo>[];
    if (mounted) {
      setState(() {
        _permission = permission;
        _calendars = calendars;
      });
    }
  }

  Future<void> _requestPermission() async {
    await DeviceSetup.requestCalendar();
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_permission == null) return const SizedBox.shrink();
    if (_permission == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(l10n.calendarAccessNeeded),
          M3EButton(onPressed: _requestPermission, child: Text(l10n.allow)),
        ],
      );
    }
    final refresh = Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.calendarMissingHint,
              style: context.text.bodySmall,
            ),
          ),
        ),
        M3EButton.icon(
          style: M3EButtonStyle.text,
          onPressed: _refreshing ? null : _refresh,
          icon: _refreshing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: Text(l10n.calendarRefresh),
        ),
      ],
    );
    if (_calendars.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [Text(l10n.noCalendars), refresh],
      );
    }

    final accounts = <String, List<CalendarInfo>>{};
    for (final calendar in _calendars) {
      accounts.putIfAbsent(calendar.accountName, () => []).add(calendar);
    }
    return RadioGroup<String>(
      groupValue: widget.selectedId,
      onChanged: (id) => _choose(_calendars.firstWhere((c) => c.id == id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          refresh,
          for (final MapEntry(key: account, value: calendars)
              in accounts.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(account, style: context.text.labelMedium),
            ),
            for (final calendar in calendars)
              RadioListTile<String>(
                value: calendar.id,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: CircleAvatar(
                  radius: 8,
                  backgroundColor: Color(calendar.color),
                ),
                title: Text(calendar.name),
                subtitle: calendar.synced ? null : Text(l10n.calendarNotSynced),
              ),
          ],
        ],
      ),
    );
  }
}

/// Settings: choose the calendar, or none.
Future<void> showCalendarPicker(
  BuildContext context,
  WidgetRef ref,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) {
    final l10n = context.l10n;
    final settings = ref.read(settingsProvider).value ?? const AppSettings();
    Future<void> choose(CalendarInfo? calendar) async {
      Navigator.pop(context);
      if (calendar?.id == settings.calendarId) return;
      await ref.services.calendar.switchCalendar(calendar);
      await ref.services.syncAll();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.calendar, style: context.text.headlineSmall),
          ),
          CalendarChooser(selectedId: settings.calendarId, onSelected: choose),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_busy),
            title: Text(l10n.calendarNone),
            subtitle: Text(l10n.calendarNoneHint),
            onTap: () => choose(null),
          ),
        ],
      ),
    );
  },
);

/// Choose the event color for all shifts in the calendar.
Future<void> showEventColorPicker(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _EventColorSheet(),
    );

class _EventColorSheet extends ConsumerStatefulWidget {
  const _EventColorSheet();

  @override
  ConsumerState<_EventColorSheet> createState() => _EventColorSheetState();
}

class _EventColorSheetState extends ConsumerState<_EventColorSheet> {
  List<EventColor>? _colors;
  int? _calendarColor;
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey =
        (ref.read(settingsProvider).value ?? const AppSettings()).eventColorKey;
    _load();
  }

  Future<void> _load() async {
    final calendarId =
        (ref.read(settingsProvider).value ?? const AppSettings()).calendarId;
    if (calendarId == null) return;
    final bridge = ref.services.calendar.bridge;
    final colors = await bridge.eventColors(calendarId);
    final calendars = await bridge.writableCalendars();
    if (!mounted) return;
    setState(() {
      _colors = colors;
      _calendarColor = calendars
          .where((c) => c.id == calendarId)
          .firstOrNull
          ?.color;
    });
  }

  Future<void> _apply() async {
    final color = _colors?.where((c) => c.key == _selectedKey).firstOrNull;
    final services = ref.services;
    Navigator.pop(context);
    await services.settings.update(
      (s) => s.copyWith(
        eventColorKey: () => color?.key,
        eventColor: () => color?.color,
      ),
    );
    await services.shifts.markAllEventsDirty();
    await services.syncAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.settings;
    final colors = _colors;
    final options = <(String?, Color, String)>[
      (null, Color(_calendarColor ?? 0xFF9E9E9E), l10n.colorOfCalendar),
      for (final c in colors ?? const <EventColor>[])
        (
          c.key,
          Color(c.color),
          googleEventColorName(c.key, l10n) ?? l10n.colorWithKey(c.key),
        ),
    ];
    final selected =
        options.where((o) => o.$1 == _selectedKey).firstOrNull ?? options.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(l10n.eventColor, style: context.text.headlineSmall),
          Text(l10n.eventColorHint, style: context.text.bodyMedium),
          if (colors == null)
            const Center(child: CircularProgressIndicator())
          else
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: [
                for (final (key, color, name) in options)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _selectedKey = key),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: key == _selectedKey
                                ? Border.all(
                                    color: context.colors.onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: key == _selectedKey
                              ? const Icon(Icons.check, color: Colors.white)
                              : key == null
                              ? const Icon(Icons.event, color: Colors.white)
                              : null,
                        ),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: context.text.labelSmall,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          Text(l10n.previewInCalendar, style: context.text.titleSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected.$2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${settings.eventTitle}\n17:30 – 23:00',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              M3EButton(
                style: M3EButtonStyle.text,
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              M3EButton(onPressed: _apply, child: Text(l10n.apply)),
            ],
          ),
        ],
      ),
    );
  }
}
