// Small pieces shared by the team planner screens (F11).
// Rules live in domain/roster.dart; see docs/02-design.md §4.9 and §7.

import 'package:intl/intl.dart';

import '../material.dart';

import '../../core/format.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/roster.dart';
import '../../domain/team_hours.dart';
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

/// Icon, colour and label of a monthly-hours warning; null when [state] is ok.
({IconData icon, Color color, String label})? hoursStateStyle(
  BuildContext context,
  HoursState state,
) => switch (state) {
  HoursState.ok => null,
  HoursState.aboveWeekShare => (
    icon: Icons.info_outline,
    color: context.colors.tertiary,
    label: context.l10n.teamAboveWeekShare,
  ),
  HoursState.overLimit => (
    icon: Icons.warning_amber,
    color: context.colors.error,
    label: context.l10n.teamOverLimit,
  ),
};

/// "noch 12,5 h" or "2,0 h zu viel" for minutes left under a monthly limit.
String hoursLeftText(BuildContext context, int minutesLeft) => minutesLeft < 0
    ? context.l10n.teamHoursOver(formatHours(-minutesLeft, context.locale))
    : context.l10n.teamHoursLeft(formatHours(minutesLeft, context.locale));

/// Explains the warnings of [member] this week: their answer for [slot]
/// (if given) and their monthly limit, with its numbers.
Future<void> showMemberWarnings(
  BuildContext context,
  RosterWeek week,
  TeamMember member, {
  TeamSlot? slot,
}) {
  final l10n = context.l10n;
  final colors = context.colors;
  final locale = context.locale;
  String h(int minutes) => formatHours(minutes, locale);

  Widget line(IconData icon, Color color, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: [
      Icon(icon, size: 20, color: color),
      Expanded(child: Text(text)),
    ],
  );

  final availability = slot == null
      ? Availability.available
      : week.availability(member.id, slot);
  final hours = week.weekHoursOf(member.id);
  final style = hours == null ? null : hoursStateStyle(context, hours.state);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: MemberName(member, style: context.text.headlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            if (availability == Availability.noAnswer)
              line(Icons.warning_amber, colors.error, l10n.teamWarnNoAnswer),
            if (availability == Availability.unavailable)
              line(Icons.warning_amber, colors.error, l10n.teamWarnCantWork),
            if (hours != null && style != null) ...[
              line(
                style.icon,
                style.color,
                hours.state == HoursState.overLimit
                    ? l10n.teamWarnOverLimit(
                        DateFormat.MMMM(locale).format(hours.month),
                        h(hours.monthMinutes),
                        h(hours.limit),
                        h(hours.monthMinutes - hours.limit),
                      )
                    // Vague on purpose: the share in whole hours, and no
                    // word on how much more is fine (the developer's wish).
                    : l10n.teamWarnAboveShare(
                        h(hours.leftBefore < 0 ? 0 : hours.leftBefore),
                        '${(hours.share / 60).round()}',
                        h(hours.weekMinutes),
                      ),
              ),
              Text(
                l10n.teamWarnFill,
                style: context.text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}
