// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notifIdMeta = const VerificationMeta(
    'notifId',
  );
  @override
  late final GeneratedColumn<int> notifId = GeneratedColumn<int>(
    'notif_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ShiftType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ShiftType>($ShiftsTable.$convertertype);
  static const VerificationMeta _plannedStartMeta = const VerificationMeta(
    'plannedStart',
  );
  @override
  late final GeneratedColumn<DateTime> plannedStart = GeneratedColumn<DateTime>(
    'planned_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedEndMeta = const VerificationMeta(
    'plannedEnd',
  );
  @override
  late final GeneratedColumn<DateTime> plannedEnd = GeneratedColumn<DateTime>(
    'planned_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedCustomizedMeta = const VerificationMeta(
    'plannedCustomized',
  );
  @override
  late final GeneratedColumn<bool> plannedCustomized = GeneratedColumn<bool>(
    'planned_customized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("planned_customized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rawStartMeta = const VerificationMeta(
    'rawStart',
  );
  @override
  late final GeneratedColumn<DateTime> rawStart = GeneratedColumn<DateTime>(
    'raw_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawEndMeta = const VerificationMeta('rawEnd');
  @override
  late final GeneratedColumn<DateTime> rawEnd = GeneratedColumn<DateTime>(
    'raw_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualStartMeta = const VerificationMeta(
    'actualStart',
  );
  @override
  late final GeneratedColumn<DateTime> actualStart = GeneratedColumn<DateTime>(
    'actual_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualEndMeta = const VerificationMeta(
    'actualEnd',
  );
  @override
  late final GeneratedColumn<DateTime> actualEnd = GeneratedColumn<DateTime>(
    'actual_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakMinutesMeta = const VerificationMeta(
    'breakMinutes',
  );
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
    'break_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _calendarEventIdMeta = const VerificationMeta(
    'calendarEventId',
  );
  @override
  late final GeneratedColumn<String> calendarEventId = GeneratedColumn<String>(
    'calendar_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calendarIdMeta = const VerificationMeta(
    'calendarId',
  );
  @override
  late final GeneratedColumn<String> calendarId = GeneratedColumn<String>(
    'calendar_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, int> syncState =
      GeneratedColumn<int>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.dirty.index),
      ).withConverter<SyncState>($ShiftsTable.$convertersyncState);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    notifId,
    day,
    type,
    plannedStart,
    plannedEnd,
    plannedCustomized,
    rawStart,
    rawEnd,
    actualStart,
    actualEnd,
    breakMinutes,
    calendarEventId,
    calendarId,
    syncState,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shift> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('notif_id')) {
      context.handle(
        _notifIdMeta,
        notifId.isAcceptableOrUnknown(data['notif_id']!, _notifIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notifIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('planned_start')) {
      context.handle(
        _plannedStartMeta,
        plannedStart.isAcceptableOrUnknown(
          data['planned_start']!,
          _plannedStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedStartMeta);
    }
    if (data.containsKey('planned_end')) {
      context.handle(
        _plannedEndMeta,
        plannedEnd.isAcceptableOrUnknown(data['planned_end']!, _plannedEndMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedEndMeta);
    }
    if (data.containsKey('planned_customized')) {
      context.handle(
        _plannedCustomizedMeta,
        plannedCustomized.isAcceptableOrUnknown(
          data['planned_customized']!,
          _plannedCustomizedMeta,
        ),
      );
    }
    if (data.containsKey('raw_start')) {
      context.handle(
        _rawStartMeta,
        rawStart.isAcceptableOrUnknown(data['raw_start']!, _rawStartMeta),
      );
    }
    if (data.containsKey('raw_end')) {
      context.handle(
        _rawEndMeta,
        rawEnd.isAcceptableOrUnknown(data['raw_end']!, _rawEndMeta),
      );
    }
    if (data.containsKey('actual_start')) {
      context.handle(
        _actualStartMeta,
        actualStart.isAcceptableOrUnknown(
          data['actual_start']!,
          _actualStartMeta,
        ),
      );
    }
    if (data.containsKey('actual_end')) {
      context.handle(
        _actualEndMeta,
        actualEnd.isAcceptableOrUnknown(data['actual_end']!, _actualEndMeta),
      );
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
        _breakMinutesMeta,
        breakMinutes.isAcceptableOrUnknown(
          data['break_minutes']!,
          _breakMinutesMeta,
        ),
      );
    }
    if (data.containsKey('calendar_event_id')) {
      context.handle(
        _calendarEventIdMeta,
        calendarEventId.isAcceptableOrUnknown(
          data['calendar_event_id']!,
          _calendarEventIdMeta,
        ),
      );
    }
    if (data.containsKey('calendar_id')) {
      context.handle(
        _calendarIdMeta,
        calendarId.isAcceptableOrUnknown(data['calendar_id']!, _calendarIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      notifId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notif_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      type: $ShiftsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      plannedStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_start'],
      )!,
      plannedEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_end'],
      )!,
      plannedCustomized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}planned_customized'],
      )!,
      rawStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}raw_start'],
      ),
      rawEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}raw_end'],
      ),
      actualStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_start'],
      ),
      actualEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_end'],
      ),
      breakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_minutes'],
      )!,
      calendarEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_event_id'],
      ),
      calendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_id'],
      ),
      syncState: $ShiftsTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ShiftType, int, int> $convertertype =
      const EnumIndexConverter<ShiftType>(ShiftType.values);
  static JsonTypeConverter2<SyncState, int, int> $convertersyncState =
      const EnumIndexConverter<SyncState>(SyncState.values);
}

class Shift extends DataClass implements Insertable<Shift> {
  /// UUID, so backups can be merged later without id clashes.
  final String id;

  /// Small number for notification ids (Android needs ints). Device-only.
  final int notifId;

  /// Local date the shift belongs to, `yyyy-MM-dd`.
  final String day;
  final ShiftType type;
  final DateTime plannedStart;
  final DateTime plannedEnd;

  /// Set once planned times were edited by hand: no more automatic changes.
  final bool plannedCustomized;

  /// Exact Start/Stop taps. Started but not stopped = recording is running.
  final DateTime? rawStart;
  final DateTime? rawEnd;

  /// Rounded or hand-entered times. These are what counts.
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final int breakMinutes;

