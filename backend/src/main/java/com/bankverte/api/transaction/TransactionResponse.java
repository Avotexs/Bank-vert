package com.bankverte.api.transaction;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionResponse {
    private Integer id;
    private String description;
    private Double amount;
    private String category;
    private String categoryDisplayName;
    private Double carbonFootprint;
    private String merchant;
    private LocalDateTime createdAt;
}
