// ignore_for_file: constant_identifier_names

import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/expense_model.dart';

class ExpenseController extends GetxController {
  // Services
  final ExpenseService _expenseService = ExpenseService();
  final PreferencesService _preferencesService = PreferencesService();

  // State variables
  List<ExpenseModel> expenses = <ExpenseModel>[];
  double totalExpenses = 0.0;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  // UI Update IDs
  static const String EXPENSES_LIST_ID = 'expenses_list';
  static const String TOTAL_EXPENSES_ID = 'total_expenses';
  static const String SELECTED_DATE_ID = 'selected_date';
  static const String LOADING_ID = 'loading';

  @override
  void onInit() async {
    debugPrint('init called');
    super.onInit();
    await _loadSelectedDate();
    await fetchExpenses();
  }

  /// Load selected date from preferences
  Future<void> _loadSelectedDate() async {
    try {
      final savedDate = await _preferencesService.loadSelectedDate();
      if (savedDate != null) {
        selectedDate = savedDate;
        update([SELECTED_DATE_ID]);
      }
    } catch (e) {
      debugPrint('Error loading selected date: $e');
    }
  }

  /// Save selected date and fetch expenses
  Future<void> saveSelectedDate(DateTime date) async {
    try {
      await _preferencesService.saveSelectedDate(date);
      selectedDate = date;
      update([SELECTED_DATE_ID]);
      await fetchExpenses();
    } catch (e) {
      _showErrorSnackbar('Failed to save selected date');
      debugPrint('Error saving selected date: $e');
    }
  }

  /// Fetch expenses for the selected date
  Future<void> fetchExpenses() async {
    try {
      _setLoading(true);

      expenses = await _expenseService.fetchExpensesForDate(selectedDate);
      _calculateTotal();

      _setLoading(false);
      update([EXPENSES_LIST_ID, TOTAL_EXPENSES_ID]);
    } catch (e) {
      _setLoading(false);
      _showErrorSnackbar('Failed to fetch expenses');
      debugPrint('Error fetching expenses: $e');
    }
  }

  /// Add a new expense
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final newExpense = await _expenseService.addExpense(expense);

      // If the expense date matches the currently selected date, update the local list
      if (_isSameDate(expense.date, selectedDate)) {
        _insertExpenseInOrder(newExpense);
        totalExpenses += expense.amount;
        update([EXPENSES_LIST_ID, TOTAL_EXPENSES_ID]);
      }

      _showSuccessSnackbar('Expense added successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to add expense');
      debugPrint('Error adding expense: $e');
    }
  }

  /// Update an existing expense
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _expenseService.updateExpense(expense);

      final index = expenses.indexWhere((e) => e.id == expense.id);

      if (index != -1) {
        final oldAmount = expenses[index].amount;

        // Check if updated expense still belongs to current selected date
        if (_isSameDate(expense.date, selectedDate)) {
          expenses[index] = expense;
          totalExpenses = totalExpenses - oldAmount + expense.amount;

          // Re-sort if time changed
          expenses.sort((a, b) => b.time.compareTo(a.time));
        } else {
          // Remove from list if date changed
          expenses.removeAt(index);
          totalExpenses -= oldAmount;
        }
      } else if (_isSameDate(expense.date, selectedDate)) {
        // Add to list if it now matches the selected date
        _insertExpenseInOrder(expense);
        totalExpenses += expense.amount;
      }

      update([EXPENSES_LIST_ID, TOTAL_EXPENSES_ID]);
      _showSuccessSnackbar('Expense updated successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to update expense');
      debugPrint('Error updating expense: $e');
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expenseService.deleteExpense(expenseId);

      final index = expenses.indexWhere((e) => e.id == expenseId);
      if (index != -1) {
        final removedAmount = expenses[index].amount;
        expenses.removeAt(index);
        totalExpenses -= removedAmount;
        update([EXPENSES_LIST_ID, TOTAL_EXPENSES_ID]);
      }

      _showSuccessSnackbar('Expense deleted successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to delete expense');
      debugPrint('Error deleting expense: $e');
    }
  }

  /// Refresh expenses manually
  Future<void> refreshExpenses() async {
    await fetchExpenses();
  }

  /// Get expenses for a date range
  Future<List<ExpenseModel>> getExpensesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _expenseService.fetchExpensesForDateRange(
        startDate,
        endDate,
      );
    } catch (e) {
      _showErrorSnackbar('Failed to fetch expenses for date range');
      debugPrint('Error fetching expenses for date range: $e');
      return [];
    }
  }

  /// Get total expenses for a date range
  Future<double> getTotalForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _expenseService.getTotalExpensesForDateRange(
        startDate,
        endDate,
      );
    } catch (e) {
      debugPrint('Error getting total for date range: $e');
      return 0.0;
    }
  }

  // Helper Methods

  void _calculateTotal() {
    totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  void _insertExpenseInOrder(ExpenseModel expense) {
    final insertIndex = expenses.indexWhere(
      (e) =>
          e.time.millisecondsSinceEpoch < expense.time.millisecondsSinceEpoch,
    );

    if (insertIndex == -1) {
      expenses.add(expense);
    } else {
      expenses.insert(insertIndex, expense);
    }
  }

  void _setLoading(bool loading) {
    isLoading = loading;
    update([LOADING_ID]);
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isToday(DateTime expenseDate) {
    return _isSameDate(expenseDate, DateTime.now());
  }

  // Snackbar helpers
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
    );
  }
}
