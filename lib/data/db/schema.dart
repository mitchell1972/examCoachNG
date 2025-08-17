import 'package:drift/drift.dart';

class Packs extends Table {
  TextColumn get id => text()();
  TextColumn get subject => text()();
  TextColumn get topic => text()();
  IntColumn get version => integer()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get installedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Questions extends Table {
  TextColumn get id => text()();
  TextColumn get packId => text()();
  TextColumn get stem => text()();
  TextColumn get a => text()();
  TextColumn get b => text()();
  TextColumn get c => text()();
  TextColumn get d => text()();
  TextColumn get correct => text()();
  TextColumn get explanation => text()();
  IntColumn get difficulty => integer().withDefault(const Constant(2))();
  TextColumn get syllabusNode => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get mode => text()(); // practice | mock
  TextColumn get subject => text()();
  TextColumn get topic => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get score => integer().nullable()();
  TextColumn get metaJson => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Attempts extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get questionId => text()();
  TextColumn get chosen => text()();
  BoolColumn get correct => boolean()();
  IntColumn get timeMs => integer()();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class TopicStats extends Table {
  TextColumn get topic => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get correct => integer().withDefault(const Constant(0))();
  RealColumn get accuracy => real().withDefault(const Constant(0))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {topic};
}

class Entitlements extends Table {
  TextColumn get plan => text()();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  TextColumn get source => text()(); // paystack | flutterwave | apple_iap
  
  @override
  Set<Column> get primaryKey => {plan, startAt};
}
