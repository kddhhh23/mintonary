package com.example.mintonary.equipment.dto;

import com.example.mintonary.equipment.EquipmentType;
import com.example.mintonary.equipment.model.GripType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.time.LocalDate;

public record EquipmentRegisterRequest(
        @NotNull(message = "장비 종류를 선택해 주세요.") EquipmentType type,
        @NotNull(message = "모델을 선택해 주세요.") Long modelId,
        LocalDate purchaseDate,
        @Positive(message = "가격은 0원보다 커야 합니다.")
        @Max(value = Integer.MAX_VALUE, message = "가격이 너무 큽니다.")
        Integer price,
        String memo,
        Boolean addToExpenses,
        // 라켓 전용 — 등록하면서 함께 기록할 초기 스트링/그립 (생략 가능)
        @Valid StringInfo string,
        @Valid GripInfo grip
) {

    public record StringInfo(
            @NotBlank(message = "스트링명을 입력해 주세요.") String name,
            Integer tension,
            LocalDate strungAt
    ) {
    }

    public record GripInfo(
            @NotBlank(message = "그립명을 입력해 주세요.") String name,
            @NotNull(message = "그립 종류를 선택해 주세요.") GripType type,
            LocalDate wrappedAt
    ) {
    }
}
