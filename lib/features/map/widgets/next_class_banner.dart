import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/time_slot.dart';
import '../../timetable/providers/timetable_provider.dart';

class NextClassBanner extends ConsumerWidget {
  const NextClassBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayCourses = ref.watch(todayCourseProvider);
    if (todayCourses.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    // Find next upcoming class
    for (final course in todayCourses) {
      final slot = TimeSlot.forPeriod(course.period);
      if (slot == null) continue;
      try {
        final parts = slot.startTime.split(':');
        if (parts.length != 2) continue;
        final slotMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        if (slotMinutes > nowMinutes) {
          final diff = slotMinutes - nowMinutes;
          final diffText =
              diff >= 60 ? '${diff ~/ 60}時間${diff % 60}分後' : '$diff分後';
          return Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('次の授業: ${course.name}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                              '$diffText | ${slot.startTime}〜 | ${course.roomId}',
                              style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } catch (_) {
        // Skip courses with invalid time format
        continue;
      }
    }
    return const SizedBox.shrink();
  }
}
