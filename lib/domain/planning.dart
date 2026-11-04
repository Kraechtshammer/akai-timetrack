import '../core/time.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';
import '../data/shift_repository.dart';
import 'shift_info.dart';

/// Default times for a new shift. Lunch ends earlier when there is an
/// evening shift on the same day.
ShiftTimes defaultTimes(
  ShiftType type,
  AppSettings settings, {
  bool eveningSameDay = false,
}) => switch (type) {
  ShiftType.lunch =>
    eveningSameDay ? settings.lunchBeforeEvening : settings.lunch,
  ShiftType.evening => settings.evening,
  ShiftType.custom => const ShiftTimes(18 * 60, 22 * 60),
};

enum ToggleResult { added, removed, keptRecorded }

/// Planning on the Plan tab: add, change and remove shifts.
class PlanningService {
  PlanningService(this._shifts, this._settings, this._onChanged);

  final ShiftRepository _shifts;
  final SettingsRepository _settings;

  /// Runs calendar sync and notification updates after a change.
  final Future<void> Function() _onChanged;

  /// Tap on "Mittag" or "Abend": adds the shift or removes it again.
  /// Recorded or running shifts are never removed this way.
  Future<ToggleResult> toggle(DateTime day, ShiftType type) async {
    final shifts = await _shiftsOn(day);
    final existing = shifts.where((s) => s.type == type).firstOrNull;

    final ToggleResult result;
    if (existing == null) {
      final settings = await _settings.load();
      final hasEvening = shifts.any((s) => s.type == ShiftType.evening);
      final times = defaultTimes(type, settings, eveningSameDay: hasEvening);
      final (start, end) = timesOn(day, times.start, times.end);
      await _shifts.create(
        day: day,
        type: type,
        plannedStart: start,
        plannedEnd: end,
      );
      result = ToggleResult.added;
    } else if (existing.isRecorded || existing.isRunning) {
      return ToggleResult.keptRecorded;
    } else {
      await _shifts.delete(existing);
      result = ToggleResult.removed;
    }

    await _adjustLunch(day);
    await _onChanged();
    return result;
  }

  /// Creates a shift from the edit sheet.
  Future<Shift> create(
    DateTime day,
    ShiftType type,
    DateTime plannedStart,
    DateTime plannedEnd,
  ) async {
    final shift = await _shifts.create(
      day: day,
      type: type,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      plannedCustomized: type == ShiftType.custom,
    );
    await _adjustLunch(day);
    await _onChanged();
    return shift;
  }

  Future<void> save(Shift shift) async {
    await _shifts.save(shift);
    await _adjustLunch(shift.dayDate);
    await _onChanged();
  }

  Future<void> delete(Shift shift) async {
    await _shifts.delete(shift);
    await _adjustLunch(shift.dayDate);
    await _onChanged();
  }

  Future<void> restore(Shift shift) async {
    await _shifts.restore(shift);
    await _adjustLunch(shift.dayDate);
    await _onChanged();
  }

  /// Keeps an untouched lunch shift at the right default:
  /// 12:00–15:30 with an evening shift that day, otherwise 12:00–16:00.
  Future<void> _adjustLunch(DateTime day) async {
    final shifts = await _shiftsOn(day);
    final lunch = shifts.where((s) => s.type == ShiftType.lunch).firstOrNull;
    if (lunch == null ||
        lunch.plannedCustomized ||
        lunch.isRecorded ||
        lunch.isRunning) {
      return;
    }
    final hasEvening = shifts.any((s) => s.type == ShiftType.evening);
    final times = defaultTimes(
      ShiftType.lunch,
      await _settings.load(),
      eveningSameDay: hasEvening,
    );
    final (start, end) = timesOn(day, times.start, times.end);
    if (start != lunch.plannedStart || end != lunch.plannedEnd) {
      await _shifts.save(lunch.copyWith(plannedStart: start, plannedEnd: end));
    }
  }

  Future<List<Shift>> _shiftsOn(DateTime day) =>
      _shifts.getDays(dateOnly(day), addDays(day, 1));
}
