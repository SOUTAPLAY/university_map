import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/timetable_grid.dart';
import '../providers/timetable_provider.dart';
import '../screens/course_detail_screen.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '授業を追加',
            onPressed: () => _showAddCourse(context),
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (courses) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                '授業をタップすると詳細・マップ表示ができます',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: TimetableGrid(
                courses: courses,
                onCourseTap: (course) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailScreen(course: course),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCourse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CourseDetailScreen(course: null),
      ),
    );
  }
}
