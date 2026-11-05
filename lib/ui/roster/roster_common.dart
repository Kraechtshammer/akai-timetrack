// Small pieces shared by the team planner screens (F11).
// Rules live in domain/roster.dart; see docs/02-design.md §4.9 and §7.

import 'package:intl/intl.dart';

import '../material.dart';

import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/roster.dart';
import '../../l10n/app_localizations.dart';
import '../common.dart';

/// The Monday of the week the planner opens on: next week.
DateTime nextPlanWeek(DateTime now) => addDays(weekStart(now), 7);

/// Sun for lunch, moon for evening, as on the Home tab.
IconData teamShiftIcon(TeamShift shift) => switch (shift) {
  TeamShift.lunch => Icons.light_mode,
  TeamShift.evening => Icons.dark_mode,
};

/// "Lunch" / "Evening".
String teamShiftLabel(TeamShift shift, AppLocalizations l10n) =>
    switch (shift) {
      TeamShift.lunch => l10n.shiftLunch,
      TeamShift.evening => l10n.shiftEvening,
    };

/// "lunch" / "evening" inside a sentence.
String teamShiftShort(TeamShift shift, AppLocalizations l10n) =>
    switch (shift) {
      TeamShift.lunch => l10n.teamLunchShort,
      TeamShift.evening => l10n.teamEveningShort,
    };

/// "9 Nov – 15 Nov" style range of a week, in the app's language.
String weekRange(DateTime weekStart, String locale) {
  final dates = DateFormat.MMMd(locale);
  return '${dates.format(weekStart)} – ${dates.format(addDays(weekStart, 6))}';
}

/// The summary line of an answer: "Available: Mon evening, Thu, Sat lunch",
/// "Available: every shift", "Away this week" or "No answer yet".
String availabilitySummary(
  RosterWeek week,
  String memberId,
  AppLocalizations l10n,
) {
  if (week.answerOf(memberId) == null) return l10n.teamNoAnswer;
  if (week.isAway(memberId)) return l10n.teamAway;
  final days = week.availableDays(memberId);
  final possible = week.possibleCount(memberId);
  if (possible == 0) return l10n.teamAvailableNone;
  if (possible == week.openSlotCount) return l10n.teamAvailableAll;
  final weekday = DateFormat.E(l10n.localeName);
  return l10n.teamAvailable(
    days
        .map(
          (d) => d.shift == null
              ? weekday.format(d.day)
              : '${weekday.format(d.day)} ${teamShiftShort(d.shift!, l10n)}',
        )
        .join(', '),
  );
}

/// The small star after a core worker's name.
class CoreStar extends StatelessWidget {
  const CoreStar({super.key, this.size = 16, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Icon(
    Icons.star_rounded,
    size: size,
    color: color ?? context.colors.tertiary,
    semanticLabel: context.l10n.teamCore,
  );
}

/// A name with the core star, for list rows and titles.
class MemberName extends StatelessWidget {
  const MemberName(this.member, {super.key, this.style});

  final TeamMember member;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      Flexible(
        child: Text(member.name, style: style, overflow: TextOverflow.ellipsis),
      ),
      if (member.core) CoreStar(size: (style?.fontSize ?? 14) + 2),
    ],
  );
}
