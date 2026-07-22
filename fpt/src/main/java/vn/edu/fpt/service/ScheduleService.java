package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.edu.fpt.dto.response.ScheduleResponse;
import vn.edu.fpt.entity.Schedule;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.repository.ScheduleRepository;
import vn.edu.fpt.repository.StudentRepository;

import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final StudentRepository studentRepository;

    private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("HH:mm");

    public List<ScheduleResponse> getSchedules(UUID accountId, Integer dayOfWeek) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        if (student.getSchoolClass() == null) {
            return Collections.emptyList();
        }

        UUID classId = student.getSchoolClass().getId();
        List<Schedule> schedules;
        if (dayOfWeek != null) {
            schedules = scheduleRepository.findBySchoolClassIdAndDayOfWeekOrderByStartTime(
                    classId, dayOfWeek);
        } else {
            schedules = scheduleRepository.findBySchoolClassIdOrderByDayOfWeekAscStartTimeAsc(
                    classId);
        }

        return schedules.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private ScheduleResponse toResponse(Schedule schedule) {
        String startStr = schedule.getStartTime().format(TIME_FORMAT);
        String endStr = schedule.getEndTime().format(TIME_FORMAT);

        return ScheduleResponse.builder()
                .id(schedule.getId())
                .subject(schedule.getSubject().getName())
                .startTime(startStr)
                .endTime(endStr)
                .time(startStr + " - " + endStr)
                .room(schedule.getRoom())
                .teacher(schedule.getTeacher().getFullName())
                .dayOfWeek(schedule.getDayOfWeek())
                .status(schedule.getStatus())
                .build();
    }
}
