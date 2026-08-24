package com.example.mintonary.record;

import com.example.mintonary.common.BaseEntity;
import com.example.mintonary.member.Member;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDate;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/** 운동 기록 한 건 */
@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class WorkoutRecord extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(nullable = false)
    private LocalDate recordDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private WorkoutType type;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(length = 100)
    private String place;

    /** 레슨일 때 코치 이름 */
    @Column(length = 50)
    private String coach;

    /** 대회일 때 결과 (예: 준우승, 조별 예선 탈락) */
    @Column(length = 100)
    private String result;

    @Column(length = 500)
    private String memo;

    public static WorkoutRecord create(
            Member member,
            LocalDate recordDate,
            WorkoutType type,
            String title,
            String place,
            String coach,
            String result,
            String memo
    ) {
        WorkoutRecord record = new WorkoutRecord();
        record.member = member;
        record.recordDate = recordDate;
        record.type = type;
        record.title = title;
        record.place = place;
        record.coach = coach;
        record.result = result;
        record.memo = memo;
        return record;
    }
}
