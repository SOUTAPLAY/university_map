import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/campus_map_webview.dart';
import '../widgets/timetable_overlay.dart';
import '../widgets/next_class_banner.dart';
import '../providers/map_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildingsAsync = ref.watch(buildingsProvider);
    final selectedBuilding = ref.watch(selectedBuildingProvider);

    return Scaffold(
      body: Stack(
        children: [
          buildingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
            data: (buildings) => CampusMapWebView(
              buildings: buildings,
              highlightedBuildingId: selectedBuilding,
              onBuildingTapped: (id) {
                ref.read(selectedBuildingProvider.notifier).state = id;
              },
            ),
          ),
          const NextClassBanner(),
          const TimetableOverlay(),
          // Top-right navigation buttons
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconCard(
                      icon: Icons.calendar_today,
                      tooltip: '時間割',
                      onTap: () => context.push('/timetable'),
                    ),
                    const SizedBox(height: 8),
                    _IconCard(
                      icon: Icons.settings,
                      tooltip: '設定',
                      onTap: () => context.push('/settings'),
                    ),
                    const SizedBox(height: 8),
                    _IconCard(
                      icon: Icons.home,
                      tooltip: '全体表示',
                      onTap: () {
                        ref.read(selectedBuildingProvider.notifier).state =
                            null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCard extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconCard({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, size: 22),
          ),
        ),
      ),
    );
  }
}
