import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/time.dart';
import '../domain/roster.dart';
import 'database.dart';

/// Reads and writes the team planner's tables (F11): people, their answers
/// per week, who is in which shift, and the week's own staff counts.
/// See docs/02-design.md §3 and §4.9.
class RosterRepository {
  RosterRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // People

  /// Everyone on the team list.
  Stream<List<TeamMember>> watchMembers() =>
      _db.select(_db.teamMembers).watch();

  Future<TeamMember> addMember(
    String name, {
    bool core = false,
    bool isMe = false,
    int? maxMonthMinutes,
  }) async {
    final now = DateTime.now();
    final member = TeamMember(
      id: _uuid.v4(),
      name: name.trim(),
      core: core,
      isMe: isMe,
      maxMonthMinutes: maxMonthMinutes,
      active: true,
      createdAt: now,
      updatedAt: now,
    );
    await _db.transaction(() async {
      if (isMe) await _clearMe();
      await _db.into(_db.teamMembers).insert(member);
    });
    return member;
  }

  /// Saves a changed person. "This is me" is taken away from everyone else.
  Future<void> saveMember(TeamMember member) => _db.transaction(() async {
    if (member.isMe) await _clearMe();
    await _db
        .update(_db.teamMembers)
        .replace(
          member.copyWith(name: member.name.trim(), updatedAt: DateTime.now()),
        );
  });

  Future<void> _clearMe() =>
      (_db.update(_db.teamMembers)..where((t) => t.isMe.equals(true))).write(
        const TeamMembersCompanion(isMe: Value(false)),
      );

  /// Whether the person has answers or shifts in any week (then deleting
  /// asks first).
  Future<bool> hasEntries(String memberId) async {
    final answer =
        await (_db.select(_db.teamAnswers)
              ..where((t) => t.memberId.equals(memberId))
              ..limit(1))
            .getSingleOrNull();
    if (answer != null) return true;
    final assignment =
        await (_db.select(_db.teamAssignments)
              ..where((t) => t.memberId.equals(memberId))
              ..limit(1))
            .getSingleOrNull();
    return assignment != null;
  }

  /// Deletes the person with their answers and shifts in all weeks, so no
  /// shift counts someone the board can't show.
  Future<void> deleteMember(String memberId) => _db.transaction(() async {
    await (_db.delete(
      _db.teamAnswers,
    )..where((t) => t.memberId.equals(memberId))).go();
    await (_db.delete(
      _db.teamAssignments,
    )..where((t) => t.memberId.equals(memberId))).go();
    await (_db.delete(
      _db.teamMembers,
    )..where((t) => t.id.equals(memberId))).go();
  });

  // Answers

  Stream<List<TeamAnswer>> watchAnswers(DateTime weekStart) => (_db.select(
    _db.teamAnswers,
  )..where((t) => t.weekStart.equals(dayKey(weekStart)))).watch();

