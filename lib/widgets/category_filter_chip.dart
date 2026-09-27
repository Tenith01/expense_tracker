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

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
              showCheckmark: false,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                fontWeight: selectedCategory == null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          // Category chips
          ...AppConstants.categories.map((cat) {
            final isSelected = selectedCategory == cat.name;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                avatar: isSelected
                    ? null
                    : Icon(cat.icon, size: 16, color: cat.color),
                label: Text(cat.name),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(
                  isSelected ? null : cat.name,
                ),
                showCheckmark: false,
                selectedColor: cat.color.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
