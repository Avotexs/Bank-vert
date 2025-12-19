import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/app_theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final transactions = await _apiService.getTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkGreen, AppColors.backgroundDark],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTransactions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first transaction to track CO₂',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryEmoji(tx['category'] as String),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['description'] as String,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€${(tx['amount'] as num).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      if (tx['merchant'] != null && (tx['merchant'] as String).isNotEmpty) ...{
                        const SizedBox(height: 2),
                        Text(
                          tx['merchant'] as String,
                          style: TextStyle(
                            color: AppColors.textMuted.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      },
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(tx['carbonFootprint'] as num).toStringAsFixed(2)} kg',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CO₂',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'TRANSPORT_FLIGHT':
        return '✈️';
      case 'TRANSPORT_CAR':
        return '🚗';
      case 'TRANSPORT_PUBLIC':
        return '🚌';
      case 'FOOD_MEAT':
        return '🥩';
      case 'FOOD_LOCAL':
        return '🥬';
      case 'ENERGY':
        return '⚡';
      case 'SHOPPING':
        return '🛍️';
      default:
        return '📦';
    }
  }
}
