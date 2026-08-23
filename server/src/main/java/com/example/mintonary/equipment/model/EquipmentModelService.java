package com.example.mintonary.equipment.model;

import com.example.mintonary.equipment.model.dto.RacketModelResponse;
import com.example.mintonary.equipment.model.dto.ShoeModelResponse;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class EquipmentModelService {

    private final RacketModelRepository racketModelRepository;
    private final ShoeModelRepository shoeModelRepository;

    public List<RacketModelResponse> findRacketModels() {
        return racketModelRepository.findAllByOrderByBrandAscNameAsc().stream()
                .map(RacketModelResponse::from)
                .toList();
    }

    public List<ShoeModelResponse> findShoeModels() {
        return shoeModelRepository.findAllByOrderByBrandAscNameAsc().stream()
                .map(ShoeModelResponse::from)
                .toList();
    }
}
