import 'package:flutter/material.dart';
import '../../../core/models/course.dart';
import '../../../core/models/time_slot.dart';

class TimetableGrid extends StatelessWidget {
  final List<Course> courses;
  final void Function(Course)? onCourseTap;

  const TimetableGrid({
    super.key,
    required this.courses,
    this.onCourseTap,
  });

  static const _days = ['月', '火', '水', '木', '金', '土'];
  static const _periods = [1, 2, 3, 4, 5, 6];

  Course? _getCourse(int day, int period) {
    try {
      return courses.firstWhere(
        (c) => c.dayOfWeek == day && c.period == period,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellWidth = (MediaQuery.of(context).size.width - 48) / 6;
    const headerH = 28.0;
    const cellH = 72.0;
    const periodW = 40.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                SizedBox(width: periodW),
                ..._days.asMap().entries.map((e) {
                  final today = DateTime.now().weekday == e.key + 1;
                  return Container(
                    width: cellWidth,
                    height: headerH,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: today
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceVariant,
                      border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: Text(e.value,
                        style: TextStyle(
                          fontWeight:
                              today ? FontWeight.bold : FontWeight.normal,
                          color: today ? theme.colorScheme.primary : null,
                          fontSize: 12,
                        )),
                  );
                }),
              ],
            ),
            // Period rows
            ..._periods.map((period) {
              final slot = TimeSlot.forPeriod(period);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period label
                  Container(
                    width: periodW,
                    height: cellH,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$period',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.colorScheme.primary,
                            )),
                        if (slot != null)
                          Text(slot.startTime,
                              style: const TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                  ..._days.asMap().entries.map((e) {
                    final course = _getCourse(e.key + 1, period);
                    return GestureDetector(
                      onTap: course != null
                          ? () => onCourseTap?.call(course)
                          : null,
                      child: Container(
                        width: cellWidth,
                        height: cellH,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: course != null
                              ? _parseColor(course.color).withOpacity(0.85)
                              : null,
                          border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: course != null
                            ? Padding(
                                padding: const EdgeInsets.all(3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      course.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      course.roomId,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 8),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
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
