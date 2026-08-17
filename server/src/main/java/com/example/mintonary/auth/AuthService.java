package com.example.mintonary.auth;

import com.example.mintonary.auth.dto.LoginRequest;
import com.example.mintonary.auth.dto.LoginResponse;
import com.example.mintonary.member.Member;
import com.example.mintonary.member.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private static final String LOGIN_FAILED = "아이디 또는 비밀번호가 올바르지 않습니다.";

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;

    public LoginResponse login(LoginRequest request) {
        Member member = memberRepository.findByLoginId(request.loginId())
                .orElseThrow(() -> new BadCredentialsException(LOGIN_FAILED));

        if (!passwordEncoder.matches(request.password(), member.getPassword())) {
            throw new BadCredentialsException(LOGIN_FAILED);
        }
        if (member.getDeletedAt() != null) {
            throw new BadCredentialsException(LOGIN_FAILED);
        }

        return new LoginResponse(jwtProvider.createToken(member.getId()), member.getNickname());
    }
}
