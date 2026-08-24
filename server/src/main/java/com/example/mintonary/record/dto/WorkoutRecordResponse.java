package com.example.mintonary.record.dto;

import com.example.mintonary.record.WorkoutRecord;
import com.example.mintonary.record.WorkoutType;
import java.time.LocalDate;

public record WorkoutRecordResponse(
        Long id,
        LocalDate date,
        WorkoutType type,
        String title,
        String place,
        String coach,
        String result,
        String memo
) {

    public static WorkoutRecordResponse from(WorkoutRecord record) {
        return new WorkoutRecordResponse(
                record.getId(),
                record.getRecordDate(),
                record.getType(),
                record.getTitle(),
                record.getPlace(),
                record.getCoach(),
                record.getResult(),
                record.getMemo()
        );
    }
}
