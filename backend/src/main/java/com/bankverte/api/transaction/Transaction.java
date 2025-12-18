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

    @Enumerated(EnumType.STRING)
    private TransactionCategory category;

    private Double carbonFootprint; // in kg CO₂

    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        if (this.category != null && this.amount != null) {
            this.carbonFootprint = this.category.calculateCarbonFootprint(this.amount);
        }
    }
}
