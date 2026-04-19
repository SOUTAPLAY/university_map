import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/time_slot.dart';
import '../../timetable/providers/timetable_provider.dart';
import '../providers/map_provider.dart';

class TimetableOverlay extends ConsumerWidget {
  const TimetableOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final selectedCourse = ref.watch(selectedCourseProvider);

    return coursesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (courses) {
        if (courses.isEmpty) return const SizedBox.shrink();
        final today = DateTime.now().weekday;
        final todaysCourses =
            courses.where((c) => c.dayOfWeek == today).toList()
              ..sort((a, b) => a.period.compareTo(b.period));

        return DraggableScrollableSheet(
          initialChildSize: 0.25,
          minChildSize: 0.1,
          maxChildSize: 0.55,
          builder: (ctx, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 8),
                      Text('本日の時間割',
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
                Expanded(
                  child: todaysCourses.isEmpty
                      ? const Center(child: Text('本日の授業はありません'))
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: todaysCourses.length,
                          itemBuilder: (ctx, i) {
                            final c = todaysCourses[i];
                            final slot = TimeSlot.forPeriod(c.period);
                            final isSelected = selectedCourse?.id == c.id;
                            return Card(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : null,
                              child: ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  backgroundColor: _parseColor(c.color),
                                  child: Text('${c.period}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                title: Text(c.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                    '${slot?.startTime ?? ''} ${c.roomId}'),
                                trailing: isSelected
                                    ? const Icon(Icons.location_on,
                                        color: Colors.orange)
                                    : null,
                                onTap: () {
                                  ref
                                      .read(selectedCourseProvider.notifier)
                                      .state = isSelected ? null : c;
                                  ref
                                      .read(selectedBuildingProvider.notifier)
                                      .state =
                                      isSelected ? null : c.buildingId;
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}
