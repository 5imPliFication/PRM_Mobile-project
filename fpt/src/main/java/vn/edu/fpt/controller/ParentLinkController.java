package vn.edu.fpt.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.request.ParentLinkRequestCreateRequest;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.ParentLinkRequestResponse;
import vn.edu.fpt.service.ParentLinkService;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class ParentLinkController {

    private final ParentLinkService parentLinkService;

    // ---------------- Student side ----------------

    @PostMapping("/api/students/parent-link/requests")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<ParentLinkRequestResponse>> createRequest(
            Authentication auth,
            @Valid @RequestBody ParentLinkRequestCreateRequest req) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(
                "Đã gửi lời mời liên kết đến phụ huynh",
                parentLinkService.createRequest(accountId, req)));
    }

    @GetMapping("/api/students/parent-link/requests")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<List<ParentLinkRequestResponse>>> myRequests(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(parentLinkService.getMyRequests(accountId)));
    }

    @DeleteMapping("/api/students/parent-link/requests/{id}")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<String>> cancelRequest(
            Authentication auth,
            @PathVariable UUID id) {
        UUID accountId = (UUID) auth.getPrincipal();
        parentLinkService.cancelRequest(accountId, id);
        return ResponseEntity.ok(ApiResponse.ok("Đã hủy lời mời", null));
    }

    // ---------------- Parent side ----------------

    @GetMapping("/api/parents/link-requests")
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<ApiResponse<List<ParentLinkRequestResponse>>> incomingRequests(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(parentLinkService.getIncomingRequests(accountId)));
    }

    @PostMapping("/api/parents/link-requests/{id}/accept")
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<ApiResponse<ParentLinkRequestResponse>> accept(
            Authentication auth, @PathVariable UUID id) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(
                "Đã chấp nhận liên kết",
                parentLinkService.acceptRequest(accountId, id)));
    }

    @PostMapping("/api/parents/link-requests/{id}/reject")
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<ApiResponse<ParentLinkRequestResponse>> reject(
            Authentication auth, @PathVariable UUID id) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(
                "Đã từ chối",
                parentLinkService.rejectRequest(accountId, id)));
    }
}