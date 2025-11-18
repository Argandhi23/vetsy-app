// lib/core/widgets/responsive_constraint_box.dart
import 'package:flutter/material.dart';

// Widget ini akan membungkus semua layar kita
class ResponsiveConstraintBox extends StatelessWidget {
  final Widget child;
  const ResponsiveConstraintBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600, // <-- Lebar maksimal aplikasi (seperti tablet)
        ),
        child: child,
      ),
    );
  }
}