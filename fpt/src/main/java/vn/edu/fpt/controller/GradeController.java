package vn.edu.fpt.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.GradeResponse;
import vn.edu.fpt.service.GradeService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/grades")
@RequiredArgsConstructor
public class GradeController {

    private final GradeService gradeService;

    @GetMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<List<GradeResponse>>> getGrades(
            Authentication authentication,
            @RequestParam(required = false) String semester) {

        UUID accountId = (UUID) authentication.getPrincipal();
        List<GradeResponse> grades = gradeService.getGrades(accountId, semester);
        return ResponseEntity.ok(ApiResponse.ok(grades));
    }
}
