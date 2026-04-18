import 'package:account_book/views/add_transaction/add_transaction_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transaction.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () => _showQuickTransactionDialog(context),
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add),
    );
  }

  void _showQuickTransactionDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('add_transaction'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: Text('give_debit'.tr),
              subtitle: Text('money_gave'.tr),
              onTap: () {
                Get.back();
                Get.to(() => const AddTransactionView(
                      initialType: TransactionType.give,
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
              title: Text('got_credit'.tr),
              subtitle: Text('money_received'.tr),
              onTap: () {
                Get.back();
                Get.to(() => const AddTransactionView(
                      initialType: TransactionType.got,
                    ));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }
}
