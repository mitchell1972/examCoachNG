class Pack {
  final String id;
  final String subject;
  final String topic;
  final int version;
  final int sizeBytes;
  final String? checksum;
  final DateTime? installedAt;

  const Pack({
    required this.id,
    required this.subject,
    required this.topic,
    required this.version,
    this.sizeBytes = 0,
    this.checksum,
    this.installedAt,
  });

  Pack copyWith({
    String? id,
    String? subject,
    String? topic,
    int? version,
    int? sizeBytes,
    String? checksum,
    DateTime? installedAt,
  }) {
    return Pack(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      version: version ?? this.version,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      checksum: checksum ?? this.checksum,
      installedAt: installedAt ?? this.installedAt,
    );
  }

  bool get isInstalled => installedAt != null;
  
  double get sizeMB => sizeBytes / (1024 * 1024);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Pack &&
      other.id == id &&
      other.subject == subject &&
      other.topic == topic &&
      other.version == version &&
      other.sizeBytes == sizeBytes &&
      other.checksum == checksum &&
      other.installedAt == installedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      subject.hashCode ^
      topic.hashCode ^
      version.hashCode ^
      sizeBytes.hashCode ^
      checksum.hashCode ^
      installedAt.hashCode;
  }
}
