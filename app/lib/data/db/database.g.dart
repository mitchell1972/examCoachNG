// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PacksTable extends Packs with TableInfo<$PacksTable, Pack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _installedAtMeta =
      const VerificationMeta('installedAt');
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
      'installed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, subject, topic, version, sizeBytes, installedAt, checksum];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packs';
  @override
  VerificationContext validateIntegrity(Insertable<Pack> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    if (data.containsKey('installed_at')) {
      context.handle(
          _installedAtMeta,
          installedAt.isAcceptableOrUnknown(
              data['installed_at']!, _installedAtMeta));
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pack(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      installedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}installed_at']),
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum']),
    );
  }

  @override
  $PacksTable createAlias(String alias) {
    return $PacksTable(attachedDatabase, alias);
  }
}

class Pack extends DataClass implements Insertable<Pack> {
  final String id;
  final String subject;
  final String topic;
  final int version;
  final int sizeBytes;
  final DateTime? installedAt;
  final String? checksum;
  const Pack(
      {required this.id,
      required this.subject,
      required this.topic,
      required this.version,
      required this.sizeBytes,
      this.installedAt,
      this.checksum});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject'] = Variable<String>(subject);
    map['topic'] = Variable<String>(topic);
    map['version'] = Variable<int>(version);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<DateTime>(installedAt);
    }
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    return map;
  }

  PacksCompanion toCompanion(bool nullToAbsent) {
    return PacksCompanion(
      id: Value(id),
      subject: Value(subject),
      topic: Value(topic),
      version: Value(version),
      sizeBytes: Value(sizeBytes),
      installedAt: installedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAt),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
    );
  }

  factory Pack.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pack(
      id: serializer.fromJson<String>(json['id']),
      subject: serializer.fromJson<String>(json['subject']),
      topic: serializer.fromJson<String>(json['topic']),
      version: serializer.fromJson<int>(json['version']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      installedAt: serializer.fromJson<DateTime?>(json['installedAt']),
      checksum: serializer.fromJson<String?>(json['checksum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subject': serializer.toJson<String>(subject),
      'topic': serializer.toJson<String>(topic),
      'version': serializer.toJson<int>(version),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'installedAt': serializer.toJson<DateTime?>(installedAt),
      'checksum': serializer.toJson<String?>(checksum),
    };
  }

  Pack copyWith(
          {String? id,
          String? subject,
          String? topic,
          int? version,
          int? sizeBytes,
          Value<DateTime?> installedAt = const Value.absent(),
          Value<String?> checksum = const Value.absent()}) =>
      Pack(
        id: id ?? this.id,
        subject: subject ?? this.subject,
        topic: topic ?? this.topic,
        version: version ?? this.version,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        installedAt: installedAt.present ? installedAt.value : this.installedAt,
        checksum: checksum.present ? checksum.value : this.checksum,
      );
  Pack copyWithCompanion(PacksCompanion data) {
    return Pack(
      id: data.id.present ? data.id.value : this.id,
      subject: data.subject.present ? data.subject.value : this.subject,
      topic: data.topic.present ? data.topic.value : this.topic,
      version: data.version.present ? data.version.value : this.version,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      installedAt:
          data.installedAt.present ? data.installedAt.value : this.installedAt,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pack(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('version: $version, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('installedAt: $installedAt, ')
          ..write('checksum: $checksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, subject, topic, version, sizeBytes, installedAt, checksum);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pack &&
          other.id == this.id &&
          other.subject == this.subject &&
          other.topic == this.topic &&
          other.version == this.version &&
          other.sizeBytes == this.sizeBytes &&
          other.installedAt == this.installedAt &&
          other.checksum == this.checksum);
}

class PacksCompanion extends UpdateCompanion<Pack> {
  final Value<String> id;
  final Value<String> subject;
  final Value<String> topic;
  final Value<int> version;
  final Value<int> sizeBytes;
  final Value<DateTime?> installedAt;
  final Value<String?> checksum;
  final Value<int> rowid;
  const PacksCompanion({
    this.id = const Value.absent(),
    this.subject = const Value.absent(),
    this.topic = const Value.absent(),
    this.version = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PacksCompanion.insert({
    required String id,
    required String subject,
    required String topic,
    required int version,
    this.sizeBytes = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subject = Value(subject),
        topic = Value(topic),
        version = Value(version);
  static Insertable<Pack> custom({
    Expression<String>? id,
    Expression<String>? subject,
    Expression<String>? topic,
    Expression<int>? version,
    Expression<int>? sizeBytes,
    Expression<DateTime>? installedAt,
    Expression<String>? checksum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subject != null) 'subject': subject,
      if (topic != null) 'topic': topic,
      if (version != null) 'version': version,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (installedAt != null) 'installed_at': installedAt,
      if (checksum != null) 'checksum': checksum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PacksCompanion copyWith(
      {Value<String>? id,
      Value<String>? subject,
      Value<String>? topic,
      Value<int>? version,
      Value<int>? sizeBytes,
      Value<DateTime?>? installedAt,
      Value<String?>? checksum,
      Value<int>? rowid}) {
    return PacksCompanion(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      version: version ?? this.version,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      installedAt: installedAt ?? this.installedAt,
      checksum: checksum ?? this.checksum,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PacksCompanion(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('version: $version, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('installedAt: $installedAt, ')
          ..write('checksum: $checksum, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
      'pack_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stemMeta = const VerificationMeta('stem');
  @override
  late final GeneratedColumn<String> stem = GeneratedColumn<String>(
      'stem', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aMeta = const VerificationMeta('a');
  @override
  late final GeneratedColumn<String> a = GeneratedColumn<String>(
      'a', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bMeta = const VerificationMeta('b');
  @override
  late final GeneratedColumn<String> b = GeneratedColumn<String>(
      'b', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cMeta = const VerificationMeta('c');
  @override
  late final GeneratedColumn<String> c = GeneratedColumn<String>(
      'c', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dMeta = const VerificationMeta('d');
  @override
  late final GeneratedColumn<String> d = GeneratedColumn<String>(
      'd', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctMeta =
      const VerificationMeta('correct');
  @override
  late final GeneratedColumn<String> correct = GeneratedColumn<String>(
      'correct', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  static const VerificationMeta _syllabusNodeMeta =
      const VerificationMeta('syllabusNode');
  @override
  late final GeneratedColumn<String> syllabusNode = GeneratedColumn<String>(
      'syllabus_node', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        packId,
        stem,
        a,
        b,
        c,
        d,
        correct,
        explanation,
        difficulty,
        syllabusNode
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(Insertable<Question> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(_packIdMeta,
          packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta));
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('stem')) {
      context.handle(
          _stemMeta, stem.isAcceptableOrUnknown(data['stem']!, _stemMeta));
    } else if (isInserting) {
      context.missing(_stemMeta);
    }
    if (data.containsKey('a')) {
      context.handle(_aMeta, a.isAcceptableOrUnknown(data['a']!, _aMeta));
    } else if (isInserting) {
      context.missing(_aMeta);
    }
    if (data.containsKey('b')) {
      context.handle(_bMeta, b.isAcceptableOrUnknown(data['b']!, _bMeta));
    } else if (isInserting) {
      context.missing(_bMeta);
    }
    if (data.containsKey('c')) {
      context.handle(_cMeta, c.isAcceptableOrUnknown(data['c']!, _cMeta));
    } else if (isInserting) {
      context.missing(_cMeta);
    }
    if (data.containsKey('d')) {
      context.handle(_dMeta, d.isAcceptableOrUnknown(data['d']!, _dMeta));
    } else if (isInserting) {
      context.missing(_dMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(_correctMeta,
          correct.isAcceptableOrUnknown(data['correct']!, _correctMeta));
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('syllabus_node')) {
      context.handle(
          _syllabusNodeMeta,
          syllabusNode.isAcceptableOrUnknown(
              data['syllabus_node']!, _syllabusNodeMeta));
    } else if (isInserting) {
      context.missing(_syllabusNodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      packId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pack_id'])!,
      stem: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stem'])!,
      a: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}a'])!,
      b: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}b'])!,
      c: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}c'])!,
      d: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}d'])!,
      correct: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correct'])!,
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty'])!,
      syllabusNode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}syllabus_node'])!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final String id;
  final String packId;
  final String stem;
  final String a;
  final String b;
  final String c;
  final String d;
  final String correct;
  final String explanation;
  final int difficulty;
  final String syllabusNode;
  const Question(
      {required this.id,
      required this.packId,
      required this.stem,
      required this.a,
      required this.b,
      required this.c,
      required this.d,
      required this.correct,
      required this.explanation,
      required this.difficulty,
      required this.syllabusNode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pack_id'] = Variable<String>(packId);
    map['stem'] = Variable<String>(stem);
    map['a'] = Variable<String>(a);
    map['b'] = Variable<String>(b);
    map['c'] = Variable<String>(c);
    map['d'] = Variable<String>(d);
    map['correct'] = Variable<String>(correct);
    map['explanation'] = Variable<String>(explanation);
    map['difficulty'] = Variable<int>(difficulty);
    map['syllabus_node'] = Variable<String>(syllabusNode);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      packId: Value(packId),
      stem: Value(stem),
      a: Value(a),
      b: Value(b),
      c: Value(c),
      d: Value(d),
      correct: Value(correct),
      explanation: Value(explanation),
      difficulty: Value(difficulty),
      syllabusNode: Value(syllabusNode),
    );
  }

  factory Question.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<String>(json['id']),
      packId: serializer.fromJson<String>(json['packId']),
      stem: serializer.fromJson<String>(json['stem']),
      a: serializer.fromJson<String>(json['a']),
      b: serializer.fromJson<String>(json['b']),
      c: serializer.fromJson<String>(json['c']),
      d: serializer.fromJson<String>(json['d']),
      correct: serializer.fromJson<String>(json['correct']),
      explanation: serializer.fromJson<String>(json['explanation']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      syllabusNode: serializer.fromJson<String>(json['syllabusNode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'packId': serializer.toJson<String>(packId),
      'stem': serializer.toJson<String>(stem),
      'a': serializer.toJson<String>(a),
      'b': serializer.toJson<String>(b),
      'c': serializer.toJson<String>(c),
      'd': serializer.toJson<String>(d),
      'correct': serializer.toJson<String>(correct),
      'explanation': serializer.toJson<String>(explanation),
      'difficulty': serializer.toJson<int>(difficulty),
      'syllabusNode': serializer.toJson<String>(syllabusNode),
    };
  }

  Question copyWith(
          {String? id,
          String? packId,
          String? stem,
          String? a,
          String? b,
          String? c,
          String? d,
          String? correct,
          String? explanation,
          int? difficulty,
          String? syllabusNode}) =>
      Question(
        id: id ?? this.id,
        packId: packId ?? this.packId,
        stem: stem ?? this.stem,
        a: a ?? this.a,
        b: b ?? this.b,
        c: c ?? this.c,
        d: d ?? this.d,
        correct: correct ?? this.correct,
        explanation: explanation ?? this.explanation,
        difficulty: difficulty ?? this.difficulty,
        syllabusNode: syllabusNode ?? this.syllabusNode,
      );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      packId: data.packId.present ? data.packId.value : this.packId,
      stem: data.stem.present ? data.stem.value : this.stem,
      a: data.a.present ? data.a.value : this.a,
      b: data.b.present ? data.b.value : this.b,
      c: data.c.present ? data.c.value : this.c,
      d: data.d.present ? data.d.value : this.d,
      correct: data.correct.present ? data.correct.value : this.correct,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      syllabusNode: data.syllabusNode.present
          ? data.syllabusNode.value
          : this.syllabusNode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('stem: $stem, ')
          ..write('a: $a, ')
          ..write('b: $b, ')
          ..write('c: $c, ')
          ..write('d: $d, ')
          ..write('correct: $correct, ')
          ..write('explanation: $explanation, ')
          ..write('difficulty: $difficulty, ')
          ..write('syllabusNode: $syllabusNode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, packId, stem, a, b, c, d, correct,
      explanation, difficulty, syllabusNode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.packId == this.packId &&
          other.stem == this.stem &&
          other.a == this.a &&
          other.b == this.b &&
          other.c == this.c &&
          other.d == this.d &&
          other.correct == this.correct &&
          other.explanation == this.explanation &&
          other.difficulty == this.difficulty &&
          other.syllabusNode == this.syllabusNode);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<String> id;
  final Value<String> packId;
  final Value<String> stem;
  final Value<String> a;
  final Value<String> b;
  final Value<String> c;
  final Value<String> d;
  final Value<String> correct;
  final Value<String> explanation;
  final Value<int> difficulty;
  final Value<String> syllabusNode;
  final Value<int> rowid;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.packId = const Value.absent(),
    this.stem = const Value.absent(),
    this.a = const Value.absent(),
    this.b = const Value.absent(),
    this.c = const Value.absent(),
    this.d = const Value.absent(),
    this.correct = const Value.absent(),
    this.explanation = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.syllabusNode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionsCompanion.insert({
    required String id,
    required String packId,
    required String stem,
    required String a,
    required String b,
    required String c,
    required String d,
    required String correct,
    required String explanation,
    this.difficulty = const Value.absent(),
    required String syllabusNode,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        packId = Value(packId),
        stem = Value(stem),
        a = Value(a),
        b = Value(b),
        c = Value(c),
        d = Value(d),
        correct = Value(correct),
        explanation = Value(explanation),
        syllabusNode = Value(syllabusNode);
  static Insertable<Question> custom({
    Expression<String>? id,
    Expression<String>? packId,
    Expression<String>? stem,
    Expression<String>? a,
    Expression<String>? b,
    Expression<String>? c,
    Expression<String>? d,
    Expression<String>? correct,
    Expression<String>? explanation,
    Expression<int>? difficulty,
    Expression<String>? syllabusNode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packId != null) 'pack_id': packId,
      if (stem != null) 'stem': stem,
      if (a != null) 'a': a,
      if (b != null) 'b': b,
      if (c != null) 'c': c,
      if (d != null) 'd': d,
      if (correct != null) 'correct': correct,
      if (explanation != null) 'explanation': explanation,
      if (difficulty != null) 'difficulty': difficulty,
      if (syllabusNode != null) 'syllabus_node': syllabusNode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? packId,
      Value<String>? stem,
      Value<String>? a,
      Value<String>? b,
      Value<String>? c,
      Value<String>? d,
      Value<String>? correct,
      Value<String>? explanation,
      Value<int>? difficulty,
      Value<String>? syllabusNode,
      Value<int>? rowid}) {
    return QuestionsCompanion(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      stem: stem ?? this.stem,
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      d: d ?? this.d,
      correct: correct ?? this.correct,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      syllabusNode: syllabusNode ?? this.syllabusNode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (stem.present) {
      map['stem'] = Variable<String>(stem.value);
    }
    if (a.present) {
      map['a'] = Variable<String>(a.value);
    }
    if (b.present) {
      map['b'] = Variable<String>(b.value);
    }
    if (c.present) {
      map['c'] = Variable<String>(c.value);
    }
    if (d.present) {
      map['d'] = Variable<String>(d.value);
    }
    if (correct.present) {
      map['correct'] = Variable<String>(correct.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (syllabusNode.present) {
      map['syllabus_node'] = Variable<String>(syllabusNode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('stem: $stem, ')
          ..write('a: $a, ')
          ..write('b: $b, ')
          ..write('c: $c, ')
          ..write('d: $d, ')
          ..write('correct: $correct, ')
          ..write('explanation: $explanation, ')
          ..write('difficulty: $difficulty, ')
          ..write('syllabusNode: $syllabusNode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _metaJsonMeta =
      const VerificationMeta('metaJson');
  @override
  late final GeneratedColumn<String> metaJson = GeneratedColumn<String>(
      'meta_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, mode, subject, topic, startedAt, endedAt, score, metaJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('meta_json')) {
      context.handle(_metaJsonMeta,
          metaJson.isAcceptableOrUnknown(data['meta_json']!, _metaJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score']),
      metaJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meta_json']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String mode;
  final String subject;
  final String? topic;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? score;
  final String? metaJson;
  const Session(
      {required this.id,
      required this.mode,
      required this.subject,
      this.topic,
      required this.startedAt,
      this.endedAt,
      this.score,
      this.metaJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mode'] = Variable<String>(mode);
    map['subject'] = Variable<String>(subject);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || metaJson != null) {
      map['meta_json'] = Variable<String>(metaJson);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      mode: Value(mode),
      subject: Value(subject),
      topic:
          topic == null && nullToAbsent ? const Value.absent() : Value(topic),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
      metaJson: metaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metaJson),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      subject: serializer.fromJson<String>(json['subject']),
      topic: serializer.fromJson<String?>(json['topic']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      score: serializer.fromJson<int?>(json['score']),
      metaJson: serializer.fromJson<String?>(json['metaJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mode': serializer.toJson<String>(mode),
      'subject': serializer.toJson<String>(subject),
      'topic': serializer.toJson<String?>(topic),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'score': serializer.toJson<int?>(score),
      'metaJson': serializer.toJson<String?>(metaJson),
    };
  }

  Session copyWith(
          {String? id,
          String? mode,
          String? subject,
          Value<String?> topic = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          Value<int?> score = const Value.absent(),
          Value<String?> metaJson = const Value.absent()}) =>
      Session(
        id: id ?? this.id,
        mode: mode ?? this.mode,
        subject: subject ?? this.subject,
        topic: topic.present ? topic.value : this.topic,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        score: score.present ? score.value : this.score,
        metaJson: metaJson.present ? metaJson.value : this.metaJson,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      subject: data.subject.present ? data.subject.value : this.subject,
      topic: data.topic.present ? data.topic.value : this.topic,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      score: data.score.present ? data.score.value : this.score,
      metaJson: data.metaJson.present ? data.metaJson.value : this.metaJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('score: $score, ')
          ..write('metaJson: $metaJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, mode, subject, topic, startedAt, endedAt, score, metaJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.subject == this.subject &&
          other.topic == this.topic &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.score == this.score &&
          other.metaJson == this.metaJson);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> mode;
  final Value<String> subject;
  final Value<String?> topic;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int?> score;
  final Value<String?> metaJson;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.subject = const Value.absent(),
    this.topic = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.metaJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String mode,
    required String subject,
    this.topic = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.metaJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mode = Value(mode),
        subject = Value(subject),
        startedAt = Value(startedAt);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? mode,
    Expression<String>? subject,
    Expression<String>? topic,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? score,
    Expression<String>? metaJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (subject != null) 'subject': subject,
      if (topic != null) 'topic': topic,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (score != null) 'score': score,
      if (metaJson != null) 'meta_json': metaJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? mode,
      Value<String>? subject,
      Value<String?>? topic,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int?>? score,
      Value<String?>? metaJson,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      score: score ?? this.score,
      metaJson: metaJson ?? this.metaJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (metaJson.present) {
      map['meta_json'] = Variable<String>(metaJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('score: $score, ')
          ..write('metaJson: $metaJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chosenMeta = const VerificationMeta('chosen');
  @override
  late final GeneratedColumn<String> chosen = GeneratedColumn<String>(
      'chosen', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctMeta =
      const VerificationMeta('correct');
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
      'correct', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("correct" IN (0, 1))'));
  static const VerificationMeta _timeMsMeta = const VerificationMeta('timeMs');
  @override
  late final GeneratedColumn<int> timeMs = GeneratedColumn<int>(
      'time_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, questionId, chosen, correct, timeMs, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(Insertable<Attempt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('chosen')) {
      context.handle(_chosenMeta,
          chosen.isAcceptableOrUnknown(data['chosen']!, _chosenMeta));
    } else if (isInserting) {
      context.missing(_chosenMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(_correctMeta,
          correct.isAcceptableOrUnknown(data['correct']!, _correctMeta));
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('time_ms')) {
      context.handle(_timeMsMeta,
          timeMs.isAcceptableOrUnknown(data['time_ms']!, _timeMsMeta));
    } else if (isInserting) {
      context.missing(_timeMsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      chosen: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chosen'])!,
      correct: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}correct'])!,
      timeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_ms'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }
}

class Attempt extends DataClass implements Insertable<Attempt> {
  final String id;
  final String sessionId;
  final String questionId;
  final String chosen;
  final bool correct;
  final int timeMs;
  final DateTime createdAt;
  final bool synced;
  const Attempt(
      {required this.id,
      required this.sessionId,
      required this.questionId,
      required this.chosen,
      required this.correct,
      required this.timeMs,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['question_id'] = Variable<String>(questionId);
    map['chosen'] = Variable<String>(chosen);
    map['correct'] = Variable<bool>(correct);
    map['time_ms'] = Variable<int>(timeMs);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      questionId: Value(questionId),
      chosen: Value(chosen),
      correct: Value(correct),
      timeMs: Value(timeMs),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Attempt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      chosen: serializer.fromJson<String>(json['chosen']),
      correct: serializer.fromJson<bool>(json['correct']),
      timeMs: serializer.fromJson<int>(json['timeMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'questionId': serializer.toJson<String>(questionId),
      'chosen': serializer.toJson<String>(chosen),
      'correct': serializer.toJson<bool>(correct),
      'timeMs': serializer.toJson<int>(timeMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Attempt copyWith(
          {String? id,
          String? sessionId,
          String? questionId,
          String? chosen,
          bool? correct,
          int? timeMs,
          DateTime? createdAt,
          bool? synced}) =>
      Attempt(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        questionId: questionId ?? this.questionId,
        chosen: chosen ?? this.chosen,
        correct: correct ?? this.correct,
        timeMs: timeMs ?? this.timeMs,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      chosen: data.chosen.present ? data.chosen.value : this.chosen,
      correct: data.correct.present ? data.correct.value : this.correct,
      timeMs: data.timeMs.present ? data.timeMs.value : this.timeMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('chosen: $chosen, ')
          ..write('correct: $correct, ')
          ..write('timeMs: $timeMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sessionId, questionId, chosen, correct, timeMs, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.questionId == this.questionId &&
          other.chosen == this.chosen &&
          other.correct == this.correct &&
          other.timeMs == this.timeMs &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> questionId;
  final Value<String> chosen;
  final Value<bool> correct;
  final Value<int> timeMs;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.chosen = const Value.absent(),
    this.correct = const Value.absent(),
    this.timeMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttemptsCompanion.insert({
    required String id,
    required String sessionId,
    required String questionId,
    required String chosen,
    required bool correct,
    required int timeMs,
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        questionId = Value(questionId),
        chosen = Value(chosen),
        correct = Value(correct),
        timeMs = Value(timeMs),
        createdAt = Value(createdAt);
  static Insertable<Attempt> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? questionId,
    Expression<String>? chosen,
    Expression<bool>? correct,
    Expression<int>? timeMs,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (questionId != null) 'question_id': questionId,
      if (chosen != null) 'chosen': chosen,
      if (correct != null) 'correct': correct,
      if (timeMs != null) 'time_ms': timeMs,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttemptsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? questionId,
      Value<String>? chosen,
      Value<bool>? correct,
      Value<int>? timeMs,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return AttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      questionId: questionId ?? this.questionId,
      chosen: chosen ?? this.chosen,
      correct: correct ?? this.correct,
      timeMs: timeMs ?? this.timeMs,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (chosen.present) {
      map['chosen'] = Variable<String>(chosen.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (timeMs.present) {
      map['time_ms'] = Variable<int>(timeMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('chosen: $chosen, ')
          ..write('correct: $correct, ')
          ..write('timeMs: $timeMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TopicStatsTable extends TopicStats
    with TableInfo<$TopicStatsTable, TopicStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _correctMeta =
      const VerificationMeta('correct');
  @override
  late final GeneratedColumn<int> correct = GeneratedColumn<int>(
      'correct', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastSeenAtMeta =
      const VerificationMeta('lastSeenAt');
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
      'last_seen_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [topic, attempts, correct, accuracy, lastSeenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topic_stats';
  @override
  VerificationContext validateIntegrity(Insertable<TopicStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('correct')) {
      context.handle(_correctMeta,
          correct.isAcceptableOrUnknown(data['correct']!, _correctMeta));
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
          _lastSeenAtMeta,
          lastSeenAt.isAcceptableOrUnknown(
              data['last_seen_at']!, _lastSeenAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {topic};
  @override
  TopicStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicStat(
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      correct: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      lastSeenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen_at']),
    );
  }

  @override
  $TopicStatsTable createAlias(String alias) {
    return $TopicStatsTable(attachedDatabase, alias);
  }
}

class TopicStat extends DataClass implements Insertable<TopicStat> {
  final String topic;
  final int attempts;
  final int correct;
  final double accuracy;
  final DateTime? lastSeenAt;
  const TopicStat(
      {required this.topic,
      required this.attempts,
      required this.correct,
      required this.accuracy,
      this.lastSeenAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['topic'] = Variable<String>(topic);
    map['attempts'] = Variable<int>(attempts);
    map['correct'] = Variable<int>(correct);
    map['accuracy'] = Variable<double>(accuracy);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    return map;
  }

  TopicStatsCompanion toCompanion(bool nullToAbsent) {
    return TopicStatsCompanion(
      topic: Value(topic),
      attempts: Value(attempts),
      correct: Value(correct),
      accuracy: Value(accuracy),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
    );
  }

  factory TopicStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicStat(
      topic: serializer.fromJson<String>(json['topic']),
      attempts: serializer.fromJson<int>(json['attempts']),
      correct: serializer.fromJson<int>(json['correct']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'topic': serializer.toJson<String>(topic),
      'attempts': serializer.toJson<int>(attempts),
      'correct': serializer.toJson<int>(correct),
      'accuracy': serializer.toJson<double>(accuracy),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
    };
  }

  TopicStat copyWith(
          {String? topic,
          int? attempts,
          int? correct,
          double? accuracy,
          Value<DateTime?> lastSeenAt = const Value.absent()}) =>
      TopicStat(
        topic: topic ?? this.topic,
        attempts: attempts ?? this.attempts,
        correct: correct ?? this.correct,
        accuracy: accuracy ?? this.accuracy,
        lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
      );
  TopicStat copyWithCompanion(TopicStatsCompanion data) {
    return TopicStat(
      topic: data.topic.present ? data.topic.value : this.topic,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      correct: data.correct.present ? data.correct.value : this.correct,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      lastSeenAt:
          data.lastSeenAt.present ? data.lastSeenAt.value : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicStat(')
          ..write('topic: $topic, ')
          ..write('attempts: $attempts, ')
          ..write('correct: $correct, ')
          ..write('accuracy: $accuracy, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(topic, attempts, correct, accuracy, lastSeenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicStat &&
          other.topic == this.topic &&
          other.attempts == this.attempts &&
          other.correct == this.correct &&
          other.accuracy == this.accuracy &&
          other.lastSeenAt == this.lastSeenAt);
}

class TopicStatsCompanion extends UpdateCompanion<TopicStat> {
  final Value<String> topic;
  final Value<int> attempts;
  final Value<int> correct;
  final Value<double> accuracy;
  final Value<DateTime?> lastSeenAt;
  final Value<int> rowid;
  const TopicStatsCompanion({
    this.topic = const Value.absent(),
    this.attempts = const Value.absent(),
    this.correct = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicStatsCompanion.insert({
    required String topic,
    this.attempts = const Value.absent(),
    this.correct = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : topic = Value(topic);
  static Insertable<TopicStat> custom({
    Expression<String>? topic,
    Expression<int>? attempts,
    Expression<int>? correct,
    Expression<double>? accuracy,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (topic != null) 'topic': topic,
      if (attempts != null) 'attempts': attempts,
      if (correct != null) 'correct': correct,
      if (accuracy != null) 'accuracy': accuracy,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicStatsCompanion copyWith(
      {Value<String>? topic,
      Value<int>? attempts,
      Value<int>? correct,
      Value<double>? accuracy,
      Value<DateTime?>? lastSeenAt,
      Value<int>? rowid}) {
    return TopicStatsCompanion(
      topic: topic ?? this.topic,
      attempts: attempts ?? this.attempts,
      correct: correct ?? this.correct,
      accuracy: accuracy ?? this.accuracy,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (correct.present) {
      map['correct'] = Variable<int>(correct.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicStatsCompanion(')
          ..write('topic: $topic, ')
          ..write('attempts: $attempts, ')
          ..write('correct: $correct, ')
          ..write('accuracy: $accuracy, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntitlementsTable extends Entitlements
    with TableInfo<$EntitlementsTable, Entitlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
      'plan', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
      'start_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
      'end_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [plan, startAt, endAt, source, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entitlements';
  @override
  VerificationContext validateIntegrity(Insertable<Entitlement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plan')) {
      context.handle(
          _planMeta, plan.isAcceptableOrUnknown(data['plan']!, _planMeta));
    } else if (isInserting) {
      context.missing(_planMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
          _endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {plan, startAt};
  @override
  Entitlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entitlement(
      plan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan'])!,
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_at'])!,
      endAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_at'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
    );
  }

  @override
  $EntitlementsTable createAlias(String alias) {
    return $EntitlementsTable(attachedDatabase, alias);
  }
}

class Entitlement extends DataClass implements Insertable<Entitlement> {
  final String plan;
  final DateTime startAt;
  final DateTime endAt;
  final String source;
  final bool active;
  const Entitlement(
      {required this.plan,
      required this.startAt,
      required this.endAt,
      required this.source,
      required this.active});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plan'] = Variable<String>(plan);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['source'] = Variable<String>(source);
    map['active'] = Variable<bool>(active);
    return map;
  }

  EntitlementsCompanion toCompanion(bool nullToAbsent) {
    return EntitlementsCompanion(
      plan: Value(plan),
      startAt: Value(startAt),
      endAt: Value(endAt),
      source: Value(source),
      active: Value(active),
    );
  }

  factory Entitlement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entitlement(
      plan: serializer.fromJson<String>(json['plan']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      source: serializer.fromJson<String>(json['source']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'plan': serializer.toJson<String>(plan),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'source': serializer.toJson<String>(source),
      'active': serializer.toJson<bool>(active),
    };
  }

  Entitlement copyWith(
          {String? plan,
          DateTime? startAt,
          DateTime? endAt,
          String? source,
          bool? active}) =>
      Entitlement(
        plan: plan ?? this.plan,
        startAt: startAt ?? this.startAt,
        endAt: endAt ?? this.endAt,
        source: source ?? this.source,
        active: active ?? this.active,
      );
  Entitlement copyWithCompanion(EntitlementsCompanion data) {
    return Entitlement(
      plan: data.plan.present ? data.plan.value : this.plan,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      source: data.source.present ? data.source.value : this.source,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entitlement(')
          ..write('plan: $plan, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('source: $source, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(plan, startAt, endAt, source, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entitlement &&
          other.plan == this.plan &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.source == this.source &&
          other.active == this.active);
}

class EntitlementsCompanion extends UpdateCompanion<Entitlement> {
  final Value<String> plan;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<String> source;
  final Value<bool> active;
  final Value<int> rowid;
  const EntitlementsCompanion({
    this.plan = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.source = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitlementsCompanion.insert({
    required String plan,
    required DateTime startAt,
    required DateTime endAt,
    required String source,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : plan = Value(plan),
        startAt = Value(startAt),
        endAt = Value(endAt),
        source = Value(source);
  static Insertable<Entitlement> custom({
    Expression<String>? plan,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<String>? source,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (plan != null) 'plan': plan,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (source != null) 'source': source,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitlementsCompanion copyWith(
      {Value<String>? plan,
      Value<DateTime>? startAt,
      Value<DateTime>? endAt,
      Value<String>? source,
      Value<bool>? active,
      Value<int>? rowid}) {
    return EntitlementsCompanion(
      plan: plan ?? this.plan,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      source: source ?? this.source,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitlementsCompanion(')
          ..write('plan: $plan, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('source: $source, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, operation, entity, payload, retryCount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String operation;
  final String entity;
  final String payload;
  final int retryCount;
  final DateTime createdAt;
  const SyncQueueData(
      {required this.id,
      required this.operation,
      required this.entity,
      required this.payload,
      required this.retryCount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['entity'] = Variable<String>(entity);
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      operation: Value(operation),
      entity: Value(entity),
      payload: Value(payload),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      entity: serializer.fromJson<String>(json['entity']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'entity': serializer.toJson<String>(entity),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? operation,
          String? entity,
          String? payload,
          int? retryCount,
          DateTime? createdAt}) =>
      SyncQueueData(
        id: id ?? this.id,
        operation: operation ?? this.operation,
        entity: entity ?? this.entity,
        payload: payload ?? this.payload,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      entity: data.entity.present ? data.entity.value : this.entity,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('entity: $entity, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, operation, entity, payload, retryCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.entity == this.entity &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> entity;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.entity = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String entity,
    required String payload,
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
  })  : operation = Value(operation),
        entity = Value(entity),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? entity,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (entity != null) 'entity': entity,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? operation,
      Value<String>? entity,
      Value<String>? payload,
      Value<int>? retryCount,
      Value<DateTime>? createdAt}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      entity: entity ?? this.entity,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('entity: $entity, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PacksTable packs = $PacksTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $TopicStatsTable topicStats = $TopicStatsTable(this);
  late final $EntitlementsTable entitlements = $EntitlementsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        packs,
        questions,
        sessions,
        attempts,
        topicStats,
        entitlements,
        syncQueue
      ];
}

typedef $$PacksTableCreateCompanionBuilder = PacksCompanion Function({
  required String id,
  required String subject,
  required String topic,
  required int version,
  Value<int> sizeBytes,
  Value<DateTime?> installedAt,
  Value<String?> checksum,
  Value<int> rowid,
});
typedef $$PacksTableUpdateCompanionBuilder = PacksCompanion Function({
  Value<String> id,
  Value<String> subject,
  Value<String> topic,
  Value<int> version,
  Value<int> sizeBytes,
  Value<DateTime?> installedAt,
  Value<String?> checksum,
  Value<int> rowid,
});

class $$PacksTableFilterComposer extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));
}

class $$PacksTableOrderingComposer
    extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));
}

class $$PacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);
}

class $$PacksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PacksTable,
    Pack,
    $$PacksTableFilterComposer,
    $$PacksTableOrderingComposer,
    $$PacksTableAnnotationComposer,
    $$PacksTableCreateCompanionBuilder,
    $$PacksTableUpdateCompanionBuilder,
    (Pack, BaseReferences<_$AppDatabase, $PacksTable, Pack>),
    Pack,
    PrefetchHooks Function()> {
  $$PacksTableTableManager(_$AppDatabase db, $PacksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> topic = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<DateTime?> installedAt = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PacksCompanion(
            id: id,
            subject: subject,
            topic: topic,
            version: version,
            sizeBytes: sizeBytes,
            installedAt: installedAt,
            checksum: checksum,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subject,
            required String topic,
            required int version,
            Value<int> sizeBytes = const Value.absent(),
            Value<DateTime?> installedAt = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PacksCompanion.insert(
            id: id,
            subject: subject,
            topic: topic,
            version: version,
            sizeBytes: sizeBytes,
            installedAt: installedAt,
            checksum: checksum,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PacksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PacksTable,
    Pack,
    $$PacksTableFilterComposer,
    $$PacksTableOrderingComposer,
    $$PacksTableAnnotationComposer,
    $$PacksTableCreateCompanionBuilder,
    $$PacksTableUpdateCompanionBuilder,
    (Pack, BaseReferences<_$AppDatabase, $PacksTable, Pack>),
    Pack,
    PrefetchHooks Function()>;
typedef $$QuestionsTableCreateCompanionBuilder = QuestionsCompanion Function({
  required String id,
  required String packId,
  required String stem,
  required String a,
  required String b,
  required String c,
  required String d,
  required String correct,
  required String explanation,
  Value<int> difficulty,
  required String syllabusNode,
  Value<int> rowid,
});
typedef $$QuestionsTableUpdateCompanionBuilder = QuestionsCompanion Function({
  Value<String> id,
  Value<String> packId,
  Value<String> stem,
  Value<String> a,
  Value<String> b,
  Value<String> c,
  Value<String> d,
  Value<String> correct,
  Value<String> explanation,
  Value<int> difficulty,
  Value<String> syllabusNode,
  Value<int> rowid,
});

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packId => $composableBuilder(
      column: $table.packId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stem => $composableBuilder(
      column: $table.stem, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get a => $composableBuilder(
      column: $table.a, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get b => $composableBuilder(
      column: $table.b, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get c => $composableBuilder(
      column: $table.c, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get d => $composableBuilder(
      column: $table.d, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syllabusNode => $composableBuilder(
      column: $table.syllabusNode, builder: (column) => ColumnFilters(column));
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packId => $composableBuilder(
      column: $table.packId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stem => $composableBuilder(
      column: $table.stem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get a => $composableBuilder(
      column: $table.a, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get b => $composableBuilder(
      column: $table.b, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get c => $composableBuilder(
      column: $table.c, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get d => $composableBuilder(
      column: $table.d, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syllabusNode => $composableBuilder(
      column: $table.syllabusNode,
      builder: (column) => ColumnOrderings(column));
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<String> get stem =>
      $composableBuilder(column: $table.stem, builder: (column) => column);

  GeneratedColumn<String> get a =>
      $composableBuilder(column: $table.a, builder: (column) => column);

  GeneratedColumn<String> get b =>
      $composableBuilder(column: $table.b, builder: (column) => column);

  GeneratedColumn<String> get c =>
      $composableBuilder(column: $table.c, builder: (column) => column);

  GeneratedColumn<String> get d =>
      $composableBuilder(column: $table.d, builder: (column) => column);

  GeneratedColumn<String> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get syllabusNode => $composableBuilder(
      column: $table.syllabusNode, builder: (column) => column);
}

class $$QuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (Question, BaseReferences<_$AppDatabase, $QuestionsTable, Question>),
    Question,
    PrefetchHooks Function()> {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> packId = const Value.absent(),
            Value<String> stem = const Value.absent(),
            Value<String> a = const Value.absent(),
            Value<String> b = const Value.absent(),
            Value<String> c = const Value.absent(),
            Value<String> d = const Value.absent(),
            Value<String> correct = const Value.absent(),
            Value<String> explanation = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<String> syllabusNode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionsCompanion(
            id: id,
            packId: packId,
            stem: stem,
            a: a,
            b: b,
            c: c,
            d: d,
            correct: correct,
            explanation: explanation,
            difficulty: difficulty,
            syllabusNode: syllabusNode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String packId,
            required String stem,
            required String a,
            required String b,
            required String c,
            required String d,
            required String correct,
            required String explanation,
            Value<int> difficulty = const Value.absent(),
            required String syllabusNode,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionsCompanion.insert(
            id: id,
            packId: packId,
            stem: stem,
            a: a,
            b: b,
            c: c,
            d: d,
            correct: correct,
            explanation: explanation,
            difficulty: difficulty,
            syllabusNode: syllabusNode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (Question, BaseReferences<_$AppDatabase, $QuestionsTable, Question>),
    Question,
    PrefetchHooks Function()>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String mode,
  required String subject,
  Value<String?> topic,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<int?> score,
  Value<String?> metaJson,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> mode,
  Value<String> subject,
  Value<String?> topic,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int?> score,
  Value<String?> metaJson,
  Value<int> rowid,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metaJson => $composableBuilder(
      column: $table.metaJson, builder: (column) => ColumnFilters(column));
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metaJson => $composableBuilder(
      column: $table.metaJson, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get metaJson =>
      $composableBuilder(column: $table.metaJson, builder: (column) => column);
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int?> score = const Value.absent(),
            Value<String?> metaJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            mode: mode,
            subject: subject,
            topic: topic,
            startedAt: startedAt,
            endedAt: endedAt,
            score: score,
            metaJson: metaJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mode,
            required String subject,
            Value<String?> topic = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int?> score = const Value.absent(),
            Value<String?> metaJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            mode: mode,
            subject: subject,
            topic: topic,
            startedAt: startedAt,
            endedAt: endedAt,
            score: score,
            metaJson: metaJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()>;
typedef $$AttemptsTableCreateCompanionBuilder = AttemptsCompanion Function({
  required String id,
  required String sessionId,
  required String questionId,
  required String chosen,
  required bool correct,
  required int timeMs,
  required DateTime createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$AttemptsTableUpdateCompanionBuilder = AttemptsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> questionId,
  Value<String> chosen,
  Value<bool> correct,
  Value<int> timeMs,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$AttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chosen => $composableBuilder(
      column: $table.chosen, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeMs => $composableBuilder(
      column: $table.timeMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chosen => $composableBuilder(
      column: $table.chosen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeMs => $composableBuilder(
      column: $table.timeMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<String> get chosen =>
      $composableBuilder(column: $table.chosen, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get timeMs =>
      $composableBuilder(column: $table.timeMs, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$AttemptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttemptsTable,
    Attempt,
    $$AttemptsTableFilterComposer,
    $$AttemptsTableOrderingComposer,
    $$AttemptsTableAnnotationComposer,
    $$AttemptsTableCreateCompanionBuilder,
    $$AttemptsTableUpdateCompanionBuilder,
    (Attempt, BaseReferences<_$AppDatabase, $AttemptsTable, Attempt>),
    Attempt,
    PrefetchHooks Function()> {
  $$AttemptsTableTableManager(_$AppDatabase db, $AttemptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> questionId = const Value.absent(),
            Value<String> chosen = const Value.absent(),
            Value<bool> correct = const Value.absent(),
            Value<int> timeMs = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttemptsCompanion(
            id: id,
            sessionId: sessionId,
            questionId: questionId,
            chosen: chosen,
            correct: correct,
            timeMs: timeMs,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String questionId,
            required String chosen,
            required bool correct,
            required int timeMs,
            required DateTime createdAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttemptsCompanion.insert(
            id: id,
            sessionId: sessionId,
            questionId: questionId,
            chosen: chosen,
            correct: correct,
            timeMs: timeMs,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AttemptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttemptsTable,
    Attempt,
    $$AttemptsTableFilterComposer,
    $$AttemptsTableOrderingComposer,
    $$AttemptsTableAnnotationComposer,
    $$AttemptsTableCreateCompanionBuilder,
    $$AttemptsTableUpdateCompanionBuilder,
    (Attempt, BaseReferences<_$AppDatabase, $AttemptsTable, Attempt>),
    Attempt,
    PrefetchHooks Function()>;
typedef $$TopicStatsTableCreateCompanionBuilder = TopicStatsCompanion Function({
  required String topic,
  Value<int> attempts,
  Value<int> correct,
  Value<double> accuracy,
  Value<DateTime?> lastSeenAt,
  Value<int> rowid,
});
typedef $$TopicStatsTableUpdateCompanionBuilder = TopicStatsCompanion Function({
  Value<String> topic,
  Value<int> attempts,
  Value<int> correct,
  Value<double> accuracy,
  Value<DateTime?> lastSeenAt,
  Value<int> rowid,
});

class $$TopicStatsTableFilterComposer
    extends Composer<_$AppDatabase, $TopicStatsTable> {
  $$TopicStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => ColumnFilters(column));
}

class $$TopicStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicStatsTable> {
  $$TopicStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => ColumnOrderings(column));
}

class $$TopicStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicStatsTable> {
  $$TopicStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => column);
}

class $$TopicStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TopicStatsTable,
    TopicStat,
    $$TopicStatsTableFilterComposer,
    $$TopicStatsTableOrderingComposer,
    $$TopicStatsTableAnnotationComposer,
    $$TopicStatsTableCreateCompanionBuilder,
    $$TopicStatsTableUpdateCompanionBuilder,
    (TopicStat, BaseReferences<_$AppDatabase, $TopicStatsTable, TopicStat>),
    TopicStat,
    PrefetchHooks Function()> {
  $$TopicStatsTableTableManager(_$AppDatabase db, $TopicStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> topic = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int> correct = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TopicStatsCompanion(
            topic: topic,
            attempts: attempts,
            correct: correct,
            accuracy: accuracy,
            lastSeenAt: lastSeenAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String topic,
            Value<int> attempts = const Value.absent(),
            Value<int> correct = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TopicStatsCompanion.insert(
            topic: topic,
            attempts: attempts,
            correct: correct,
            accuracy: accuracy,
            lastSeenAt: lastSeenAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TopicStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TopicStatsTable,
    TopicStat,
    $$TopicStatsTableFilterComposer,
    $$TopicStatsTableOrderingComposer,
    $$TopicStatsTableAnnotationComposer,
    $$TopicStatsTableCreateCompanionBuilder,
    $$TopicStatsTableUpdateCompanionBuilder,
    (TopicStat, BaseReferences<_$AppDatabase, $TopicStatsTable, TopicStat>),
    TopicStat,
    PrefetchHooks Function()>;
typedef $$EntitlementsTableCreateCompanionBuilder = EntitlementsCompanion
    Function({
  required String plan,
  required DateTime startAt,
  required DateTime endAt,
  required String source,
  Value<bool> active,
  Value<int> rowid,
});
typedef $$EntitlementsTableUpdateCompanionBuilder = EntitlementsCompanion
    Function({
  Value<String> plan,
  Value<DateTime> startAt,
  Value<DateTime> endAt,
  Value<String> source,
  Value<bool> active,
  Value<int> rowid,
});

class $$EntitlementsTableFilterComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));
}

class $$EntitlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));
}

class $$EntitlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$EntitlementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntitlementsTable,
    Entitlement,
    $$EntitlementsTableFilterComposer,
    $$EntitlementsTableOrderingComposer,
    $$EntitlementsTableAnnotationComposer,
    $$EntitlementsTableCreateCompanionBuilder,
    $$EntitlementsTableUpdateCompanionBuilder,
    (
      Entitlement,
      BaseReferences<_$AppDatabase, $EntitlementsTable, Entitlement>
    ),
    Entitlement,
    PrefetchHooks Function()> {
  $$EntitlementsTableTableManager(_$AppDatabase db, $EntitlementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> plan = const Value.absent(),
            Value<DateTime> startAt = const Value.absent(),
            Value<DateTime> endAt = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntitlementsCompanion(
            plan: plan,
            startAt: startAt,
            endAt: endAt,
            source: source,
            active: active,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String plan,
            required DateTime startAt,
            required DateTime endAt,
            required String source,
            Value<bool> active = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntitlementsCompanion.insert(
            plan: plan,
            startAt: startAt,
            endAt: endAt,
            source: source,
            active: active,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EntitlementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntitlementsTable,
    Entitlement,
    $$EntitlementsTableFilterComposer,
    $$EntitlementsTableOrderingComposer,
    $$EntitlementsTableAnnotationComposer,
    $$EntitlementsTableCreateCompanionBuilder,
    $$EntitlementsTableUpdateCompanionBuilder,
    (
      Entitlement,
      BaseReferences<_$AppDatabase, $EntitlementsTable, Entitlement>
    ),
    Entitlement,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String operation,
  required String entity,
  required String payload,
  Value<int> retryCount,
  required DateTime createdAt,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> operation,
  Value<String> entity,
  Value<String> payload,
  Value<int> retryCount,
  Value<DateTime> createdAt,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> entity = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            operation: operation,
            entity: entity,
            payload: payload,
            retryCount: retryCount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String operation,
            required String entity,
            required String payload,
            Value<int> retryCount = const Value.absent(),
            required DateTime createdAt,
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            operation: operation,
            entity: entity,
            payload: payload,
            retryCount: retryCount,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PacksTableTableManager get packs =>
      $$PacksTableTableManager(_db, _db.packs);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$TopicStatsTableTableManager get topicStats =>
      $$TopicStatsTableTableManager(_db, _db.topicStats);
  $$EntitlementsTableTableManager get entitlements =>
      $$EntitlementsTableTableManager(_db, _db.entitlements);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
