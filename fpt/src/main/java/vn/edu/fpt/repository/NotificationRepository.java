package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Notification;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByStudentIdOrderByCreatedAtDesc(UUID studentId);
    List<Notification> findByAccountIdOrderByCreatedAtDesc(UUID accountId);

    @Query("SELECT n FROM Notification n WHERE n.account.id = :accountId OR (n.student IS NOT NULL AND n.student.id = :studentId) ORDER BY n.createdAt DESC")
    List<Notification> findByAccountIdOrStudentIdOrderByCreatedAtDesc(@Param("accountId") UUID accountId, @Param("studentId") UUID studentId);

    @Query("SELECT n FROM Notification n WHERE n.account.id = :accountId OR (n.student IS NOT NULL AND n.student.id IN :studentIds) ORDER BY n.createdAt DESC")
    List<Notification> findByAccountIdOrStudentIdInOrderByCreatedAtDesc(@Param("accountId") UUID accountId, @Param("studentIds") List<UUID> studentIds);

    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.student.id = :studentId")
    void markAllAsReadByStudentId(UUID studentId);

    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.account.id = :accountId OR (n.student IS NOT NULL AND n.student.id = :studentId)")
    void markAllAsReadByAccountIdOrStudentId(@Param("accountId") UUID accountId, @Param("studentId") UUID studentId);

    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.account.id = :accountId")
    void markAllAsReadByAccountId(@Param("accountId") UUID accountId);
}
