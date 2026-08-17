package com.example.mintonary.equipment.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/** 스트링 제품 정보 */
@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class StringModel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 100)
    private String brand;

    @Column(nullable = false, length = 100)
    private String name;
}
