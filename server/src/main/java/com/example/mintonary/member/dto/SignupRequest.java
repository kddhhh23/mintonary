package com.example.mintonary.member.dto;

import com.example.mintonary.member.Gender;
import com.example.mintonary.member.PlayerClass;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

/** 아이디·비밀번호·닉네임만 필수, 나머지는 선택 */
public record SignupRequest(

        @NotBlank(message = "아이디를 입력해 주세요.")
        @Size(min = 4, max = 30, message = "아이디는 4~30자여야 합니다.")
        String loginId,

        @NotBlank(message = "비밀번호를 입력해 주세요.")
        @Size(min = 8, max = 20, message = "비밀번호는 8~20자여야 합니다.")
        String password,

        @NotBlank(message = "닉네임을 입력해 주세요.")
        @Size(max = 20, message = "닉네임은 20자 이하여야 합니다.")
        String nickname,

        @Email(message = "이메일 형식이 올바르지 않습니다.")
        @Size(max = 100)
        String email,

        @Past(message = "생년월일이 올바르지 않습니다.")
        LocalDate birthDate,

        Gender gender,

        /** 구 대회 급수 */
        PlayerClass localClass,

        /** 전국 대회 급수 */
        PlayerClass nationalClass
) {
}
