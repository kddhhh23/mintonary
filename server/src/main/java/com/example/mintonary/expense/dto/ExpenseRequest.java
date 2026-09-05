package com.example.mintonary.expense.dto;

import com.example.mintonary.expense.ExpenseCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public record ExpenseRequest(
        @NotNull(message = "지출일을 입력해 주세요.") LocalDate date,
        @NotNull(message = "카테고리를 선택해 주세요.") ExpenseCategory category,
        @NotBlank(message = "지출명을 입력해 주세요.")
        @Size(max = 100, message = "지출명은 100자 이내로 입력해 주세요.")
        String title,
        @NotNull(message = "금액을 입력해 주세요.")
        @Positive(message = "금액은 0원보다 커야 합니다.")
        @Max(value = Integer.MAX_VALUE, message = "금액이 너무 큽니다.")
        Integer amount,
        @Size(max = 500, message = "메모는 500자 이내로 입력해 주세요.") String memo
) {
}
