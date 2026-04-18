import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../services/export_service.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import '../../widgets/amount_field.dart';

class CustomerDetailsView extends StatelessWidget {
  final int customerId;

  const CustomerDetailsView({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final customerController = Get.find<CustomerController>();
    final transactionController = Get.find<TransactionController>();

    Future.microtask(
        () => transactionController.loadTransactionsForCustomer(customerId));

    final customer = customerController.getCustomerById(customerId);
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text('customer_details'.tr)),
        body: Center(child: Text('customer_not_found'.tr)),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(customer.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'export_pdf'.tr,
            onPressed: () async {
              final tc = Get.find<TransactionController>();
              final cc = Get.find<CustomerController>();
              final balance = cc.getCustomerBalance(customerId);
              await ExportService.exportCustomerToPDF(
                customer: customer,
                transactions: tc.transactions.toList(),
                balance: balance,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, customerController),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildCustomerHeader(context, customerController),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: _buildTransactionSummary(context, transactionController),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          _buildTransactionsListSliver(context, transactionController),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddTransactionDialog(context, transactionController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomerHeader(
      BuildContext context, CustomerController controller) {
    final balance = controller.getCustomerBalance(customerId);
    final customer = controller.getCustomerById(customerId)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.isSmall(context) ? 14 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'customer-${customer.id}',
            child: CircleAvatar(
              radius: Responsive.avatarRadius(context),
              backgroundColor: balance >= 0
                  ? AppTheme.gotColor.withValues(alpha: 0.1)
                  : AppTheme.giveColor.withValues(alpha: 0.1),
              child: customer.profilePicturePath != null
                  ? ClipOval(
                      child: Image.asset(
                        customer.profilePicturePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[400]),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: Responsive.avatarRadius(context) * 0.8,
                      color:
                          balance >= 0 ? AppTheme.gotColor : AppTheme.giveColor,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            customer.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              final cleanNumber = customer.phoneNumber.replaceAll(' ', '');
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: cleanNumber,
              );
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    customer.phoneNumber,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: Responsive.isSmall(context) ? 16 : 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.call,
                    size: Responsive.isSmall(context) ? 16 : 18,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildBalanceIndicator(context, balance),
        ],
      ),
    );
  }

  Widget _buildBalanceIndicator(BuildContext context, double balance) {
    final color = balance >= 0 ? AppTheme.gotColor : AppTheme.giveColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            balance >= 0 ? 'they_owe_you'.tr : 'you_owe_them'.tr,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatAbs(balance),
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900, fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary(
      BuildContext context, TransactionController controller) {
    return Obx(() {
      final totalGive = controller.getTotalGiveAmount();
      final totalGot = controller.getTotalGotAmount();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _SummaryItem(
                label: 'you_gave'.tr,
                amount: totalGive,
                color: AppTheme.giveColor),
            const SizedBox(width: 12),
            _SummaryItem(
                label: 'you_got'.tr,
                amount: totalGot,
                color: AppTheme.gotColor),
          ],
        ),
      );
    });
  }

  Widget _buildTransactionsListSliver(
      BuildContext context, TransactionController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.transactions.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyTransactions(context),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final transaction = controller.transactions[index];
              return _TransactionTile(
                transaction: transaction,
                onDelete: () => controller.deleteTransaction(transaction.id),
                onShare: () {
                  final customer = Get.find<CustomerController>()
                      .getCustomerById(customerId);
                  _shareInvoice(transaction, customer);
                },
              );
            },
            childCount: controller.transactions.length,
          ),
        ),
      );
    });
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('no_transactions'.tr,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(
      BuildContext context, TransactionController controller) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedType = TransactionType.got;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text('add_transaction_title'.tr,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _TypeButton(
                      label: 'you_got_btn'.tr,
                      isSelected: selectedType == TransactionType.got,
                      color: AppTheme.gotColor,
                      onTap: () =>
                          setState(() => selectedType = TransactionType.got),
                    ),
                    const SizedBox(width: 12),
                    _TypeButton(
                      label: 'you_gave_btn'.tr,
                      isSelected: selectedType == TransactionType.give,
                      color: AppTheme.giveColor,
                      onTap: () =>
                          setState(() => selectedType = TransactionType.give),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AmountField(
                  controller: amountController,
                  label: 'amount'.tr,
                  hint: '0',
                  icon: Icons.attach_money_rounded,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'description'.tr,
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) {
                        Get.snackbar('error'.tr, 'valid_amount'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.errorColor,
                            colorText: Colors.white);
                        return;
                      }
                      controller.addTransaction(
                        customerId: customerId,
                        amount: amount,
                        type: selectedType,
                        description: descriptionController.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'confirm'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareInvoice(
      TransactionModel transaction, Customer? customer) async {
    if (customer == null) return;
    await ExportService.shareTransactionAsPDF(
      transaction: transaction,
      customer: customer,
    );
  }

  void _confirmDelete(BuildContext context, CustomerController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_customer'.tr),
        content: Text('delete_customer_confirm'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              controller.deleteCustomer(customerId);
              Get.back();
              Get.back();
            },
            child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryItem(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            const SizedBox(height: 4),
            FittedBox(
                child: Text(CurrencyFormatter.format(amount),
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton(
      {required this.label,
      required this.isSelected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _TransactionTile(
      {required this.transaction,
      required this.onDelete,
      required this.onShare});

  @override
  Widget build(BuildContext context) {
    final isGive = transaction.type == TransactionType.give;
    final color = isGive ? AppTheme.giveColor : AppTheme.gotColor;

    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
          AlertDialog(
            title: Text('delete_transaction'.tr),
            content: Text('delete_transaction_confirm'.tr),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text('cancel'.tr)),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('delete'.tr,
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03), blurRadius: 5)
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
                isGive ? Icons.north_east_rounded : Icons.south_west_rounded,
                color: color,
                size: 18),
          ),
          title: Text(transaction.description,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(transaction.formattedDate,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isGive ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 4),
              IconButton(
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  onPressed: onShare),
            ],
          ),
        ),
      ),
    );
  }
}
