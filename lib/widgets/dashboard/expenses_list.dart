// lib/widgets/dashboard/expenses_list.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/widgets/dashboard/expense_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 

class ExpensesList extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final Function(ExpenseModel) onEdit;
  final Function(ExpenseModel) onDelete;

  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ExpenseController expenseController = Get.find<ExpenseController>();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 100),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        ExpenseModel expense = expenses[index];
        bool canEdit = expenseController.isToday(expense.date);

        return ExpenseListItem(
          expense: expense,
          canEdit: canEdit,
          onEdit: () => onEdit(expense),
          onDelete: () => onDelete(expense),
        );
      },
    );
  }
}
