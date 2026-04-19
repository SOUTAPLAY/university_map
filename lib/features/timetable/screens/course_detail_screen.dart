import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/course.dart';
import '../../../core/models/time_slot.dart';
import '../../map/providers/map_provider.dart';
import '../providers/timetable_provider.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final Course? course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _instructorCtrl;
  late final TextEditingController _notesCtrl;
  int _dayOfWeek = 1;
  int _period = 1;
  String _roomId = 'A101';
  String _buildingId = 'A';
  String _color = '#1976D2';
  String _semester = '前期';
  bool _saving = false;

  static const _colorOptions = [
    '#1976D2',
    '#388E3C',
    '#F57C00',
    '#D32F2F',
    '#7B1FA2',
    '#0097A7',
    '#5D4037',
    '#455A64',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _instructorCtrl = TextEditingController(text: c?.instructor ?? '');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');
    if (c != null) {
      _dayOfWeek = c.dayOfWeek;
      _period = c.period;
      _roomId = c.roomId;
      _buildingId = c.buildingId;
      _color = c.color;
      _semester = c.semester;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instructorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final course = Course(
      id: widget.course?.id,
      name: _nameCtrl.text.trim(),
      instructor: _instructorCtrl.text.trim(),
      dayOfWeek: _dayOfWeek,
      period: _period,
      roomId: _roomId,
      buildingId: _buildingId,
      color: _color,
      semester: _semester,
      notes: _notesCtrl.text.trim(),
    );
    try {
      if (widget.course == null) {
        await ref.read(timetableNotifierProvider.notifier).addCourse(course);
      } else {
        await ref.read(timetableNotifierProvider.notifier).updateCourse(course);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.course == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('授業を削除'),
        content: Text('${widget.course!.name} を削除しますか？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('キャンセル')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('削除')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref
          .read(timetableNotifierProvider.notifier)
          .deleteCourse(widget.course!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final rooms = roomsAsync.value ?? [];
    final buildingsAsync = ref.watch(buildingsProvider);
    final buildings = buildingsAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? '授業を追加' : '授業を編集'),
        actions: [
          if (widget.course != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          if (widget.course != null)
            IconButton(
              icon: const Icon(Icons.location_on_outlined),
              tooltip: 'マップで表示',
              onPressed: () {
                ref.read(selectedBuildingProvider.notifier).state = _buildingId;
                context.go('/map');
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: '科目名', border: OutlineInputBorder()),
              validator: (v) =>
                  (v?.isNotEmpty ?? false) ? null : '科目名を入力してください',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructorCtrl,
              decoration: const InputDecoration(
                  labelText: '担当教員', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _dayOfWeek,
                    decoration: const InputDecoration(
                        labelText: '曜日', border: OutlineInputBorder()),
                    items: [
                      for (int i = 1; i <= 6; i++)
                        DropdownMenuItem(
                            value: i, child: Text(Course.dayName(i)))
                    ],
                    onChanged: (v) => setState(() => _dayOfWeek = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _period,
                    decoration: const InputDecoration(
                        labelText: '時限', border: OutlineInputBorder()),
                    items: [
                      for (final s in TimeSlot.meiseiSlots)
                        DropdownMenuItem(
                            value: s.period, child: Text('${s.period}限'))
                    ],
                    onChanged: (v) => setState(() => _period = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (buildings.isNotEmpty)
              DropdownButtonFormField<String>(
                value: buildings.any((b) => b.id == _buildingId)
                    ? _buildingId
                    : buildings.first.id,
                decoration: const InputDecoration(
                    labelText: '建物', border: OutlineInputBorder()),
                items: buildings
                    .map((b) => DropdownMenuItem(
                        value: b.id, child: Text('${b.id}館 (${b.name})')))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _buildingId = v!;
                    final firstRoom =
                        rooms.where((r) => r.buildingId == v).firstOrNull;
                    if (firstRoom != null) _roomId = firstRoom.id;
                  });
                },
              ),
            const SizedBox(height: 16),
            if (rooms.isNotEmpty)
              DropdownButtonFormField<String>(
                value: rooms.any((r) => r.id == _roomId) ? _roomId : null,
                decoration: const InputDecoration(
                    labelText: '教室', border: OutlineInputBorder()),
                items: rooms
                    .where((r) => r.buildingId == _buildingId)
                    .map((r) => DropdownMenuItem(
                        value: r.id,
                        child: Text('${r.name} (${r.typeLabel})')))
                    .toList(),
                onChanged: (v) => setState(() => _roomId = v!),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _semester,
              decoration: const InputDecoration(
                  labelText: '学期', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: '前期', child: Text('前期')),
                DropdownMenuItem(value: '後期', child: Text('後期')),
              ],
              onChanged: (v) => setState(() => _semester = v!),
            ),
            const SizedBox(height: 16),
            Text('カラー', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colorOptions.map((c) {
                final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _color == c
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'メモ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.course == null ? '追加する' : '保存する'),
            ),
          ],
        ),
      ),
    );
  }
}
