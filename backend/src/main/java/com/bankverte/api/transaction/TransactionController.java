package com.bankverte.api.transaction;

import com.bankverte.api.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionRepository transactionRepository;

    @GetMapping("/categories")
    public ResponseEntity<?> getCategories() {
        var categories = Arrays.stream(TransactionCategory.values())
            .map(c -> Map.of(
                "name", c.name(),
                "displayName", c.getDisplayName(),
                "carbonFactor", c.getCarbonFactor()
            ))
            .collect(Collectors.toList());
        return ResponseEntity.ok(categories);
    }

    @PostMapping
    public ResponseEntity<?> createTransaction(
            @AuthenticationPrincipal User user,
            @RequestBody CreateTransactionRequest request) {
        
        Transaction transaction = Transaction.builder()
            .description(request.getDescription())
            .amount(request.getAmount())
            .category(request.getCategory())
            .user(user)
            .build();
        
        transaction = transactionRepository.save(transaction);
        
        return ResponseEntity.ok(toResponse(transaction));
    }

    @GetMapping
    public ResponseEntity<?> getTransactions(@AuthenticationPrincipal User user) {
        List<TransactionResponse> transactions = transactionRepository
            .findByUserOrderByCreatedAtDesc(user)
            .stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
        
        return ResponseEntity.ok(transactions);
    }

    @GetMapping("/carbon-summary")
    public ResponseEntity<?> getCarbonSummary(@AuthenticationPrincipal User user) {
        YearMonth currentMonth = YearMonth.now();
        LocalDateTime startOfMonth = currentMonth.atDay(1).atStartOfDay();
        LocalDateTime startOfLastMonth = currentMonth.minusMonths(1).atDay(1).atStartOfDay();
        
        Double currentMonthTotal = transactionRepository.sumCarbonFootprintByUserSince(user, startOfMonth);
        Double lastMonthTotal = transactionRepository.sumCarbonFootprintByUserBetween(user, startOfLastMonth, startOfMonth);
        
        return ResponseEntity.ok(Map.of(
            "currentMonth", currentMonthTotal != null ? currentMonthTotal : 0.0,
            "lastMonth", lastMonthTotal != null ? lastMonthTotal : 0.0,
            "month", currentMonth.toString()
        ));
    }

    private TransactionResponse toResponse(Transaction t) {
        return TransactionResponse.builder()
            .id(t.getId())
            .description(t.getDescription())
            .amount(t.getAmount())
            .category(t.getCategory().name())
            .categoryDisplayName(t.getCategory().getDisplayName())
            .carbonFootprint(t.getCarbonFootprint())
            .createdAt(t.getCreatedAt())
            .build();
    }
}
