package com.example.mintonary.expense.dto;

import com.example.mintonary.expense.Expense;
import com.example.mintonary.expense.ExpenseCategory;
import java.time.LocalDate;

public record ExpenseResponse(
        Long id,
        LocalDate date,
        ExpenseCategory category,
        String title,
        Integer amount,
        String memo
) {

    public static ExpenseResponse from(Expense expense) {
        return new ExpenseResponse(
                expense.getId(),
                expense.getExpenseDate(),
                expense.getCategory(),
                expense.getTitle(),
                expense.getAmount(),
                expense.getMemo()
        );
    }
}
