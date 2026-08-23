package com.example.mintonary.equipment.dto;

import java.time.LocalDate;
import java.util.List;

/** 장비 탭 목록 — 라켓과 신발을 나눠서 내려준다 */
public record EquipmentListResponse(
        List<RacketSummary> rackets,
        List<ShoeSummary> shoes
) {

    public record RacketSummary(
            Long id,
            String brand,
            String name,
            LocalDate purchaseDate,
            Integer price,
            boolean inUse,
            // 현재 스트링/그립 — 이력이 없으면 null
            String stringName,
            Integer tension,
            LocalDate strungAt,
            String gripName,
            LocalDate wrappedAt
    ) {
    }

    public record ShoeSummary(
            Long id,
            String brand,
            String name,
            LocalDate purchaseDate,
            Integer price,
            boolean inUse
    ) {
    }
}
