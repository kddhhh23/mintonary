package com.example.mintonary.equipment;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RacketStringHistoryRepository extends JpaRepository<RacketStringHistory, Long> {

    /** 최신순 — 교체일이 같으면 나중에 등록한 것이 위 */
    List<RacketStringHistory> findAllByMyRacketIdOrderByStrungAtDescIdDesc(Long myRacketId);

    /** 현재 스트링 = 가장 최근 교체 건 */
    Optional<RacketStringHistory> findFirstByMyRacketIdOrderByStrungAtDescIdDesc(Long myRacketId);

    Optional<RacketStringHistory> findByIdAndMyRacketId(Long id, Long myRacketId);

    void deleteAllByMyRacketId(Long myRacketId);
}
