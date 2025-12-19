package com.bankverte.api.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MerchantAnalytics {
    private String merchantName;
    private Double totalCO2;
    private Integer transactionCount;
    private Double averageCO2;
    private String primaryCategory;
}
