import 'package:drift/drift.dart' show Value;

import '../core/time.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';
import '../data/shift_repository.dart';
import 'planning.dart';
import 'rounding.dart';
import 'shift_info.dart';

/// How long before its planned start a shift can be started from "Heute".
const startWindow = Duration(hours: 2);

/// The shift the big Start button on "Heute" would start: today's first
/// shift that isn't recorded yet and starts within [startWindow] or has
/// already begun. null if there is none.
Shift? shiftToStart(List<Shift> todaysShifts, DateTime now) {
  for (final shift in todaysShifts) {
    if (shift.isRecorded || shift.isRunning) continue;
    final opensAt = shift.plannedStart.subtract(startWindow);
    if (!now.isBefore(opensAt) && now.isBefore(shift.plannedEnd)) return shift;
  }
  return null;
}

/// Starting and stopping the time recording. Used by the screens and by the
/// notification buttons.
class RecordingService {
  RecordingService(this._shifts, this._settings, this._onChanged);

  final ShiftRepository _shifts;
  final SettingsRepository _settings;
  final Future<void> Function() _onChanged;

  /// Starts recording. Uses [shiftId] if given, otherwise today's shift
  /// that is about to start. Without a planned shift, it creates one:
  /// lunch before 15:00, evening after.
  Future<Shift?> start({String? shiftId, DateTime? at}) async {
    final now = at ?? DateTime.now();
    if (await _shifts.running() != null) return null;

    var shift = shiftId != null ? await _shifts.get(shiftId) : null;
    if (shift == null || shift.isRecorded) {
      final today = dateOnly(now);
      shift = shiftToStart(
        await _shifts.getDays(today, addDays(today, 1)),
        now,
      );
    }
    shift ??= await _createUnplanned(now);

    final started = shift.copyWith(rawStart: Value(now), rawEnd: Value(null));
    await _shifts.save(started);
    await _onChanged();
    return started;
  }

  /// Stops recording and saves the rounded times. With [atPlannedEnd], the
  /// shift ends at its planned end ("Ende 23:00" in the notification).
  Future<Shift?> stop({DateTime? at, bool atPlannedEnd = false}) async {
    final shift = await _shifts.running();
    if (shift == null) return null;

    var end = at ?? DateTime.now();
    if (atPlannedEnd && shift.plannedEnd.isAfter(shift.rawStart!)) {
      end = shift.plannedEnd;
    }
    final settings = await _settings.load();
    final (actualStart, actualEnd) = roundShift(
      shift.rawStart!,
      end,
      settings.roundingMode,
    );
    final stopped = shift.copyWith(
      rawEnd: Value(end),
      actualStart: Value(actualStart),
      actualEnd: Value(actualEnd),
    );
    await _shifts.save(stopped);
    await _onChanged();
    return stopped;
  }

  /// Corrects the start time of the running recording.
  Future<void> changeStart(DateTime start) async {
    final shift = await _shifts.running();
    if (shift == null) return;
    await _shifts.save(shift.copyWith(rawStart: Value(start)));
    await _onChanged();
  }

  Future<Shift> _createUnplanned(DateTime now) async {
    final type = now.hour < 15 ? ShiftType.lunch : ShiftType.evening;
    final times = defaultTimes(type, await _settings.load());
    final day = dateOnly(now);
    final (start, end) = timesOn(day, times.start, times.end);
    return _shifts.create(
      day: day,
      type: type,
      plannedStart: start,
      plannedEnd: end,
    );
  }
}
