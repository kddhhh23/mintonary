package com.example.mintonary.equipment.model;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GripModelRepository extends JpaRepository<GripModel, Long> {

    Optional<GripModel> findFirstByNameAndType(String name, GripType type);
}
