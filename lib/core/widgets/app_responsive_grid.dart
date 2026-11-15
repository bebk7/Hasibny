import 'package:flutter/material.dart';

/// Central responsive grid system that calculates columns dynamically
/// based on available constraints, preventing card clipping and overflow
class AppResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AppResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 160.0,
    this.spacing = 10.0,
    this.runSpacing = 10.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Dynamically compute column count
        final columnCount =
            (availableWidth / (minItemWidth + spacing)).floor().clamp(1, 6);

        // If single column or small phone, use Column or Wrap
        if (columnCount <= 1) {
          return Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  if (i > 0) SizedBox(height: runSpacing),
                  children[i],
                ],
              ],
            ),
          );
        }

        // Multiple columns: calculate item width
        final itemWidth = (availableWidth - (spacing * (columnCount - 1))) / columnCount;

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((child) {
              return SizedBox(
                width: itemWidth,
                child: child,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

