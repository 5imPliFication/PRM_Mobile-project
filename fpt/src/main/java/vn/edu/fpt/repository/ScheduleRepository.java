package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Schedule;

import java.util.List;
import java.util.UUID;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, UUID> {
    List<Schedule> findByStudentIdAndDayOfWeekOrderByStartTime(UUID studentId, Integer dayOfWeek);
    List<Schedule> findByStudentIdOrderByDayOfWeekAscStartTimeAsc(UUID studentId);

    List<Schedule> findByTeacherIdOrderByDayOfWeekAscStartTimeAsc(UUID teacherId);
    List<Schedule> findByTeacherIdAndDayOfWeekOrderByStartTime(UUID teacherId, Integer dayOfWeek);

    List<Schedule> findBySubjectId(UUID subjectId);
}