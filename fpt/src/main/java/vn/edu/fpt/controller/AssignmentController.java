package vn.edu.fpt.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.request.SubmissionRequest;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.AssignmentResponse;
import vn.edu.fpt.service.AssignmentService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/assignments")
@RequiredArgsConstructor
public class AssignmentController {

    private final AssignmentService assignmentService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<AssignmentResponse>>> getAssignments(
            Authentication authentication,
            @RequestParam(required = false) String status) {

        UUID accountId = (UUID) authentication.getPrincipal();
        List<AssignmentResponse> assignments = assignmentService.getAssignments(accountId, status);
        return ResponseEntity.ok(ApiResponse.ok(assignments));
    }

    @PostMapping("/{id}/submit")
    public ResponseEntity<ApiResponse<AssignmentResponse>> submitAssignment(
            Authentication authentication,
            @PathVariable UUID id,
            @Valid @RequestBody SubmissionRequest request) {

        UUID accountId = (UUID) authentication.getPrincipal();
        AssignmentResponse response = assignmentService.submitAssignment(accountId, id, request);
        return ResponseEntity.ok(ApiResponse.ok("Nộp bài thành công", response));
    }
}
