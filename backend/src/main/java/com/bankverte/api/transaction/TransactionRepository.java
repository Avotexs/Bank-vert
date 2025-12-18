package com.bankverte.api.transaction;

import com.bankverte.api.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Integer> {

    List<Transaction> findByUserOrderByCreatedAtDesc(User user);

    @Query("SELECT COALESCE(SUM(t.carbonFootprint), 0) FROM Transaction t WHERE t.user = :user AND t.createdAt >= :startDate")
    Double sumCarbonFootprintByUserSince(@Param("user") User user, @Param("startDate") LocalDateTime startDate);

    @Query("SELECT COALESCE(SUM(t.carbonFootprint), 0) FROM Transaction t WHERE t.user = :user AND t.createdAt >= :startDate AND t.createdAt < :endDate")
    Double sumCarbonFootprintByUserBetween(@Param("user") User user, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
