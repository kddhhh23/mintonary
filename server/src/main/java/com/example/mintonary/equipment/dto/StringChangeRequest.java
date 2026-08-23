package com.example.mintonary.equipment.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record StringChangeRequest(
        @NotBlank(message = "스트링명을 입력해 주세요.") String name,
        Integer tension,
        @NotNull(message = "교체일을 입력해 주세요.") LocalDate strungAt,
        String memo
) {
}
