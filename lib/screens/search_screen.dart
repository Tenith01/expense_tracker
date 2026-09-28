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
      final categoryMatch = expense.category.toLowerCase().contains(_searchQuery);
      final noteMatch = expense.note?.toLowerCase().contains(_searchQuery) ?? false;
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
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          autofocus: true,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Search expenses...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: theme.colorScheme.primary,
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
                            fillColor: theme.colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                          ),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickFilters.map((filter) {
                          return ActionChip(
                            label: Text(filter),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // ── Search Results List ──────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 88, top: 8),
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
