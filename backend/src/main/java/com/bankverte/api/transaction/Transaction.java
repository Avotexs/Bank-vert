package com.bankverte.api.transaction;

import com.bankverte.api.user.User;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "transaction")
public class Transaction {

    @Id
    @GeneratedValue
    private Integer id;

    private String description;

    private Double amount;

    private String currency; // e.g., "EUR", "USD"

    @Enumerated(EnumType.STRING)
    private TransactionCategory category;

    private Double carbonFootprint; // in kg CO₂

    private String merchant; // Merchant/vendor name

    @Enumerated(EnumType.STRING)
    private PaymentType paymentType;

    private Double emissionFactor; // Specific emission factor used (kg CO₂ per euro)

    private String factorSource; // Source of emission factor (e.g., "CATEGORY_DEFAULT", "MERCHANT_SPECIFIC")

    private Double confidenceScore; // Confidence in category detection (0.0 to 1.0)

    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();

        // Set default currency if not provided
        if (this.currency == null || this.currency.isEmpty()) {
            this.currency = "EUR";
        }

        // Calculate carbon footprint and store emission factor
        if (this.category != null && this.amount != null) {
            this.emissionFactor = this.category.getCarbonFactor();
            this.carbonFootprint = this.category.calculateCarbonFootprint(this.amount);
            this.factorSource = "CATEGORY_DEFAULT";

            // Set default confidence score if not already set
            if (this.confidenceScore == null) {
                this.confidenceScore = 1.0; // High confidence for manually categorized transactions
            }
        }
    }
}
