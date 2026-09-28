import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../widgets/expense_tile.dart';
import 'add_edit_expense_screen.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  List<Expense> _allExpenses = [];
  List<Expense> _searchResults = [];
  bool _isLoading = true;
  String _searchQuery = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _quickFilters = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'High Amount (>100)',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadAllExpenses();
  }

  Future<void> _loadAllExpenses() async {
    try {
      final expenses = await _firestoreService.getAllExpenses();
      setState(() {
        _allExpenses = expenses;
        _searchResults = expenses;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filterExpenses();
    });
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      if (filter == 'High Amount (>100)') {
        _searchController.text = 'amount:>100';
      } else {
        _searchController.text = filter;
      }
      _searchQuery = _searchController.text.toLowerCase();
      _filterExpenses();
    });
  }

  void _filterExpenses() {
    if (_searchQuery.isEmpty) {
      _searchResults = _allExpenses;
      return;
    }

    _searchResults = _allExpenses.where((expense) {
      if (_searchQuery.startsWith('amount:>')) {
        final amountStr = _searchQuery.split('>').last.trim();
        final amount = double.tryParse(amountStr) ?? 0;
        return expense.amount > amount;
      }

      final titleMatch = expense.title.toLowerCase().contains(_searchQuery);
      final categoryMatch =
          expense.category.toLowerCase().contains(_searchQuery);
      final noteMatch =
          expense.note?.toLowerCase().contains(_searchQuery) ?? false;
      final amountMatch = expense.amount.toString().contains(_searchQuery);

      return titleMatch || categoryMatch || noteMatch || amountMatch;
    }).toList();
  }

  void _navigateToEdit(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(expense: expense),
      ),
    ).then((_) {
      if (!mounted) return;
      // Reload on return
      _loadAllExpenses();
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  void _deleteExpense(Expense expense) async {
    await _firestoreService.deleteExpense(expense.id);
    _loadAllExpenses();
    if (mounted) {
      context.read<ExpenseProvider>().fetchExpenses();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF00897B);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Custom Search App Bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF253345)
                              : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      autofocus: true,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: accentColor,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1A2332)
                            : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF253345)
                                : theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF253345)
                                : theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: accentColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Quick Filters ────────────────────────────────────────────────
            if (_searchQuery.isEmpty)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Filters',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickFilters.map((filter) {
                          return ActionChip(
                            label: Text(filter),
                            backgroundColor: isDark
                                ? const Color(0xFF1A2332)
                                : theme.colorScheme.surface,
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF253345)
                                  : theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                            ),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onPressed: () => _applyQuickFilter(filter),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

            // ── Results Label ────────────────────────────────────────────────
            if (_searchQuery.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            // ── Search Results List ──────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: accentColor),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 36,
                                  color: accentColor.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try a different search term',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.only(bottom: 88, top: 8),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final expense = _searchResults[index];
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: ExpenseTile(
                                expense: expense,
                                onTap: () => _navigateToEdit(expense),
                                onDelete: () => _deleteExpense(expense),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
