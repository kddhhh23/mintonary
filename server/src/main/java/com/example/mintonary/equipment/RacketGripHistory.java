package com.example.mintonary.equipment;

import com.example.mintonary.equipment.model.GripModel;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

/** 그립 교체 이력 */
@Getter
@Entity
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RacketGripHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "my_racket_id", nullable = false)
    private MyRacket myRacket;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "grip_model_id", nullable = false)
    private GripModel gripModel;

    @Column(nullable = false)
    private LocalDate wrappedAt;

    @Column(length = 500)
    private String memo;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public static RacketGripHistory create(
            MyRacket myRacket,
            GripModel gripModel,
            LocalDate wrappedAt,
            String memo
    ) {
        RacketGripHistory history = new RacketGripHistory();
        history.myRacket = myRacket;
        history.gripModel = gripModel;
        history.wrappedAt = wrappedAt;
        history.memo = memo;
        return history;
    }
}
