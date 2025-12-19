package com.bankverte.api.analytics;

import com.bankverte.api.analytics.dto.*;
import com.bankverte.api.transaction.Transaction;
import com.bankverte.api.transaction.TransactionCategory;
import com.bankverte.api.transaction.TransactionRepository;
import com.bankverte.api.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

        private final TransactionRepository transactionRepository;
        private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ISO_DATE;

        // Category colors for charts
        private static final Map<String, String> CATEGORY_COLORS = Map.of(
                        "TRANSPORT_FLIGHT", "#FF6B6B",
                        "TRANSPORT_CAR", "#FFA07A",
                        "TRANSPORT_PUBLIC", "#90EE90",
                        "FOOD_MEAT", "#FF8C00",
                        "FOOD_LOCAL", "#32CD32",
                        "ENERGY", "#FFD700",
                        "SHOPPING", "#9370DB",
                        "OTHER", "#808080");

        @GetMapping("/summary")
        public ResponseEntity<?> getSummary(
                        @AuthenticationPrincipal User user,
                        @RequestParam(required = false) String from,
                        @RequestParam(required = false) String to) {

                LocalDateTime endDate = to != null ? parseEndDate(to) : LocalDateTime.now();
                LocalDateTime startDate = from != null
                                ? parseStartDate(from)
                                : endDate.minusDays(365).withHour(0).withMinute(0).withSecond(0).withNano(0);

                System.out.println("=== ANALYTICS DEBUG ===");
                System.out.println("User ID: " + (user != null ? user.getId() : "NULL"));
                System.out.println("User Email: " + (user != null ? user.getEmail() : "NULL"));
                System.out.println("Date Range: " + startDate + " to " + endDate);

                // Get current period data
                List<Transaction> currentTransactions = transactionRepository
                                .findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(user, startDate, endDate);

                System.out.println("Transactions found: " + currentTransactions.size());
                if (!currentTransactions.isEmpty()) {
                        System.out.println("First transaction: " + currentTransactions.get(0).getDescription());
                }

                Double totalCO2 = currentTransactions.stream()
                                .mapToDouble(t -> t.getCarbonFootprint() != null ? t.getCarbonFootprint() : 0.0)
                                .sum();

                Double avgCO2 = currentTransactions.isEmpty() ? 0.0 : totalCO2 / currentTransactions.size();

                // Find top category
                Map<TransactionCategory, Double> categoryTotals = currentTransactions.stream()
                                .filter(t -> t.getCategory() != null && t.getCarbonFootprint() != null)
                                .collect(Collectors.groupingBy(
                                                Transaction::getCategory,
                                                Collectors.summingDouble(Transaction::getCarbonFootprint)));

                AnalyticsSummaryResponse.TopCategoryInfo topCategory = categoryTotals.entrySet().stream()
                                .max(Map.Entry.comparingByValue())
                                .map(entry -> AnalyticsSummaryResponse.TopCategoryInfo.builder()
                                                .name(entry.getKey().name())
                                                .displayName(entry.getKey().getDisplayName())
                                                .co2(entry.getValue())
                                                .percentage(totalCO2 > 0 ? (entry.getValue() / totalCO2) * 100 : 0.0)
                                                .build())
                                .orElse(null);

                // Calculate evolution vs previous period
                long daysDiff = ChronoUnit.DAYS.between(startDate, endDate);
                LocalDateTime prevStart = startDate.minusDays(daysDiff);
                Double prevTotal = transactionRepository.sumCarbonFootprintByUserBetween(user, prevStart, startDate);
                Double evolutionPct = (prevTotal != null && prevTotal > 0)
                                ? ((totalCO2 - prevTotal) / prevTotal) * 100
                                : 0.0;

                AnalyticsSummaryResponse response = AnalyticsSummaryResponse.builder()
                                .totalCO2(Math.round(totalCO2 * 100.0) / 100.0)
                                .averageCO2PerTransaction(Math.round(avgCO2 * 100.0) / 100.0)
                                .transactionCount(currentTransactions.size())
                                .topCategory(topCategory)
                                .evolutionPercentage(Math.round(evolutionPct * 10.0) / 10.0)
                                .periodStart(startDate.format(DATE_FORMATTER))
                                .periodEnd(endDate.format(DATE_FORMATTER))
                                .build();

                return ResponseEntity.ok(response);
        }

        @GetMapping("/timeseries")
        public ResponseEntity<?> getTimeSeries(
                        @AuthenticationPrincipal User user,
                        @RequestParam(required = false) String from,
                        @RequestParam(required = false) String to,
                        @RequestParam(defaultValue = "day") String groupBy) {

                LocalDateTime endDate = to != null ? parseEndDate(to) : LocalDateTime.now();
                LocalDateTime startDate = from != null
                                ? parseStartDate(from)
                                : endDate.minusDays(30).withHour(0).withMinute(0).withSecond(0).withNano(0);

                List<Transaction> transactions = transactionRepository
                                .findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(user, startDate, endDate);

                Map<LocalDate, List<Transaction>> grouped = transactions.stream()
                                .collect(Collectors.groupingBy(t -> t.getCreatedAt().toLocalDate()));

                List<TimeSeriesDataPoint> dataPoints = grouped.entrySet().stream()
                                .map(entry -> {
                                        Double co2 = entry.getValue().stream()
                                                        .mapToDouble(t -> t.getCarbonFootprint() != null
                                                                        ? t.getCarbonFootprint()
                                                                        : 0.0)
                                                        .sum();
                                        return TimeSeriesDataPoint.builder()
                                                        .date(entry.getKey().format(DATE_FORMATTER))
                                                        .co2Value(Math.round(co2 * 100.0) / 100.0)
                                                        .transactionCount(entry.getValue().size())
                                                        .build();
                                })
                                .sorted(Comparator.comparing(TimeSeriesDataPoint::getDate))
                                .collect(Collectors.toList());

                return ResponseEntity.ok(dataPoints);
        }

        @GetMapping("/by-category")
        public ResponseEntity<?> getByCategory(
                        @AuthenticationPrincipal User user,
                        @RequestParam(required = false) String from,
                        @RequestParam(required = false) String to) {

                LocalDateTime endDate = to != null ? parseEndDate(to) : LocalDateTime.now();
                LocalDateTime startDate = from != null
                                ? parseStartDate(from)
                                : endDate.minusDays(30).withHour(0).withMinute(0).withSecond(0).withNano(0);

                List<Transaction> transactions = transactionRepository
                                .findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(user, startDate, endDate);

                Double totalCO2 = transactions.stream()
                                .mapToDouble(t -> t.getCarbonFootprint() != null ? t.getCarbonFootprint() : 0.0)
                                .sum();

                Map<TransactionCategory, List<Transaction>> grouped = transactions.stream()
                                .filter(t -> t.getCategory() != null)
                                .collect(Collectors.groupingBy(Transaction::getCategory));

                List<CategoryBreakdown> breakdown = grouped.entrySet().stream()
                                .map(entry -> {
                                        Double co2 = entry.getValue().stream()
                                                        .mapToDouble(t -> t.getCarbonFootprint() != null
                                                                        ? t.getCarbonFootprint()
                                                                        : 0.0)
                                                        .sum();
                                        return CategoryBreakdown.builder()
                                                        .category(entry.getKey().name())
                                                        .displayName(entry.getKey().getDisplayName())
                                                        .totalCO2(Math.round(co2 * 100.0) / 100.0)
                                                        .percentage(totalCO2 > 0
                                                                        ? Math.round((co2 / totalCO2) * 1000.0) / 10.0
                                                                        : 0.0)
                                                        .transactionCount(entry.getValue().size())
                                                        .color(CATEGORY_COLORS.getOrDefault(entry.getKey().name(),
                                                                        "#808080"))
                                                        .build();
                                })
                                .sorted((a, b) -> Double.compare(b.getTotalCO2(), a.getTotalCO2()))
                                .collect(Collectors.toList());

                return ResponseEntity.ok(breakdown);
        }

        @GetMapping("/top-merchants")
        public ResponseEntity<?> getTopMerchants(
                        @AuthenticationPrincipal User user,
                        @RequestParam(required = false) String from,
                        @RequestParam(required = false) String to,
                        @RequestParam(defaultValue = "10") Integer limit) {

                LocalDateTime endDate = to != null ? parseEndDate(to) : LocalDateTime.now();
                LocalDateTime startDate = from != null
                                ? parseStartDate(from)
                                : endDate.minusDays(30).withHour(0).withMinute(0).withSecond(0).withNano(0);

                List<Transaction> transactions = transactionRepository
                                .findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(user, startDate, endDate);

                Map<String, List<Transaction>> grouped = transactions.stream()
                                .filter(t -> t.getMerchant() != null && !t.getMerchant().isEmpty())
                                .collect(Collectors.groupingBy(Transaction::getMerchant));

                List<MerchantAnalytics> merchants = grouped.entrySet().stream()
                                .map(entry -> {
                                        List<Transaction> merchantTxns = entry.getValue();
                                        Double totalCO2 = merchantTxns.stream()
                                                        .mapToDouble(t -> t.getCarbonFootprint() != null
                                                                        ? t.getCarbonFootprint()
                                                                        : 0.0)
                                                        .sum();
                                        String primaryCat = merchantTxns.stream()
                                                        .filter(t -> t.getCategory() != null)
                                                        .collect(Collectors.groupingBy(Transaction::getCategory,
                                                                        Collectors.counting()))
                                                        .entrySet().stream()
                                                        .max(Map.Entry.comparingByValue())
                                                        .map(e -> e.getKey().getDisplayName())
                                                        .orElse("Unknown");

                                        return MerchantAnalytics.builder()
                                                        .merchantName(entry.getKey())
                                                        .totalCO2(Math.round(totalCO2 * 100.0) / 100.0)
                                                        .transactionCount(merchantTxns.size())
                                                        .averageCO2(Math.round((totalCO2 / merchantTxns.size()) * 100.0)
                                                                        / 100.0)
                                                        .primaryCategory(primaryCat)
                                                        .build();
                                })
                                .sorted((a, b) -> Double.compare(b.getTotalCO2(), a.getTotalCO2()))
                                .limit(limit)
                                .collect(Collectors.toList());

                return ResponseEntity.ok(merchants);
        }

        @GetMapping("/transactions")
        public ResponseEntity<?> getFilteredTransactions(
                        @AuthenticationPrincipal User user,
                        @RequestParam(required = false) String from,
                        @RequestParam(required = false) String to,
                        @RequestParam(required = false) String category,
                        @RequestParam(required = false) String merchant,
                        @RequestParam(required = false) Double minAmount,
                        @RequestParam(required = false) Double maxAmount) {

                LocalDateTime endDate = to != null ? parseEndDate(to) : LocalDateTime.now();
                LocalDateTime startDate = from != null
                                ? parseStartDate(from)
                                : endDate.minusMonths(1).withHour(0).withMinute(0).withSecond(0).withNano(0);

                List<Transaction> transactions = transactionRepository
                                .findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(user, startDate, endDate)
                                .stream()
                                .filter(t -> category == null
                                                || (t.getCategory() != null && t.getCategory().name().equals(category)))
                                .filter(t -> merchant == null
                                                || (t.getMerchant() != null && t.getMerchant().toLowerCase()
                                                                .contains(merchant.toLowerCase())))
                                .filter(t -> minAmount == null || (t.getAmount() != null && t.getAmount() >= minAmount))
                                .filter(t -> maxAmount == null || (t.getAmount() != null && t.getAmount() <= maxAmount))
                                .collect(Collectors.toList());

                return ResponseEntity.ok(transactions);
        }

        @GetMapping("/insights")
        public ResponseEntity<?> getInsights(
                        @AuthenticationPrincipal User user,
                        @RequestParam(required = false) String from,
                        @RequestParam(required = false) String to) {

                LocalDateTime endDate = to != null ? parseEndDate(to) : LocalDateTime.now();
                LocalDateTime startDate = from != null
                                ? parseStartDate(from)
                                : endDate.minusDays(30).withHour(0).withMinute(0).withSecond(0).withNano(0);

                List<Transaction> currentTransactions = transactionRepository
                                .findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(user, startDate, endDate);

                List<Insight> insights = new ArrayList<>();

                if (currentTransactions.isEmpty()) {
                        insights.add(Insight.builder()
                                        .type(Insight.InsightType.RECOMMENDATION)
                                        .severity(Insight.InsightSeverity.INFO)
                                        .title("Start Tracking")
                                        .message("Add your first transaction to start tracking your carbon footprint!")
                                        .actionable(true)
                                        .suggestedAction("Add a transaction")
                                        .build());
                        return ResponseEntity.ok(insights);
                }

                // Analyze top category
                Map<TransactionCategory, Double> categoryTotals = currentTransactions.stream()
                                .filter(t -> t.getCategory() != null && t.getCarbonFootprint() != null)
                                .collect(Collectors.groupingBy(
                                                Transaction::getCategory,
                                                Collectors.summingDouble(Transaction::getCarbonFootprint)));

                Double totalCO2 = categoryTotals.values().stream().mapToDouble(Double::doubleValue).sum();

                categoryTotals.entrySet().stream()
                                .max(Map.Entry.comparingByValue())
                                .ifPresent(entry -> {
                                        double pct = (entry.getValue() / totalCO2) * 100;
                                        if (pct > 30) {
                                                insights.add(Insight.builder()
                                                                .type(Insight.InsightType.ALERT)
                                                                .severity(Insight.InsightSeverity.WARNING)
                                                                .title("High CO₂ Category")
                                                                .message(String.format(
                                                                                "%s represents %.0f%% of your carbon footprint this period.",
                                                                                entry.getKey().getDisplayName(), pct))
                                                                .actionable(true)
                                                                .suggestedAction(
                                                                                "Consider eco-friendly alternatives in this category")
                                                                .build());
                                        }
                                });

                // Evolution insight
                long daysDiff = ChronoUnit.DAYS.between(startDate, endDate);
                LocalDateTime prevStart = startDate.minusDays(daysDiff);
                Double prevTotal = transactionRepository.sumCarbonFootprintByUserBetween(user, prevStart, startDate);

                if (prevTotal != null && prevTotal > 0) {
                        double change = ((totalCO2 - prevTotal) / prevTotal) * 100;
                        if (change < -10) {
                                insights.add(Insight.builder()
                                                .type(Insight.InsightType.TREND)
                                                .severity(Insight.InsightSeverity.SUCCESS)
                                                .title("Great Progress!")
                                                .message(String.format(
                                                                "Your CO₂ emissions decreased by %.1f%% compared to the previous period. Keep it up!",
                                                                Math.abs(change)))
                                                .actionable(false)
                                                .build());
                        } else if (change > 10) {
                                insights.add(Insight.builder()
                                                .type(Insight.InsightType.TREND)
                                                .severity(Insight.InsightSeverity.WARNING)
                                                .title("Emissions Increased")
                                                .message(String.format(
                                                                "Your CO₂ emissions increased by %.1f%% compared to the previous period.",
                                                                change))
                                                .actionable(true)
                                                .suggestedAction(
                                                                "Review your recent transactions to identify high-emission activities")
                                                .build());
                        }
                }

                // Merchant insights
                Map<String, Double> merchantTotals = currentTransactions.stream()
                                .filter(t -> t.getMerchant() != null && !t.getMerchant().isEmpty()
                                                && t.getCarbonFootprint() != null)
                                .collect(Collectors.groupingBy(
                                                Transaction::getMerchant,
                                                Collectors.summingDouble(Transaction::getCarbonFootprint)));

                merchantTotals.entrySet().stream()
                                .filter(e -> (e.getValue() / totalCO2) > 0.25)
                                .forEach(entry -> {
                                        double pct = (entry.getValue() / totalCO2) * 100;
                                        insights.add(Insight.builder()
                                                        .type(Insight.InsightType.RECOMMENDATION)
                                                        .severity(Insight.InsightSeverity.INFO)
                                                        .title("Top Emitter")
                                                        .message(String.format(
                                                                        "'%s' accounts for %.0f%% of your emissions.",
                                                                        entry.getKey(), pct))
                                                        .actionable(true)
                                                        .suggestedAction(
                                                                        "Look for greener alternatives or reduce frequency")
                                                        .build());
                                });

                return ResponseEntity.ok(insights);
        }

        private LocalDateTime parseStartDate(String dateStr) {
                try {
                        return LocalDate.parse(dateStr, DATE_FORMATTER).atStartOfDay();
                } catch (Exception e) {
                        return LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
                }
        }

        private LocalDateTime parseEndDate(String dateStr) {
                try {
                        return LocalDate.parse(dateStr, DATE_FORMATTER).plusDays(1).atStartOfDay().minusNanos(1);
                } catch (Exception e) {
                        return LocalDateTime.now();
                }
        }
}
