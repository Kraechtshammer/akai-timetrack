// The People screen and the person sheet of the team planner (F11).
// See docs/02-design.md §7, "People".
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../core/format.dart';
import '../../domain/roster.dart';
import '../common.dart';
import 'roster_common.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final people = ref.watch(teamMembersProvider).value ?? const [];
    final sorted = [...people]..sort(compareByName);

    Widget row(TeamMember m) {
      final limit = m.maxMonthMinutes;
      final notes = [
        if (m.core) l10n.teamCore,
        if (m.isMe) l10n.teamIsMe,
        if (limit != null)
          l10n.teamHoursOnly(formatHours(limit, context.locale)),
      ];
      return ListTile(
        title: MemberName(m, style: context.text.bodyLarge),
        subtitle: notes.isEmpty ? null : Text(notes.join(' · ')),
        onTap: () => showPersonSheet(context, member: m),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.teamPeople)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPersonSheet(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.teamAddPerson),
      ),
      body: people.isEmpty
          ? Center(child: Text(l10n.teamNobodyYet))
          : ListView(
              // Space so the button does not cover the last row.
              padding: const EdgeInsets.only(bottom: 96),
              children: sorted.map(row).toList(),
            ),
    );
  }
}

/// Adds a person, or edits [member].
Future<void> showPersonSheet(BuildContext context, {TeamMember? member}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PersonSheet(member: member),
    );

class _PersonSheet extends ConsumerStatefulWidget {
  const _PersonSheet({this.member});

  final TeamMember? member;

  @override
  ConsumerState<_PersonSheet> createState() => _PersonSheetState();
}

class _PersonSheetState extends ConsumerState<_PersonSheet> {
  late final _name = TextEditingController(text: widget.member?.name);
  late final _max = TextEditingController(
    text: widget.member?.maxMonthMinutes == null
        ? ''
        : formatHours(widget.member!.maxMonthMinutes!, context.locale),
  );
  late var _core = widget.member?.core ?? false;
  late var _isMe = widget.member?.isMe ?? false;

  @override
  void dispose() {
    _name.dispose();
    _max.dispose();
    super.dispose();
  }

  String get _trimmed => _name.text.trim();

  bool get _duplicate {
    final others = ref.read(teamMembersProvider).value ?? const [];
    return others.any(
      (m) =>
          m.id != widget.member?.id &&
          m.name.trim().toLowerCase() == _trimmed.toLowerCase(),
    );
  }

  /// The limit in minutes; null when the field is empty or invalid.
  int? get _maxMinutes {
    final hours = double.tryParse(_max.text.trim().replaceAll(',', '.'));
    return hours == null ? null : (hours * 60).round();
  }

  bool get _maxInvalid {
    if (_max.text.trim().isEmpty) return false;
    final hours = double.tryParse(_max.text.trim().replaceAll(',', '.'));
    return hours == null || hours <= 0 || hours > 744;
  }

  Future<void> _save() async {
    final roster = ref.services.roster;
    final member = widget.member;
    if (member == null) {
      await roster.addMember(
        _trimmed,
        core: _core,
        isMe: _isMe,
        maxMonthMinutes: _maxMinutes,
      );
    } else {
      await roster.saveMember(
        member.copyWith(
          name: _trimmed,
          core: _core,
          isMe: _isMe,
          maxMonthMinutes: Value(_maxMinutes),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// Deletes the person; asks first if they have answers or shifts,
  /// because those go too.
  Future<void> _delete() async {
    final l10n = context.l10n;
    final member = widget.member!;
    final roster = ref.services.roster;
    if (await roster.hasEntries(member.id)) {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.teamDeleteTitle(member.name)),
          content: Text(l10n.teamDeleteBody),
          actions: [
            M3EButton(
              style: M3EButtonStyle.text,
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            M3EButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await roster.deleteMember(member.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final member = widget.member;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.teamName,
              helperText: _duplicate ? l10n.teamDuplicateName : null,
              helperStyle: TextStyle(color: context.colors.error),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _max,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.teamMaxHours,
              helperText: l10n.teamMaxHoursHelp,
              helperMaxLines: 2,
              suffixText: 'h',
              errorText: _maxInvalid ? l10n.teamMaxHoursInvalid : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          SwitchListTile(
            title: Text(l10n.teamCore),
            subtitle: Text(l10n.teamCoreHint),
            value: _core,
            onChanged: (v) => setState(() => _core = v),
          ),
          SwitchListTile(
            title: Text(l10n.teamIsMe),
            value: _isMe,
            onChanged: (v) => setState(() => _isMe = v),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              if (member != null)
                M3EButton(
                  onPressed: _delete,
                  style: M3EButtonStyle.text,
                  label: Text(l10n.delete),
                ),
              M3EButton(
                onPressed: _trimmed.isEmpty || _maxInvalid ? null : _save,
                label: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
