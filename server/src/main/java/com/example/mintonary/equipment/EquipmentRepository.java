package com.example.mintonary.equipment;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EquipmentRepository extends JpaRepository<Equipment, Long> {

    List<Equipment> findAllByMemberIdOrderByIdDesc(Long memberId);

    /** 본인 장비만 조회되도록 회원 조건을 함께 건다 */
    Optional<Equipment> findByIdAndMemberId(Long id, Long memberId);
}
