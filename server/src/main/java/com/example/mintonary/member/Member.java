package com.example.mintonary.member;

import com.example.mintonary.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Member extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 30)
    private String loginId;

    @Column(nullable = false)
    private String password;

    @Column(unique = true, length = 100)
    private String email;

    @Column(nullable = false)
    private boolean emailVerified;

    @Column(nullable = false, unique = true, length = 20)
    private String nickname;

    private LocalDate birthDate;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private Gender gender;

    /** 구 대회 급수 */
    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private PlayerClass localClass;

    /** 전국 대회 급수 */
    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private PlayerClass nationalClass;

    /** 탈퇴 시각, null이면 활성 회원 */
    private LocalDateTime deletedAt;
}
