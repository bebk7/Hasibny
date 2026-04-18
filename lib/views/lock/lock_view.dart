import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lock_controller.dart';
import '../../themes/app_theme.dart';

class LockView extends StatefulWidget {
  const LockView({super.key});

  @override
  State<LockView> createState() => _LockViewState();
}

class _LockViewState extends State<LockView> {
  final LockController _lockController = Get.find<LockController>();
  final List<String> _enteredPin = [];
  bool _hasError = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lockController.isBioEnabled.value) {
        _tryBiometric();
      }
    });
  }

  Future<void> _tryBiometric() async {
    setState(() => _isChecking = true);
    await _lockController.authenticateWithBiometrics();
    if (mounted) setState(() => _isChecking = false);
  }

  void _onKeyTap(String key) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin.add(key);
      _hasError = false;
    });
    if (_enteredPin.length == 4) {
      _checkPin();
    }
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin.removeLast();
      _hasError = false;
    });
  }

  Future<void> _checkPin() async {
    setState(() => _isChecking = true);
    final pin = _enteredPin.join();
    final ok = await _lockController.verifyPinAsync(pin);
    if (mounted) {
      setState(() {
        _isChecking = false;
        if (!ok) {
          _hasError = true;
          _enteredPin.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'app_lock'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _lockController.isPinEnabled.value
                    ? 'enter_pin'.tr
                    : 'use_biometric'.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // PIN dots
              if (_lockController.isPinEnabled.value) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _enteredPin.length;
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
                  Text(
                    'wrong_pin'.tr,
                    style: const TextStyle(
                        color: AppTheme.errorColor, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 40),

                // Numpad
                _buildNumpad(),
              ],

              // Biometric only
              if (!_lockController.isPinEnabled.value &&
                  _lockController.isBioEnabled.value) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _tryBiometric,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text('use_biometric'.tr),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                  ),
                ),
              ],
            ],
          ),
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
          [
            _lockController.isBioEnabled.value ? 'bio' : '',
            '0',
            'del'
          ],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) => _buildKey(key)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) return const SizedBox(width: 80, height: 64);

    if (key == 'del') {
      return _KeyButton(
        onTap: _onDelete,
        child: const Icon(Icons.backspace_outlined, size: 22),
      );
    }

    if (key == 'bio') {
      return _KeyButton(
        onTap: _isChecking ? null : _tryBiometric,
        child: const Icon(Icons.fingerprint, size: 26, color: AppTheme.primaryColor),
      );
    }

    return _KeyButton(
      onTap: () => _onKeyTap(key),
      child: Text(
        key,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _KeyButton({required this.onTap, required this.child});

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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
