package com.example.mintonary.equipment;

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

/** 회원이 보유한 장비의 공통 정보 */
@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Equipment extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EquipmentType type;

    private LocalDate purchaseDate;

    private Integer price;

    @Column(length = 500)
    private String memo;

    /** 방출일, null이면 사용 중 */
    private LocalDate retiredAt;

    public static Equipment create(
            Member member,
            EquipmentType type,
            LocalDate purchaseDate,
            Integer price,
            String memo
    ) {
        Equipment equipment = new Equipment();
        equipment.member = member;
        equipment.type = type;
        equipment.purchaseDate = purchaseDate;
        equipment.price = price;
        equipment.memo = memo;
        return equipment;
    }

    public boolean isInUse() {
        return retiredAt == null;
    }

    /** 미사용 처리 — 방출일을 오늘로 기록한다 */
    public void retire() {
        this.retiredAt = LocalDate.now();
    }

    /** 다시 사용 중으로 되돌린다 */
    public void restore() {
        this.retiredAt = null;
    }
}
