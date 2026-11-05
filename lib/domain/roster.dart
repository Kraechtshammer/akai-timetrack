// Team planner (F11): availability, staff counts, the order of people in
// the shift sheet, and Fill. Pure Dart. See docs/02-design.md §4.9.

import '../core/time.dart';
import '../data/app_settings.dart';
import '../data/database.dart';

/// One shift of the team plan: a day and lunch or evening.
class TeamSlot {
  TeamSlot(DateTime day, this.shift) : day = dateOnly(day);

  final DateTime day;
  final TeamShift shift;

  String get dayKey => _dayKey(day);

  @override
  bool operator ==(Object other) =>
      other is TeamSlot && other.day == day && other.shift == shift;

  @override
  int get hashCode => Object.hash(day, shift);

  @override
  String toString() => '$dayKey ${shift.name}';
}

/// The core helper under another name, because [TeamSlot.dayKey] hides it.
String _dayKey(DateTime day) => dayKey(day);

/// The bit in [TeamAnswer.marks] for a shift on [day].
int markBit(DateTime day, TeamShift shift) =>
    1 << ((day.weekday - 1) * 2 + shift.index);

/// Marks with the shift on [day] switched on or off.
int withMark(int marks, DateTime day, TeamShift shift, bool on) =>
    on ? marks | markBit(day, shift) : marks & ~markBit(day, shift);

bool isMarked(int marks, DateTime day, TeamShift shift) =>
    marks & markBit(day, shift) != 0;

enum Availability { available, noAnswer, unavailable }

/// What an answer says about one shift. Closed shifts are never available.
bool answerAllows(AnswerMode mode, int marks, DateTime day, TeamShift shift) {
  final marked = isMarked(marks, day, shift);
  return mode == AnswerMode.canWork ? marked : !marked;
}

/// Case-insensitive by name, then by id so the order is stable.
int compareByName(TeamMember a, TeamMember b) {
  final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
  return byName != 0 ? byName : a.id.compareTo(b.id);
}

/// The people of a shift sheet, in their groups (§4.9).
class SlotCandidates {
  const SlotCandidates(this.available, this.noAnswer, this.unavailable);

  final List<TeamMember> available;
  final List<TeamMember> noAnswer;
  final List<TeamMember> unavailable;
}

/// A day of the availability summary: both open shifts, or just one.
class AvailableDay {
  const AvailableDay(this.day, this.shift);

  final DateTime day;

  /// null = every open shift of the day.
  final TeamShift? shift;
}

/// A person added by Fill.
class FillPick {
  const FillPick(this.memberId, this.slot);

  final String memberId;
  final TeamSlot slot;
}

class FillResult {
  const FillResult(this.added, this.openPlaces, this.withoutCore);

  final List<FillPick> added;

  /// Free places left in open shifts after filling.
  final int openPlaces;

  /// Open shifts that still have no core worker (only counted when
  /// someone is a core worker).
  final List<TeamSlot> withoutCore;
}

/// Everything about one planned week, with the rules of §4.9.
class RosterWeek {
  RosterWeek({
    required DateTime weekStart,
    required List<TeamMember> members,
    required List<TeamAnswer> answers,
    required List<TeamAssignment> assignments,
    required List<TeamNeed> needs,
    required this.defaults,
  }) : weekStart = dateOnly(weekStart),
       members = [...members]..sort(compareByName),
       assignments = List.unmodifiable(assignments),
       _answers = {for (final a in answers) a.memberId: a},
       _needs = {for (final n in needs) '${n.day} ${n.shift.index}': n.needed};

  final DateTime weekStart;

  /// Everyone on the team list, sorted by name. (The table's `active`
  /// column is unused since 2026-11-05: people who leave are deleted.)
  final List<TeamMember> members;
  final List<TeamAssignment> assignments;
  final StaffNeeds defaults;
  final Map<String, TeamAnswer> _answers;
  final Map<String, int> _needs;

  late final Map<String, TeamMember> _byId = {for (final m in members) m.id: m};

  List<DateTime> get days => [
    for (var i = 0; i < 7; i++) addDays(weekStart, i),
  ];

  List<TeamSlot> get slots => [
    for (final day in days)
      for (final shift in TeamShift.values) TeamSlot(day, shift),
  ];

