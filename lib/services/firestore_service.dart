// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  /// Add a new expense document.
  Future<void> addExpense(Expense expense) async {
    await _expensesCollection.doc(expense.id).set(expense.toFirestore());
  }

  /// Update an existing expense document.
  Future<void> updateExpense(Expense expense) async {
    await _expensesCollection.doc(expense.id).update(expense.toFirestore());
  }

  /// Delete an expense document by ID.
  Future<void> deleteExpense(String id) async {
    await _expensesCollection.doc(id).delete();
  }

  /// Fetch expenses for a given month.
  /// Optionally filter by [category].
  Future<List<Expense>> getExpensesForMonth(
    DateTime month, {
    String? category,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    Query query = _expensesCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }
}
