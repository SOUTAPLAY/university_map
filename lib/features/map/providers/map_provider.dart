import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/building.dart';
import '../../../core/models/room.dart';

final buildingsProvider = FutureProvider<List<Building>>((ref) async {
  final data = await rootBundle.loadString('assets/data/buildings.json');
  final list = jsonDecode(data) as List;
  return list.map((e) => Building.fromJson(e as Map<String, dynamic>)).toList();
});

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final data = await rootBundle.loadString('assets/data/rooms.json');
  final list = jsonDecode(data) as List;
  return list.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
});

final selectedBuildingProvider = StateProvider<String?>((ref) => null);

final roomsByBuildingProvider =
    Provider.family<List<Room>, String>((ref, buildingId) {
  return ref.watch(roomsProvider).maybeWhen(
        data: (rooms) =>
            rooms.where((r) => r.buildingId == buildingId).toList(),
        orElse: () => [],
      );
});
