import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, String>> _availableCurrencies = [
    {'symbol': '\$', 'code': 'USD', 'name': 'US Dollar'},
    {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
    {'symbol': '£', 'code': 'GBP', 'name': 'British Pound'},
    {'symbol': '₹', 'code': 'INR', 'name': 'Indian Rupee'},
    {'symbol': '¥', 'code': 'JPY', 'name': 'Japanese Yen / Yuan'},
    {'symbol': '₩', 'code': 'KRW', 'name': 'South Korean Won'},
    {'symbol': '₱', 'code': 'PHP', 'name': 'Philippine Peso'},
    {'symbol': 'C\$', 'code': 'CAD', 'name': 'Canadian Dollar'},
    {'symbol': 'A\$', 'code': 'AUD', 'name': 'Australian Dollar'},
    {'symbol': 'CHF', 'code': 'CHF', 'name': 'Swiss Franc'},
    {'symbol': 'R\$', 'code': 'BRL', 'name': 'Brazilian Real'},
  ];

  void _showCurrencyPicker(BuildContext context, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Main Currency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableCurrencies.length,
                  itemBuilder: (ctx, idx) {
                    final item = _availableCurrencies[idx];
                    final isSel = item['symbol'] == state.currencySymbol;

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E273D) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['symbol']!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      title: Text('${item['name']} (${item['code']})'),
                      trailing: isSel
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF818CF8))
                          : null,
                      onTap: () {
                        state.setCurrency(item['symbol']!);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportDataJson(BuildContext context, AppState state) {
    final jsonMap = {
      'exportedAt': DateTime.now().toIso8601String(),
      'currency': state.currencySymbol,
      'transactions': state.transactions.map((t) => t.toJson()).toList(),
      'budgets': state.budgets.map((b) => b.toJson()).toList(),
      'savingsGoals': state.savingsGoals.map((g) => g.toJson()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonMap);
    Clipboard.setData(ClipboardData(text: jsonStr));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data copied to clipboard as JSON backup!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences & Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Preference Section
            _buildSectionHeader('DISPLAY & REGIONAL', isDark),
            _buildSettingsTile(
              context: context,
              icon: Icons.currency_exchange_rounded,
              title: 'Primary Currency',
              subtitle: 'Active: ${appState.currencySymbol}',
              onTap: () => _showCurrencyPicker(context, appState),
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.palette_outlined,
              title: 'Theme & Appearance',
              subtitle: appState.themeMode == ThemeMode.dark
                  ? 'Celestial Dark'
                  : (appState.themeMode == ThemeMode.light ? 'Moonlit Light' : 'System Default'),
              onTap: () {
                final next = appState.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                appState.setThemeMode(next);
              },
            ),

            const SizedBox(height: 20),
            _buildSectionHeader('DATA & PRIVACY', isDark),
            _buildSettingsTile(
              context: context,
              icon: Icons.file_download_outlined,
              title: 'Export Backup (JSON)',
              subtitle: 'Copy complete financial ledger to clipboard',
              onTap: () => _exportDataJson(context, appState),
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.restart_alt_rounded,
              title: 'Reset & Restore Starter Data',
              subtitle: 'Reset storage or reload sample transactions',
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset All Data?'),
                    content: const Text(
                      'This will reset your data back to default starter demo transactions.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: MoonsTheme.expenseRed),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await appState.resetAllData();
                }
              },
            ),

            const SizedBox(height: 20),
            _buildSectionHeader('ABOUT MOONS', isDark),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151C2C) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? const Color(0xFF242E45) : Colors.grey.shade100,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.nightlight_round, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Moons Finance',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Version 1.0.0 • Material 3 Expressive',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Moons is crafted with Material 3 Expressive guidelines, offline-first JSON persistence, dynamic budgeting, and lunar aesthetic cash flow management.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151C2C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF242E45) : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E273D) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF818CF8)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}