  TeamMember? member(String id) => _byId[id];

  /// The person marked "This is me", if any.
  TeamMember? get me => members.where((m) => m.isMe).firstOrNull;

  /// Staff needed: the week's own number, else the default.
  int needed(TeamSlot slot) =>
      _needs['${slot.dayKey} ${slot.shift.index}'] ??
      defaults.needed(slot.day.weekday, slot.shift);

  /// The default number, for "back to default" when saving.
  int defaultNeeded(TeamSlot slot) =>
      defaults.needed(slot.day.weekday, slot.shift);

  bool isOpen(TeamSlot slot) => needed(slot) > 0;

  List<TeamAssignment> assignmentsIn(TeamSlot slot) => assignments
      .where((a) => a.day == slot.dayKey && a.shift == slot.shift)
      .toList();

  /// The people in [slot], sorted by name.
  List<TeamMember> membersIn(TeamSlot slot) =>
      [for (final a in assignmentsIn(slot)) ?_byId[a.memberId]]
        ..sort(compareByName);

  /// Shown on the board and in the image: open or with people in it.
  bool slotShown(TeamSlot slot) =>
      isOpen(slot) || assignmentsIn(slot).isNotEmpty;

  bool dayShown(DateTime day) =>
      TeamShift.values.any((s) => slotShown(TeamSlot(day, s)));

  List<DateTime> get shownDays => days.where(dayShown).toList();

  TeamAnswer? answerOf(String memberId) => _answers[memberId];

  Availability availability(String memberId, TeamSlot slot) {
    final answer = _answers[memberId];
    if (answer == null) return Availability.noAnswer;
    return isOpen(slot) &&
            answerAllows(answer.mode, answer.marks, slot.day, slot.shift)
        ? Availability.available
        : Availability.unavailable;
  }

  int shiftCount(String memberId) =>
      assignments.where((a) => a.memberId == memberId).length;

  /// Open shifts the person is available for.
  int possibleCount(String memberId) => slots
      .where((s) => availability(memberId, s) == Availability.available)
      .length;

  bool hasCore(TeamSlot slot) =>
      assignmentsIn(slot).any((a) => _byId[a.memberId]?.core ?? false);

  /// Whether anyone is a core worker (else no core warnings).
  bool get anyCore => members.any((m) => m.core);

  /// "No core worker" on the board.
  bool missesCore(TeamSlot slot) => anyCore && isOpen(slot) && !hasCore(slot);

  int get answeredCount =>
      members.where((m) => _answers.containsKey(m.id)).length;

  /// Where the walk-through starts: the first person without an answer,
  /// else the first one.
  int get firstUnanswered {
    final i = members.indexWhere((m) => !_answers.containsKey(m.id));
    return i < 0 ? 0 : i;
  }

  /// Free places left in open shifts.
  int get openPlaces => slots
      .where(isOpen)
      .fold(0, (sum, s) => sum + _free(needed(s), assignmentsIn(s).length));

  static int _free(int needed, int filled) =>
      needed > filled ? needed - filled : 0;

  /// The people for the shift sheet of [slot], in their groups.
  SlotCandidates candidates(TeamSlot slot) {
    final people = members;
    final available = <TeamMember>[];
    final noAnswer = <TeamMember>[];
    final unavailable = <TeamMember>[];
    for (final m in people) {
      switch (availability(m.id, slot)) {
        case Availability.available:
          available.add(m);
        case Availability.noAnswer:
          noAnswer.add(m);
        case Availability.unavailable:
          unavailable.add(m);
      }
    }
    // Without a core worker in the shift, core workers come first. Once
    // there is one, the others come first, because core workers cost more.
    final coreFirst = !hasCore(slot);
    available.sort((a, b) {
      if (a.core != b.core) return a.core == coreFirst ? -1 : 1;
      final byCount = shiftCount(a.id).compareTo(shiftCount(b.id));
      return byCount != 0 ? byCount : compareByName(a, b);
    });
    return SlotCandidates(available, noAnswer, unavailable);
  }

