package com.example.mintonary.equipment.dto;

import com.example.mintonary.equipment.model.GripType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record GripChangeRequest(
        @NotBlank(message = "그립명을 입력해 주세요.") String name,
        @NotNull(message = "그립 종류를 선택해 주세요.") GripType type,
        @NotNull(message = "교체일을 입력해 주세요.") LocalDate wrappedAt,
        String memo
) {
}
