package com.example.mintonary.expense;

import com.example.mintonary.common.BaseEntity;
import com.example.mintonary.member.Member;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDate;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Expense extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(nullable = false)
    private LocalDate expenseDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ExpenseCategory category;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false)
    private Integer amount;

    @Column(length = 500)
    private String memo;

    public static Expense create(
            Member member,
            LocalDate expenseDate,
            ExpenseCategory category,
            String title,
            Integer amount,
            String memo
    ) {
        Expense expense = new Expense();
        expense.member = member;
        expense.change(expenseDate, category, title, amount, memo);
        return expense;
    }

    public void change(
            LocalDate expenseDate,
            ExpenseCategory category,
            String title,
            Integer amount,
            String memo
    ) {
        this.expenseDate = expenseDate;
        this.category = category;
        this.title = title;
        this.amount = amount;
        this.memo = memo;
    }
}
