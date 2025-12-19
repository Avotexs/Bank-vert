package com.bankverte.api.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Insight {
    private InsightType type;
    private InsightSeverity severity;
    private String title;
    private String message;
    private Boolean actionable;
    private String suggestedAction;

    public enum InsightType {
        TREND,
        ALERT,
        RECOMMENDATION
    }

    public enum InsightSeverity {
        INFO,
        WARNING,
        SUCCESS
    }
}
