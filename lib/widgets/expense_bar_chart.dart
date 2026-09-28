// lib/widgets/expense_bar_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';

import 'package:intl/intl.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;

  const ExpenseBarChart({
    super.key,
    required this.expenses,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Process expenses by day for the selected month
    final daysInMonth = DateUtils.getDaysInMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
    final List<double> dailyTotals = List.filled(daysInMonth, 0.0);

    for (var expense in expenses) {
      if (expense.date.year == selectedMonth.year &&
          expense.date.month == selectedMonth.month) {
        dailyTotals[expense.date.day - 1] += expense.amount;
      }
    }

    // Find the maximum spending day to scale the chart
    double maxAmount = 0;
    for (var amount in dailyTotals) {
      if (amount > maxAmount) maxAmount = amount;
    }
    if (maxAmount == 0) maxAmount = 1; // Prevent division by zero

    final barColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF00897B);
    final barEmptyColor = isDark
        ? const Color(0xFF253345)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);

    return Container(
      height: 150,
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2332) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF253345)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Spending',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bar_chart_rounded, size: 18, color: barColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipColor: (group) => isDark
                        ? const Color(0xFF253345)
                        : theme.colorScheme.primaryContainer,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${group.x.toInt()} ${DateFormat('MMM').format(selectedMonth)}\n',
                        theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: 'LKR ${rod.toY.toStringAsFixed(0)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: barColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final day = value.toInt();
                        if (day % 5 != 0 && day != 1 && day != daysInMonth) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            day.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(daysInMonth, (index) {
                  final day = index + 1;
                  final amount = dailyTotals[index];
                  return BarChartGroupData(
                    x: day,
                    barRods: [
                      BarChartRodData(
                        toY: amount > 0 ? amount : maxAmount * 0.04,
                        gradient: amount > 0
                            ? LinearGradient(
                                colors: [
                                  barColor.withValues(alpha: 0.7),
                                  barColor,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : null,
                        color: amount > 0 ? null : barEmptyColor,
                        width: daysInMonth > 30 ? 4 : 6,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxAmount,
                          color: barEmptyColor,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
