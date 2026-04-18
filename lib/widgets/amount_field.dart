import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class AmountField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;

  const AmountField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '0',
    this.icon = Icons.attach_money_rounded,
    this.validator,
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
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final val = double.tryParse(widget.controller.text.trim());
    setState(() {
      _wordsText = (val != null && val > 0)
          ? CurrencyFormatter.amountToWords(val)
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_wordsText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8, left: 8),
            child: Text(
              _wordsText,
              style: TextStyle(
                color: Colors.deepPurple[300],
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