  /// Saves the person's answer for the week, replacing an earlier one.
  /// Select and write share a transaction, so a double tap can't hit the
  /// unique key.
  Future<void> setAnswer(
    DateTime weekStart,
    String memberId, {
    required AnswerMode mode,
    required int marks,
    int? maxShifts,
  }) => _db.transaction(() async {
    final key = dayKey(weekStart);
    final existing =
        await (_db.select(_db.teamAnswers)..where(
              (t) => t.weekStart.equals(key) & t.memberId.equals(memberId),
            ))
            .getSingleOrNull();
    final now = DateTime.now();
    if (existing == null) {
      await _db
          .into(_db.teamAnswers)
          .insert(
            TeamAnswer(
              id: _uuid.v4(),
              weekStart: key,
              memberId: memberId,
              mode: mode,
              marks: marks,
              maxShifts: maxShifts,
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await _db
          .update(_db.teamAnswers)
          .replace(
            existing.copyWith(
              mode: mode,
              marks: marks,
              maxShifts: Value(maxShifts),
              updatedAt: now,
            ),
          );
    }
  });

  /// Back to "No answer yet".
  Future<void> removeAnswer(DateTime weekStart, String memberId) =>
      (_db.delete(_db.teamAnswers)..where(
            (t) =>
                t.weekStart.equals(dayKey(weekStart)) &
                t.memberId.equals(memberId),
          ))
          .go();

  // Assignments

  /// Who is in which shift, in the week starting [weekStart].
  Stream<List<TeamAssignment>> watchAssignments(DateTime weekStart) =>
      (_db.select(_db.teamAssignments)..where(
            (t) => t.day.isBetweenValues(
              dayKey(weekStart),
              dayKey(addDays(weekStart, 6)),
            ),
          ))
          .watch();

  /// Who is in which shift from [from] to [to], both days included.
  Stream<List<TeamAssignment>> watchAssignmentsBetween(
    DateTime from,
    DateTime to,
  ) => (_db.select(
    _db.teamAssignments,
  )..where((t) => t.day.isBetweenValues(dayKey(from), dayKey(to)))).watch();

  Future<List<TeamAssignment>> assignmentsOfWeek(DateTime weekStart) =>
      (_db.select(_db.teamAssignments)..where(
            (t) => t.day.isBetweenValues(
              dayKey(weekStart),
              dayKey(addDays(weekStart, 6)),
            ),
          ))
          .get();

  /// Puts the person into the shift (nothing happens if already there).
  Future<void> assign(TeamSlot slot, String memberId) =>
      addAll([FillPick(memberId, slot)]);

  /// Adds several people at once; returns the new rows (for Undo).
  Future<List<TeamAssignment>> addAll(List<FillPick> picks) async {
    final now = DateTime.now();
    final rows = [
      for (final p in picks)
        TeamAssignment(
          id: _uuid.v4(),
          day: p.slot.dayKey,
          shift: p.slot.shift,
          memberId: p.memberId,
          createdAt: now,
          updatedAt: now,
        ),
    ];
    await _db.batch(
      (b) => b.insertAll(
        _db.teamAssignments,
        rows,
        mode: InsertMode.insertOrIgnore,
      ),
    );
    return rows;
  }

  Future<void> unassign(TeamSlot slot, String memberId) =>
      (_db.delete(_db.teamAssignments)..where(
            (t) =>
                t.day.equals(slot.dayKey) &
                t.shift.equalsValue(slot.shift) &
                t.memberId.equals(memberId),
          ))
          .go();

  /// Sets a special start time; null = the shift's normal start.
  Future<void> setStart(TeamAssignment assignment, int? startMinutes) => _db
      .update(_db.teamAssignments)
      .replace(
        assignment.copyWith(
          startMinutes: Value(startMinutes),
          updatedAt: DateTime.now(),
        ),
      );

  /// Removes these rows (Undo of Fill).
  Future<void> removeAll(List<TeamAssignment> rows) => (_db.delete(
    _db.teamAssignments,
  )..where((t) => t.id.isIn(rows.map((r) => r.id)))).go();

  /// Empties the week's shifts; returns what was removed (for Undo).
  Future<List<TeamAssignment>> clearWeek(DateTime weekStart) =>
      _db.transaction(() async {
        final rows = await assignmentsOfWeek(weekStart);
        await removeAll(rows);
        return rows;
      });

  /// Puts removed rows back unchanged (Undo of Clear).
  Future<void> restoreAll(List<TeamAssignment> rows) => _db.batch(
    (b) =>
        b.insertAll(_db.teamAssignments, rows, mode: InsertMode.insertOrIgnore),
  );

  // Staff counts

  Stream<List<TeamNeed>> watchNeeds(DateTime weekStart) =>
      (_db.select(_db.teamNeeds)..where(
            (t) => t.day.isBetweenValues(
              dayKey(weekStart),
              dayKey(addDays(weekStart, 6)),
            ),
          ))
          .watch();

  /// The week's own staff count for [slot]. Equal to [defaultNeeded], the
  /// row is removed, so the setting counts again.
  Future<void> setNeeded(TeamSlot slot, int needed, int defaultNeeded) =>
      _db.transaction(() async {
        await (_db.delete(_db.teamNeeds)..where(
              (t) =>
                  t.day.equals(slot.dayKey) & t.shift.equalsValue(slot.shift),
            ))
            .go();
        if (needed != defaultNeeded) {
          await _db
              .into(_db.teamNeeds)
              .insert(
                TeamNeed(
                  id: _uuid.v4(),
                  day: slot.dayKey,
                  shift: slot.shift,
                  needed: needed,
                ),
              );
        }
      });
}
