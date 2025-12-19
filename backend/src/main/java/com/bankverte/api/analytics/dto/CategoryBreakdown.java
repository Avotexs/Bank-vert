package com.bankverte.api.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryBreakdown {
    private String category;
    private String displayName;
    private Double totalCO2;
    private Double percentage;
    private Integer transactionCount;
    private String color; // Hex color for charts
}
