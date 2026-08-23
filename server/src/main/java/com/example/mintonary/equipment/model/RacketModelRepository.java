package com.example.mintonary.equipment.model;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RacketModelRepository extends JpaRepository<RacketModel, Long> {

    List<RacketModel> findAllByOrderByBrandAscNameAsc();
}
