import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/api/api_client.dart';
import '../../../data/api/dto/session_dto.dart';
import '../../../core/utils/constants.dart';

final catalogProvider = AsyncNotifierProvider<CatalogNotifier, CatalogState>(() {
  return CatalogNotifier();
});

final subjectsProvider = FutureProvider<List<SubjectItem>>((ref) async {
  return await ref.read(catalogProvider.notifier).getSubjects();
});

final syllabusProvider = FutureProvider.family<List<SyllabusNode>, String>((ref, subject) async {
  return await ref.read(catalogProvider.notifier).getSyllabus(subject);
});

class CatalogNotifier extends AsyncNotifier<CatalogState> {
  @override
  Future<CatalogState> build() async {
    return const CatalogState();
  }

  Future<List<SubjectItem>> getSubjects() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiEndpoints.subjects);
      
      final subjectsData = response.data as List<dynamic>;
      return subjectsData.map((data) {
        final dto = SubjectDto.fromJson(data as Map<String, dynamic>);
        return SubjectItem(
          id: dto.id,
          name: dto.name,
          isSelected: false,
        );
      }).toList();
    } catch (e) {
      // Return default subjects if API fails
      return Subjects.subjectNames.entries.map((entry) {
        return SubjectItem(
          id: entry.key,
          name: entry.value,
          isSelected: false,
        );
      }).toList();
    }
  }

  Future<List<SyllabusNode>> getSyllabus(String subject) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiEndpoints.syllabus(subject));
      
      final syllabusData = response.data as List<dynamic>;
      return syllabusData.map((data) {
        final dto = SyllabusNodeDto.fromJson(data as Map<String, dynamic>);
        return SyllabusNode(
          nodeId: dto.nodeId,
          name: dto.name,
          parentNodeId: dto.parentNodeId,
          objectives: dto.objectives ?? [],
        );
      }).toList();
    } catch (e) {
      // Return empty list if API fails
      return [];
    }
  }
}

class CatalogState {
  const CatalogState();
}

class SubjectItem {
  final String id;
  final String name;
  final bool isSelected;

  const SubjectItem({
    required this.id,
    required this.name,
    required this.isSelected,
  });

  SubjectItem copyWith({
    String? id,
    String? name,
    bool? isSelected,
  }) {
    return SubjectItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class SyllabusNode {
  final String nodeId;
  final String name;
  final String? parentNodeId;
  final List<String> objectives;

  const SyllabusNode({
    required this.nodeId,
    required this.name,
    this.parentNodeId,
    required this.objectives,
  });
}
