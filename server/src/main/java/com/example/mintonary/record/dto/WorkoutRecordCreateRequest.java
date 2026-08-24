package com.example.mintonary.record.dto;

import com.example.mintonary.record.WorkoutType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public record WorkoutRecordCreateRequest(
        @NotNull(message = "날짜를 입력해 주세요.") LocalDate date,
        @NotNull(message = "기록 종류를 선택해 주세요.") WorkoutType type,
        @NotBlank(message = "한 줄 기록을 입력해 주세요.")
        @Size(max = 100, message = "한 줄 기록은 100자 이내로 입력해 주세요.")
        String title,
        @Size(max = 100, message = "장소는 100자 이내로 입력해 주세요.") String place,
        @Size(max = 50, message = "코치 이름은 50자 이내로 입력해 주세요.") String coach,
        @Size(max = 100, message = "결과는 100자 이내로 입력해 주세요.") String result,
        @Size(max = 500, message = "메모는 500자 이내로 입력해 주세요.") String memo
) {
}