  /// The available open shifts of [memberId], for the summary line.
  /// A day is named once when all its open shifts are available.
  List<AvailableDay> availableDays(String memberId) {
    final result = <AvailableDay>[];
    for (final day in days) {
      final open = [
        for (final s in TeamShift.values)
          if (isOpen(TeamSlot(day, s))) s,
      ];
      final ok = [
        for (final s in open)
          if (availability(memberId, TeamSlot(day, s)) ==
              Availability.available)
            s,
      ];
      if (ok.isEmpty) continue;
      result.add(
        AvailableDay(day, ok.length == open.length ? null : ok.single),
      );
    }
    return result;
  }

  /// Answered, but available for no shift and not in the plan ("Away").
  bool isAway(String memberId) =>
      answerOf(memberId) != null &&
      possibleCount(memberId) == 0 &&
      shiftCount(memberId) == 0;

  /// Number of open shifts in the week.
  int get openSlotCount => slots.where(isOpen).length;

  /// Fills free places (§4.9): first one core worker per shift without
  /// one, then the rest, preferring people who aren't core workers.
  /// Never removes or moves anyone. Deterministic.
  FillResult fill() {
    final order = slots;
    final inSlot = {
      for (final s in order) s: {for (final a in assignmentsIn(s)) a.memberId},
    };
    final counts = {for (final m in members) m.id: shiftCount(m.id)};
    final added = <FillPick>[];

    int free(TeamSlot s) => _free(needed(s), inSlot[s]!.length);
    bool coreIn(TeamSlot s) => inSlot[s]!.any((id) => _byId[id]?.core ?? false);

    bool eligible(TeamMember m, TeamSlot s) {
      if (inSlot[s]!.contains(m.id)) return false;
      if (availability(m.id, s) != Availability.available) return false;
      final max = _answers[m.id]?.maxShifts;
      return max == null || counts[m.id]! < max;
    }

    bool worksOtherShift(TeamMember m, TeamSlot s) => inSlot.entries.any(
      (e) => e.key.day == s.day && e.key != s && e.value.contains(m.id),
    );

    int otherOptions(TeamMember m, TeamSlot s) =>
        order.where((o) => o != s && free(o) > 0 && eligible(m, o)).length;

    /// [othersFirst]: people who aren't core workers win before anything
    /// else (round two: core workers cost more).
    TeamMember best(
      List<TeamMember> people,
      TeamSlot s, {
      required bool othersFirst,
    }) {
      int key(TeamMember a, TeamMember b) {
        if (othersFirst && a.core != b.core) return a.core ? 1 : -1;
        final c = counts[a.id]!.compareTo(counts[b.id]!);
        if (c != 0) return c;
        final wa = worksOtherShift(a, s), wb = worksOtherShift(b, s);
        if (wa != wb) return wa ? 1 : -1;
        final o = otherOptions(a, s).compareTo(otherOptions(b, s));
        return o != 0 ? o : compareByName(a, b);
      }

      return ([...people]..sort(key)).first;
    }

    /// Adds one person per round to the hardest shift that [want] accepts,
    /// choosing among the people [pool] allows. Stops when nobody fits.
    void run(
      bool Function(TeamSlot) want,
      bool Function(TeamMember) pool, {
      bool othersFirst = false,
    }) {
      while (true) {
        TeamSlot? hardest;
        List<TeamMember> hardestPeople = const [];
        for (final s in order) {
          if (free(s) == 0 || !want(s)) continue;
          final people = members
              .where((m) => pool(m) && eligible(m, s))
              .toList();
          if (people.isEmpty) continue;
          if (hardest == null || people.length < hardestPeople.length) {
            hardest = s;
            hardestPeople = people;
          }
        }
        if (hardest == null) return;
        final pick = best(hardestPeople, hardest, othersFirst: othersFirst);
        inSlot[hardest]!.add(pick.id);
        counts[pick.id] = counts[pick.id]! + 1;
        added.add(FillPick(pick.id, hardest));
      }
    }

    run((s) => !coreIn(s), (m) => m.core);
    run((_) => true, (_) => true, othersFirst: true);

    final open = order.where(isOpen);
    return FillResult(
      added,
      open.fold(0, (sum, s) => sum + free(s)),
      anyCore ? open.where((s) => !coreIn(s)).toList() : const [],
    );
  }
}
