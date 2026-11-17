import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all'; // 'all', 'expense', 'income'

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = appState.currencySymbol;

    // Filter transactions
    var list = appState.transactions;

    if (_typeFilter == 'expense') {
      list = list.where((t) => t.type == TransactionType.expense).toList();
    } else if (_typeFilter == 'income') {
      list = list.where((t) => t.type == TransactionType.income).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((t) {
        return t.title.toLowerCase().contains(query) ||
            (t.note?.toLowerCase().contains(query) ?? false) ||
            t.categoryId.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by date descending
    list.sort((a, b) => b.date.compareTo(a.date));

    // Calculate total for filtered
    final filteredTotal = list.fold(0.0, (sum, t) {
      return sum + (t.type == TransactionType.income ? t.amount : -t.amount);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity & Records'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search by title, note, or category...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF151C2C) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF242E45) : Colors.grey.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF242E45) : Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips Row & Summary
              Row(
                children: [
                  _buildFilterChip('all', 'All', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('expense', 'Expenses', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('income', 'Incomes', isDark),
                  const Spacer(),
                  Text(
                    '${list.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Grouped Transactions List
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48,
                                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No matching transactions found',
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final tx = list[index];
                          return TransactionTile(
                            transaction: tx,
                            currencySymbol: currency,
                            onDelete: () => appState.deleteTransaction(tx.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isDark) {
    final isSelected = _typeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
      ),
      onSelected: (_) => setState(() => _typeFilter = value),
    );
  }
}
