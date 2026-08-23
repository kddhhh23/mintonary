package com.example.mintonary.equipment.dto;

import jakarta.validation.constraints.NotNull;

public record StatusChangeRequest(
        @NotNull(message = "사용 상태를 선택해 주세요.") Boolean inUse
) {
}
