package vn.edu.fpt.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> getNotifications(
            Authentication authentication) {

        UUID accountId = (UUID) authentication.getPrincipal();
        List<NotificationResponse> notifications = notificationService.getNotifications(accountId);
        return ResponseEntity.ok(ApiResponse.ok(notifications));
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<ApiResponse<NotificationResponse>> markAsRead(@PathVariable UUID id) {
        NotificationResponse response = notificationService.markAsRead(id);
        return ResponseEntity.ok(ApiResponse.ok("Đã đánh dấu đã đọc", response));
    }

    @PutMapping("/read-all")
    public ResponseEntity<ApiResponse<String>> markAllAsRead(Authentication authentication) {
        UUID accountId = (UUID) authentication.getPrincipal();
        notificationService.markAllAsRead(accountId);
        return ResponseEntity.ok(ApiResponse.ok("Đã đánh dấu tất cả đã đọc", null));
    }
}
