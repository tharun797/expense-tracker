import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:expense_tracker/widgets/dashboard/delete_confirmation_dialog.dart';
import 'package:expense_tracker/widgets/dashboard/empty_expenses_view.dart';
import 'package:expense_tracker/widgets/dashboard/expenses_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import '../widgets/dashboard/total_expenses_card.dart';
import '../widgets/common/date_selector.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthController _authController = Get.find<AuthController>();

  late final ExpenseController _expenseController;

  @override
  void initState() {
    super.initState();
    // Ensure ExpenseController exists, create if it doesn't
    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(ExpenseController());
    }
    _expenseController = Get.find<ExpenseController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          TotalExpensesCard(),

          GetBuilder<ExpenseController>(
            id: ExpenseController.SELECTED_DATE_ID,
            builder: (controller) {
              return DateSelector(
                selectedDate: controller.selectedDate,
                onDateChanged: (date) => controller.saveSelectedDate(date),
                style: DateSelectorStyle.container,
                label: 'Date',
                buttonText: 'Change Date',
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildExpensesSection()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Dashboard'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _authController.signOut(),
        ),
      ],
    );
  }

  Widget _buildExpensesSection() {
    return GetBuilder<ExpenseController>(
      id: ExpenseController.LOADING_ID,
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return GetBuilder<ExpenseController>(
          id: ExpenseController.EXPENSES_LIST_ID,
          builder: (controller) {
            if (controller.expenses.isEmpty) {
              return const EmptyExpensesView();
            }

            return ExpensesList(
              expenses: controller.expenses,
              onEdit: _handleEdit,
              onDelete: _handleDelete,
            );
          },
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Get.to(() => AddExpenseScreen()),
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _handleEdit(ExpenseModel expense) {
    Get.to(() => AddExpenseScreen(expense: expense));
  }

  void _handleDelete(ExpenseModel expense) {
    DeleteConfirmationDialog.show(
      title: 'Delete Expense',
      content: 'Are you sure you want to delete "${expense.title}"?',
      onConfirm: () => _expenseController.deleteExpense(expense.id!),
    );
  }
}
