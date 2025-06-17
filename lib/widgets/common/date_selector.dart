// lib/widgets/common/date_selector.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateSelectorStyle {
  card, // For expense form (card with list tile)
  container, // For dashboard (container with button)
}

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final DateSelectorStyle style;
  final String? label;
  final IconData? icon;
  final String? buttonText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.style = DateSelectorStyle.card,
    this.label,
    this.icon,
    this.buttonText,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case DateSelectorStyle.card:
        return _buildCardStyle(context);
      case DateSelectorStyle.container:
        return _buildContainerStyle(context);
    }
  }

  Widget _buildCardStyle(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon ?? Icons.calendar_today),
        title: Text(label ?? 'Date'),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildContainerStyle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${label ?? 'Date'}: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text(buttonText ?? 'Change Date'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }
}
