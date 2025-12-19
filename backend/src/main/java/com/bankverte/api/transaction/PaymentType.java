package com.bankverte.api.transaction;

public enum PaymentType {
    DEBIT_CARD("💳 Debit Card"),
    CREDIT_CARD("💳 Credit Card"),
    BANK_TRANSFER("🏦 Bank Transfer"),
    CASH("💵 Cash"),
    MOBILE_PAYMENT("📱 Mobile Payment"),
    OTHER("📄 Other");

    private final String displayName;

    PaymentType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
