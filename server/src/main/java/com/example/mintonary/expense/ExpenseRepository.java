package com.example.mintonary.expense;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    List<Expense> findAllByMemberIdAndExpenseDateBetweenOrderByExpenseDateDescIdDesc(
            Long memberId,
            LocalDate start,
            LocalDate end
    );

    Optional<Expense> findByIdAndMemberId(Long id, Long memberId);
}
