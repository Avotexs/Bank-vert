import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> _categories = [];
  String? _selectedCategory;
  double _estimatedCO2 = 0.0;
  bool _isLoading = false;
  bool _isCategoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _amountController.addListener(_calculateEstimate);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() => _isCategoriesLoading = false);
    }
  }

  void _calculateEstimate() {
    if (_selectedCategory == null || _amountController.text.isEmpty) {
      setState(() => _estimatedCO2 = 0.0);
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final category = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
      orElse: () => {'carbonFactor': 0.04},
    );
    final factor = (category['carbonFactor'] as num).toDouble();

    setState(() => _estimatedCO2 = amount * factor);
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.createTransaction(
        _descriptionController.text,
        double.parse(_amountController.text),
        _selectedCategory!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaction added! CO₂: ${_estimatedCO2.toStringAsFixed(2)} kg',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkGreen, AppColors.backgroundDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textLight,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.add_card, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    const Text(
                      'Add Transaction',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CO2 Estimate Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen,
                                AppColors.darkGreen,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.eco,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${_estimatedCO2.toStringAsFixed(2)} kg CO₂',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estimated Carbon Footprint',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Transaction Form
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Transaction Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Description
                              TextFormField(
                                controller: _descriptionController,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  hintText: 'e.g., Flight to Paris',
                                  labelStyle: TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted.withOpacity(0.5),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.description_outlined,
                                    color: AppColors.primaryGreen,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.textMuted.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.backgroundDark,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Amount
                              TextFormField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Amount (€)',
                                  hintText: 'e.g., 150.00',
                                  labelStyle: TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted.withOpacity(0.5),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.euro,
                                    color: AppColors.primaryGreen,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.textMuted.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.backgroundDark,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Category Dropdown
                              _isCategoriesLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryGreen,
                                      ),
                                    )
                                  : DropdownButtonFormField<String>(
                                      value: _selectedCategory,
                                      dropdownColor: AppColors.cardDark,
                                      style: const TextStyle(
                                        color: AppColors.textLight,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Category',
                                        labelStyle: TextStyle(
                                          color: AppColors.textMuted,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.category_outlined,
                                          color: AppColors.primaryGreen,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.textMuted
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: AppColors.backgroundDark,
                                      ),
                                      items: _categories
                                          .map<DropdownMenuItem<String>>((
                                            category,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: category['name'] as String,
                                              child: Text(
                                                category['displayName']
                                                    as String,
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (value) {
                                        setState(
                                          () => _selectedCategory = value,
                                        );
                                        _calculateEstimate();
                                      },
                                    ),
                              const SizedBox(height: 24),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _submitTransaction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Add Transaction',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'What is Carbon Footprint?',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Carbon footprint is the amount of CO₂ emitted by your purchases. '
                                'For example:\n'
                                '• ✈️ Flight ticket → High CO₂\n'
                                '• 🥬 Local vegetables → Low CO₂\n\n'
                                'We calculate it automatically based on the category and amount.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
