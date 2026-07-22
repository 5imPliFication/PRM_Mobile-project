package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.dto.response.NotificationResponse;
import vn.edu.fpt.entity.Account;
import vn.edu.fpt.entity.Notification;
import vn.edu.fpt.entity.Parent;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.repository.AccountRepository;
import vn.edu.fpt.repository.NotificationRepository;
import vn.edu.fpt.repository.ParentRepository;
import vn.edu.fpt.repository.StudentRepository;

import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final StudentRepository studentRepository;
    private final ParentRepository parentRepository;
    private final AccountRepository accountRepository;

    public List<NotificationResponse> getNotifications(UUID accountId) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));

        List<Notification> list;
        if (account.getRole() == Account.Role.STUDENT) {
            Student student = studentRepository.findByAccountId(accountId).orElse(null);
            if (student != null) {
                list = notificationRepository.findByAccountIdOrStudentIdOrderByCreatedAtDesc(accountId, student.getId());
            } else {
                list = notificationRepository.findByAccountIdOrderByCreatedAtDesc(accountId);
            }
        } else if (account.getRole() == Account.Role.PARENT) {
            Parent parent = parentRepository.findByAccountId(accountId).orElse(null);
            if (parent != null && parent.getStudents() != null && !parent.getStudents().isEmpty()) {
                List<UUID> studentIds = parent.getStudents().stream().map(Student::getId).collect(Collectors.toList());
                list = notificationRepository.findByAccountIdOrStudentIdInOrderByCreatedAtDesc(accountId, studentIds);
            } else {
                list = notificationRepository.findByAccountIdOrderByCreatedAtDesc(accountId);
            }
        } else {
            list = notificationRepository.findByAccountIdOrderByCreatedAtDesc(accountId);
        }

        return list.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public NotificationResponse markAsRead(UUID accountId, UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));

        notification.setIsRead(true);
        notificationRepository.save(notification);

        return toResponse(notification);
    }

    @Transactional
    public void markAllAsRead(UUID accountId) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));

        if (account.getRole() == Account.Role.STUDENT) {
            Student student = studentRepository.findByAccountId(accountId).orElse(null);
            if (student != null) {
                notificationRepository.markAllAsReadByAccountIdOrStudentId(accountId, student.getId());
            } else {
                notificationRepository.markAllAsReadByAccountId(accountId);
            }
        } else {
            notificationRepository.markAllAsReadByAccountId(accountId);
        }
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
