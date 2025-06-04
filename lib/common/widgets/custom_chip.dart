import 'package:flutter/material.dart';
import 'package:journaling/core/utils/context_extension.dart';

class CustomChip extends StatelessWidget {
  final bool isSelected;
  final String text;
  final VoidCallback? onTap;

  const CustomChip({
    super.key,
    this.isSelected = false,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20.0), // Pill shape for chips
        border: Border.all(
          color: isSelected ? context.primaryColor : Colors.grey.shade700,
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: context.textTheme.bodyMedium?.copyWith(
          color: isSelected ? context.primaryColor : Colors.grey.shade700,
        ),
      ),
    );
  }
}
