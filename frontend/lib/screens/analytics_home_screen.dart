import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../core/models/analytics_models.dart';

class AnalyticsHomeScreen extends StatefulWidget {
  const AnalyticsHomeScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsHomeScreen> createState() => _AnalyticsHomeScreenState();
}

class _AnalyticsHomeScreenState extends State<AnalyticsHomeScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  AnalyticsSummary? _summary;
  List<TimeSeriesDataPoint> _timeSeries = [];
  List<CategoryBreakdown> _categories = [];
  List<MerchantAnalytics> _merchants = [];
  List<Insight> _insights = [];
  
  bool _loading = true;
  String? _errorMessage;
  String _period = '30'; // days
  bool _useDemoData = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    
    try {
      final now = DateTime.now();
      final to = now.toIso8601String().split('T')[0];
      final from = now.subtract(Duration(days: int.parse(_period))).toIso8601String().split('T')[0];
      
      print('Loading analytics from $from to $to');
      
      final summary = await _analyticsService.getSummary(from: from, to: to);
      print('Summary loaded: $summary');
      
      final timeSeries = await _analyticsService.getTimeSeries(from: from, to: to);
      print('TimeSeries loaded: ${timeSeries.length} points');
      
      final categories = await _analyticsService.getCategoryBreakdown(from: from, to: to);
      print('Categories loaded: ${categories.length} categories');
      
      final merchants = await _analyticsService.getTopMerchants(from: from, to: to, limit: 5);
      print('Merchants loaded: ${merchants.length} merchants');
      
      final insights = await _analyticsService.getInsights(from: from, to: to);
      print('Insights loaded: ${insights.length} insights');
      
      // Check if data is empty - if so, use demo data
      bool isEmpty = summary == null && timeSeries.isEmpty && categories.isEmpty;
      
      if (isEmpty) {
        _loadDemoData();
      } else {
        setState(() {
          _summary = summary;
          _timeSeries = timeSeries;
          _categories = categories;
          _merchants = merchants;
          _insights = insights;
          _loading = false;
          _useDemoData = false;
        });
      }
    } catch (e) {
      print('Error loading analytics: $e');
      // Load demo data on error
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    setState(() {
      _useDemoData = true;
      _summary = AnalyticsSummary(
        totalCO2: 156.75,
        averageCO2PerTransaction: 15.68,
        transactionCount: 10,
        evolutionPercentage: -12.5,
        periodStart: DateTime.now().subtract(Duration(days: int.parse(_period))).toIso8601String().split('T')[0],
        periodEnd: DateTime.now().toIso8601String().split('T')[0],
        topCategory: TopCategoryInfo(
          name: 'TRANSPORT_CAR',
          displayName: 'Car Transport',
          co2: 65.0,
          percentage: 41.5,
        ),
      );
      
      _timeSeries = [
        TimeSeriesDataPoint(date: '2025-12-13', co2Value: 12.5, transactionCount: 2),
        TimeSeriesDataPoint(date: '2025-12-14', co2Value: 18.3, transactionCount: 1),
        TimeSeriesDataPoint(date: '2025-12-15', co2Value: 25.0, transactionCount: 3),
        TimeSeriesDataPoint(date: '2025-12-16', co2Value: 8.7, transactionCount: 1),
        TimeSeriesDataPoint(date: '2025-12-17', co2Value: 32.5, transactionCount: 2),
        TimeSeriesDataPoint(date: '2025-12-18', co2Value: 28.0, transactionCount: 2),
        TimeSeriesDataPoint(date: '2025-12-19', co2Value: 31.75, transactionCount: 2),
      ];
      
      _categories = [
        CategoryBreakdown(
          category: 'TRANSPORT_CAR',
          displayName: 'Car Transport',
          totalCO2: 65.0,
          percentage: 41.5,
          transactionCount: 4,
          color: '#FFA07A',
        ),
        CategoryBreakdown(
          category: 'FOOD_MEAT',
          displayName: 'Meat & Dairy',
          totalCO2: 48.25,
          percentage: 30.8,
          transactionCount: 3,
          color: '#FF8C00',
        ),
        CategoryBreakdown(
          category: 'ENERGY',
          displayName: 'Energy',
          totalCO2: 28.5,
          percentage: 18.2,
          transactionCount: 2,
          color: '#FFD700',
        ),
        CategoryBreakdown(
          category: 'SHOPPING',
          displayName: 'Shopping',
          totalCO2: 15.0,
          percentage: 9.5,
          transactionCount: 1,
          color: '#9370DB',
        ),
      ];
      
      _merchants = [
        MerchantAnalytics(
          merchantName: 'Gas Station',
          totalCO2: 45.0,
          transactionCount: 3,
          averageCO2: 15.0,
          primaryCategory: 'Car Transport',
        ),
        MerchantAnalytics(
          merchantName: 'Supermarket',
          totalCO2: 32.5,
          transactionCount: 2,
          averageCO2: 16.25,
          primaryCategory: 'Meat & Dairy',
        ),
        MerchantAnalytics(
          merchantName: 'Restaurant',
          totalCO2: 25.0,
          transactionCount: 2,
          averageCO2: 12.5,
          primaryCategory: 'Meat & Dairy',
        ),
      ];
      
      _insights = [
        Insight(
          type: 'ALERT',
          severity: 'WARNING',
          title: 'High CO₂ Category',
          message: 'Car Transport represents 41.5% of your carbon footprint this period.',
          actionable: true,
          suggestedAction: 'Consider using public transport or carpooling',
        ),
        Insight(
          type: 'TREND',
          severity: 'SUCCESS',
          title: 'Great Progress!',
          message: 'Your CO₂ emissions decreased by 12.5% compared to the previous period.',
          actionable: false,
        ),
        Insight(
          type: 'RECOMMENDATION',
          severity: 'INFO',
          title: 'Reduce Food Impact',
          message: 'Try incorporating more plant-based meals to reduce your food carbon footprint.',
          actionable: true,
          suggestedAction: 'Start with one plant-based meal per day',
        ),
      ];
      
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F17),
      appBar: AppBar(
        title: const Text('CO₂ Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _period = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90', child: Text('Last 3 months')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(_period == '7' ? 'Week' : _period == '30' ? 'Month' : '3 Months'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Loading analytics...',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              color: Colors.green.shade400,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Demo Data Banner
                    if (_useDemoData)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade800.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade600.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber.shade400, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Showing demo data. Add transactions to see your real analytics!',
                                style: TextStyle(color: Colors.amber.shade300, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // KPI Cards
                    _buildKPICards(),
                    const SizedBox(height: 24),
                    
                    // Time Series Chart
                    if (_timeSeries.isNotEmpty) ...[
                      _buildSectionTitle('CO₂ Trend'),
                      const SizedBox(height: 12),
                      _buildTimeSeriesChart(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Category Breakdown with Pie Chart
                    if (_categories.isNotEmpty) ...[
                      _buildSectionTitle('By Category'),
                      const SizedBox(height: 12),
                      _buildCategoryPieChart(),
                      const SizedBox(height: 16),
                      _buildCategoryBreakdown(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Top Merchants
                    if (_merchants.isNotEmpty) ...[
                      _buildSectionTitle('Top Emitters'),
                      const SizedBox(height: 12),
                      _buildMerchantsList(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Insights
                    if (_insights.isNotEmpty) ...[
                      _buildSectionTitle('Insights & Recommendations'),
                      const SizedBox(height: 12),
                      _buildInsights(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildKPICards() {
    if (_summary == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Total CO₂',
                '${_summary!.totalCO2.toStringAsFixed(2)} kg',
                Icons.eco,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                'Transactions',
                '${_summary!.transactionCount}',
                Icons.receipt_long,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Average',
                '${_summary!.averageCO2PerTransaction.toStringAsFixed(2)} kg',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                'Evolution',
                '${_summary!.evolutionPercentage >= 0 ? '+' : ''}${_summary!.evolutionPercentage.toStringAsFixed(1)}%',
                _summary!.evolutionPercentage >= 0 ? Icons.trending_up : Icons.trending_down,
                _summary!.evolutionPercentage >= 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesChart() {
    if (_timeSeries.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < _timeSeries.length; i++) {
      spots.add(FlSpot(i.toDouble(), _timeSeries[i].co2Value));
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _timeSeries.length) {
                    final date = _timeSeries[value.toInt()].date;
                    final parts = date.split('-');
                    return Text(
                      '${parts[2]}/${parts[1]}',
                      style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green.shade400,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.green.shade400,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400.withOpacity(0.3),
                    Colors.green.shade400.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _categories.map((cat) {
                  return PieChartSectionData(
                    color: _parseColor(cat.color),
                    value: cat.percentage,
                    title: '${cat.percentage.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _categories.take(4).map((cat) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _parseColor(cat.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat.displayName,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: _categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _parseColor(category.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: category.percentage / 100,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation(_parseColor(category.color)),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${category.percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${category.totalCO2.toStringAsFixed(2)} kg',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMerchantsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: _merchants.asMap().entries.map((entry) {
          final index = entry.key;
          final merchant = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.merchantName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        merchant.primaryCategory,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${merchant.totalCO2.toStringAsFixed(2)} kg',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade400,
                      ),
                    ),
                    Text(
                      '${merchant.transactionCount} txn',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsights() {
    return Column(
      children: _insights.map((insight) {
        Color color;
        IconData icon;
        
        switch (insight.severity) {
          case 'WARNING':
            color = Colors.orange;
            icon = Icons.warning_amber_rounded;
            break;
          case 'SUCCESS':
            color = Colors.green;
            icon = Icons.check_circle;
            break;
          default:
            color = Colors.blue;
            icon = Icons.info;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.message,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
                    ),
                    if (insight.suggestedAction != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb_outline, color: color, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                insight.suggestedAction!,
                                style: TextStyle(fontSize: 12, color: color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}
