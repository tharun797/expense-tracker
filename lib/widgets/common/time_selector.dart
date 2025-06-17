// lib/widgets/common/time_selector.dart
import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeChanged;
  final String? label;
  final IconData? icon;

  const TimeSelector({
    super.key,
    required this.selectedTime,
    required this.onTimeChanged,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon ?? Icons.access_time),
        title: Text(label ?? 'Time'),
        subtitle: Text(selectedTime.format(context)),
        onTap: () => _selectTime(context),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }
}
