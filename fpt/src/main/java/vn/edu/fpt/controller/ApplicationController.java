package vn.edu.fpt.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.request.ApplicationRequest;
import vn.edu.fpt.dto.request.ApplicationRespondRequest;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.ApplicationResponse;
import vn.edu.fpt.service.ApplicationService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/applications")
@RequiredArgsConstructor
public class ApplicationController {

    private final ApplicationService applicationService;

    /** Student: get my applications. */
    @GetMapping("/me")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<List<ApplicationResponse>>> myApplications(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(applicationService.getMyApplications(accountId)));
    }

    /** Student: submit a new application. */
    @PostMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<ApplicationResponse>> submit(
            Authentication auth,
            @Valid @RequestBody ApplicationRequest request) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(applicationService.submit(accountId, request)));
    }

    /** Teacher (homeroom): get applications from class. */
    @GetMapping("/class")
    @PreAuthorize("hasRole('TEACHER')")
    public ResponseEntity<ApiResponse<List<ApplicationResponse>>> classApplications(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(applicationService.getClassApplications(accountId)));
    }

    /** Teacher (homeroom): approve or reject an application. */
    @PostMapping("/{applicationId}/respond")
    @PreAuthorize("hasRole('TEACHER')")
    public ResponseEntity<ApiResponse<ApplicationResponse>> respond(
            Authentication auth,
            @PathVariable UUID applicationId,
            @Valid @RequestBody ApplicationRespondRequest request) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(applicationService.respond(accountId, applicationId, request)));
    }
}
