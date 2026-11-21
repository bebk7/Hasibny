import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'guided_tour_config.dart';
import 'guided_tour_step.dart';

/// Predefined application tour configurations and centralized keys.
class AppTours {
  AppTours._();

  /// Shared scope name for the main navigation tabs and HomeView
  static const String mainScope = 'main_app_tour_scope';

  // Tour IDs
  static const String dashboardTourId = 'dashboard_tour';
  static const String customersTourId = 'customers_tour';
  static const String transactionsTourId = 'transactions_tour';
  static const String settingsTourId = 'settings_tour';

  // Dashboard Target Keys
  static final GlobalKey keyDashboardHeader = GlobalKey(debugLabel: 'tour_dash_header');
  static final GlobalKey keyDashboardActions = GlobalKey(debugLabel: 'tour_dash_actions');
  static final GlobalKey keyDashboardCurrencies = GlobalKey(debugLabel: 'tour_dash_currencies');
  static final GlobalKey keyDashboardBalances = GlobalKey(debugLabel: 'tour_dash_balances');
  static final GlobalKey keyDashboardFab = GlobalKey(debugLabel: 'tour_dash_fab');

  // Customers Target Keys
  static final GlobalKey keyCustomersSearch = GlobalKey(debugLabel: 'tour_cust_search');
  static final GlobalKey keyCustomersList = GlobalKey(debugLabel: 'tour_cust_list');
  static final GlobalKey keyCustomersAdd = GlobalKey(debugLabel: 'tour_cust_add');

  // Transactions Target Keys
  static final GlobalKey keyTransactionsFilter = GlobalKey(debugLabel: 'tour_tx_filter');
  static final GlobalKey keyTransactionsList = GlobalKey(debugLabel: 'tour_tx_list');
  static final GlobalKey keyTransactionsExport = GlobalKey(debugLabel: 'tour_tx_export');

  // Settings Target Keys
  static final GlobalKey keySettingsStore = GlobalKey(debugLabel: 'tour_set_store');
  static final GlobalKey keySettingsBackup = GlobalKey(debugLabel: 'tour_set_backup');
  static final GlobalKey keySettingsSecurity = GlobalKey(debugLabel: 'tour_set_security');
  static final GlobalKey keySettingsGuidedTour = GlobalKey(debugLabel: 'tour_set_guided');

