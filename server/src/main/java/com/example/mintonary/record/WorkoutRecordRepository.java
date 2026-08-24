package com.example.mintonary.record;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WorkoutRecordRepository extends JpaRepository<WorkoutRecord, Long> {

    /** 기간 내 기록 — 날짜순, 같은 날은 등록순 */
    List<WorkoutRecord> findAllByMemberIdAndRecordDateBetweenOrderByRecordDateAscIdAsc(
            Long memberId,
            LocalDate start,
            LocalDate end
    );

    /** 본인 기록만 조회되도록 회원 조건을 함께 건다 */
    Optional<WorkoutRecord> findByIdAndMemberId(Long id, Long memberId);
}
