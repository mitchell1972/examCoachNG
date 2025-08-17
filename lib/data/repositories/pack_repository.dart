import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/dto/pack_dto.dart';
import '../db/database.dart';
import '../../domain/entities/pack.dart';
import '../../domain/entities/question.dart';
import '../../core/utils/constants.dart';

class PackRepository {
  final ApiClient _apiClient;
  final AppDatabase _database;
  final SharedPreferences _prefs;

  PackRepository(this._apiClient, this._database, this._prefs);

  Future<List<PackManifestItem>> getPackManifest({
    String? subject,
    int? sinceVersion,
  }) async {
    final queryParams = <String, dynamic>{};
    if (subject != null) queryParams['subject'] = subject;
    if (sinceVersion != null) queryParams['since_version'] = sinceVersion;

    final response = await _apiClient.get(
      ApiEndpoints.packsManifest,
      queryParameters: queryParams,
    );

    final manifestDto = PackManifestDto.fromJson(response.data);
    return manifestDto.packs.map((dto) => dto.toDomain()).toList();
  }

  Future<void> downloadAndInstallPack(String packId, {
    Function(double progress)? onProgress,
  }) async {
    try {
      // Download pack
      final response = await _apiClient.download(
        ApiEndpoints.packDownload(packId),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final packFile = File('${tempDir.path}/$packId.zip');
      await packFile.writeAsBytes(response.data);

      // Verify checksum if available
      final pack = await _database.getPackById(packId);
      if (pack != null) {
        // Verify pack integrity here if needed
      }

      // Extract and install pack
      await _extractAndInstallPack(packFile, packId);

      // Update pack installation timestamp
      await _database.insertPack(PacksCompanion(
        id: drift.Value(packId),
        installedAt: drift.Value(DateTime.now()),
      ));

      // Clean up temporary file
      await packFile.delete();

    } catch (e) {
      throw Exception('Failed to download pack: $e');
    }
  }

  Future<void> _extractAndInstallPack(File packFile, String packId) async {
    final bytes = await packFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find pack.json
    final packJsonFile = archive.findFile('pack.json');
    if (packJsonFile == null) {
      throw Exception('Invalid pack format: pack.json not found');
    }

    final packJsonContent = utf8.decode(packJsonFile.content as List<int>);
    final packData = json.decode(packJsonContent) as Map<String, dynamic>;
    final packDto = PackContentDto.fromJson(packData);

    // Insert pack metadata
    await _database.insertPack(PacksCompanion(
      id: drift.Value(packDto.id),
      subject: drift.Value(packDto.subject),
      topic: drift.Value(packDto.topic),
      version: drift.Value(packDto.version),
      sizeBytes: drift.Value(bytes.length),
      installedAt: drift.Value(DateTime.now()),
    ));

    // Insert questions
    final questionsData = packDto.items.map((item) => QuestionsCompanion(
      id: drift.Value(item.id),
      packId: drift.Value(packDto.id),
      stem: drift.Value(item.stem),
      a: drift.Value(item.options['A'] ?? ''),
      b: drift.Value(item.options['B'] ?? ''),
      c: drift.Value(item.options['C'] ?? ''),
      d: drift.Value(item.options['D'] ?? ''),
      correct: drift.Value(item.correct),
      explanation: drift.Value(item.explanation),
      difficulty: drift.Value(item.difficulty),
      syllabusNode: drift.Value(item.syllabusNode),
    )).toList();

    await _database.insertQuestions(questionsData);
  }

  Future<List<PackEntity>> getInstalledPacks() async {
    final packs = await _database.getAllPacks();
    return packs.map((pack) => PackEntity(
      id: pack.id,
      subject: pack.subject,
      topic: pack.topic,
      version: pack.version,
      sizeBytes: pack.sizeBytes,
      installedAt: pack.installedAt,
    )).toList();
  }

  Future<void> deletePack(String packId) async {
    await _database.deletePack(packId);
  }

  Future<List<QuestionEntity>> getQuestionsFromPack(String packId) async {
    final questions = await _database.getQuestionsByPack(packId);
    return questions.map((q) => QuestionEntity(
      id: q.id,
      packId: q.packId,
      stem: q.stem,
      options: {
        'A': q.a,
        'B': q.b,
        'C': q.c,
        'D': q.d,
      },
      correct: q.correct,
      explanation: q.explanation,
      difficulty: q.difficulty,
      syllabusNode: q.syllabusNode,
    )).toList();
  }

  Future<List<QuestionEntity>> getRandomQuestions({
    required String subject,
    String? topic,
    required int count,
    List<String>? excludeIds,
  }) async {
    final questions = await _database.getRandomQuestions(
      subject: subject,
      topic: topic,
      count: count,
      excludeIds: excludeIds,
    );
    
    return questions.map((q) => QuestionEntity(
      id: q.id,
      packId: q.packId,
      stem: q.stem,
      options: {
        'A': q.a,
        'B': q.b,
        'C': q.c,
        'D': q.d,
      },
      correct: q.correct,
      explanation: q.explanation,
      difficulty: q.difficulty,
      syllabusNode: q.syllabusNode,
    )).toList();
  }

  Future<DateTime?> getLastSyncTime() async {
    final timestamp = _prefs.getInt(StorageKeys.lastSyncTime);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> updateLastSyncTime() async {
    await _prefs.setInt(StorageKeys.lastSyncTime, DateTime.now().millisecondsSinceEpoch);
  }
}

final packRepositoryProvider = Provider<PackRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final database = ref.read(databaseProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  
  return PackRepository(apiClient, database, prefs);
});
