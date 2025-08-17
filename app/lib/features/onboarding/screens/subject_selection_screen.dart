import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/storage_service.dart';

class SubjectSelectionScreen extends HookConsumerWidget {
  const SubjectSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    
    final selectedSubjects = ValueNotifier<Set<String>>({});
    final storageService = StorageService.instance;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Choose Your Subjects'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Select the subjects you want to practice',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'You can always change this later in settings',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Required Subject (Use of English)
                  _buildRequiredSubjectCard(context),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Choose 3 additional subjects',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subject Grid
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: selectedSubjects,
                    builder: (context, selected, child) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _getSelectableSubjects().length,
                        itemBuilder: (context, index) {
                          final subject = _getSelectableSubjects()[index];
                          final isSelected = selected.contains(subject);
                          final canSelect = selected.length < 3 || isSelected;
                          
                          return _buildSubjectCard(
                            context,
                            subject: subject,
                            isSelected: isSelected,
                            canSelect: canSelect,
                            onTap: () {
                              final newSelected = Set<String>.from(selected);
                              if (isSelected) {
                                newSelected.remove(subject);
                              } else if (newSelected.length < 3) {
                                newSelected.add(subject);
                              }
                              selectedSubjects.value = newSelected;
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom section with selection count and continue button
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                ValueListenableBuilder<Set<String>>(
                  valueListenable: selectedSubjects,
                  builder: (context, selected, child) {
                    return Text(
                      '${selected.length}/3 subjects selected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                ValueListenableBuilder<Set<String>>(
                  valueListenable: selectedSubjects,
                  builder: (context, selected, child) {
                    return CustomButton(
                      onPressed: (selected.length == 3 && !authState.isLoading) 
                        ? () async {
                          // Include Use of English (required)
                          final allSubjects = ['ENG', ...selected].toList();
                          
                          await authNotifier.updateUserSubjects(allSubjects);
                          await storageService.setSelectedSubjects(allSubjects);
                          await storageService.setOnboardingComplete(true);
                          
                          if (!authState.isLoading && authState.error == null) {
                            context.go('/home');
                          }
                        }
                        : null,
                      child: authState.isLoading 
                        ? const LoadingWidget(size: 20)
                        : const Text('Continue'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredSubjectCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use of English',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Required for all students',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'REQUIRED',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context, {
    required String subject,
    required bool isSelected,
    required bool canSelect,
    required VoidCallback onTap,
  }) {
    final subjectName = AppConstants.subjectNames[subject] ?? subject;
    
    return GestureDetector(
      onTap: canSelect ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppTheme.primaryColor.withOpacity(0.1)
            : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? AppTheme.primaryColor
              : canSelect 
                ? Colors.grey.shade300
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppTheme.primaryColor
                  : canSelect
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check : _getSubjectIcon(subject),
                color: isSelected 
                  ? Colors.white
                  : canSelect
                    ? AppTheme.primaryColor
                    : Colors.grey.shade500,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subjectName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: canSelect 
                  ? AppTheme.textPrimary
                  : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getSelectableSubjects() {
    // Return all subjects except Use of English (which is required)
    return AppConstants.availableSubjects
        .where((subject) => subject != 'ENG')
        .toList();
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'MAT':
        return Icons.calculate;
      case 'PHY':
        return Icons.science;
      case 'CHE':
        return Icons.biotech;
      case 'BIO':
        return Icons.local_florist;
      case 'ECO':
        return Icons.trending_up;
      case 'GOV':
        return Icons.account_balance;
      case 'HIS':
        return Icons.history_edu;
      case 'GEO':
        return Icons.public;
      case 'LIT':
        return Icons.menu_book;
      default:
        return Icons.book;
    }
  }
}
