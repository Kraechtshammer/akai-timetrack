import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/time.dart';
import '../../domain/tips.dart';
import '../common.dart';

/// Opens the sheet for a day's pool total ("Tagestopf"). [current]: the
/// stored amount in cents, if any.
Future<void> showTipDaySheet(
  BuildContext context,
  WidgetRef ref, {
  required DateTime day,
  int? current,
}) {
  final l10n = context.l10n;
  final tips = ref.services.tips;
  final date = DateFormat.MMMEd(context.locale).format(day);
  return _showMoneySheet(
    context,
    title: l10n.tipPoolTitle(date),
    hint: l10n.tipPoolHint,
    current: current,
    save: (cents) => tips.setDay(day, cents),
  );
}

/// Opens the sheet for a week's payout ("Ausgezahlt").
Future<void> showTipPayoutSheet(
  BuildContext context,
  WidgetRef ref, {
  required DateTime week,
  int? current,
}) {
  final l10n = context.l10n;
  final tips = ref.services.tips;
  return _showMoneySheet(
    context,
    title: l10n.tipPayoutTitle(isoWeekNumber(week)),
    hint: l10n.tipPayoutHint,
    current: current,
    save: (cents) => tips.setPayout(weekStart(week), cents),
  );
}

Future<void> _showMoneySheet(
  BuildContext context, {
  required String title,
  required String hint,
  required int? current,
  required Future<void> Function(int? cents) save,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final deleted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) =>
        _MoneySheet(title: title, hint: hint, current: current, save: save),
  );
  if (deleted == true && current != null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.tipDeleted),
          // A snack bar with an action stays until dismissed unless told not to.
          persist: false,
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => save(current),
          ),
        ),
      );
  }
}

/// One money field with "Speichern" and, for a stored amount, "Löschen".
/// Pops `true` when the amount was deleted (so the caller offers undo).
class _MoneySheet extends StatefulWidget {
  const _MoneySheet({
    required this.title,
    required this.hint,
    required this.current,
    required this.save,
  });

  final String title;
  final String hint;
  final int? current;
  final Future<void> Function(int? cents) save;

  @override
  State<_MoneySheet> createState() => _MoneySheetState();
}

class _MoneySheetState extends State<_MoneySheet> {
  late final TextEditingController _controller;
  var _invalid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cents = widget.current;
    if (cents != null && _controller.text.isEmpty) {
      // Without grouping, so it's easy to edit: "1234,50", "40".
      _controller.text = cents % 100 == 0
          ? '${cents ~/ 100}'
          : NumberFormat('0.00', context.locale).format(cents / 100);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      // An empty field means "no amount".
      if (widget.current != null) return _delete();
      Navigator.pop(context);
      return;
    }
    final cents = parseEuroCents(text, context.locale);
    if (cents == null) {
      setState(() => _invalid = true);
      return;
    }
    await widget.save(cents);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await widget.save(null);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(widget.title, style: context.text.titleLarge),
          Text(
            widget.hint,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            onChanged: (_) {
              if (_invalid) setState(() => _invalid = false);
            },
            style: context.text.headlineSmall?.copyWith(
              fontFeatures: tabularFigures,
            ),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixText: '€',
              hintText: '0',
              errorText: _invalid ? l10n.tipInvalid : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              if (widget.current != null)
                M3EButton(
                  style: M3EButtonStyle.text,
                  onPressed: _delete,
                  child: Text(l10n.delete),
                ),
              M3EButton(onPressed: _save, child: Text(l10n.save)),
            ],
          ),
        ],
      ),
    );
  }
}
