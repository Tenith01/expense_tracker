// lib/widgets/category_filter_chip.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A horizontal scrollable row of filter chips for expense categories.
class CategoryFilterChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: const Text('All'),
              avatar: selectedCategory == null
                  ? null
                  : Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
              showCheckmark: false,
              selectedColor: isDark
                  ? const Color(0xFF4ADE80).withValues(alpha: 0.15)
                  : theme.colorScheme.primaryContainer,
              backgroundColor: isDark
                  ? const Color(0xFF1A2332)
                  : theme.colorScheme.surface,
              side: BorderSide(
                color: selectedCategory == null
                    ? (isDark
                        ? const Color(0xFF4ADE80).withValues(alpha: 0.4)
                        : theme.colorScheme.primary.withValues(alpha: 0.5))
                    : (isDark
                        ? const Color(0xFF253345)
                        : theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5)),
              ),
              labelStyle: TextStyle(
                fontWeight: selectedCategory == null
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selectedCategory == null
                    ? (isDark
                        ? const Color(0xFF4ADE80)
                        : theme.colorScheme.primary)
                    : theme.colorScheme.onSurfaceVariant,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
          // Category chips
          ...AppConstants.categories.map((cat) {
            final isSelected = selectedCategory == cat.name;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                avatar: Icon(cat.icon, size: 16, color: cat.color),
                label: Text(cat.name),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(
                  isSelected ? null : cat.name,
                ),
                showCheckmark: false,
                selectedColor: cat.color.withValues(alpha: isDark ? 0.15 : 0.12),
                backgroundColor: isDark
                    ? const Color(0xFF1A2332)
                    : theme.colorScheme.surface,
                side: BorderSide(
                  color: isSelected
                      ? cat.color.withValues(alpha: 0.5)
                      : (isDark
                          ? const Color(0xFF253345)
                          : theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.5)),
                ),
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? cat.color
                      : theme.colorScheme.onSurfaceVariant,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }),
        ],
      ),
    );
  }
}
