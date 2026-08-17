package com.example.mintonary.equipment.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/** 라켓 제품 정보 */
@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RacketModel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    private String brand;

    @Column(length = 50)
    private String series;

    @Column(nullable = false, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private RacketWeight weight;

    @Column(length = 50)
    private String balance;

    @Column(length = 50)
    private String flex;
}
