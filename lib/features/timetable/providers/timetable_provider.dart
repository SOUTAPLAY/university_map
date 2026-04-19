import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/course.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/local_cache_service.dart';
import '../../auth/providers/auth_provider.dart';

final localCacheProvider =
    Provider<LocalCacheService>((_) => LocalCacheService());

final coursesProvider = StreamProvider<List<Course>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.read(firestoreServiceProvider).watchCourses(user.uid);
});

final timetableNotifierProvider =
    AsyncNotifierProvider<TimetableNotifier, List<Course>>(
        TimetableNotifier.new);

class TimetableNotifier extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return ref.read(localCacheProvider).getCachedCourses();
    }
    try {
      final courses =
          await ref.read(firestoreServiceProvider).getCourses(user.uid);
      await ref.read(localCacheProvider).cacheCourses(courses);
      return courses;
    } catch (_) {
      return ref.read(localCacheProvider).getCachedCourses();
    }
  }

  Future<void> addCourse(Course course) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref.read(firestoreServiceProvider).saveCourse(user.uid, course);
    }
    await ref.read(localCacheProvider).cacheCourse(course);
    ref.invalidateSelf();
  }

  Future<void> updateCourse(Course course) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref.read(firestoreServiceProvider).saveCourse(user.uid, course);
    }
    await ref.read(localCacheProvider).cacheCourse(course);
    ref.invalidateSelf();
  }

  Future<void> deleteCourse(String courseId) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref
          .read(firestoreServiceProvider)
          .deleteCourse(user.uid, courseId);
    }
    await ref.read(localCacheProvider).removeCachedCourse(courseId);
    ref.invalidateSelf();
  }
}

final selectedCourseProvider = StateProvider<Course?>((ref) => null);

final todayCourseProvider = Provider<List<Course>>((ref) {
  final courses = ref.watch(coursesProvider).value ?? [];
  final now = DateTime.now();
  final dayOfWeek = now.weekday; // 1=Mon...6=Sat
  return courses
      .where((c) => c.dayOfWeek == dayOfWeek)
      .toList()
    ..sort((a, b) => a.period.compareTo(b.period));
});
