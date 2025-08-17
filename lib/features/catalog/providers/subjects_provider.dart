import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/utils/constants.dart';
import '../../../data/repositories/pack_repository.dart';

final selectedSubjectsProvider = StateNotifierProvider<SelectedSubjectsNotifier, List<String>>((ref) {
  return SelectedSubjectsNotifier();
});

final availableSubjectsProvider = Provider<List<SubjectInfo>>((ref) {
  return AppConstants.availableSubjects.map((code) => SubjectInfo(
    code: code,
    name: AppConstants.subjectNames[code] ?? code,
  )).toList();
});

final subjectPacksProvider = FutureProvider.family<List<dynamic>, String>((ref, subject) async {
  final packRepository = ref.read(packRepositoryProvider);
  return await packRepository.getInstalledPacksBySubject(subject);
});

class SelectedSubjectsNotifier extends StateNotifier<List<String>> {
  SelectedSubjectsNotifier() : super([]);
  
  void toggleSubject(String subject) {
    if (state.contains(subject)) {
      state = state.where((s) => s != subject).toList();
    } else {
      if (state.length < 4) {
        state = [...state, subject];
      }
    }
  }
  
  void setSubjects(List<String> subjects) {
    state = subjects.take(4).toList();
  }
  
  void clearSubjects() {
    state = [];
  }
  
  bool isSelected(String subject) => state.contains(subject);
  
  bool get hasSelection => state.isNotEmpty;
  
  bool get isMaxSelected => state.length >= 4;
}

class SubjectInfo {
  final String code;
  final String name;
  
  const SubjectInfo({
    required this.code,
    required this.name,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubjectInfo && other.code == code;
  }
  
  @override
  int get hashCode => code.hashCode;
  
  @override
  String toString() => 'SubjectInfo(code: $code, name: $name)';
}

// Provider for subject statistics
final subjectStatsProvider = FutureProvider.family<SubjectStats, String>((ref, subject) async {
  // This would typically fetch from database
  // For now, return empty stats
  return SubjectStats(
    subject: subject,
    totalQuestions: 0,
    packCount: 0,
    lastStudied: null,
    averageScore: 0.0,
  );
});

class SubjectStats {
  final String subject;
  final int totalQuestions;
  final int packCount;
  final DateTime? lastStudied;
  final double averageScore;
  
  const SubjectStats({
    required this.subject,
    required this.totalQuestions,
    required this.packCount,
    this.lastStudied,
    required this.averageScore,
  });
}
