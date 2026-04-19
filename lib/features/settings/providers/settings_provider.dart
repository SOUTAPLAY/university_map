import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme setting: 'system', 'light', 'dark'
final themeSettingProvider = StateProvider<String>((ref) => 'system');
