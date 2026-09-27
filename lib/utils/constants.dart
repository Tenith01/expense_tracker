// lib/utils/constants.dart

import 'package:flutter/material.dart';

/// Predefined expense categories with their display properties.
class AppCategory {
  final String name;
  final IconData icon;
  final Color color;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AppConstants {
  AppConstants._();

  static const List<AppCategory> categories = [
    AppCategory(
      name: 'Food',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF6B6B),
    ),
    AppCategory(
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF4ECDC4),
    ),
    AppCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFFBE0B),
    ),
    AppCategory(
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF845EC2),
    ),
    AppCategory(
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFFF9671),
    ),
    AppCategory(
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFFF9F871),
    ),
    AppCategory(
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF00C9A7),
    ),
    AppCategory(
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFFC4C4C4),
    ),
  ];

  /// Get an [AppCategory] by name. Returns 'Other' if not found.
  static AppCategory getCategoryByName(String name) {
    return categories.firstWhere(
      (c) => c.name == name,
      orElse: () => categories.last,
    );
  }

  /// List of category names for dropdown / chips.
  static List<String> get categoryNames =>
      categories.map((c) => c.name).toList();
}
