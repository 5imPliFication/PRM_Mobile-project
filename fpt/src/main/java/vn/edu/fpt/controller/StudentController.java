package vn.edu.fpt.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.StudentProfileResponse;
import vn.edu.fpt.service.StudentService;

import java.util.UUID;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
public class StudentController {

    private final StudentService studentService;

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<StudentProfileResponse>> getProfile(Authentication authentication) {
        UUID accountId = (UUID) authentication.getPrincipal();
        StudentProfileResponse profile = studentService.getProfile(accountId);
        return ResponseEntity.ok(ApiResponse.ok(profile));
    }
}
