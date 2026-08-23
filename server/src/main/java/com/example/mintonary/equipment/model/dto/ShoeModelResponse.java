package com.example.mintonary.equipment.model.dto;

import com.example.mintonary.equipment.model.ShoeModel;

public record ShoeModelResponse(
        Long id,
        String brand,
        String name,
        String width
) {

    public static ShoeModelResponse from(ShoeModel model) {
        return new ShoeModelResponse(
                model.getId(),
                model.getBrand(),
                model.getName(),
                model.getWidth()
        );
    }
}
