import 'package:flutter/material.dart';
import '../typography/app_typography.dart';

/// Standard, auto-adaptive AppBar title widget that prevents overflow and cleanly
/// scales down long or multi-word titles on compact devices.
class AppAppBarTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final int maxLines;
  final TextAlign textAlign;
  final bool isCompact;

  const AppAppBarTitle(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines = 1,
    this.textAlign = TextAlign.center,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = isCompact
        ? AppTypography.pageTitleCompact(context)
        : AppTypography.pageTitle(context);
    final effectiveStyle = style != null
        ? (color != null ? style!.copyWith(color: color) : style!)
        : (color != null ? baseStyle.copyWith(color: color) : baseStyle);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        text,
        style: effectiveStyle,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
