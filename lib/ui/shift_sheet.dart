import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../app/providers.dart';
import '../core/format.dart';
import '../core/time.dart';
import '../data/database.dart';
import '../domain/planning.dart';
import '../domain/shift_info.dart';
import '../l10n/labels.dart';
import 'common.dart';
import 'plan/plan_screen.dart';

/// Opens the edit sheet for [shift], or for a new shift on [day].
Future<void> showShiftSheet(
  BuildContext context, {
  required DateTime day,
  Shift? shift,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => _ShiftSheet(day: dateOnly(day), shift: shift),
);

class _ShiftSheet extends ConsumerStatefulWidget {
  const _ShiftSheet({required this.day, this.shift});

  final DateTime day;
  final Shift? shift;

  @override
  ConsumerState<_ShiftSheet> createState() => _ShiftSheetState();
}

class _ShiftSheetState extends ConsumerState<_ShiftSheet> {
  // The form works with minutes after midnight; DateTimes are built on save.
  late ShiftType _type;
  late Minutes _plannedStart, _plannedEnd;
  late bool _plannedCustomized;
  Minutes? _actualStart, _actualEnd;
  late int _break;

  @override
  void initState() {
    super.initState();
    final shift = widget.shift;
    if (shift != null) {
      _type = shift.type;
      _plannedStart = minutesOf(shift.plannedStart);
      _plannedEnd = minutesOf(shift.plannedEnd);
      _plannedCustomized = shift.plannedCustomized;
      _actualStart = shift.actualStart == null
          ? null
          : minutesOf(shift.actualStart!);
      _actualEnd = shift.actualEnd == null ? null : minutesOf(shift.actualEnd!);
      _break = shift.breakMinutes;
    } else {
      _type = ShiftType.custom;
      final times = defaultTimes(
        ShiftType.custom,
        ref.read(settingsProvider).value!,
      );
      _plannedStart = times.start;
      _plannedEnd = times.end;
      _plannedCustomized = false; // switching the type loads its defaults
      _break = 0;
    }
  }

  bool get _isNew => widget.shift == null;
  bool get _isRunning => widget.shift?.isRunning ?? false;
  bool get _hasActual => _actualStart != null && _actualEnd != null;

  void _changeType(ShiftType type) {
    setState(() {
      _type = type;
      if (!_plannedCustomized) {
        final times = defaultTimes(type, ref.settings);
        _plannedStart = times.start;
        _plannedEnd = times.end;
      }
    });
  }

  int _minutes(Minutes start, Minutes end) {
    final (from, to) = timesOn(widget.day, start, end);
    return to.difference(from).inMinutes;
  }

  Future<void> _save() async {
    final planning = ref.services.planning;
    final (plannedStart, plannedEnd) = timesOn(
      widget.day,
      _plannedStart,
      _plannedEnd,
    );
    final actual = _hasActual
        ? timesOn(widget.day, _actualStart!, _actualEnd!)
        : null;

    var shift =
        widget.shift ??
        await planning.create(widget.day, _type, plannedStart, plannedEnd);
    shift = shift.copyWith(
      type: _type,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      plannedCustomized: _plannedCustomized,
      actualStart: Value(actual?.$1),
      actualEnd: Value(actual?.$2),
      breakMinutes: _break,
    );
    await planning.save(shift);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final deleted = await deleteWithUndo(context, ref, widget.shift!);
    if (deleted && mounted) Navigator.pop(context);
  }

  Future<void> _pickOtherBreak() async {
    final controller = TextEditingController(text: _break > 0 ? '$_break' : '');
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.pauseOtherTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'min'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
    if (minutes != null && minutes >= 0) setState(() => _break = minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final settings = ref.settings;
    final shift = widget.shift;
    final worked = _hasActual
        ? _minutes(_actualStart!, _actualEnd!) - _break
        : _minutes(_plannedStart, _plannedEnd);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.MMMMEEEEd(context.locale).format(widget.day),
                        style: context.text.headlineSmall,
                      ),
                      Text(
                        _isNew
                            ? l10n.newShift
                            : _isRunning
                            ? l10n.recordingRunning
                            : _hasActual
                            ? l10n.statusRecorded
                            : l10n.statusPlanned,
                        style: TextStyle(color: colors.primary),
                      ),
                    ],
                  ),
                ),
                if (!_isNew)
                  IconButton(
                    tooltip: l10n.delete,
                    color: colors.error,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _delete,
                  ),
              ],
            ),
            SegmentedButton<ShiftType>(
              segments: [
                for (final type in ShiftType.values)
                  ButtonSegment(
                    value: type,
                    label: Text(shiftTypeLabel(type, l10n)),
                  ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => _changeType(selection.single),
            ),
            _section(context, l10n.planned),
            _timeRow(
              start: _plannedStart,
              end: _plannedEnd,
              onStart: (m) => setState(() {
                _plannedStart = m;
                _plannedCustomized = true;
              }),
              onEnd: (m) => setState(() {
                _plannedEnd = m;
                _plannedCustomized = true;
              }),
            ),
            _section(context, l10n.actual, highlight: true),
            if (_isRunning)
              Text(l10n.recordingRunning)
            else if (_hasActual) ...[
              _timeRow(
                start: _actualStart!,
                end: _actualEnd!,
                highlight: true,
                onStart: (m) => setState(() => _actualStart = m),
                onEnd: (m) => setState(() => _actualEnd = m),
              ),
              if (shift?.rawStart != null && shift?.rawEnd != null)
                Text(
                  l10n.recordedRaw(hhmm(shift!.rawStart!), hhmm(shift.rawEnd!)),
                  style: context.text.bodySmall,
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _actualStart = _actualEnd = null),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.removeActual),
                ),
              ),
            ] else
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _actualStart = _plannedStart;
                  _actualEnd = _plannedEnd;
                }),
                icon: const Icon(Icons.content_copy),
                label: Text(l10n.takePlanned),
              ),
            _section(context, l10n.pause),
            Wrap(
              spacing: 8,
              children: [
                for (final minutes in [0, 15, 30, 45])
                  ChoiceChip(
                    label: Text(
                      minutes == 0
                          ? l10n.pauseNone
                          : l10n.minutesShort(minutes),
                    ),
                    selected: _break == minutes,
                    onSelected: (_) => setState(() => _break = minutes),
                  ),
                ChoiceChip(
                  label: Text(
                    [0, 15, 30, 45].contains(_break)
                        ? l10n.pauseOther
                        : l10n.minutesShort(_break),
                  ),
                  selected: ![0, 15, 30, 45].contains(_break),
                  onSelected: (_) => _pickOtherBreak(),
                ),
              ],
            ),
            Panel(
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: colors.surfaceContainer,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.workingTime, style: context.text.titleSmall),
                        if (!_hasActual)
                          Text(
                            l10n.notRecordedYet,
                            style: context.text.bodySmall,
                          ),
                        if (settings.calendarName != null)
                          Text(
                            l10n.calendarInfo(
                              settings.calendarName!,
                              settings.eventTitle,
                            ),
                            style: context.text.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.hours(formatHours(worked, context.locale)),
                    style: context.text.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                FilledButton(onPressed: _save, child: Text(l10n.save)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title, {
    bool highlight = false,
  }) => Text(
    title,
    style: context.text.titleSmall?.copyWith(
      color: highlight
          ? context.colors.primary
          : context.colors.onSurfaceVariant,
    ),
  );

  Widget _timeRow({
    required Minutes start,
    required Minutes end,
    required ValueChanged<Minutes> onStart,
    required ValueChanged<Minutes> onEnd,
    bool highlight = false,
  }) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: TimeField(
                label: l10n.start,
                value: start,
                highlight: highlight,
                onPicked: onStart,
              ),
            ),
            Expanded(
              child: TimeField(
                label: l10n.end,
                value: end,
                highlight: highlight,
                onPicked: onEnd,
              ),
            ),
          ],
        ),
        if (end <= start) Text(l10n.endsNextDay, style: context.text.bodySmall),
      ],
    );
  }
}
