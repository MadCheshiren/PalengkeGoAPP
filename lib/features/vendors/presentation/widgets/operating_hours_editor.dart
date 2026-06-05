import 'package:flutter/material.dart';
import 'package:palengkego/features/vendors/domain/day_schedule.dart';

class OperatingHoursEditor extends StatelessWidget {
  final List<DaySchedule> schedules;
  final VoidCallback onApplyMondayToAll;
  final VoidCallback onChanged;

  const OperatingHoursEditor({
    super.key,
    required this.schedules,
    required this.onApplyMondayToAll,
    required this.onChanged,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(BuildContext context, int index, bool isOpenTime) async {
    final schedule = schedules[index];
    final initialTime = isOpenTime ? schedule.openTime : schedule.closeTime;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B372B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0B372B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isOpenTime) {
        schedule.openTime = picked;
      } else {
        schedule.closeTime = picked;
      }
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.schedule_rounded, color: Color(0xFF0B372B), size: 20),
                SizedBox(width: 8),
                Text(
                  'Operating Hours',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF0B372B)),
              label: const Text(
                'Apply Mon to All',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B372B),
                ),
              ),
              onPressed: onApplyMondayToAll,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(schedules.length, (index) {
          final schedule = schedules[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    schedule.name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: schedule.isOpen
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _selectTime(context, index, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  _formatTime(schedule.openTime),
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0B372B),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('-', style: TextStyle(color: Color(0xFF64748B))),
                            ),
                            InkWell(
                              onTap: () => _selectTime(context, index, false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  _formatTime(schedule.closeTime),
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0B372B),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Closed',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                ),
                Switch(
                  value: schedule.isOpen,
                  onChanged: (val) {
                    schedule.isOpen = val;
                    onChanged();
                  },
                  activeThumbColor: const Color(0xFF0B372B),
                  activeTrackColor: const Color(0xFF0B372B).withValues(alpha: 0.3),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
