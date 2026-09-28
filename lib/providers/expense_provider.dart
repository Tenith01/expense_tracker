// lib/providers/expense_provider.dart

import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/firestore_service.dart';

/// Manages expense state: fetching, filtering, CRUD, and loading/error states.
class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // ── State ──────────────────────────────────────────────────────────────

  List<Expense> _expenses = [];
  DateTime _selectedMonth = DateTime.now();
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────

  List<Expense> get expenses => _expenses;
  DateTime get selectedMonth => _selectedMonth;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Total of all currently-visible expenses.
  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Group expenses by date for sectioned list display.
  Map<String, List<Expense>> get groupedExpenses {
    final Map<String, List<Expense>> grouped = {};
    for (final expense in _expenses) {
      final key =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(expense);
    }
    return grouped;
  }

  /// Total expenses grouped by category for the current selected month.
  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in _expenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }

  // ── Month Navigation ───────────────────────────────────────────────────

  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    fetchExpenses();
  }

  void goToNextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    fetchExpenses();
  }

  // ── Category Filter ────────────────────────────────────────────────────

  void setCategory(String? category) {
    _selectedCategory = category;
    fetchExpenses();
  }

  // ── CRUD Operations ────────────────────────────────────────────────────

  /// Fetch expenses from Firestore for the selected month / category.
  Future<void> fetchExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _firestoreService.getExpensesForMonth(
        _selectedMonth,
        category: _selectedCategory,
      );
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
      _errorMessage = 'Failed to load expenses.\n$e';
      _expenses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new expense and refresh the list.
  Future<void> addExpense(Expense expense) async {
    try {
      await _firestoreService.addExpense(expense);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to add expense. Please try again.';
      notifyListeners();
    }
  }

  /// Update an existing expense and refresh the list.
  Future<void> updateExpense(Expense expense) async {
    try {
      await _firestoreService.updateExpense(expense);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to update expense. Please try again.';
      notifyListeners();
    }
  }

  /// Delete an expense by ID and refresh the list.
  Future<void> deleteExpense(String id) async {
    try {
      await _firestoreService.deleteExpense(id);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to delete expense. Please try again.';
      notifyListeners();
    }
  }
}
