package com.bankverte.api.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AnalyticsSummaryResponse {
    private Double totalCO2;
    private Double averageCO2PerTransaction;
    private Integer transactionCount;
    private TopCategoryInfo topCategory;
    private Double evolutionPercentage; // Percentage change vs previous period
    private String periodStart;
    private String periodEnd;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopCategoryInfo {
        private String name;
        private String displayName;
        private Double co2;
        private Double percentage;
    }
}
