import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lock_controller.dart';
import '../../themes/app_theme.dart';

class SetPinView extends StatefulWidget {
  const SetPinView({super.key});

  @override
  State<SetPinView> createState() => _SetPinViewState();
}

class _SetPinViewState extends State<SetPinView> {
  final LockController _lc = Get.find<LockController>();
  final List<String> _pin = [];
  final List<String> _confirm = [];
  bool _confirming = false;
  bool _hasError = false;

  void _onKey(String key) {
    final current = _confirming ? _confirm : _pin;
    if (current.length >= 4) return;
    setState(() {
      current.add(key);
      _hasError = false;
    });
    if (current.length == 4) {
      if (!_confirming) {
        setState(() => _confirming = true);
      } else {
        _checkMatch();
      }
    }
  }

  void _onDelete() {
    final current = _confirming ? _confirm : _pin;
    if (current.isEmpty) return;
    setState(() {
      current.removeLast();
      _hasError = false;
    });
  }

  Future<void> _checkMatch() async {
    if (_pin.join() == _confirm.join()) {
      await _lc.setPin(_pin.join());
      Get.back();
      Get.snackbar('success'.tr, 'pin_set_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } else {
      setState(() {
        _hasError = true;
        _confirm.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _confirming ? _confirm : _pin;
    return Scaffold(
      appBar: AppBar(title: Text('set_pin'.tr)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _confirming ? 'confirm_pin'.tr : 'enter_new_pin'.tr,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < current.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hasError
                        ? AppTheme.errorColor
                        : filled
                            ? AppTheme.primaryColor
                            : Colors.grey[300],
                    border: Border.all(
                      color: _hasError
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            if (_hasError) ...[
              const SizedBox(height: 12),
              Text('pin_mismatch'.tr,
                  style: const TextStyle(
                      color: AppTheme.errorColor, fontSize: 13)),
            ],
            const SizedBox(height: 40),
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((k) => _buildKey(k)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) return const SizedBox(width: 80, height: 64);
    if (key == 'del') {
      return _KeyBtn(
          onTap: _onDelete,
          child: const Icon(Icons.backspace_outlined, size: 22));
    }
    return _KeyBtn(
      onTap: () => _onKey(key),
      child: Text(key,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w500)),
    );
  }
}

class _KeyBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _KeyBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
