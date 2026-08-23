package com.example.mintonary.equipment;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MyShoeRepository extends JpaRepository<MyShoe, Long> {

    Optional<MyShoe> findByEquipmentId(Long equipmentId);
}
