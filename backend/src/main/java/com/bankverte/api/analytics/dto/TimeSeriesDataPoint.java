package com.bankverte.api.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TimeSeriesDataPoint {
    private String date; // ISO date string
    private Double co2Value;
    private Integer transactionCount;
}
