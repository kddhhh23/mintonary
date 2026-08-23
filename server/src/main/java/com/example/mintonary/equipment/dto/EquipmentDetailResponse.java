package com.example.mintonary.equipment.dto;

import com.example.mintonary.equipment.EquipmentType;
import com.example.mintonary.equipment.model.GripType;
import java.time.LocalDate;
import java.util.List;

/** 장비 상세 — type에 따라 racket 또는 shoe 중 하나만 채워진다 */
public record EquipmentDetailResponse(
        Long id,
        EquipmentType type,
        LocalDate purchaseDate,
        Integer price,
        String memo,
        boolean inUse,
        RacketInfo racket,
        ShoeInfo shoe
) {

    public record RacketInfo(
            String brand,
            String series,
            String name,
            String weight,
            String balance,
            String flex,
            LocalDate stringAlarmDate,
            List<StringHistoryItem> stringHistories,
            List<GripHistoryItem> gripHistories
    ) {
    }

    public record ShoeInfo(
            String brand,
            String name,
            String width
    ) {
    }

    public record StringHistoryItem(
            Long id,
            String name,
            Integer tension,
            LocalDate strungAt
    ) {
    }

    public record GripHistoryItem(
            Long id,
            String name,
            GripType type,
            LocalDate wrappedAt
    ) {
    }
}