  /// Build Dashboard Tour Configuration
  static GuidedTourConfig buildDashboardTour() {
    return GuidedTourConfig(
      tourId: dashboardTourId,
      title: 'tour_dashboard_title'.tr,
      scope: mainScope,
      steps: [
        GuidedTourStep(
          id: 'dash_header',
          targetKey: keyDashboardHeader,
          title: 'tour_dashboard_header_title'.tr,
          description: 'tour_dashboard_header_desc'.tr,
          icon: Icons.storefront_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        GuidedTourStep(
          id: 'dash_actions',
          targetKey: keyDashboardActions,
          title: 'tour_dashboard_actions_title'.tr,
          description: 'tour_dashboard_actions_desc'.tr,
          icon: Icons.bolt_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.all(8),
        ),
        GuidedTourStep(
          id: 'dash_currencies',
          targetKey: keyDashboardCurrencies,
          title: 'tour_dashboard_currencies_title'.tr,
          description: 'tour_dashboard_currencies_desc'.tr,
          icon: Icons.currency_exchange_rounded,
          targetBorderRadius: BorderRadius.circular(14),
          targetPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        ),
        GuidedTourStep(
          id: 'dash_balances',
          targetKey: keyDashboardBalances,
          title: 'tour_dashboard_balances_title'.tr,
          description: 'tour_dashboard_balances_desc'.tr,
          icon: Icons.account_balance_wallet_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.all(8),
        ),
        GuidedTourStep(
          id: 'dash_fab',
          targetKey: keyDashboardFab,
          title: 'tour_dashboard_fab_title'.tr,
          description: 'tour_dashboard_fab_desc'.tr,
          icon: Icons.add_circle_outline_rounded,
          targetBorderRadius: BorderRadius.circular(32),
          targetPadding: const EdgeInsets.all(10),
        ),
      ],
    );
  }

  /// Build Customers Tour Configuration
  static GuidedTourConfig buildCustomersTour() {
    return GuidedTourConfig(
      tourId: customersTourId,
      title: 'tour_customers_title'.tr,
      scope: mainScope,
      steps: [
        GuidedTourStep(
          id: 'cust_search',
          targetKey: keyCustomersSearch,
          title: 'tour_customers_search_title'.tr,
          description: 'tour_customers_search_desc'.tr,
          icon: Icons.search_rounded,
          targetBorderRadius: BorderRadius.circular(14),
          targetPadding: const EdgeInsets.all(6),
        ),
        GuidedTourStep(
          id: 'cust_list',
          targetKey: keyCustomersList,
          title: 'tour_customers_list_title'.tr,
          description: 'tour_customers_list_desc'.tr,
          icon: Icons.people_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.all(8),
        ),
        GuidedTourStep(
          id: 'cust_add',
          targetKey: keyCustomersAdd,
          title: 'tour_customers_add_title'.tr,
          description: 'tour_customers_add_desc'.tr,
          icon: Icons.person_add_alt_1_rounded,
          targetBorderRadius: BorderRadius.circular(14),
          targetPadding: const EdgeInsets.all(6),
        ),
      ],
    );
  }

  /// Build Transactions Tour Configuration
  static GuidedTourConfig buildTransactionsTour() {
    return GuidedTourConfig(
      tourId: transactionsTourId,
      title: 'tour_transactions_title'.tr,
      scope: mainScope,
      steps: [
        GuidedTourStep(
          id: 'tx_filter',
          targetKey: keyTransactionsFilter,
          title: 'tour_transactions_filter_title'.tr,
          description: 'tour_transactions_filter_desc'.tr,
          icon: Icons.tune_rounded,
          targetBorderRadius: BorderRadius.circular(14),
          targetPadding: const EdgeInsets.all(6),
        ),
        GuidedTourStep(
          id: 'tx_list',
          targetKey: keyTransactionsList,
          title: 'tour_transactions_item_title'.tr,
          description: 'tour_transactions_item_desc'.tr,
          icon: Icons.receipt_long_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.all(8),
        ),
        GuidedTourStep(
          id: 'tx_export',
          targetKey: keyTransactionsExport,
          title: 'tour_transactions_export_title'.tr,
          description: 'tour_transactions_export_desc'.tr,
          icon: Icons.file_download_outlined,
          targetBorderRadius: BorderRadius.circular(14),
          targetPadding: const EdgeInsets.all(6),
        ),
      ],
    );
  }

  /// Build Settings Tour Configuration
  static GuidedTourConfig buildSettingsTour() {
    return GuidedTourConfig(
      tourId: settingsTourId,
      title: 'tour_settings_title'.tr,
      scope: mainScope,
      steps: [
        GuidedTourStep(
          id: 'set_store',
          targetKey: keySettingsStore,
          title: 'tour_settings_store_title'.tr,
          description: 'tour_settings_store_desc'.tr,
          icon: Icons.storefront_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.all(6),
        ),
        GuidedTourStep(
          id: 'set_backup',
          targetKey: keySettingsBackup,
          title: 'tour_settings_backup_title'.tr,
          description: 'tour_settings_backup_desc'.tr,
          icon: Icons.cloud_sync_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.all(6),
        ),
        GuidedTourStep(
          id: 'set_security',
          targetKey: keySettingsSecurity,
          title: 'tour_settings_security_title'.tr,
          description: 'tour_settings_security_desc'.tr,
          icon: Icons.security_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.all(6),
        ),
        GuidedTourStep(
          id: 'set_guided',
          targetKey: keySettingsGuidedTour,
          title: 'tour_settings_guided_tours_title'.tr,
          description: 'tour_settings_guided_tours_desc'.tr,
          icon: Icons.help_outline_rounded,
          targetBorderRadius: BorderRadius.circular(16),
          targetPadding: const EdgeInsets.all(6),
        ),
      ],
    );
  }
}
