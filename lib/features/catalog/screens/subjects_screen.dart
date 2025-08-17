import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_provider.dart';
import '../widgets/subject_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_widget.dart';
import '../../../core/utils/constants.dart';

class SubjectsScreen extends HookConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSubjects = useState<Set<String>>({Subjects.english});
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Subjects'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your exam subjects',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose Use of English and 3 other subjects you want to practice.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedSubjects.value.length}/4 selected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: subjectsAsync.when(
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stackTrace) => AppErrorWidget(
                error: error.toString(),
                onRetry: () => ref.refresh(subjectsProvider),
              ),
              data: (subjects) {
                final coreSubjects = subjects.where((s) => Subjects.coreSubjects.contains(s.id)).toList();
                final electiveSubjects = subjects.where((s) => Subjects.electiveSubjects.contains(s.id)).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Core subjects
                      Text(
                        'Core Subject (Required)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...coreSubjects.map((subject) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SubjectCard(
                          subject: subject,
                          isSelected: selectedSubjects.value.contains(subject.id),
                          isRequired: true,
                          onTap: null, // Core subjects are required
                        ),
                      )),
                      const SizedBox(height: 24),

                      // Elective subjects
                      Text(
                        'Choose 3 Other Subjects',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...electiveSubjects.map((subject) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SubjectCard(
                          subject: subject,
                          isSelected: selectedSubjects.value.contains(subject.id),
                          isRequired: false,
                          onTap: () {
                            final newSelection = Set<String>.from(selectedSubjects.value);
                            if (newSelection.contains(subject.id)) {
                              newSelection.remove(subject.id);
                            } else {
                              if (newSelection.length < 4) {
                                newSelection.add(subject.id);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You can only select 4 subjects maximum'),
                                  ),
                                );
                              }
                            }
                            selectedSubjects.value = newSelection;
                          },
                        ),
                      )),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Continue button
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  text: 'Continue',
                  isEnabled: selectedSubjects.value.length == 4,
                  onPressed: selectedSubjects.value.length == 4
                      ? () async {
                          await ref.read(authProvider.notifier)
                              .saveSelectedSubjects(selectedSubjects.value.toList());
                          if (context.mounted) {
                            context.go('/home');
                          }
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  'You can change your subjects later in settings',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
