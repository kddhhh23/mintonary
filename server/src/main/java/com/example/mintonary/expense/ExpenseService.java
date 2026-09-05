package com.example.mintonary.expense;

import com.example.mintonary.expense.dto.ExpenseMonthlyResponse;
import com.example.mintonary.expense.dto.ExpenseRequest;
import com.example.mintonary.expense.dto.ExpenseResponse;
import com.example.mintonary.member.Member;
import com.example.mintonary.member.MemberRepository;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.NoSuchElementException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExpenseService {

    private final MemberRepository memberRepository;
    private final ExpenseRepository expenseRepository;

    @Transactional
    public Long create(Long memberId, ExpenseRequest request) {
        validateDate(request.date());
        Member member = memberRepository.getReferenceById(memberId);
        Expense expense = expenseRepository.save(Expense.create(
                member,
                request.date(),
                request.category(),
                request.title(),
                request.amount(),
                request.memo()
        ));
        return expense.getId();
    }

    public ExpenseMonthlyResponse findMonthly(Long memberId, int year, int month) {
        YearMonth yearMonth;
        try {
            yearMonth = YearMonth.of(year, month);
        } catch (RuntimeException e) {
            throw new IllegalArgumentException("조회할 연월이 올바르지 않습니다.");
        }
        List<ExpenseResponse> expenses = expenseRepository
                .findAllByMemberIdAndExpenseDateBetweenOrderByExpenseDateDescIdDesc(
                        memberId,
                        yearMonth.atDay(1),
                        yearMonth.atEndOfMonth()
                )
                .stream()
                .map(ExpenseResponse::from)
                .toList();
        long totalAmount = expenses.stream().mapToLong(ExpenseResponse::amount).sum();
        ExpenseResponse recent = expenses.isEmpty() ? null : expenses.getFirst();
        return new ExpenseMonthlyResponse(totalAmount, recent, expenses);
    }

    @Transactional
    public void update(Long memberId, Long expenseId, ExpenseRequest request) {
        validateDate(request.date());
        Expense expense = findOwned(memberId, expenseId);
        expense.change(
                request.date(),
                request.category(),
                request.title(),
                request.amount(),
                request.memo()
        );
    }

    @Transactional
    public void delete(Long memberId, Long expenseId) {
        expenseRepository.delete(findOwned(memberId, expenseId));
    }

    private Expense findOwned(Long memberId, Long expenseId) {
        return expenseRepository.findByIdAndMemberId(expenseId, memberId)
                .orElseThrow(() -> new NoSuchElementException("지출 내역을 찾을 수 없습니다."));
    }

    private void validateDate(LocalDate date) {
        if (date.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("미래 날짜는 입력할 수 없습니다.");
        }
    }
}
