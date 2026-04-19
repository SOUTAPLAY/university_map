class TimeSlot {
  final int period;
  final String startTime;
  final String endTime;

  const TimeSlot({
    required this.period,
    required this.startTime,
    required this.endTime,
  });

  static const List<TimeSlot> meiseiSlots = [
    TimeSlot(period: 1, startTime: '08:50', endTime: '10:20'),
    TimeSlot(period: 2, startTime: '10:30', endTime: '12:00'),
    TimeSlot(period: 3, startTime: '13:00', endTime: '14:30'),
    TimeSlot(period: 4, startTime: '14:40', endTime: '16:10'),
    TimeSlot(period: 5, startTime: '16:20', endTime: '17:50'),
    TimeSlot(period: 6, startTime: '18:00', endTime: '19:30'),
  ];

  static TimeSlot? forPeriod(int period) {
    try {
      return meiseiSlots.firstWhere((s) => s.period == period);
    } catch (_) {
      return null;
    }
  }

  String get label => '$period限 ($startTime〜$endTime)';
}
