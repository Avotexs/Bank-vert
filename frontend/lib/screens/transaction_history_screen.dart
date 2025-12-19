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
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _transactions = [];
  List<dynamic> _filteredTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filter and sort options
  String _sortOption = 'recent';
  String _selectedCategory = 'all';
  
  final List<Map<String, String>> _sortOptions = [
    {'value': 'recent', 'label': 'Most Recent'},
    {'value': 'oldest', 'label': 'Oldest'},
    {'value': 'co2_high', 'label': 'Highest CO₂'},
    {'value': 'co2_low', 'label': 'Lowest CO₂'},
    {'value': 'price_high', 'label': 'Highest Price'},
    {'value': 'price_low', 'label': 'Lowest Price'},
  ];
  
  final List<Map<String, String>> _categoryOptions = [
    {'value': 'all', 'label': 'All'},
    {'value': 'TRANSPORT', 'label': 'Transport'},
    {'value': 'FOOD', 'label': 'Food'},
    {'value': 'ENERGY', 'label': 'Energy'},
    {'value': 'SHOPPING', 'label': 'Shopping'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    _applyFilters();
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
      _applyFilters();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }
  
  void _applyFilters() {
    List<dynamic> result = List.from(_transactions);
    
    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      result = result.where((tx) {
        final description = (tx['description'] as String? ?? '').toLowerCase();
        final merchant = (tx['merchant'] as String? ?? '').toLowerCase();
        return description.contains(searchQuery) || merchant.contains(searchQuery);
      }).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != 'all') {
      result = result.where((tx) {
        final category = tx['category'] as String? ?? '';
        return category.startsWith(_selectedCategory);
      }).toList();
    }
    
    // Apply sorting
    result.sort((a, b) {
      switch (_sortOption) {
        case 'co2_high':
          return ((b['carbonFootprint'] as num?) ?? 0)
              .compareTo((a['carbonFootprint'] as num?) ?? 0);
        case 'co2_low':
          return ((a['carbonFootprint'] as num?) ?? 0)
              .compareTo((b['carbonFootprint'] as num?) ?? 0);
        case 'price_high':
          return ((b['amount'] as num?) ?? 0)
              .compareTo((a['amount'] as num?) ?? 0);
        case 'price_low':
          return ((a['amount'] as num?) ?? 0)
              .compareTo((b['amount'] as num?) ?? 0);
        case 'oldest':
          final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
          return dateA.compareTo(dateB);
        case 'recent':
        default:
          final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA);
      }
    });
    
    setState(() {
      _filteredTransactions = result;
    });
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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textLight),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                ),
              ),
            ),
            
            // Sort Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sort, color: AppColors.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _sortOptions.map((option) {
                        final isSelected = _sortOption == option['value'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(option['label']!),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _sortOption = option['value']!;
                              });
                              _applyFilters();
                            },
                            backgroundColor: AppColors.cardDark,
                            selectedColor: AppColors.primaryGreen.withOpacity(0.3),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Category Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_list, color: AppColors.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Category',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categoryOptions.map((option) {
                        final isSelected = _selectedCategory == option['value'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(option['label']!),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = option['value']!;
                              });
                              _applyFilters();
                            },
                            backgroundColor: AppColors.cardDark,
                            selectedColor: AppColors.primaryGreen.withOpacity(0.3),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredTransactions.length} transaction${_filteredTransactions.length != 1 ? 's' : ''}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Transaction List
            Expanded(child: _buildBody()),
          ],
        ),
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

    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _transactions.isEmpty ? Icons.receipt_long_outlined : Icons.search_off,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              _transactions.isEmpty ? 'No transactions yet' : 'No matching transactions',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _transactions.isEmpty 
                  ? 'Add your first transaction to track CO₂'
                  : 'Try adjusting your search or filters',
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final tx = _filteredTransactions[index];
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
