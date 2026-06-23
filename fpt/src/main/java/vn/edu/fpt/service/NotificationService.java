package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.dto.response.NotificationResponse;
import vn.edu.fpt.entity.Notification;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.repository.NotificationRepository;
import vn.edu.fpt.repository.StudentRepository;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final StudentRepository studentRepository;

    public List<NotificationResponse> getNotifications(UUID accountId) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        return notificationRepository.findByStudentIdOrderByCreatedAtDesc(student.getId())
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public NotificationResponse markAsRead(UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));

        notification.setIsRead(true);
        notificationRepository.save(notification);

        return toResponse(notification);
    }

    @Transactional
    public void markAllAsRead(UUID accountId) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        notificationRepository.markAllAsReadByStudentId(student.getId());
    }

    private NotificationResponse toResponse(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .title(notification.getTitle())
                .body(notification.getBody())
                .category(notification.getCategory())
                .isRead(notification.getIsRead())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
