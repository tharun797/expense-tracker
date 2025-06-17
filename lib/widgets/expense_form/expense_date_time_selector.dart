// lib/widgets/expense_form/expense_date_time_selector.dart
import 'package:expense_tracker/widgets/common/date_selector.dart';
import 'package:expense_tracker/widgets/common/time_selector.dart';
import 'package:flutter/material.dart';

class ExpenseDateTimeSelector extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Function(DateTime) onDateChanged;
  final Function(TimeOfDay) onTimeChanged;

  const ExpenseDateTimeSelector({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DateSelector(
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
          style: DateSelectorStyle.card,
          label: 'Date',
          icon: Icons.calendar_today,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 8),
        TimeSelector(
          selectedTime: selectedTime,
          onTimeChanged: onTimeChanged,
          label: 'Time',
          icon: Icons.access_time,
        ),
      ],
    );
  }
}
