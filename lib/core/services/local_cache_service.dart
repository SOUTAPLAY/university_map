import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/course.dart';

class LocalCacheService {
  static const _coursesBox = 'courses';
  static const _settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.openBox(_coursesBox);
    await Hive.openBox(_settingsBox);
  }

  // Courses
  List<Course> getCachedCourses() {
    final box = Hive.box(_coursesBox);
    final result = <Course>[];
    for (final v in box.values) {
      try {
        result.add(Course.fromJson(jsonDecode(v as String)));
      } catch (_) {
        // Skip corrupted cache entries
      }
    }
    return result;
  }

  Future<void> cacheCourses(List<Course> courses) async {
    final box = Hive.box(_coursesBox);
    await box.clear();
    for (final c in courses) {
      await box.put(c.id, jsonEncode(c.toJson()));
    }
  }

  Future<void> cacheCourse(Course course) async {
    final box = Hive.box(_coursesBox);
    await box.put(course.id, jsonEncode(course.toJson()));
  }

  Future<void> removeCachedCourse(String courseId) async {
    await Hive.box(_coursesBox).delete(courseId);
  }

  // Settings
  T? getSetting<T>(String key) {
    return Hive.box(_settingsBox).get(key) as T?;
  }

  Future<void> setSetting(String key, dynamic value) async {
    await Hive.box(_settingsBox).put(key, value);
  }
}
