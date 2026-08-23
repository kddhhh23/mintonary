package com.example.mintonary.equipment;

import com.example.mintonary.equipment.model.ShoeModel;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/** 내 신발 (Equipment 1건에 1개) */
@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MyShoe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipment_id", nullable = false, unique = true)
    private Equipment equipment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shoe_model_id", nullable = false)
    private ShoeModel shoeModel;

    public static MyShoe create(Equipment equipment, ShoeModel shoeModel) {
        MyShoe myShoe = new MyShoe();
        myShoe.equipment = equipment;
        myShoe.shoeModel = shoeModel;
        return myShoe;
    }
}
