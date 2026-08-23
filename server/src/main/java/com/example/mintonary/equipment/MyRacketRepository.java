package com.example.mintonary.equipment;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MyRacketRepository extends JpaRepository<MyRacket, Long> {

    Optional<MyRacket> findByEquipmentId(Long equipmentId);
}
