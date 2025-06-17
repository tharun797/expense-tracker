// lib/services/expense_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's expenses collection reference
  CollectionReference? get _expensesCollection {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _firestore.collection('users').doc(user.uid).collection('expenses');
  }

  /// Fetch expenses for a specific date
  Future<List<ExpenseModel>> fetchExpensesForDate(DateTime date) async {
    final collection = _expensesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await collection
          .where(
            'date',
            isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch,
          )
          .where('date', isLessThan: endOfDay.millisecondsSinceEpoch)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ExpenseModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  /// Add a new expense
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final collection = _expensesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    try {
      DocumentReference docRef = await collection.add(expense.toMap());

      return ExpenseModel(
        id: docRef.id,
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
        time: expense.time,
      );
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  /// Update an existing expense
  Future<void> updateExpense(ExpenseModel expense) async {
    final collection = _expensesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    if (expense.id == null) {
      throw Exception('Expense ID is required for update');
    }

    try {
      await collection.doc(expense.id).update(expense.toMap());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    final collection = _expensesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    try {
      await collection.doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  /// Get expenses for a date range
  Future<List<ExpenseModel>> fetchExpensesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final collection = _expensesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    try {
      DateTime startOfDay = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      DateTime endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      QuerySnapshot snapshot = await collection
          .where(
            'date',
            isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch,
          )
          .where('date', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ExpenseModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses for date range: $e');
    }
  }

  Future<double> getTotalExpensesForDate(DateTime date) async {
    final expenses = await fetchExpensesForDate(date);
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  Future<double> getTotalExpensesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await fetchExpensesForDateRange(startDate, endDate);
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  /// Get expenses by category for a date
  Future<Map<String, List<ExpenseModel>>> getExpensesByCategory(
    DateTime date,
  ) async {
    final expenses = await fetchExpensesForDate(date);
    Map<String, List<ExpenseModel>> categorizedExpenses = {};

    for (var expense in expenses) {
      // Assuming you have a category field in your ExpenseModel
      // If not, you can group by title or add a category field
      String category = expense.title; // or expense.category if you have it

      if (categorizedExpenses.containsKey(category)) {
        categorizedExpenses[category]!.add(expense);
      } else {
        categorizedExpenses[category] = [expense];
      }
    }

    return categorizedExpenses;
  }
}
