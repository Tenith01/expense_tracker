// lib/screens/summary_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/month_selector.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          final categoryTotals = provider.categoryTotals;
          final totalExpenses = provider.totalExpenses;
          
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (totalExpenses == 0) {
            return Column(
              children: [
                MonthSelector(
                  selectedMonth: provider.selectedMonth,
                  onPrevious: provider.goToPreviousMonth,
                  onNext: provider.goToNextMonth,
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pie_chart_outline_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses this month',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Sort categories by total amount descending
          final sortedCategories = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Column(
            children: [
              MonthSelector(
                selectedMonth: provider.selectedMonth,
                onPrevious: provider.goToPreviousMonth,
                onNext: provider.goToNextMonth,
              ),
              const SizedBox(height: 16),
              
              // Chart
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 70,
                        sections: sortedCategories.map((entry) {
                          final category = AppConstants.getCategoryByName(entry.key);
                          final percentage = (entry.value / totalExpenses) * 100;
                          return PieChartSectionData(
                            color: category.color,
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 40,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            AppFormatters.currency(totalExpenses),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Category Breakdown List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: sortedCategories.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = sortedCategories[index];
                    final category = AppConstants.getCategoryByName(entry.key);
                    final percentage = (entry.value / totalExpenses) * 100;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withValues(alpha: 0.2),
                        child: Icon(category.icon, color: category.color),
                      ),
                      title: Text(
                        category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              color: category.color,
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        AppFormatters.currency(entry.value),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
