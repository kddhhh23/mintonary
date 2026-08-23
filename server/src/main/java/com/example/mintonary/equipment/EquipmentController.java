package com.example.mintonary.equipment;

import com.example.mintonary.equipment.dto.EquipmentDetailResponse;
import com.example.mintonary.equipment.dto.EquipmentListResponse;
import com.example.mintonary.equipment.dto.EquipmentRegisterRequest;
import com.example.mintonary.equipment.dto.GripChangeRequest;
import com.example.mintonary.equipment.dto.StatusChangeRequest;
import com.example.mintonary.equipment.dto.StringAlarmRequest;
import com.example.mintonary.equipment.dto.StringChangeRequest;
import jakarta.validation.Valid;
import java.net.URI;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/equipments")
@RequiredArgsConstructor
public class EquipmentController {

    private final EquipmentService equipmentService;

    @PostMapping
    public ResponseEntity<Void> register(
            @AuthenticationPrincipal Long memberId,
            @Valid @RequestBody EquipmentRegisterRequest request
    ) {
        Long id = equipmentService.register(memberId, request);
        return ResponseEntity.created(URI.create("/api/equipments/" + id)).build();
    }

    @GetMapping
    public EquipmentListResponse list(@AuthenticationPrincipal Long memberId) {
        return equipmentService.list(memberId);
    }

    @GetMapping("/{id}")
    public EquipmentDetailResponse detail(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id
    ) {
        return equipmentService.detail(memberId, id);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id
    ) {
        equipmentService.delete(memberId, id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Void> changeStatus(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id,
            @Valid @RequestBody StatusChangeRequest request
    ) {
        equipmentService.changeStatus(memberId, id, request);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/string-alarm")
    public ResponseEntity<Void> changeStringAlarm(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id,
            @RequestBody StringAlarmRequest request
    ) {
        equipmentService.changeStringAlarm(memberId, id, request);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/string-changes")
    public ResponseEntity<Void> addStringChange(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id,
            @Valid @RequestBody StringChangeRequest request
    ) {
        Long historyId = equipmentService.addStringChange(memberId, id, request);
        return ResponseEntity
                .created(URI.create("/api/equipments/" + id + "/string-changes/" + historyId))
                .build();
    }

    @DeleteMapping("/{id}/string-changes/{historyId}")
    public ResponseEntity<Void> deleteStringChange(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id,
            @PathVariable Long historyId
    ) {
        equipmentService.deleteStringChange(memberId, id, historyId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/grip-changes")
    public ResponseEntity<Void> addGripChange(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id,
            @Valid @RequestBody GripChangeRequest request
    ) {
        Long historyId = equipmentService.addGripChange(memberId, id, request);
        return ResponseEntity
                .created(URI.create("/api/equipments/" + id + "/grip-changes/" + historyId))
                .build();
    }

    @DeleteMapping("/{id}/grip-changes/{historyId}")
    public ResponseEntity<Void> deleteGripChange(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id,
            @PathVariable Long historyId
    ) {
        equipmentService.deleteGripChange(memberId, id, historyId);
        return ResponseEntity.noContent().build();
    }
}
