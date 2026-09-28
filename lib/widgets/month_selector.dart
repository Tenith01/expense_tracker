// lib/widgets/month_selector.dart

import 'package:flutter/material.dart';
import '../utils/formatters.dart';

/// A horizontal month navigator with left/right arrows.
class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  /// Disable the "next" arrow if already at the current month.
  bool get _canGoNext {
    final now = DateTime.now();
    return selectedMonth.year < now.year ||
        (selectedMonth.year == now.year && selectedMonth.month < now.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildArrowButton(
            context,
            icon: Icons.chevron_left_rounded,
            onPressed: onPrevious,
            tooltip: 'Previous month',
            isDark: isDark,
          ),
          Text(
            AppFormatters.monthYear(selectedMonth),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          _buildArrowButton(
            context,
            icon: Icons.chevron_right_rounded,
            onPressed: _canGoNext ? onNext : null,
            tooltip: 'Next month',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isEnabled
                ? (isDark
                    ? const Color(0xFF253345)
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isEnabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
