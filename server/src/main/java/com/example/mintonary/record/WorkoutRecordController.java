package com.example.mintonary.record;

import com.example.mintonary.record.dto.WorkoutRecordCreateRequest;
import com.example.mintonary.record.dto.WorkoutRecordResponse;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/records")
@RequiredArgsConstructor
public class WorkoutRecordController {

    private final WorkoutRecordService workoutRecordService;

    @PostMapping
    public ResponseEntity<Void> create(
            @AuthenticationPrincipal Long memberId,
            @Valid @RequestBody WorkoutRecordCreateRequest request
    ) {
        Long id = workoutRecordService.create(memberId, request);
        return ResponseEntity.created(URI.create("/api/records/" + id)).build();
    }

    /** 한 달치 기록 조회 — /api/records?year=2026&month=8 */
    @GetMapping
    public List<WorkoutRecordResponse> monthly(
            @AuthenticationPrincipal Long memberId,
            @RequestParam int year,
            @RequestParam int month
    ) {
        return workoutRecordService.findMonthly(memberId, year, month);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id
    ) {
        workoutRecordService.delete(memberId, id);
        return ResponseEntity.noContent().build();
    }
}
