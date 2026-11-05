import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/salary.dart';
import '../../domain/tips.dart';
import '../common.dart';

/// Opens the sheet for the hourly wage. A new rate starts on the 1st of
/// [month] (the month on screen) unless another day is picked
/// (docs/02-design.md §4.8).
Future<void> showWageSheet(BuildContext context, {required DateTime month}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _WageSheet(month: monthStart(month)),
    );

/// "Hourly wage": the amount, "Valid from", and the list of all rates.
class _WageSheet extends ConsumerStatefulWidget {
  const _WageSheet({required this.month});

  final DateTime month;

  @override
  ConsumerState<_WageSheet> createState() => _WageSheetState();
}

class _WageSheetState extends ConsumerState<_WageSheet> {
  final _controller = TextEditingController();
  late var _validFrom = widget.month;
  var _invalid = false;
  var _filled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filled) return;
    _filled = true;
    // Start with the rate that applies to the month, easy to edit: "14,5".
    final rates = ref.read(wageRatesProvider).value ?? const [];
    final cents = rateOn(dayKey(_validFrom), rates);
    if (cents != null) {
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

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _validFrom,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2, 12, 31),
    );
    if (picked != null) setState(() => _validFrom = dateOnly(picked));
  }

  Future<void> _save() async {
    final cents = parseEuroCents(_controller.text.trim(), context.locale);
    if (cents == null || cents == 0) {
      setState(() => _invalid = true);
      return;
    }
    await ref.services.wages.setRate(_validFrom, cents);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete(WageRate rate) async {
    final l10n = context.l10n;
    final date = DateFormat.yMMMd(context.locale)
        .format(parseDayKey(rate.validFrom));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.wageDeleteTitle(date)),
        actions: [
          M3EButton(
            style: M3EButtonStyle.text,
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          M3EButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.services.wages.deleteRate(parseDayKey(rate.validFrom));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.locale;
    final colors = context.colors;
    final rates = ref.watch(wageRatesProvider).value ?? const [];
    final dates = DateFormat.yMMMd(locale);

    return SingleChildScrollView(
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
          Text(l10n.wageRate, style: context.text.titleLarge),
          Text(
            rates.isEmpty
                ? '${l10n.wageSheetHint} ${l10n.wageFirstHint}'
                : l10n.wageSheetHint,
            style: context.text.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
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
              suffixText: '€/h',
              hintText: '0',
              errorText: _invalid ? l10n.wageInvalid : null,
            ),
          ),
          // The first rate counts for every month, so the day doesn't matter.
          if (rates.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.wageValidFrom,
                    style: context.text.titleSmall,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.event_outlined),
                  label: Text(dates.format(_validFrom)),
                  onPressed: _pickDay,
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [M3EButton(onPressed: _save, child: Text(l10n.save))],
          ),
          if (rates.isNotEmpty) ...[
            Divider(height: 8, color: colors.outlineVariant),
            Text(l10n.wageAll, style: context.text.titleSmall),
            for (final rate in rates.reversed)
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(
                      l10n.wageSince(dates.format(parseDayKey(rate.validFrom))),
                    ),
                  ),
                  Text(
                    '${formatEuros(rate.hourlyCents, locale)}/h',
                    style: context.text.titleMedium?.copyWith(
                      fontFeatures: tabularFigures,
                    ),
                  ),
                  M3EIconButton(
                    variant: M3EIconButtonVariant.standard,
                    tooltip: l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(rate),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
