import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../api/dio_client.dart';
import '../db/database.dart';
import '../models/pack_model.dart';
import '../models/question_model.dart';

class PackRepository {
  final DioClient _dioClient = DioClient.instance;
  final AppDatabase _database = AppDatabase();
  
  Future<PackManifest> getPackManifest({
    required String subject,
    int? sinceVersion,
  }) async {
    try {
      Logger.info('Getting pack manifest for subject: $subject');
      
      final queryParams = <String, dynamic>{
        'subject': subject,
        if (sinceVersion != null) 'since_version': sinceVersion,
      };
      
      final response = await _dioClient.get(
        '${AppConstants.packsEndpoint}/manifest',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        Logger.info('Pack manifest retrieved successfully');
        
        return PackManifest.fromJson(data);
      } else {
        throw Exception('Failed to get pack manifest: ${response.statusMessage}');
      }
    } catch (e) {
      Logger.error('Error getting pack manifest', error: e);
      rethrow;
    }
  }
  
  Future<void> downloadAndInstallPack(PackModel pack) async {
    try {
      Logger.info('Downloading pack: ${pack.id}');
      
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final packsDir = Directory('${appDir.path}/packs');
      if (!await packsDir.exists()) {
        await packsDir.create(recursive: true);
      }
      
      final packFile = File('${packsDir.path}/${pack.id}.zip');
      
      // Download the pack
      await _dioClient.download(
        '${AppConstants.packsEndpoint}/${pack.id}',
        packFile.path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total * 100).toStringAsFixed(1);
            Logger.debug('Download progress: $progress%');
          }
        },
      );
      
      Logger.info('Pack downloaded, starting installation');
      
      // Verify checksum
      if (pack.checksum != null) {
        final bytes = await packFile.readAsBytes();
        final hash = sha256.convert(bytes).toString();
        
        if (hash != pack.checksum) {
          await packFile.delete();
          throw Exception('Pack checksum verification failed');
        }
      }
      
      // Extract and install pack
      await _installPack(packFile, pack);
      
      // Clean up zip file
      await packFile.delete();
      
      Logger.info('Pack installed successfully: ${pack.id}');
    } catch (e) {
      Logger.error('Error downloading/installing pack', error: e);
      rethrow;
    }
  }
  
  Future<void> _installPack(File packFile, PackModel pack) async {
    try {
      // Read and extract ZIP
      final bytes = await packFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // Find pack.json
      final packJsonFile = archive.files.firstWhere(
        (file) => file.name == 'pack.json',
        orElse: () => throw Exception('pack.json not found in ZIP'),
      );
      
      // Parse pack.json
      final packJsonContent = utf8.decode(packJsonFile.content as Uint8List);
      final packData = json.decode(packJsonContent) as Map<String, dynamic>;
      
      // Validate pack data
      if (packData['id'] != pack.id) {
        throw Exception('Pack ID mismatch');
      }
      
      // Begin database transaction
      await _database.transaction(() async {
        // Insert pack record
        await _database.insertPack(PacksCompanion.insert(
          id: pack.id,
          subject: pack.subject,
          topic: pack.topic,
          version: pack.version,
          sizeBytes: Value(pack.sizeBytes),
          installedAt: Value(DateTime.now()),
          checksum: Value(pack.checksum),
        ));
        
        // Insert questions
        final items = packData['items'] as List<dynamic>;
        final questions = items.map((item) {
          final questionMap = item as Map<String, dynamic>;
          return QuestionsCompanion.insert(
            id: questionMap['id'] as String,
            packId: pack.id,
            stem: questionMap['stem'] as String,
            a: questionMap['options']['A'] as String,
            b: questionMap['options']['B'] as String,
            c: questionMap['options']['C'] as String,
            d: questionMap['options']['D'] as String,
            correct: questionMap['correct'] as String,
            explanation: questionMap['explanation'] as String,
            difficulty: Value(questionMap['difficulty'] as int? ?? 2),
            syllabusNode: questionMap['syllabus_node'] as String,
          );
        }).toList();
        
        await _database.insertQuestions(questions);
      });
      
      Logger.info('Pack data inserted into database');
    } catch (e) {
      Logger.error('Error installing pack', error: e);
      rethrow;
    }
  }
  
  Future<List<Pack>> getInstalledPacks() async {
    try {
      return await _database.getAllPacks();
    } catch (e) {
      Logger.error('Error getting installed packs', error: e);
      rethrow;
    }
  }
  
  Future<List<Pack>> getPacksBySubject(String subject) async {
    try {
      return await _database.getPacksBySubject(subject);
    } catch (e) {
      Logger.error('Error getting packs by subject', error: e);
      rethrow;
    }
  }
  
  Future<List<Question>> getQuestionsByPack(String packId) async {
    try {
      return await _database.getQuestionsByPack(packId);
    } catch (e) {
      Logger.error('Error getting questions by pack', error: e);
      rethrow;
    }
  }
  
  Future<List<Question>> getQuestionsByTopic(String subject, String topic) async {
    try {
      return await _database.getQuestionsByTopic(subject, topic);
    } catch (e) {
      Logger.error('Error getting questions by topic', error: e);
      rethrow;
    }
  }
  
  Future<void> deletePack(String packId) async {
    try {
      Logger.info('Deleting pack: $packId');
      
      await _database.transaction(() async {
        await _database.deleteQuestionsByPack(packId);
        await _database.deletePack(packId);
      });
      
      Logger.info('Pack deleted successfully');
    } catch (e) {
      Logger.error('Error deleting pack', error: e);
      rethrow;
    }
  }
  
  Future<bool> isPackUpdateAvailable(String packId, int currentVersion) async {
    try {
      final pack = await _database.getAllPacks()
          .then((packs) => packs.firstWhere((p) => p.id == packId));
      
      final manifest = await getPackManifest(
        subject: pack.subject,
        sinceVersion: currentVersion,
      );
      
      return manifest.packs.any((p) => p.id == packId && p.version > currentVersion);
    } catch (e) {
      Logger.error('Error checking pack update', error: e);
      return false;
    }
  }
}

class PackManifest {
  final List<PackModel> packs;
  
  PackManifest({required this.packs});
  
  factory PackManifest.fromJson(Map<String, dynamic> json) {
    final packsJson = json['packs'] as List<dynamic>;
    final packs = packsJson
        .map((pack) => PackModel.fromJson(pack as Map<String, dynamic>))
        .toList();
    
    return PackManifest(packs: packs);
  }
}
