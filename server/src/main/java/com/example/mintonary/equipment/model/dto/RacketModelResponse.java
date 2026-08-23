package com.example.mintonary.equipment.model.dto;

import com.example.mintonary.equipment.model.RacketModel;

public record RacketModelResponse(
        Long id,
        String brand,
        String series,
        String name,
        String weight,
        String balance,
        String flex
) {

    public static RacketModelResponse from(RacketModel model) {
        return new RacketModelResponse(
                model.getId(),
                model.getBrand(),
                model.getSeries(),
                model.getName(),
                model.getWeight() == null ? null : model.getWeight().name(),
                model.getBalance(),
                model.getFlex()
        );
    }
}
