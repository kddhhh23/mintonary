package com.example.mintonary.equipment.model;

import com.example.mintonary.equipment.model.dto.RacketModelResponse;
import com.example.mintonary.equipment.model.dto.ShoeModelResponse;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class EquipmentModelController {

    private final EquipmentModelService equipmentModelService;

    @GetMapping("/racket-models")
    public List<RacketModelResponse> racketModels() {
        return equipmentModelService.findRacketModels();
    }

    @GetMapping("/shoe-models")
    public List<ShoeModelResponse> shoeModels() {
        return equipmentModelService.findShoeModels();
    }
}
