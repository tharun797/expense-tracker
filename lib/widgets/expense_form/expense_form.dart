// lib/widgets/expense_form/expense_form.dart
import 'package:expense_tracker/widgets/expense_form/expense_submit_button.dart';
import 'package:expense_tracker/widgets/expense_form/expense_text_field.dart';
import 'package:flutter/material.dart';
import '../../models/expense_model.dart';
import 'expense_date_time_selector.dart';

class ExpenseForm extends StatefulWidget {
  final ExpenseModel? expense;
  final Function(ExpenseModel) onSave;

  const ExpenseForm({super.key, this.expense, required this.onSave});

  @override
  ExpenseFormState createState() => ExpenseFormState();
}

class ExpenseFormState extends State<ExpenseForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.expense!.time);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ExpenseTextField(
              controller: _titleController,
              label: 'Title',
              icon: Icons.title,
              validator: _validateTitle,
            ),
            const SizedBox(height: 16),
            ExpenseTextField(
              controller: _amountController,
              label: 'Amount',
              icon: Icons.currency_rupee,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateAmount,
            ),
            const SizedBox(height: 16),
            ExpenseDateTimeSelector(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              onDateChanged: _updateDate,
              onTimeChanged: _updateTime,
            ),
            const Spacer(),
            ExpenseSubmitButton(isEditing: _isEditing, onPressed: _saveExpense),
          ],
        ),
      ),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  void _updateDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _updateTime(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      DateTime combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      ExpenseModel expense = ExpenseModel(
        id: widget.expense?.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        time: combinedDateTime,
      );

      widget.onSave(expense);
    }
  }
}
