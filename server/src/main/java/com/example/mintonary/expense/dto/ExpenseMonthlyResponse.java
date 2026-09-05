package com.example.mintonary.expense.dto;

import java.util.List;

public record ExpenseMonthlyResponse(
        long totalAmount,
        ExpenseResponse recentExpense,
        List<ExpenseResponse> expenses
) {
}
