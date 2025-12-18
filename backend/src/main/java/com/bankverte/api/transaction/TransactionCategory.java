package com.bankverte.api.transaction;

public enum TransactionCategory {
    TRANSPORT_FLIGHT(0.25, "✈️ Transport - Flight"),
    TRANSPORT_CAR(0.12, "🚗 Transport - Car"),
    TRANSPORT_PUBLIC(0.03, "🚌 Transport - Public"),
    FOOD_MEAT(0.08, "🥩 Food - Meat"),
    FOOD_LOCAL(0.02, "🥬 Food - Local/Vegetables"),
    ENERGY(0.15, "⚡ Energy"),
    SHOPPING(0.05, "🛍️ Shopping"),
    OTHER(0.04, "📦 Other");

    private final double carbonFactor; // kg CO₂ per euro
    private final String displayName;

    TransactionCategory(double carbonFactor, String displayName) {
        this.carbonFactor = carbonFactor;
        this.displayName = displayName;
    }

    public double getCarbonFactor() {
        return carbonFactor;
    }

    public String getDisplayName() {
        return displayName;
    }

    public double calculateCarbonFootprint(double amount) {
        return amount * carbonFactor;
    }
}
