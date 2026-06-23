package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import vn.edu.fpt.dto.request.ForgotPasswordRequest;
import vn.edu.fpt.dto.request.LoginRequest;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.LoginResponse;
import vn.edu.fpt.entity.Account;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.repository.AccountRepository;
import vn.edu.fpt.repository.StudentRepository;
import vn.edu.fpt.security.JwtTokenProvider;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AccountRepository accountRepository;
    private final StudentRepository studentRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public ApiResponse<LoginResponse> login(LoginRequest request) {
        Account account = accountRepository.findByPhone(request.getPhone())
                .orElse(null);

        if (account == null) {
            return ApiResponse.error("Số điện thoại không tồn tại trong hệ thống");
        }

        if (!passwordEncoder.matches(request.getPassword(), account.getPassword())) {
            return ApiResponse.error("Mật khẩu không chính xác");
        }

        if (!account.getIsActive()) {
            return ApiResponse.error("Tài khoản đã bị vô hiệu hóa");
        }

        String token = jwtTokenProvider.generateToken(
                account.getId(),
                account.getPhone(),
                account.getRole().name()
        );

        LoginResponse.LoginResponseBuilder responseBuilder = LoginResponse.builder()
                .token(token)
                .role(account.getRole().name())
                .phone(account.getPhone());

        // If student role, attach student info
        if (account.getRole() == Account.Role.STUDENT) {
            Student student = studentRepository.findByAccountId(account.getId())
                    .orElse(null);
            if (student != null) {
                responseBuilder
                        .studentId(student.getId())
                        .fullName(student.getFullName())
                        .className(student.getClassName());
            }
        }

        return ApiResponse.ok("Đăng nhập thành công", responseBuilder.build());
    }

    public ApiResponse<String> forgotPassword(ForgotPasswordRequest request) {
        boolean exists = accountRepository.existsByPhone(request.getPhone());

        if (!exists) {
            return ApiResponse.error("Số điện thoại không tồn tại trong hệ thống");
        }

        // In a real app, send OTP via SMS here
        return ApiResponse.ok("Mã xác nhận đã được gửi đến số điện thoại của bạn", null);
    }
}
