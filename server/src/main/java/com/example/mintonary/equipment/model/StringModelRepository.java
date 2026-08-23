package com.example.mintonary.equipment.model;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StringModelRepository extends JpaRepository<StringModel, Long> {

    Optional<StringModel> findFirstByName(String name);
}
