class AnalyticsSummary {
  final double totalCO2;
  final double averageCO2PerTransaction;
  final int transactionCount;
  final TopCategoryInfo? topCategory;
  final double evolutionPercentage;
  final String periodStart;
  final String periodEnd;

  AnalyticsSummary({
    required this.totalCO2,
    required this.averageCO2PerTransaction,
    required this.transactionCount,
    this.topCategory,
    required this.evolutionPercentage,
    required this.periodStart,
    required this.periodEnd,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalCO2: (json['totalCO2'] as num?)?.toDouble() ?? 0.0,
      averageCO2PerTransaction: (json['averageCO2PerTransaction'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
      topCategory: json['topCategory'] != null
          ? TopCategoryInfo.fromJson(json['topCategory'])
          : null,
      evolutionPercentage: (json['evolutionPercentage'] as num?)?.toDouble() ?? 0.0,
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
    );
  }
}

class TopCategoryInfo {
  final String name;
  final String displayName;
  final double co2;
  final double percentage;

  TopCategoryInfo({
    required this.name,
    required this.displayName,
    required this.co2,
    required this.percentage,
  });

  factory TopCategoryInfo.fromJson(Map<String, dynamic> json) {
    return TopCategoryInfo(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      co2: (json['co2'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class TimeSeriesDataPoint {
  final String date;
  final double co2Value;
  final int transactionCount;

  TimeSeriesDataPoint({
    required this.date,
    required this.co2Value,
    required this.transactionCount,
  });

  factory TimeSeriesDataPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesDataPoint(
      date: json['date'] as String,
      co2Value: (json['co2Value'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }
}

class CategoryBreakdown {
  final String category;
  final String displayName;
  final double totalCO2;
  final double percentage;
  final int transactionCount;
  final String color;

  CategoryBreakdown({
    required this.category,
    required this.displayName,
    required this.totalCO2,
    required this.percentage,
    required this.transactionCount,
    required this.color,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] as String,
      displayName: json['displayName'] as String,
      totalCO2: (json['totalCO2'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      color: json['color'] as String,
    );
  }
}

class MerchantAnalytics {
  final String merchantName;
  final double totalCO2;
  final int transactionCount;
  final double averageCO2;
  final String primaryCategory;

  MerchantAnalytics({
    required this.merchantName,
    required this.totalCO2,
    required this.transactionCount,
    required this.averageCO2,
    required this.primaryCategory,
  });

  factory MerchantAnalytics.fromJson(Map<String, dynamic> json) {
    return MerchantAnalytics(
      merchantName: json['merchantName'] as String,
      totalCO2: (json['totalCO2'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      averageCO2: (json['averageCO2'] as num).toDouble(),
      primaryCategory: json['primaryCategory'] as String,
    );
  }
}

class Insight {
  final String type; // TREND, ALERT, RECOMMENDATION
  final String severity; // INFO, WARNING, SUCCESS
  final String title;
  final String message;
  final bool actionable;
  final String? suggestedAction;

  Insight({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.actionable,
    this.suggestedAction,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      type: json['type'] as String,
      severity: json['severity'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      actionable: json['actionable'] as bool,
      suggestedAction: json['suggestedAction'] as String?,
    );
  }
}
