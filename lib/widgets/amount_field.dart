import 'package:flutter/material.dart';
import '../core/core.dart';

class AmountField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? currencyCode;
  final String? Function(String?)? validator;
  final bool autofocus;

  const AmountField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '0',
    this.icon = Icons.account_balance_wallet_rounded,
    this.currencyCode,
    this.validator,
    this.autofocus = false,
  });

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  String _wordsText = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _onChanged();
  }

  @override
  void didUpdateWidget(covariant AmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencyCode != widget.currencyCode) {
      _onChanged();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final val = double.tryParse(widget.controller.text.trim());
    final newWords = (val != null && val > 0)
        ? CurrencyFormatter.amountToWords(val,
            currencyCode: widget.currencyCode)
        : '';
    if (newWords != _wordsText && mounted) {
      setState(() {
        _wordsText = newWords;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          keyboardType: TextInputType.number,
          inputFormatters: const [
            DigitsOnlyInputFormatter(),
          ],
          validator: widget.validator,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: resp.fontSize(resp.isSmall ? 16 : 18),
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: Container(
              margin: const EdgeInsetsDirectional.only(start: 12, end: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryOf(context).withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: AppColors.primaryOf(context),
                size: 20,
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, child) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    widget.controller.clear();
                    _onChanged();
                  },
                );
              },
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _wordsText.isNotEmpty
              ? Container(
                  key: ValueKey(_wordsText),
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOf(context).withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(
                      color: AppColors.primaryOf(context).withValues(alpha: 0.2),
                      width: AppSizes.borderThin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.spellcheck_rounded,
                        size: 16,
                        color: AppColors.primaryOf(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _wordsText,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            color: AppColors.primaryOf(context),
                            fontSize: resp.fontSize(12),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
