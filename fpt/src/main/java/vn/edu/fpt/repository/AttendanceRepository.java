package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Attendance;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, UUID> {
    List<Attendance> findByScheduleIdAndAttendanceDate(UUID scheduleId, LocalDate attendanceDate);
    List<Attendance> findByStudentIdOrderByAttendanceDateDesc(UUID studentId);
    Optional<Attendance> findByScheduleIdAndStudentIdAndAttendanceDate(UUID scheduleId, UUID studentId, LocalDate attendanceDate);
    boolean existsByScheduleIdAndStudentIdAndAttendanceDate(UUID scheduleId, UUID studentId, LocalDate attendanceDate);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query("UPDATE Attendance a SET a.markedBy = null WHERE a.markedBy.id = :teacherId")
    void nullifyMarkedByTeacher(@org.springframework.data.repository.query.Param("teacherId") UUID teacherId);
}