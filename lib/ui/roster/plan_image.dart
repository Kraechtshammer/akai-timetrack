// The shareable picture of a team plan (F11), docs/02-design.md §7
// "Share preview". Fixed size and light colours, whatever the app theme.

import 'package:intl/intl.dart';

import '../material.dart';

import '../../core/time.dart';
import '../../data/app_settings.dart';
import '../../data/database.dart';
import '../../domain/roster.dart';
import '../../l10n/app_localizations.dart';
import 'roster_common.dart';

class TeamPlanImage extends StatelessWidget {
  const TeamPlanImage({
    super.key,
    required this.week,
    required this.starts,
    required this.l10n,
  });

  final RosterWeek week;
  final TeamStarts starts;
  final AppLocalizations l10n;

  /// Layout size; rendered at [pixelRatio] this gives a 1920x1080 PNG.
  static const Size size = Size(1600, 900);
  static const double pixelRatio = 1.2;

  static const _red = Color(0xFFC62828);
  static const _ink = Color(0xFF1B1B1B);
  static const _grey = Color(0xFF6B6B6B);
  static const _line = Color(0xFFD9D9D9);
  static const _closed = Color(0xFFF1F1F1);
  static const _padding = 48.0;
  static const _titleHeight = 72.0;
  static const _headerHeight = 72.0;
  static const _labelWidth = 180.0;
  static const _cellPadding = 12.0;
  static const _lineFactor = 1.35;

  /// One name size for the whole picture: the biggest that fits the
  /// fullest cell, between 18 and 30.
  double _nameSize(double rowHeight) {
    var most = 1;
    for (final slot in week.slots) {
      final n = week.membersIn(slot).length;
      if (n > most) most = n;
    }
    var fontSize = 30.0;
    while (fontSize > 18 &&
        most * fontSize * _lineFactor + 2 * _cellPadding > rowHeight) {
      fontSize -= 1;
    }
    return fontSize;
  }

  @override
  Widget build(BuildContext context) {
    final locale = l10n.localeName;
    final days = week.shownDays;
    final dayFormat = locale.startsWith('de')
        ? DateFormat('E d.M.', locale)
        : DateFormat('E M/d', locale);
    final tableHeight = size.height - 2 * _padding - _titleHeight - 24;
    final rowHeight = (tableHeight - _headerHeight) / 2;
    final nameSize = _nameSize(rowHeight);

    final theme = ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: _red,
    );
    // The phone's font size setting must not change the fixed layout.
    return MediaQuery.withNoTextScaling(
      child: Theme(
        data: theme,
        child: Material(
          color: Colors.white,
          textStyle: const TextStyle(color: _ink),
          child: SizedBox.fromSize(
            size: size,
            child: Padding(
              padding: const EdgeInsets.all(_padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: _titleHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.teamImageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: _red,
                            ),
                          ),
                        ),
                        Text(
                          l10n.teamImageWeek(
                            isoWeekNumber(week.weekStart),
                            weekRange(week.weekStart, locale),
                          ),
                          style: const TextStyle(fontSize: 32, color: _grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: _line),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Column(
                          children: [
                            SizedBox(
                              height: _headerHeight,
                              child: Row(
                                children: [
                                  const SizedBox(width: _labelWidth),
                                  for (final day in days)
                                    Expanded(
                                      child: _box(
                                        alignment: Alignment.center,
                                        child: _fit(
                                          Text(
                                            dayFormat.format(day),
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: _red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            for (final shift in TeamShift.values)
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: _labelWidth,
                                      child: _box(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fit(
                                              Text(
                                                teamShiftLabel(shift, l10n),
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: _red,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              minutesToHhmm(starts.of(shift)),
                                              style: const TextStyle(
                                                fontSize: 22,
                                                color: _grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    for (final day in days)
                                      Expanded(
                                        child: _cell(
                                          TeamSlot(day, shift),
                                          nameSize,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A grid cell with thin lines on its right and bottom edges.
  Widget _box({
    required Alignment alignment,
    required Widget child,
    Color? color,
  }) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      border: const Border(
        right: BorderSide(color: _line),
        bottom: BorderSide(color: _line),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(_cellPadding),
      child: Align(alignment: alignment, child: child),
    ),
  );

  /// Shrinks a single line instead of overflowing sideways.
  Widget _fit(Widget child) => FittedBox(fit: BoxFit.scaleDown, child: child);

  Widget _cell(TeamSlot slot, double nameSize) {
    if (!week.slotShown(slot)) {
      return _box(
        alignment: Alignment.center,
        color: _closed,
        child: const SizedBox.shrink(),
      );
    }
    final starts = {
      for (final a in week.assignmentsIn(slot))
        if (a.startMinutes != null) a.memberId: a.startMinutes!,
    };
    return _box(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final member in week.membersIn(slot))
            Align(
              alignment: Alignment.centerLeft,
              child: _fit(
                Text.rich(
                  TextSpan(
                    text: member.name,
                    style: TextStyle(
                      fontSize: nameSize,
                      height: _lineFactor,
                      color: _ink,
                    ),
                    children: [
                      if (starts[member.id] case final m?)
                        TextSpan(
                          text: '  ${l10n.teamStartAt(minutesToHhmm(m))}',
                          style: TextStyle(
                            fontSize: nameSize * 0.75,
                            color: _grey,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
