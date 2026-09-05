package com.example.mintonary.expense;

import com.example.mintonary.expense.dto.ExpenseMonthlyResponse;
import com.example.mintonary.expense.dto.ExpenseRequest;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/expenses")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;

    @PostMapping
    public ResponseEntity<Void> create(
            @AuthenticationPrincipal Long memberId,
            @Valid @RequestBody ExpenseRequest request
    ) {
        Long id = expenseService.create(memberId, request);
        return ResponseEntity.created(URI.create("/api/expenses/" + id)).build();
    }

    @GetMapping
    public ExpenseMonthlyResponse monthly(
            @AuthenticationPrincipal Long memberId,
            @RequestParam int year,
            @RequestParam int month
    ) {
        return expenseService.findMonthly(memberId, year, month);
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Void> update(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id,
            @Valid @RequestBody ExpenseRequest request
    ) {
        expenseService.update(memberId, id, request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal Long memberId,
            @PathVariable Long id
    ) {
        expenseService.delete(memberId, id);
        return ResponseEntity.noContent().build();
    }
}