  /// Calendar event this shift is mirrored to. Device-only.
  final String? calendarEventId;
  final String? calendarId;
  final SyncState syncState;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Shift({
    required this.id,
    required this.notifId,
    required this.day,
    required this.type,
    required this.plannedStart,
    required this.plannedEnd,
    required this.plannedCustomized,
    this.rawStart,
    this.rawEnd,
    this.actualStart,
    this.actualEnd,
    required this.breakMinutes,
    this.calendarEventId,
    this.calendarId,
    required this.syncState,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['notif_id'] = Variable<int>(notifId);
    map['day'] = Variable<String>(day);
    {
      map['type'] = Variable<int>($ShiftsTable.$convertertype.toSql(type));
    }
    map['planned_start'] = Variable<DateTime>(plannedStart);
    map['planned_end'] = Variable<DateTime>(plannedEnd);
    map['planned_customized'] = Variable<bool>(plannedCustomized);
    if (!nullToAbsent || rawStart != null) {
      map['raw_start'] = Variable<DateTime>(rawStart);
    }
    if (!nullToAbsent || rawEnd != null) {
      map['raw_end'] = Variable<DateTime>(rawEnd);
    }
    if (!nullToAbsent || actualStart != null) {
      map['actual_start'] = Variable<DateTime>(actualStart);
    }
    if (!nullToAbsent || actualEnd != null) {
      map['actual_end'] = Variable<DateTime>(actualEnd);
    }
    map['break_minutes'] = Variable<int>(breakMinutes);
    if (!nullToAbsent || calendarEventId != null) {
      map['calendar_event_id'] = Variable<String>(calendarEventId);
    }
    if (!nullToAbsent || calendarId != null) {
      map['calendar_id'] = Variable<String>(calendarId);
    }
    {
      map['sync_state'] = Variable<int>(
        $ShiftsTable.$convertersyncState.toSql(syncState),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      notifId: Value(notifId),
      day: Value(day),
      type: Value(type),
      plannedStart: Value(plannedStart),
      plannedEnd: Value(plannedEnd),
      plannedCustomized: Value(plannedCustomized),
      rawStart: rawStart == null && nullToAbsent
          ? const Value.absent()
          : Value(rawStart),
      rawEnd: rawEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(rawEnd),
      actualStart: actualStart == null && nullToAbsent
          ? const Value.absent()
          : Value(actualStart),
      actualEnd: actualEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(actualEnd),
      breakMinutes: Value(breakMinutes),
      calendarEventId: calendarEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarEventId),
      calendarId: calendarId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarId),
      syncState: Value(syncState),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Shift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<String>(json['id']),
      notifId: serializer.fromJson<int>(json['notifId']),
      day: serializer.fromJson<String>(json['day']),
      type: $ShiftsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      plannedStart: serializer.fromJson<DateTime>(json['plannedStart']),
      plannedEnd: serializer.fromJson<DateTime>(json['plannedEnd']),
      plannedCustomized: serializer.fromJson<bool>(json['plannedCustomized']),
      rawStart: serializer.fromJson<DateTime?>(json['rawStart']),
      rawEnd: serializer.fromJson<DateTime?>(json['rawEnd']),
      actualStart: serializer.fromJson<DateTime?>(json['actualStart']),
      actualEnd: serializer.fromJson<DateTime?>(json['actualEnd']),
      breakMinutes: serializer.fromJson<int>(json['breakMinutes']),
      calendarEventId: serializer.fromJson<String?>(json['calendarEventId']),
      calendarId: serializer.fromJson<String?>(json['calendarId']),
      syncState: $ShiftsTable.$convertersyncState.fromJson(
        serializer.fromJson<int>(json['syncState']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'notifId': serializer.toJson<int>(notifId),
      'day': serializer.toJson<String>(day),
      'type': serializer.toJson<int>($ShiftsTable.$convertertype.toJson(type)),
      'plannedStart': serializer.toJson<DateTime>(plannedStart),
      'plannedEnd': serializer.toJson<DateTime>(plannedEnd),
      'plannedCustomized': serializer.toJson<bool>(plannedCustomized),
      'rawStart': serializer.toJson<DateTime?>(rawStart),
      'rawEnd': serializer.toJson<DateTime?>(rawEnd),
      'actualStart': serializer.toJson<DateTime?>(actualStart),
      'actualEnd': serializer.toJson<DateTime?>(actualEnd),
      'breakMinutes': serializer.toJson<int>(breakMinutes),
      'calendarEventId': serializer.toJson<String?>(calendarEventId),
      'calendarId': serializer.toJson<String?>(calendarId),
      'syncState': serializer.toJson<int>(
        $ShiftsTable.$convertersyncState.toJson(syncState),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Shift copyWith({
    String? id,
    int? notifId,
    String? day,
    ShiftType? type,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    bool? plannedCustomized,
    Value<DateTime?> rawStart = const Value.absent(),
    Value<DateTime?> rawEnd = const Value.absent(),
    Value<DateTime?> actualStart = const Value.absent(),
    Value<DateTime?> actualEnd = const Value.absent(),
    int? breakMinutes,
    Value<String?> calendarEventId = const Value.absent(),
    Value<String?> calendarId = const Value.absent(),
    SyncState? syncState,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Shift(
    id: id ?? this.id,
    notifId: notifId ?? this.notifId,
    day: day ?? this.day,
    type: type ?? this.type,
    plannedStart: plannedStart ?? this.plannedStart,
    plannedEnd: plannedEnd ?? this.plannedEnd,
    plannedCustomized: plannedCustomized ?? this.plannedCustomized,
    rawStart: rawStart.present ? rawStart.value : this.rawStart,
    rawEnd: rawEnd.present ? rawEnd.value : this.rawEnd,
    actualStart: actualStart.present ? actualStart.value : this.actualStart,
    actualEnd: actualEnd.present ? actualEnd.value : this.actualEnd,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    calendarEventId: calendarEventId.present
        ? calendarEventId.value
        : this.calendarEventId,
    calendarId: calendarId.present ? calendarId.value : this.calendarId,
    syncState: syncState ?? this.syncState,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      notifId: data.notifId.present ? data.notifId.value : this.notifId,
      day: data.day.present ? data.day.value : this.day,
      type: data.type.present ? data.type.value : this.type,
      plannedStart: data.plannedStart.present
          ? data.plannedStart.value
          : this.plannedStart,
      plannedEnd: data.plannedEnd.present
          ? data.plannedEnd.value
          : this.plannedEnd,
      plannedCustomized: data.plannedCustomized.present
          ? data.plannedCustomized.value
          : this.plannedCustomized,
      rawStart: data.rawStart.present ? data.rawStart.value : this.rawStart,
      rawEnd: data.rawEnd.present ? data.rawEnd.value : this.rawEnd,
      actualStart: data.actualStart.present
          ? data.actualStart.value
          : this.actualStart,
      actualEnd: data.actualEnd.present ? data.actualEnd.value : this.actualEnd,
      breakMinutes: data.breakMinutes.present
          ? data.breakMinutes.value
          : this.breakMinutes,
      calendarEventId: data.calendarEventId.present
          ? data.calendarEventId.value
          : this.calendarEventId,
      calendarId: data.calendarId.present
          ? data.calendarId.value
          : this.calendarId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('notifId: $notifId, ')
          ..write('day: $day, ')
          ..write('type: $type, ')
          ..write('plannedStart: $plannedStart, ')
          ..write('plannedEnd: $plannedEnd, ')
          ..write('plannedCustomized: $plannedCustomized, ')
          ..write('rawStart: $rawStart, ')
          ..write('rawEnd: $rawEnd, ')
          ..write('actualStart: $actualStart, ')
          ..write('actualEnd: $actualEnd, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('calendarId: $calendarId, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    notifId,
    day,
    type,
    plannedStart,
    plannedEnd,
    plannedCustomized,
    rawStart,
    rawEnd,
    actualStart,
    actualEnd,
    breakMinutes,
    calendarEventId,
    calendarId,
    syncState,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.notifId == this.notifId &&
          other.day == this.day &&
          other.type == this.type &&
          other.plannedStart == this.plannedStart &&
          other.plannedEnd == this.plannedEnd &&
          other.plannedCustomized == this.plannedCustomized &&
          other.rawStart == this.rawStart &&
          other.rawEnd == this.rawEnd &&
          other.actualStart == this.actualStart &&
          other.actualEnd == this.actualEnd &&
          other.breakMinutes == this.breakMinutes &&
          other.calendarEventId == this.calendarEventId &&
          other.calendarId == this.calendarId &&
          other.syncState == this.syncState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<String> id;
  final Value<int> notifId;
  final Value<String> day;
  final Value<ShiftType> type;
  final Value<DateTime> plannedStart;
  final Value<DateTime> plannedEnd;
  final Value<bool> plannedCustomized;
  final Value<DateTime?> rawStart;
  final Value<DateTime?> rawEnd;
  final Value<DateTime?> actualStart;
  final Value<DateTime?> actualEnd;
  final Value<int> breakMinutes;
  final Value<String?> calendarEventId;
  final Value<String?> calendarId;
  final Value<SyncState> syncState;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.notifId = const Value.absent(),
    this.day = const Value.absent(),
    this.type = const Value.absent(),
    this.plannedStart = const Value.absent(),
    this.plannedEnd = const Value.absent(),
    this.plannedCustomized = const Value.absent(),
    this.rawStart = const Value.absent(),
    this.rawEnd = const Value.absent(),
    this.actualStart = const Value.absent(),
    this.actualEnd = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.calendarId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required int notifId,
    required String day,
    required ShiftType type,
    required DateTime plannedStart,
    required DateTime plannedEnd,
    this.plannedCustomized = const Value.absent(),
    this.rawStart = const Value.absent(),
    this.rawEnd = const Value.absent(),
    this.actualStart = const Value.absent(),
    this.actualEnd = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.calendarId = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       notifId = Value(notifId),
       day = Value(day),
       type = Value(type),
       plannedStart = Value(plannedStart),
       plannedEnd = Value(plannedEnd),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Shift> custom({
    Expression<String>? id,
    Expression<int>? notifId,
    Expression<String>? day,
    Expression<int>? type,
    Expression<DateTime>? plannedStart,
    Expression<DateTime>? plannedEnd,
    Expression<bool>? plannedCustomized,
    Expression<DateTime>? rawStart,
    Expression<DateTime>? rawEnd,
    Expression<DateTime>? actualStart,
    Expression<DateTime>? actualEnd,
    Expression<int>? breakMinutes,
    Expression<String>? calendarEventId,
    Expression<String>? calendarId,
    Expression<int>? syncState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notifId != null) 'notif_id': notifId,
      if (day != null) 'day': day,
      if (type != null) 'type': type,
      if (plannedStart != null) 'planned_start': plannedStart,
      if (plannedEnd != null) 'planned_end': plannedEnd,
      if (plannedCustomized != null) 'planned_customized': plannedCustomized,
      if (rawStart != null) 'raw_start': rawStart,
      if (rawEnd != null) 'raw_end': rawEnd,
      if (actualStart != null) 'actual_start': actualStart,
      if (actualEnd != null) 'actual_end': actualEnd,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
      if (calendarEventId != null) 'calendar_event_id': calendarEventId,
      if (calendarId != null) 'calendar_id': calendarId,
      if (syncState != null) 'sync_state': syncState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith({
    Value<String>? id,
    Value<int>? notifId,
    Value<String>? day,
    Value<ShiftType>? type,
    Value<DateTime>? plannedStart,
    Value<DateTime>? plannedEnd,
    Value<bool>? plannedCustomized,
    Value<DateTime?>? rawStart,
    Value<DateTime?>? rawEnd,
    Value<DateTime?>? actualStart,
    Value<DateTime?>? actualEnd,
    Value<int>? breakMinutes,
    Value<String?>? calendarEventId,
    Value<String?>? calendarId,
    Value<SyncState>? syncState,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      notifId: notifId ?? this.notifId,
      day: day ?? this.day,
      type: type ?? this.type,
      plannedStart: plannedStart ?? this.plannedStart,
      plannedEnd: plannedEnd ?? this.plannedEnd,
      plannedCustomized: plannedCustomized ?? this.plannedCustomized,
      rawStart: rawStart ?? this.rawStart,
      rawEnd: rawEnd ?? this.rawEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      calendarId: calendarId ?? this.calendarId,
      syncState: syncState ?? this.syncState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (notifId.present) {
      map['notif_id'] = Variable<int>(notifId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $ShiftsTable.$convertertype.toSql(type.value),
      );
    }
    if (plannedStart.present) {
      map['planned_start'] = Variable<DateTime>(plannedStart.value);
    }
    if (plannedEnd.present) {
      map['planned_end'] = Variable<DateTime>(plannedEnd.value);
    }
    if (plannedCustomized.present) {
      map['planned_customized'] = Variable<bool>(plannedCustomized.value);
    }
    if (rawStart.present) {
      map['raw_start'] = Variable<DateTime>(rawStart.value);
    }
    if (rawEnd.present) {
      map['raw_end'] = Variable<DateTime>(rawEnd.value);
    }
    if (actualStart.present) {
      map['actual_start'] = Variable<DateTime>(actualStart.value);
    }
    if (actualEnd.present) {
      map['actual_end'] = Variable<DateTime>(actualEnd.value);
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    if (calendarEventId.present) {
      map['calendar_event_id'] = Variable<String>(calendarEventId.value);
    }
    if (calendarId.present) {
      map['calendar_id'] = Variable<String>(calendarId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(
        $ShiftsTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('notifId: $notifId, ')
          ..write('day: $day, ')
          ..write('type: $type, ')
          ..write('plannedStart: $plannedStart, ')
          ..write('plannedEnd: $plannedEnd, ')
          ..write('plannedCustomized: $plannedCustomized, ')
          ..write('rawStart: $rawStart, ')
          ..write('rawEnd: $rawEnd, ')
          ..write('actualStart: $actualStart, ')
          ..write('actualEnd: $actualEnd, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('calendarId: $calendarId, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingEntry copyWith({String? key, String? value}) =>
      SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingsCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TipDaysTable extends TipDays with TableInfo<$TipDaysTable, TipDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TipDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _poolCentsMeta = const VerificationMeta(
    'poolCents',
  );
  @override
  late final GeneratedColumn<int> poolCents = GeneratedColumn<int>(
    'pool_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    poolCents,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tip_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<TipDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('pool_cents')) {
      context.handle(
        _poolCentsMeta,
        poolCents.isAcceptableOrUnknown(data['pool_cents']!, _poolCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_poolCentsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TipDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TipDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      poolCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pool_cents'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TipDaysTable createAlias(String alias) {
    return $TipDaysTable(attachedDatabase, alias);
  }
}

class TipDay extends DataClass implements Insertable<TipDay> {
  /// UUID, so backups can be merged later.
  final String id;

  /// The workday, `yyyy-MM-dd`.
  final String day;
  final int poolCents;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TipDay({
    required this.id,
    required this.day,
    required this.poolCents,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['pool_cents'] = Variable<int>(poolCents);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TipDaysCompanion toCompanion(bool nullToAbsent) {
    return TipDaysCompanion(
      id: Value(id),
      day: Value(day),
      poolCents: Value(poolCents),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TipDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TipDay(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      poolCents: serializer.fromJson<int>(json['poolCents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'poolCents': serializer.toJson<int>(poolCents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TipDay copyWith({
    String? id,
    String? day,
    int? poolCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TipDay(
    id: id ?? this.id,
    day: day ?? this.day,
    poolCents: poolCents ?? this.poolCents,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TipDay copyWithCompanion(TipDaysCompanion data) {
    return TipDay(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      poolCents: data.poolCents.present ? data.poolCents.value : this.poolCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TipDay(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('poolCents: $poolCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, poolCents, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TipDay &&
          other.id == this.id &&
          other.day == this.day &&
          other.poolCents == this.poolCents &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TipDaysCompanion extends UpdateCompanion<TipDay> {
  final Value<String> id;
  final Value<String> day;
  final Value<int> poolCents;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TipDaysCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.poolCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TipDaysCompanion.insert({
    required String id,
    required String day,
    required int poolCents,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       poolCents = Value(poolCents),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TipDay> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<int>? poolCents,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (poolCents != null) 'pool_cents': poolCents,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TipDaysCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<int>? poolCents,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TipDaysCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      poolCents: poolCents ?? this.poolCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (poolCents.present) {
      map['pool_cents'] = Variable<int>(poolCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipDaysCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('poolCents: $poolCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TipPayoutsTable extends TipPayouts
    with TableInfo<$TipPayoutsTable, TipPayout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TipPayoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekStart,
    amountCents,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tip_payouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<TipPayout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TipPayout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TipPayout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TipPayoutsTable createAlias(String alias) {
    return $TipPayoutsTable(attachedDatabase, alias);
  }
}

class TipPayout extends DataClass implements Insertable<TipPayout> {
  /// UUID, so backups can be merged later.
  final String id;

  /// The week's Monday, `yyyy-MM-dd`.
  final String weekStart;
  final int amountCents;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TipPayout({
    required this.id,
    required this.weekStart,
    required this.amountCents,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['week_start'] = Variable<String>(weekStart);
    map['amount_cents'] = Variable<int>(amountCents);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TipPayoutsCompanion toCompanion(bool nullToAbsent) {
    return TipPayoutsCompanion(
      id: Value(id),
      weekStart: Value(weekStart),
      amountCents: Value(amountCents),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TipPayout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TipPayout(
      id: serializer.fromJson<String>(json['id']),
      weekStart: serializer.fromJson<String>(json['weekStart']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'weekStart': serializer.toJson<String>(weekStart),
      'amountCents': serializer.toJson<int>(amountCents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TipPayout copyWith({
    String? id,
    String? weekStart,
    int? amountCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TipPayout(
    id: id ?? this.id,
    weekStart: weekStart ?? this.weekStart,
    amountCents: amountCents ?? this.amountCents,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TipPayout copyWithCompanion(TipPayoutsCompanion data) {
    return TipPayout(
      id: data.id.present ? data.id.value : this.id,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TipPayout(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('amountCents: $amountCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, weekStart, amountCents, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TipPayout &&
          other.id == this.id &&
          other.weekStart == this.weekStart &&
          other.amountCents == this.amountCents &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TipPayoutsCompanion extends UpdateCompanion<TipPayout> {
  final Value<String> id;
  final Value<String> weekStart;
  final Value<int> amountCents;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TipPayoutsCompanion({
    this.id = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TipPayoutsCompanion.insert({
    required String id,
    required String weekStart,
    required int amountCents,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       weekStart = Value(weekStart),
       amountCents = Value(amountCents),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TipPayout> custom({
    Expression<String>? id,
    Expression<String>? weekStart,
    Expression<int>? amountCents,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStart != null) 'week_start': weekStart,
      if (amountCents != null) 'amount_cents': amountCents,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TipPayoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? weekStart,
    Value<int>? amountCents,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TipPayoutsCompanion(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      amountCents: amountCents ?? this.amountCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipPayoutsCompanion(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('amountCents: $amountCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WageRatesTable extends WageRates
    with TableInfo<$WageRatesTable, WageRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WageRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validFromMeta = const VerificationMeta(
    'validFrom',
  );
  @override
  late final GeneratedColumn<String> validFrom = GeneratedColumn<String>(
    'valid_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _hourlyCentsMeta = const VerificationMeta(
    'hourlyCents',
  );
  @override
  late final GeneratedColumn<int> hourlyCents = GeneratedColumn<int>(
    'hourly_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    validFrom,
    hourlyCents,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wage_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<WageRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('valid_from')) {
      context.handle(
        _validFromMeta,
        validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta),
      );
    } else if (isInserting) {
      context.missing(_validFromMeta);
    }
    if (data.containsKey('hourly_cents')) {
      context.handle(
        _hourlyCentsMeta,
        hourlyCents.isAcceptableOrUnknown(
          data['hourly_cents']!,
          _hourlyCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hourlyCentsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WageRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WageRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      validFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_from'],
      )!,
      hourlyCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hourly_cents'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WageRatesTable createAlias(String alias) {
    return $WageRatesTable(attachedDatabase, alias);
  }
}

class WageRate extends DataClass implements Insertable<WageRate> {
  /// UUID, so backups can be merged later.
  final String id;

  /// The first day this rate applies to, `yyyy-MM-dd`.
  final String validFrom;
  final int hourlyCents;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WageRate({
    required this.id,
    required this.validFrom,
    required this.hourlyCents,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['valid_from'] = Variable<String>(validFrom);
    map['hourly_cents'] = Variable<int>(hourlyCents);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WageRatesCompanion toCompanion(bool nullToAbsent) {
    return WageRatesCompanion(
      id: Value(id),
      validFrom: Value(validFrom),
      hourlyCents: Value(hourlyCents),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WageRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WageRate(
      id: serializer.fromJson<String>(json['id']),
      validFrom: serializer.fromJson<String>(json['validFrom']),
      hourlyCents: serializer.fromJson<int>(json['hourlyCents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'validFrom': serializer.toJson<String>(validFrom),
      'hourlyCents': serializer.toJson<int>(hourlyCents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WageRate copyWith({
    String? id,
    String? validFrom,
    int? hourlyCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WageRate(
    id: id ?? this.id,
    validFrom: validFrom ?? this.validFrom,
    hourlyCents: hourlyCents ?? this.hourlyCents,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WageRate copyWithCompanion(WageRatesCompanion data) {
    return WageRate(
      id: data.id.present ? data.id.value : this.id,
      validFrom: data.validFrom.present ? data.validFrom.value : this.validFrom,
      hourlyCents: data.hourlyCents.present
          ? data.hourlyCents.value
          : this.hourlyCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WageRate(')
          ..write('id: $id, ')
          ..write('validFrom: $validFrom, ')
          ..write('hourlyCents: $hourlyCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, validFrom, hourlyCents, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WageRate &&
          other.id == this.id &&
          other.validFrom == this.validFrom &&
          other.hourlyCents == this.hourlyCents &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WageRatesCompanion extends UpdateCompanion<WageRate> {
  final Value<String> id;
  final Value<String> validFrom;
  final Value<int> hourlyCents;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WageRatesCompanion({
    this.id = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.hourlyCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WageRatesCompanion.insert({
    required String id,
    required String validFrom,
    required int hourlyCents,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       validFrom = Value(validFrom),
       hourlyCents = Value(hourlyCents),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WageRate> custom({
    Expression<String>? id,
    Expression<String>? validFrom,
    Expression<int>? hourlyCents,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (validFrom != null) 'valid_from': validFrom,
      if (hourlyCents != null) 'hourly_cents': hourlyCents,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WageRatesCompanion copyWith({
    Value<String>? id,
    Value<String>? validFrom,
    Value<int>? hourlyCents,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WageRatesCompanion(
      id: id ?? this.id,
      validFrom: validFrom ?? this.validFrom,
      hourlyCents: hourlyCents ?? this.hourlyCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<String>(validFrom.value);
    }
    if (hourlyCents.present) {
      map['hourly_cents'] = Variable<int>(hourlyCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WageRatesCompanion(')
          ..write('id: $id, ')
          ..write('validFrom: $validFrom, ')
          ..write('hourlyCents: $hourlyCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamMembersTable extends TeamMembers
    with TableInfo<$TeamMembersTable, TeamMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coreMeta = const VerificationMeta('core');
  @override
  late final GeneratedColumn<bool> core = GeneratedColumn<bool>(
    'core',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("core" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isMeMeta = const VerificationMeta('isMe');
  @override
  late final GeneratedColumn<bool> isMe = GeneratedColumn<bool>(
    'is_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    core,
    isMe,
    active,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('core')) {
      context.handle(
        _coreMeta,
        core.isAcceptableOrUnknown(data['core']!, _coreMeta),
      );
    }
    if (data.containsKey('is_me')) {
      context.handle(
        _isMeMeta,
        isMe.isAcceptableOrUnknown(data['is_me']!, _isMeMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      core: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}core'],
      )!,
      isMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_me'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TeamMembersTable createAlias(String alias) {
    return $TeamMembersTable(attachedDatabase, alias);
  }
}

class TeamMember extends DataClass implements Insertable<TeamMember> {
  /// UUID, so backups can be merged later.
  final String id;
  final String name;

  /// Core worker: experienced; each shift should have one.
  final bool core;

  /// This person is the user. At most one row.
  final bool isMe;

  /// Inactive people are left out of new weeks but stay in old plans.
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TeamMember({
    required this.id,
    required this.name,
    required this.core,
    required this.isMe,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['core'] = Variable<bool>(core);
    map['is_me'] = Variable<bool>(isMe);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TeamMembersCompanion toCompanion(bool nullToAbsent) {
    return TeamMembersCompanion(
      id: Value(id),
      name: Value(name),
      core: Value(core),
      isMe: Value(isMe),
      active: Value(active),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TeamMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamMember(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      core: serializer.fromJson<bool>(json['core']),
      isMe: serializer.fromJson<bool>(json['isMe']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'core': serializer.toJson<bool>(core),
      'isMe': serializer.toJson<bool>(isMe),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TeamMember copyWith({
    String? id,
    String? name,
    bool? core,
    bool? isMe,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TeamMember(
    id: id ?? this.id,
    name: name ?? this.name,
    core: core ?? this.core,
    isMe: isMe ?? this.isMe,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TeamMember copyWithCompanion(TeamMembersCompanion data) {
    return TeamMember(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      core: data.core.present ? data.core.value : this.core,
      isMe: data.isMe.present ? data.isMe.value : this.isMe,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamMember(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('core: $core, ')
          ..write('isMe: $isMe, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, core, isMe, active, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamMember &&
          other.id == this.id &&
          other.name == this.name &&
          other.core == this.core &&
          other.isMe == this.isMe &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TeamMembersCompanion extends UpdateCompanion<TeamMember> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> core;
  final Value<bool> isMe;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TeamMembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.core = const Value.absent(),
    this.isMe = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamMembersCompanion.insert({
    required String id,
    required String name,
    this.core = const Value.absent(),
    this.isMe = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TeamMember> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? core,
    Expression<bool>? isMe,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (core != null) 'core': core,
      if (isMe != null) 'is_me': isMe,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? core,
    Value<bool>? isMe,
    Value<bool>? active,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TeamMembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      core: core ?? this.core,
      isMe: isMe ?? this.isMe,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (core.present) {
      map['core'] = Variable<bool>(core.value);
    }
    if (isMe.present) {
      map['is_me'] = Variable<bool>(isMe.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamMembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('core: $core, ')
          ..write('isMe: $isMe, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamAnswersTable extends TeamAnswers
    with TableInfo<$TeamAnswersTable, TeamAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AnswerMode, int> mode =
      GeneratedColumn<int>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<AnswerMode>($TeamAnswersTable.$convertermode);
  static const VerificationMeta _marksMeta = const VerificationMeta('marks');
  @override
  late final GeneratedColumn<int> marks = GeneratedColumn<int>(
    'marks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxShiftsMeta = const VerificationMeta(
    'maxShifts',
  );
  @override
  late final GeneratedColumn<int> maxShifts = GeneratedColumn<int>(
    'max_shifts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekStart,
    memberId,
    mode,
    marks,
    maxShifts,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('marks')) {
      context.handle(
        _marksMeta,
        marks.isAcceptableOrUnknown(data['marks']!, _marksMeta),
      );
    }
    if (data.containsKey('max_shifts')) {
      context.handle(
        _maxShiftsMeta,
        maxShifts.isAcceptableOrUnknown(data['max_shifts']!, _maxShiftsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {weekStart, memberId},
  ];
  @override
  TeamAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      mode: $TeamAnswersTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}mode'],
        )!,
      ),
      marks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}marks'],
      )!,
      maxShifts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_shifts'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TeamAnswersTable createAlias(String alias) {
    return $TeamAnswersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AnswerMode, int, int> $convertermode =
      const EnumIndexConverter<AnswerMode>(AnswerMode.values);
}

class TeamAnswer extends DataClass implements Insertable<TeamAnswer> {
  final String id;

  /// The week's Monday, `yyyy-MM-dd`.
  final String weekStart;
  final String memberId;
  final AnswerMode mode;

  /// Bit `(weekday - 1) * 2 + shift` for each marked shift.
  final int marks;

  /// "At most N shifts"; null = no limit.
  final int? maxShifts;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TeamAnswer({
    required this.id,
    required this.weekStart,
    required this.memberId,
    required this.mode,
    required this.marks,
    this.maxShifts,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['week_start'] = Variable<String>(weekStart);
    map['member_id'] = Variable<String>(memberId);
    {
      map['mode'] = Variable<int>($TeamAnswersTable.$convertermode.toSql(mode));
    }
    map['marks'] = Variable<int>(marks);
    if (!nullToAbsent || maxShifts != null) {
      map['max_shifts'] = Variable<int>(maxShifts);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TeamAnswersCompanion toCompanion(bool nullToAbsent) {
    return TeamAnswersCompanion(
      id: Value(id),
      weekStart: Value(weekStart),
      memberId: Value(memberId),
      mode: Value(mode),
      marks: Value(marks),
      maxShifts: maxShifts == null && nullToAbsent
          ? const Value.absent()
          : Value(maxShifts),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TeamAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamAnswer(
      id: serializer.fromJson<String>(json['id']),
      weekStart: serializer.fromJson<String>(json['weekStart']),
      memberId: serializer.fromJson<String>(json['memberId']),
      mode: $TeamAnswersTable.$convertermode.fromJson(
        serializer.fromJson<int>(json['mode']),
      ),
      marks: serializer.fromJson<int>(json['marks']),
      maxShifts: serializer.fromJson<int?>(json['maxShifts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'weekStart': serializer.toJson<String>(weekStart),
      'memberId': serializer.toJson<String>(memberId),
      'mode': serializer.toJson<int>(
        $TeamAnswersTable.$convertermode.toJson(mode),
      ),
      'marks': serializer.toJson<int>(marks),
      'maxShifts': serializer.toJson<int?>(maxShifts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TeamAnswer copyWith({
    String? id,
    String? weekStart,
    String? memberId,
    AnswerMode? mode,
    int? marks,
    Value<int?> maxShifts = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TeamAnswer(
    id: id ?? this.id,
    weekStart: weekStart ?? this.weekStart,
    memberId: memberId ?? this.memberId,
    mode: mode ?? this.mode,
    marks: marks ?? this.marks,
    maxShifts: maxShifts.present ? maxShifts.value : this.maxShifts,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TeamAnswer copyWithCompanion(TeamAnswersCompanion data) {
    return TeamAnswer(
      id: data.id.present ? data.id.value : this.id,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      mode: data.mode.present ? data.mode.value : this.mode,
      marks: data.marks.present ? data.marks.value : this.marks,
      maxShifts: data.maxShifts.present ? data.maxShifts.value : this.maxShifts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamAnswer(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('memberId: $memberId, ')
          ..write('mode: $mode, ')
          ..write('marks: $marks, ')
          ..write('maxShifts: $maxShifts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weekStart,
    memberId,
    mode,
    marks,
    maxShifts,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamAnswer &&
          other.id == this.id &&
          other.weekStart == this.weekStart &&
          other.memberId == this.memberId &&
          other.mode == this.mode &&
          other.marks == this.marks &&
          other.maxShifts == this.maxShifts &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TeamAnswersCompanion extends UpdateCompanion<TeamAnswer> {
  final Value<String> id;
  final Value<String> weekStart;
  final Value<String> memberId;
  final Value<AnswerMode> mode;
  final Value<int> marks;
  final Value<int?> maxShifts;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TeamAnswersCompanion({
    this.id = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.memberId = const Value.absent(),
    this.mode = const Value.absent(),
    this.marks = const Value.absent(),
    this.maxShifts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamAnswersCompanion.insert({
    required String id,
    required String weekStart,
    required String memberId,
    required AnswerMode mode,
    this.marks = const Value.absent(),
    this.maxShifts = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       weekStart = Value(weekStart),
       memberId = Value(memberId),
       mode = Value(mode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TeamAnswer> custom({
    Expression<String>? id,
    Expression<String>? weekStart,
    Expression<String>? memberId,
    Expression<int>? mode,
    Expression<int>? marks,
    Expression<int>? maxShifts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStart != null) 'week_start': weekStart,
      if (memberId != null) 'member_id': memberId,
      if (mode != null) 'mode': mode,
      if (marks != null) 'marks': marks,
      if (maxShifts != null) 'max_shifts': maxShifts,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamAnswersCompanion copyWith({
    Value<String>? id,
    Value<String>? weekStart,
    Value<String>? memberId,
    Value<AnswerMode>? mode,
    Value<int>? marks,
    Value<int?>? maxShifts,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TeamAnswersCompanion(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      memberId: memberId ?? this.memberId,
      mode: mode ?? this.mode,
      marks: marks ?? this.marks,
      maxShifts: maxShifts ?? this.maxShifts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<int>(
        $TeamAnswersTable.$convertermode.toSql(mode.value),
      );
    }
    if (marks.present) {
      map['marks'] = Variable<int>(marks.value);
    }
    if (maxShifts.present) {
      map['max_shifts'] = Variable<int>(maxShifts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamAnswersCompanion(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('memberId: $memberId, ')
          ..write('mode: $mode, ')
          ..write('marks: $marks, ')
          ..write('maxShifts: $maxShifts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamAssignmentsTable extends TeamAssignments
    with TableInfo<$TeamAssignmentsTable, TeamAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TeamShift, int> shift =
      GeneratedColumn<int>(
        'shift',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TeamShift>($TeamAssignmentsTable.$convertershift);
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    shift,
    memberId,
    startMinutes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {day, shift, memberId},
  ];
  @override
  TeamAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamAssignment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      shift: $TeamAssignmentsTable.$convertershift.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}shift'],
        )!,
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TeamAssignmentsTable createAlias(String alias) {
    return $TeamAssignmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TeamShift, int, int> $convertershift =
      const EnumIndexConverter<TeamShift>(TeamShift.values);
}

class TeamAssignment extends DataClass implements Insertable<TeamAssignment> {
  final String id;

  /// `yyyy-MM-dd`
  final String day;
  final TeamShift shift;
  final String memberId;

  /// Special start, minutes after midnight; null = the shift's normal start.
  final int? startMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TeamAssignment({
    required this.id,
    required this.day,
    required this.shift,
    required this.memberId,
    this.startMinutes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    {
      map['shift'] = Variable<int>(
        $TeamAssignmentsTable.$convertershift.toSql(shift),
      );
    }
    map['member_id'] = Variable<String>(memberId);
    if (!nullToAbsent || startMinutes != null) {
      map['start_minutes'] = Variable<int>(startMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TeamAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return TeamAssignmentsCompanion(
      id: Value(id),
      day: Value(day),
      shift: Value(shift),
      memberId: Value(memberId),
      startMinutes: startMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TeamAssignment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamAssignment(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      shift: $TeamAssignmentsTable.$convertershift.fromJson(
        serializer.fromJson<int>(json['shift']),
      ),
      memberId: serializer.fromJson<String>(json['memberId']),
      startMinutes: serializer.fromJson<int?>(json['startMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'shift': serializer.toJson<int>(
        $TeamAssignmentsTable.$convertershift.toJson(shift),
      ),
      'memberId': serializer.toJson<String>(memberId),
      'startMinutes': serializer.toJson<int?>(startMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TeamAssignment copyWith({
    String? id,
    String? day,
    TeamShift? shift,
    String? memberId,
    Value<int?> startMinutes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TeamAssignment(
    id: id ?? this.id,
    day: day ?? this.day,
    shift: shift ?? this.shift,
    memberId: memberId ?? this.memberId,
    startMinutes: startMinutes.present ? startMinutes.value : this.startMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TeamAssignment copyWithCompanion(TeamAssignmentsCompanion data) {
    return TeamAssignment(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      shift: data.shift.present ? data.shift.value : this.shift,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamAssignment(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('shift: $shift, ')
          ..write('memberId: $memberId, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, day, shift, memberId, startMinutes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamAssignment &&
          other.id == this.id &&
          other.day == this.day &&
          other.shift == this.shift &&
          other.memberId == this.memberId &&
          other.startMinutes == this.startMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TeamAssignmentsCompanion extends UpdateCompanion<TeamAssignment> {
  final Value<String> id;
  final Value<String> day;
  final Value<TeamShift> shift;
  final Value<String> memberId;
  final Value<int?> startMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TeamAssignmentsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.shift = const Value.absent(),
    this.memberId = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamAssignmentsCompanion.insert({
    required String id,
    required String day,
    required TeamShift shift,
    required String memberId,
    this.startMinutes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       shift = Value(shift),
       memberId = Value(memberId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TeamAssignment> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<int>? shift,
    Expression<String>? memberId,
    Expression<int>? startMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (shift != null) 'shift': shift,
      if (memberId != null) 'member_id': memberId,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamAssignmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<TeamShift>? shift,
    Value<String>? memberId,
    Value<int?>? startMinutes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TeamAssignmentsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      shift: shift ?? this.shift,
      memberId: memberId ?? this.memberId,
      startMinutes: startMinutes ?? this.startMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (shift.present) {
      map['shift'] = Variable<int>(
        $TeamAssignmentsTable.$convertershift.toSql(shift.value),
      );
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('shift: $shift, ')
          ..write('memberId: $memberId, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamNeedsTable extends TeamNeeds
    with TableInfo<$TeamNeedsTable, TeamNeed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamNeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TeamShift, int> shift =
      GeneratedColumn<int>(
        'shift',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TeamShift>($TeamNeedsTable.$convertershift);
  static const VerificationMeta _neededMeta = const VerificationMeta('needed');
  @override
  late final GeneratedColumn<int> needed = GeneratedColumn<int>(
    'needed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, day, shift, needed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_needs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamNeed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('needed')) {
      context.handle(
        _neededMeta,
        needed.isAcceptableOrUnknown(data['needed']!, _neededMeta),
      );
    } else if (isInserting) {
      context.missing(_neededMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {day, shift},
  ];
  @override
  TeamNeed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamNeed(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      shift: $TeamNeedsTable.$convertershift.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}shift'],
        )!,
      ),
      needed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}needed'],
      )!,
    );
  }

  @override
  $TeamNeedsTable createAlias(String alias) {
    return $TeamNeedsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TeamShift, int, int> $convertershift =
      const EnumIndexConverter<TeamShift>(TeamShift.values);
}

class TeamNeed extends DataClass implements Insertable<TeamNeed> {
  final String id;

  /// `yyyy-MM-dd`
  final String day;
  final TeamShift shift;
  final int needed;
  const TeamNeed({
    required this.id,
    required this.day,
    required this.shift,
    required this.needed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    {
      map['shift'] = Variable<int>(
        $TeamNeedsTable.$convertershift.toSql(shift),
      );
    }
    map['needed'] = Variable<int>(needed);
    return map;
  }

  TeamNeedsCompanion toCompanion(bool nullToAbsent) {
    return TeamNeedsCompanion(
      id: Value(id),
      day: Value(day),
      shift: Value(shift),
      needed: Value(needed),
    );
  }

  factory TeamNeed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamNeed(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      shift: $TeamNeedsTable.$convertershift.fromJson(
        serializer.fromJson<int>(json['shift']),
      ),
      needed: serializer.fromJson<int>(json['needed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'shift': serializer.toJson<int>(
        $TeamNeedsTable.$convertershift.toJson(shift),
      ),
      'needed': serializer.toJson<int>(needed),
    };
  }

  TeamNeed copyWith({String? id, String? day, TeamShift? shift, int? needed}) =>
      TeamNeed(
        id: id ?? this.id,
        day: day ?? this.day,
        shift: shift ?? this.shift,
        needed: needed ?? this.needed,
      );
  TeamNeed copyWithCompanion(TeamNeedsCompanion data) {
    return TeamNeed(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      shift: data.shift.present ? data.shift.value : this.shift,
      needed: data.needed.present ? data.needed.value : this.needed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamNeed(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('shift: $shift, ')
          ..write('needed: $needed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, shift, needed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamNeed &&
          other.id == this.id &&
          other.day == this.day &&
          other.shift == this.shift &&
          other.needed == this.needed);
}

class TeamNeedsCompanion extends UpdateCompanion<TeamNeed> {
  final Value<String> id;
  final Value<String> day;
  final Value<TeamShift> shift;
  final Value<int> needed;
  final Value<int> rowid;
  const TeamNeedsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.shift = const Value.absent(),
    this.needed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamNeedsCompanion.insert({
    required String id,
    required String day,
    required TeamShift shift,
    required int needed,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       shift = Value(shift),
       needed = Value(needed);
  static Insertable<TeamNeed> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<int>? shift,
    Expression<int>? needed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (shift != null) 'shift': shift,
      if (needed != null) 'needed': needed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamNeedsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<TeamShift>? shift,
    Value<int>? needed,
    Value<int>? rowid,
  }) {
    return TeamNeedsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      shift: shift ?? this.shift,
      needed: needed ?? this.needed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (shift.present) {
      map['shift'] = Variable<int>(
        $TeamNeedsTable.$convertershift.toSql(shift.value),
      );
    }
    if (needed.present) {
      map['needed'] = Variable<int>(needed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamNeedsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('shift: $shift, ')
          ..write('needed: $needed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $TipDaysTable tipDays = $TipDaysTable(this);
  late final $TipPayoutsTable tipPayouts = $TipPayoutsTable(this);
  late final $WageRatesTable wageRates = $WageRatesTable(this);
  late final $TeamMembersTable teamMembers = $TeamMembersTable(this);
  late final $TeamAnswersTable teamAnswers = $TeamAnswersTable(this);
  late final $TeamAssignmentsTable teamAssignments = $TeamAssignmentsTable(
    this,
  );
  late final $TeamNeedsTable teamNeeds = $TeamNeedsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shifts,
    settings,
    tipDays,
    tipPayouts,
    wageRates,
    teamMembers,
    teamAnswers,
    teamAssignments,
    teamNeeds,
  ];
}

typedef $$ShiftsTableCreateCompanionBuilder = ShiftsCompanion Function({
  required String id,
  required int notifId,
  required String day,
  required ShiftType type,
  required DateTime plannedStart,
  required DateTime plannedEnd,
  Value<bool> plannedCustomized,
  Value<DateTime?> rawStart,
  Value<DateTime?> rawEnd,
  Value<DateTime?> actualStart,
  Value<DateTime?> actualEnd,
  Value<int> breakMinutes,
  Value<String?> calendarEventId,
  Value<String?> calendarId,
  Value<SyncState> syncState,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ShiftsTableUpdateCompanionBuilder = ShiftsCompanion Function({
  Value<String> id,
  Value<int> notifId,
  Value<String> day,
  Value<ShiftType> type,
  Value<DateTime> plannedStart,
  Value<DateTime> plannedEnd,
  Value<bool> plannedCustomized,
  Value<DateTime?> rawStart,
  Value<DateTime?> rawEnd,
  Value<DateTime?> actualStart,
  Value<DateTime?> actualEnd,
  Value<int> breakMinutes,
  Value<String?> calendarEventId,
  Value<String?> calendarId,
  Value<SyncState> syncState,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifId => $composableBuilder(
    column: $table.notifId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ShiftType, ShiftType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get plannedStart => $composableBuilder(
    column: $table.plannedStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedEnd => $composableBuilder(
    column: $table.plannedEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get plannedCustomized => $composableBuilder(
    column: $table.plannedCustomized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rawStart => $composableBuilder(
    column: $table.rawStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rawEnd => $composableBuilder(
    column: $table.rawEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualStart => $composableBuilder(
    column: $table.actualStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualEnd => $composableBuilder(
    column: $table.actualEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, int> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifId => $composableBuilder(
    column: $table.notifId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedStart => $composableBuilder(
    column: $table.plannedStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedEnd => $composableBuilder(
    column: $table.plannedEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get plannedCustomized => $composableBuilder(
    column: $table.plannedCustomized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rawStart => $composableBuilder(
    column: $table.rawStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rawEnd => $composableBuilder(
    column: $table.rawEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualStart => $composableBuilder(
    column: $table.actualStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualEnd => $composableBuilder(
    column: $table.actualEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get notifId =>
      $composableBuilder(column: $table.notifId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ShiftType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedStart => $composableBuilder(
    column: $table.plannedStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get plannedEnd => $composableBuilder(
    column: $table.plannedEnd,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get plannedCustomized => $composableBuilder(
    column: $table.plannedCustomized,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rawStart =>
      $composableBuilder(column: $table.rawStart, builder: (column) => column);

  GeneratedColumn<DateTime> get rawEnd =>
      $composableBuilder(column: $table.rawEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get actualStart => $composableBuilder(
    column: $table.actualStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualEnd =>
      $composableBuilder(column: $table.actualEnd, builder: (column) => column);

  GeneratedColumn<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncState, int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          Shift,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
          Shift,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> notifId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<ShiftType> type = const Value.absent(),
                Value<DateTime> plannedStart = const Value.absent(),
                Value<DateTime> plannedEnd = const Value.absent(),
                Value<bool> plannedCustomized = const Value.absent(),
                Value<DateTime?> rawStart = const Value.absent(),
                Value<DateTime?> rawEnd = const Value.absent(),
                Value<DateTime?> actualStart = const Value.absent(),
                Value<DateTime?> actualEnd = const Value.absent(),
                Value<int> breakMinutes = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<String?> calendarId = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                notifId: notifId,
                day: day,
                type: type,
                plannedStart: plannedStart,
                plannedEnd: plannedEnd,
                plannedCustomized: plannedCustomized,
                rawStart: rawStart,
                rawEnd: rawEnd,
                actualStart: actualStart,
                actualEnd: actualEnd,
                breakMinutes: breakMinutes,
                calendarEventId: calendarEventId,
                calendarId: calendarId,
                syncState: syncState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int notifId,
                required String day,
                required ShiftType type,
                required DateTime plannedStart,
                required DateTime plannedEnd,
                Value<bool> plannedCustomized = const Value.absent(),
                Value<DateTime?> rawStart = const Value.absent(),
                Value<DateTime?> rawEnd = const Value.absent(),
                Value<DateTime?> actualStart = const Value.absent(),
                Value<DateTime?> actualEnd = const Value.absent(),
                Value<int> breakMinutes = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<String?> calendarId = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                notifId: notifId,
                day: day,
                type: type,
                plannedStart: plannedStart,
                plannedEnd: plannedEnd,
                plannedCustomized: plannedCustomized,
                rawStart: rawStart,
                rawEnd: rawEnd,
                actualStart: actualStart,
                actualEnd: actualEnd,
                breakMinutes: breakMinutes,
                calendarEventId: calendarEventId,
                calendarId: calendarId,
                syncState: syncState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShiftsTable, Shift>(table),
                  BaseReferences<_$AppDatabase, $ShiftsTable, Shift>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      Shift,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
      Shift,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingEntry,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingEntry>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingEntry,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingsTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;
typedef $$TipDaysTableCreateCompanionBuilder = TipDaysCompanion Function({
  required String id,
  required String day,
  required int poolCents,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TipDaysTableUpdateCompanionBuilder = TipDaysCompanion Function({
  Value<String> id,
  Value<String> day,
  Value<int> poolCents,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TipDaysTableFilterComposer
    extends Composer<_$AppDatabase, $TipDaysTable> {
  $$TipDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get poolCents => $composableBuilder(
    column: $table.poolCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TipDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $TipDaysTable> {
  $$TipDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get poolCents => $composableBuilder(
    column: $table.poolCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TipDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $TipDaysTable> {
  $$TipDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get poolCents =>
      $composableBuilder(column: $table.poolCents, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TipDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TipDaysTable,
          TipDay,
          $$TipDaysTableFilterComposer,
          $$TipDaysTableOrderingComposer,
          $$TipDaysTableAnnotationComposer,
          $$TipDaysTableCreateCompanionBuilder,
          $$TipDaysTableUpdateCompanionBuilder,
          (TipDay, BaseReferences<_$AppDatabase, $TipDaysTable, TipDay>),
          TipDay,
          PrefetchHooks Function()
        > {
  $$TipDaysTableTableManager(_$AppDatabase db, $TipDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TipDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TipDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TipDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> poolCents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TipDaysCompanion(
                id: id,
                day: day,
                poolCents: poolCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required int poolCents,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TipDaysCompanion.insert(
                id: id,
                day: day,
                poolCents: poolCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TipDaysTable, TipDay>(table),
                  BaseReferences<_$AppDatabase, $TipDaysTable, TipDay>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TipDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TipDaysTable,
      TipDay,
      $$TipDaysTableFilterComposer,
      $$TipDaysTableOrderingComposer,
      $$TipDaysTableAnnotationComposer,
      $$TipDaysTableCreateCompanionBuilder,
      $$TipDaysTableUpdateCompanionBuilder,
      (TipDay, BaseReferences<_$AppDatabase, $TipDaysTable, TipDay>),
      TipDay,
      PrefetchHooks Function()
    >;
typedef $$TipPayoutsTableCreateCompanionBuilder = TipPayoutsCompanion Function({
  required String id,
  required String weekStart,
  required int amountCents,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TipPayoutsTableUpdateCompanionBuilder = TipPayoutsCompanion Function({
  Value<String> id,
  Value<String> weekStart,
  Value<int> amountCents,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TipPayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $TipPayoutsTable> {
  $$TipPayoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TipPayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $TipPayoutsTable> {
  $$TipPayoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TipPayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TipPayoutsTable> {
  $$TipPayoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TipPayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TipPayoutsTable,
          TipPayout,
          $$TipPayoutsTableFilterComposer,
          $$TipPayoutsTableOrderingComposer,
          $$TipPayoutsTableAnnotationComposer,
          $$TipPayoutsTableCreateCompanionBuilder,
          $$TipPayoutsTableUpdateCompanionBuilder,
          (
            TipPayout,
            BaseReferences<_$AppDatabase, $TipPayoutsTable, TipPayout>,
          ),
          TipPayout,
          PrefetchHooks Function()
        > {
  $$TipPayoutsTableTableManager(_$AppDatabase db, $TipPayoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TipPayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TipPayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TipPayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> weekStart = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TipPayoutsCompanion(
                id: id,
                weekStart: weekStart,
                amountCents: amountCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String weekStart,
                required int amountCents,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TipPayoutsCompanion.insert(
                id: id,
                weekStart: weekStart,
                amountCents: amountCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TipPayoutsTable, TipPayout>(table),
                  BaseReferences<_$AppDatabase, $TipPayoutsTable, TipPayout>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TipPayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TipPayoutsTable,
      TipPayout,
      $$TipPayoutsTableFilterComposer,
      $$TipPayoutsTableOrderingComposer,
      $$TipPayoutsTableAnnotationComposer,
      $$TipPayoutsTableCreateCompanionBuilder,
      $$TipPayoutsTableUpdateCompanionBuilder,
      (TipPayout, BaseReferences<_$AppDatabase, $TipPayoutsTable, TipPayout>),
      TipPayout,
      PrefetchHooks Function()
    >;
typedef $$WageRatesTableCreateCompanionBuilder = WageRatesCompanion Function({
  required String id,
  required String validFrom,
  required int hourlyCents,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$WageRatesTableUpdateCompanionBuilder = WageRatesCompanion Function({
  Value<String> id,
  Value<String> validFrom,
  Value<int> hourlyCents,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$WageRatesTableFilterComposer
    extends Composer<_$AppDatabase, $WageRatesTable> {
  $$WageRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourlyCents => $composableBuilder(
    column: $table.hourlyCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WageRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $WageRatesTable> {
  $$WageRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourlyCents => $composableBuilder(
    column: $table.hourlyCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WageRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WageRatesTable> {
  $$WageRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => column);

  GeneratedColumn<int> get hourlyCents => $composableBuilder(
    column: $table.hourlyCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WageRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WageRatesTable,
          WageRate,
          $$WageRatesTableFilterComposer,
          $$WageRatesTableOrderingComposer,
          $$WageRatesTableAnnotationComposer,
          $$WageRatesTableCreateCompanionBuilder,
          $$WageRatesTableUpdateCompanionBuilder,
          (WageRate, BaseReferences<_$AppDatabase, $WageRatesTable, WageRate>),
          WageRate,
          PrefetchHooks Function()
        > {
  $$WageRatesTableTableManager(_$AppDatabase db, $WageRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WageRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WageRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WageRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> validFrom = const Value.absent(),
                Value<int> hourlyCents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WageRatesCompanion(
                id: id,
                validFrom: validFrom,
                hourlyCents: hourlyCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String validFrom,
                required int hourlyCents,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WageRatesCompanion.insert(
                id: id,
                validFrom: validFrom,
                hourlyCents: hourlyCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WageRatesTable, WageRate>(table),
                  BaseReferences<_$AppDatabase, $WageRatesTable, WageRate>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WageRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WageRatesTable,
      WageRate,
      $$WageRatesTableFilterComposer,
      $$WageRatesTableOrderingComposer,
      $$WageRatesTableAnnotationComposer,
      $$WageRatesTableCreateCompanionBuilder,
      $$WageRatesTableUpdateCompanionBuilder,
      (WageRate, BaseReferences<_$AppDatabase, $WageRatesTable, WageRate>),
      WageRate,
      PrefetchHooks Function()
    >;
typedef $$TeamMembersTableCreateCompanionBuilder =
    TeamMembersCompanion Function({
      required String id,
      required String name,
      Value<bool> core,
      Value<bool> isMe,
      Value<bool> active,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TeamMembersTableUpdateCompanionBuilder =
    TeamMembersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> core,
      Value<bool> isMe,
      Value<bool> active,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TeamMembersTableFilterComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get core => $composableBuilder(
    column: $table.core,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get core => $composableBuilder(
    column: $table.core,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get core =>
      $composableBuilder(column: $table.core, builder: (column) => column);

  GeneratedColumn<bool> get isMe =>
      $composableBuilder(column: $table.isMe, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TeamMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamMembersTable,
          TeamMember,
          $$TeamMembersTableFilterComposer,
          $$TeamMembersTableOrderingComposer,
          $$TeamMembersTableAnnotationComposer,
          $$TeamMembersTableCreateCompanionBuilder,
          $$TeamMembersTableUpdateCompanionBuilder,
          (
            TeamMember,
            BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMember>,
          ),
          TeamMember,
          PrefetchHooks Function()
        > {
  $$TeamMembersTableTableManager(_$AppDatabase db, $TeamMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> core = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersCompanion(
                id: id,
                name: name,
                core: core,
                isMe: isMe,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> core = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersCompanion.insert(
                id: id,
                name: name,
                core: core,
                isMe: isMe,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamMembersTable, TeamMember>(table),
                  BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMember>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamMembersTable,
      TeamMember,
      $$TeamMembersTableFilterComposer,
      $$TeamMembersTableOrderingComposer,
      $$TeamMembersTableAnnotationComposer,
      $$TeamMembersTableCreateCompanionBuilder,
      $$TeamMembersTableUpdateCompanionBuilder,
      (
        TeamMember,
        BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMember>,
      ),
      TeamMember,
      PrefetchHooks Function()
    >;
typedef $$TeamAnswersTableCreateCompanionBuilder =
    TeamAnswersCompanion Function({
      required String id,
      required String weekStart,
      required String memberId,
      required AnswerMode mode,
      Value<int> marks,
      Value<int?> maxShifts,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TeamAnswersTableUpdateCompanionBuilder =
    TeamAnswersCompanion Function({
      Value<String> id,
      Value<String> weekStart,
      Value<String> memberId,
      Value<AnswerMode> mode,
      Value<int> marks,
      Value<int?> maxShifts,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TeamAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $TeamAnswersTable> {
  $$TeamAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AnswerMode, AnswerMode, int> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get marks => $composableBuilder(
    column: $table.marks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxShifts => $composableBuilder(
    column: $table.maxShifts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamAnswersTable> {
  $$TeamAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marks => $composableBuilder(
    column: $table.marks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxShifts => $composableBuilder(
    column: $table.maxShifts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamAnswersTable> {
  $$TeamAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AnswerMode, int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get marks =>
      $composableBuilder(column: $table.marks, builder: (column) => column);

  GeneratedColumn<int> get maxShifts =>
      $composableBuilder(column: $table.maxShifts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TeamAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamAnswersTable,
          TeamAnswer,
          $$TeamAnswersTableFilterComposer,
          $$TeamAnswersTableOrderingComposer,
          $$TeamAnswersTableAnnotationComposer,
          $$TeamAnswersTableCreateCompanionBuilder,
          $$TeamAnswersTableUpdateCompanionBuilder,
          (
            TeamAnswer,
            BaseReferences<_$AppDatabase, $TeamAnswersTable, TeamAnswer>,
          ),
          TeamAnswer,
          PrefetchHooks Function()
        > {
  $$TeamAnswersTableTableManager(_$AppDatabase db, $TeamAnswersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> weekStart = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<AnswerMode> mode = const Value.absent(),
                Value<int> marks = const Value.absent(),
                Value<int?> maxShifts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamAnswersCompanion(
                id: id,
                weekStart: weekStart,
                memberId: memberId,
                mode: mode,
                marks: marks,
                maxShifts: maxShifts,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String weekStart,
                required String memberId,
                required AnswerMode mode,
                Value<int> marks = const Value.absent(),
                Value<int?> maxShifts = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TeamAnswersCompanion.insert(
                id: id,
                weekStart: weekStart,
                memberId: memberId,
                mode: mode,
                marks: marks,
                maxShifts: maxShifts,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamAnswersTable, TeamAnswer>(table),
                  BaseReferences<_$AppDatabase, $TeamAnswersTable, TeamAnswer>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamAnswersTable,
      TeamAnswer,
      $$TeamAnswersTableFilterComposer,
      $$TeamAnswersTableOrderingComposer,
      $$TeamAnswersTableAnnotationComposer,
      $$TeamAnswersTableCreateCompanionBuilder,
      $$TeamAnswersTableUpdateCompanionBuilder,
      (
        TeamAnswer,
        BaseReferences<_$AppDatabase, $TeamAnswersTable, TeamAnswer>,
      ),
      TeamAnswer,
      PrefetchHooks Function()
    >;
typedef $$TeamAssignmentsTableCreateCompanionBuilder =
    TeamAssignmentsCompanion Function({
      required String id,
      required String day,
      required TeamShift shift,
      required String memberId,
      Value<int?> startMinutes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TeamAssignmentsTableUpdateCompanionBuilder =
    TeamAssignmentsCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<TeamShift> shift,
      Value<String> memberId,
      Value<int?> startMinutes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TeamAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TeamAssignmentsTable> {
  $$TeamAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TeamShift, TeamShift, int> get shift =>
      $composableBuilder(
        column: $table.shift,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamAssignmentsTable> {
  $$TeamAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shift => $composableBuilder(
    column: $table.shift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamAssignmentsTable> {
  $$TeamAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TeamShift, int> get shift =>
      $composableBuilder(column: $table.shift, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TeamAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamAssignmentsTable,
          TeamAssignment,
          $$TeamAssignmentsTableFilterComposer,
          $$TeamAssignmentsTableOrderingComposer,
          $$TeamAssignmentsTableAnnotationComposer,
          $$TeamAssignmentsTableCreateCompanionBuilder,
          $$TeamAssignmentsTableUpdateCompanionBuilder,
          (
            TeamAssignment,
            BaseReferences<
              _$AppDatabase,
              $TeamAssignmentsTable,
              TeamAssignment
            >,
          ),
          TeamAssignment,
          PrefetchHooks Function()
        > {
  $$TeamAssignmentsTableTableManager(
    _$AppDatabase db,
    $TeamAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamAssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<TeamShift> shift = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamAssignmentsCompanion(
                id: id,
                day: day,
                shift: shift,
                memberId: memberId,
                startMinutes: startMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required TeamShift shift,
                required String memberId,
                Value<int?> startMinutes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TeamAssignmentsCompanion.insert(
                id: id,
                day: day,
                shift: shift,
                memberId: memberId,
                startMinutes: startMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamAssignmentsTable, TeamAssignment>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TeamAssignmentsTable,
                    TeamAssignment
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamAssignmentsTable,
      TeamAssignment,
      $$TeamAssignmentsTableFilterComposer,
      $$TeamAssignmentsTableOrderingComposer,
      $$TeamAssignmentsTableAnnotationComposer,
      $$TeamAssignmentsTableCreateCompanionBuilder,
      $$TeamAssignmentsTableUpdateCompanionBuilder,
      (
        TeamAssignment,
        BaseReferences<_$AppDatabase, $TeamAssignmentsTable, TeamAssignment>,
      ),
      TeamAssignment,
      PrefetchHooks Function()
    >;
typedef $$TeamNeedsTableCreateCompanionBuilder = TeamNeedsCompanion Function({
  required String id,
  required String day,
  required TeamShift shift,
  required int needed,
  Value<int> rowid,
});
typedef $$TeamNeedsTableUpdateCompanionBuilder = TeamNeedsCompanion Function({
  Value<String> id,
  Value<String> day,
  Value<TeamShift> shift,
  Value<int> needed,
  Value<int> rowid,
});

class $$TeamNeedsTableFilterComposer
    extends Composer<_$AppDatabase, $TeamNeedsTable> {
  $$TeamNeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TeamShift, TeamShift, int> get shift =>
      $composableBuilder(
        column: $table.shift,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get needed => $composableBuilder(
    column: $table.needed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamNeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamNeedsTable> {
  $$TeamNeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shift => $composableBuilder(
    column: $table.shift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get needed => $composableBuilder(
    column: $table.needed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamNeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamNeedsTable> {
  $$TeamNeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TeamShift, int> get shift =>
      $composableBuilder(column: $table.shift, builder: (column) => column);

  GeneratedColumn<int> get needed =>
      $composableBuilder(column: $table.needed, builder: (column) => column);
}

class $$TeamNeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamNeedsTable,
          TeamNeed,
          $$TeamNeedsTableFilterComposer,
          $$TeamNeedsTableOrderingComposer,
          $$TeamNeedsTableAnnotationComposer,
          $$TeamNeedsTableCreateCompanionBuilder,
          $$TeamNeedsTableUpdateCompanionBuilder,
          (TeamNeed, BaseReferences<_$AppDatabase, $TeamNeedsTable, TeamNeed>),
          TeamNeed,
          PrefetchHooks Function()
        > {
  $$TeamNeedsTableTableManager(_$AppDatabase db, $TeamNeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamNeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamNeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamNeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<TeamShift> shift = const Value.absent(),
                Value<int> needed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamNeedsCompanion(
                id: id,
                day: day,
                shift: shift,
                needed: needed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required TeamShift shift,
                required int needed,
                Value<int> rowid = const Value.absent(),
              }) => TeamNeedsCompanion.insert(
                id: id,
                day: day,
                shift: shift,
                needed: needed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamNeedsTable, TeamNeed>(table),
                  BaseReferences<_$AppDatabase, $TeamNeedsTable, TeamNeed>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamNeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamNeedsTable,
      TeamNeed,
      $$TeamNeedsTableFilterComposer,
      $$TeamNeedsTableOrderingComposer,
      $$TeamNeedsTableAnnotationComposer,
      $$TeamNeedsTableCreateCompanionBuilder,
      $$TeamNeedsTableUpdateCompanionBuilder,
      (TeamNeed, BaseReferences<_$AppDatabase, $TeamNeedsTable, TeamNeed>),
      TeamNeed,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$TipDaysTableTableManager get tipDays =>
      $$TipDaysTableTableManager(_db, _db.tipDays);
  $$TipPayoutsTableTableManager get tipPayouts =>
      $$TipPayoutsTableTableManager(_db, _db.tipPayouts);
  $$WageRatesTableTableManager get wageRates =>
      $$WageRatesTableTableManager(_db, _db.wageRates);
  $$TeamMembersTableTableManager get teamMembers =>
      $$TeamMembersTableTableManager(_db, _db.teamMembers);
  $$TeamAnswersTableTableManager get teamAnswers =>
      $$TeamAnswersTableTableManager(_db, _db.teamAnswers);
  $$TeamAssignmentsTableTableManager get teamAssignments =>
      $$TeamAssignmentsTableTableManager(_db, _db.teamAssignments);
  $$TeamNeedsTableTableManager get teamNeeds =>
      $$TeamNeedsTableTableManager(_db, _db.teamNeeds);
}
