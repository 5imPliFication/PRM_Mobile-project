package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Notification;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByStudentIdOrderByCreatedAtDesc(UUID studentId);

    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.student.id = :studentId")
    void markAllAsReadByStudentId(UUID studentId);
}
