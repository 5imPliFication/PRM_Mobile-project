package vn.edu.fpt.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.NotificationResponse;
import vn.edu.fpt.service.NotificationService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> getNotifications(
            Authentication authentication) {

        UUID accountId = (UUID) authentication.getPrincipal();
        List<NotificationResponse> notifications = notificationService.getNotifications(accountId);
        return ResponseEntity.ok(ApiResponse.ok(notifications));
    }

    @PutMapping("/{id}/read")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<NotificationResponse>> markAsRead(
            Authentication authentication,
            @PathVariable UUID id) {

        UUID accountId = (UUID) authentication.getPrincipal();
        NotificationResponse response = notificationService.markAsRead(accountId, id);
        return ResponseEntity.ok(ApiResponse.ok("Đã đánh dấu đã đọc", response));
    }

    @PutMapping("/read-all")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<String>> markAllAsRead(Authentication authentication) {
        UUID accountId = (UUID) authentication.getPrincipal();
        notificationService.markAllAsRead(accountId);
        return ResponseEntity.ok(ApiResponse.ok("Đã đánh dấu tất cả đã đọc", null));
    }
}