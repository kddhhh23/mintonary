package com.example.mintonary.equipment.dto;

import java.time.LocalDate;

/** alarmDate가 null이면 알림 해제 */
public record StringAlarmRequest(LocalDate alarmDate) {
}
