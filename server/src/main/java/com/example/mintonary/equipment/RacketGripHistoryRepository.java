package com.example.mintonary.equipment;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RacketGripHistoryRepository extends JpaRepository<RacketGripHistory, Long> {

    /** 최신순 — 교체일이 같으면 나중에 등록한 것이 위 */
    List<RacketGripHistory> findAllByMyRacketIdOrderByWrappedAtDescIdDesc(Long myRacketId);

    /** 현재 그립 = 가장 최근 교체 건 */
    Optional<RacketGripHistory> findFirstByMyRacketIdOrderByWrappedAtDescIdDesc(Long myRacketId);

    Optional<RacketGripHistory> findByIdAndMyRacketId(Long id, Long myRacketId);

    void deleteAllByMyRacketId(Long myRacketId);
}
