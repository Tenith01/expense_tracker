// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/formatters.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/expense_tile.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_card.dart';
import '../widgets/expense_bar_chart.dart';
import 'add_edit_expense_screen.dart';
import 'summary_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabAnimController;
  late final Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
    );

    // Fetch expenses on first load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
      _fabAnimController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
    );
  }

  void _navigateToEdit(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditExpenseScreen(expense: expense)),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final accentColor = isDark
        ? const Color(0xFF4ADE80)
        : const Color(0xFF00897B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: false,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final isCurrentlyDark =
                  themeProvider.themeMode == ThemeMode.dark ||
                  (themeProvider.themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    isCurrentlyDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(isCurrentlyDark),
                    color: accentColor,
                  ),
                ),
                onPressed: () => themeProvider.toggleTheme(!isCurrentlyDark),
                tooltip: isCurrentlyDark
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SearchScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
              );
            },
            tooltip: 'Search expenses',
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SummaryScreen()),
              );
            },
            tooltip: 'Monthly summary',
          ),
          // User avatar / sign out
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: accentColor.withValues(alpha: 0.15),
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Text(
                      (user?.displayName ?? user?.email ?? '?')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 16),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'signout') {
                _showSignOutDialog();
              }
            },
          ),
          const SizedBox(width: 4),
        ],
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

              // ── Daily Expense Chart ───────────────────────────────
              if (provider.expenses.isNotEmpty)
                ExpenseBarChart(
                  expenses: provider.expenses,
                  selectedMonth: provider.selectedMonth,
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
              Expanded(child: _buildBody(provider, theme)),
            ],
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: _navigateToAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Expense'),
        ),
      ),
    );
  }

  Widget _buildBody(ExpenseProvider provider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF4ADE80)
        : const Color(0xFF00897B);

    // Loading state
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: accentColor, strokeWidth: 3),
      );
    }

    // Error state
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 36,
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: provider.fetchExpenses,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 40,
                  color: accentColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No expenses yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap "Add Expense" to start tracking\nyour spending',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                  height: 1.4,
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
      color: accentColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  AppFormatters.groupHeader(date),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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
