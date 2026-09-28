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
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF00897B);

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
            return Center(
              child: CircularProgressIndicator(color: accentColor),
            );
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pie_chart_outline_rounded,
                            size: 40,
                            color: accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No expenses this month',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add expenses to see your\nspending breakdown',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                            height: 1.4,
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
                        sectionsSpace: 3,
                        centerSpaceRadius: 65,
                        sections: sortedCategories.map((entry) {
                          final category =
                              AppConstants.getCategoryByName(entry.key);
                          final percentage =
                              (entry.value / totalExpenses) * 100;
                          return PieChartSectionData(
                            color: category.color,
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 45,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black38, blurRadius: 4)
                              ],
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppFormatters.currency(totalExpenses),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Category Breakdown',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${sortedCategories.length} categories',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Category Breakdown List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final entry = sortedCategories[index];
                    final category =
                        AppConstants.getCategoryByName(entry.key);
                    final percentage = (entry.value / totalExpenses) * 100;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF1A2332) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF253345)
                              : theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  category.color.withValues(alpha: 0.15),
                                  category.color.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style:
                                      theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: isDark
                                        ? const Color(0xFF253345)
                                        : theme.colorScheme
                                            .surfaceContainerHighest,
                                    color: category.color,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppFormatters.currency(entry.value),
                                style:
                                    theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: category.color
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style:
                                      theme.textTheme.labelSmall?.copyWith(
                                    color: category.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
