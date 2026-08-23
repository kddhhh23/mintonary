package com.example.mintonary.equipment;

import com.example.mintonary.equipment.model.RacketModel;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import java.time.LocalDate;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/** 내 라켓 (Equipment 1건에 1개) */
@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MyRacket {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipment_id", nullable = false, unique = true)
    private Equipment equipment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "racket_model_id", nullable = false)
    private RacketModel racketModel;

    /** 다음 스트링 교체 알림 날짜 */
    private LocalDate stringAlarmDate;

    public static MyRacket create(Equipment equipment, RacketModel racketModel) {
        MyRacket myRacket = new MyRacket();
        myRacket.equipment = equipment;
        myRacket.racketModel = racketModel;
        return myRacket;
    }

    /** 알림 날짜를 바꾼다. null이면 알림 해제 */
    public void changeStringAlarmDate(LocalDate date) {
        this.stringAlarmDate = date;
    }
}
