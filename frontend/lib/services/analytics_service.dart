import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/analytics_models.dart';

class AnalyticsService {
  static const String baseUrl = 'http://localhost:8080/api/analytics';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<AnalyticsSummary?> getSummary({String? from, String? to}) async {
    try {
      final token = await _getToken();
      print('Analytics getSummary - Token: ${token != null ? "exists (${token.length} chars)" : "NULL"}');
      if (token == null) {
        print('Analytics getSummary - No token, returning null');
        return null;
      }

      final queryParams = <String, String>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final uri = Uri.parse('$baseUrl/summary').replace(queryParameters: queryParams);
      print('Analytics getSummary - Calling: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Analytics getSummary - Response status: ${response.statusCode}');
      print('Analytics getSummary - Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        return AnalyticsSummary.fromJson(json.decode(response.body));
      }
      print('Analytics getSummary - Non-200 response, returning null');
      return null;
    } catch (e) {
      print('Error fetching summary: $e');
      return null;
    }
  }

  Future<List<TimeSeriesDataPoint>> getTimeSeries({
    String? from,
    String? to,
    String groupBy = 'day',
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final queryParams = <String, String>{'groupBy': groupBy};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final uri = Uri.parse('$baseUrl/timeseries').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => TimeSeriesDataPoint.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching timeseries: $e');
      return [];
    }
  }

  Future<List<CategoryBreakdown>> getCategoryBreakdown({
    String? from,
    String? to,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final queryParams = <String, String>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final uri = Uri.parse('$baseUrl/by-category').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => CategoryBreakdown.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching category breakdown: $e');
      return [];
    }
  }

  Future<List<MerchantAnalytics>> getTopMerchants({
    String? from,
    String? to,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final queryParams = <String, String>{'limit': limit.toString()};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final uri = Uri.parse('$baseUrl/top-merchants').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => MerchantAnalytics.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching top merchants: $e');
      return [];
    }
  }

  Future<List<Insight>> getInsights({String? from, String? to}) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final queryParams = <String, String>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final uri = Uri.parse('$baseUrl/insights').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Insight.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching insights: $e');
      return [];
    }
  }
}
