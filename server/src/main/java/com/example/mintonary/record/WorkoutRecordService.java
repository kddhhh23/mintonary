package com.example.mintonary.record;

import com.example.mintonary.member.Member;
import com.example.mintonary.member.MemberRepository;
import com.example.mintonary.record.dto.WorkoutRecordCreateRequest;
import com.example.mintonary.record.dto.WorkoutRecordResponse;
import java.time.LocalDate;
import java.util.List;
import java.util.NoSuchElementException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WorkoutRecordService {

    private final MemberRepository memberRepository;
    private final WorkoutRecordRepository workoutRecordRepository;

    @Transactional
    public Long create(Long memberId, WorkoutRecordCreateRequest request) {
        if (request.date().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("미래 날짜는 기록할 수 없습니다.");
        }
        Member member = memberRepository.getReferenceById(memberId);
        WorkoutRecord record = workoutRecordRepository.save(WorkoutRecord.create(
                member,
                request.date(),
                request.type(),
                request.title(),
                request.place(),
                request.coach(),
                request.result(),
                request.memo()
        ));
        return record.getId();
    }

    /** 한 달치 기록 */
    public List<WorkoutRecordResponse> findMonthly(Long memberId, int year, int month) {
        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());
        return workoutRecordRepository
                .findAllByMemberIdAndRecordDateBetweenOrderByRecordDateAscIdAsc(memberId, start, end)
                .stream()
                .map(WorkoutRecordResponse::from)
                .toList();
    }

    @Transactional
    public void delete(Long memberId, Long recordId) {
        WorkoutRecord record = workoutRecordRepository.findByIdAndMemberId(recordId, memberId)
                .orElseThrow(() -> new NoSuchElementException("기록을 찾을 수 없습니다."));
        workoutRecordRepository.delete(record);
    }
}
