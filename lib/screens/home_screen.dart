// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/expense_tile.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_card.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch expenses on first load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditExpenseScreen(),
      ),
    );
  }

  void _navigateToEdit(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(expense: expense),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ── Summary Card ──────────────────────────────────────
              SummaryCard(
                total: provider.totalExpenses,
                month: provider.selectedMonth,
              ),

              // ── Month Selector ────────────────────────────────────
              MonthSelector(
                selectedMonth: provider.selectedMonth,
                onPrevious: provider.goToPreviousMonth,
                onNext: provider.goToNextMonth,
              ),

              // ── Category Filter ───────────────────────────────────
              CategoryFilterChips(
                selectedCategory: provider.selectedCategory,
                onCategorySelected: provider.setCategory,
              ),
              const SizedBox(height: 8),

              // ── Expense List ──────────────────────────────────────
              Expanded(
                child: _buildBody(provider, theme),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildBody(ExpenseProvider provider, ThemeData theme) {
    // Loading state
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: theme.colorScheme.error.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: provider.fetchExpenses,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (provider.expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No expenses yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap "Add Expense" to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Grouped expense list
    final grouped = provider.groupedExpenses;
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: provider.fetchExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final dateKey = sortedKeys[index];
          final dayExpenses = grouped[dateKey]!;
          final date = dayExpenses.first.date;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date group header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  AppFormatters.groupHeader(date),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Expense tiles for this date
              ...dayExpenses.map(
                (expense) => ExpenseTile(
                  expense: expense,
                  onTap: () => _navigateToEdit(expense),
                  onDelete: () => provider.deleteExpense(expense.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
