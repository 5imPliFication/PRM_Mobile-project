package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.edu.fpt.dto.response.ChildAttendanceResponse;
import vn.edu.fpt.dto.response.GradeResponse;
import vn.edu.fpt.dto.response.NotificationResponse;
import vn.edu.fpt.dto.response.ParentProfileResponse;
import vn.edu.fpt.dto.response.ScheduleResponse;
import vn.edu.fpt.dto.response.StudentProfileResponse;
import vn.edu.fpt.entity.Attendance;
import vn.edu.fpt.entity.Grade;
import vn.edu.fpt.entity.Notification;
import vn.edu.fpt.entity.Parent;
import vn.edu.fpt.entity.Schedule;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.repository.AttendanceRepository;
import vn.edu.fpt.repository.GradeRepository;
import vn.edu.fpt.repository.NotificationRepository;
import vn.edu.fpt.repository.ParentRepository;
import vn.edu.fpt.repository.ScheduleRepository;
import vn.edu.fpt.repository.StudentRepository;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParentService {

    private final ParentRepository parentRepository;
    private final StudentRepository studentRepository;
    private final GradeRepository gradeRepository;
    private final AttendanceRepository attendanceRepository;
    private final ScheduleRepository scheduleRepository;
    private final NotificationRepository notificationRepository;

    public Parent resolveParent(UUID accountId) {
        return parentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin phụ huynh"));
    }

    /** Ensure the student belongs to the parent, throw otherwise. Returns the student. */
    private Student guardChild(Parent parent, UUID studentId) {
        if (!parentRepository.isParentOf(parent.getId(), studentId)) {
            throw new RuntimeException("Học sinh không thuộc phụ huynh này");
        }
        return studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy học sinh"));
    }

    public ParentProfileResponse getProfile(UUID accountId) {
        Parent p = resolveParent(accountId);
        List<Student> children = p.getStudents(); // many-to-many
        List<ParentProfileResponse.ChildInfo> infos = (children == null ? List.<Student>of() : children)
                .stream()
                .map(s -> ParentProfileResponse.ChildInfo.builder()
                        .id(s.getId())
                        .fullName(s.getFullName())
                        .className(s.getClassName())
                        .studentCode(s.getStudentCode())
                        .build())
                .collect(Collectors.toList());
        return ParentProfileResponse.builder()
                .id(p.getId())
                .fullName(p.getFullName())
                .phone(p.getPhone())
                .occupation(p.getOccupation())
                .relationship(p.getRelationship())
                .children(infos)
                .build();
    }

    public StudentProfileResponse getChildProfile(UUID accountId, UUID studentId) {
        Parent p = resolveParent(accountId);
        Student s = guardChild(p, studentId);
        return StudentProfileResponse.builder()
                .id(s.getId())
                .studentCode(s.getStudentCode())
                .fullName(s.getFullName())
                .className(s.getClassName())
                .academicYear(s.getAcademicYear())
                .campus(s.getCampus())
                .email(s.getEmail())
                .phone(s.getAccount() != null ? s.getAccount().getPhone() : null)
                .address(s.getAddress())
                .dateOfBirth(s.getDateOfBirth())
                .program(s.getProgram())
                .status(s.getStatus())
                .homeroomTeacher(s.getHomeroomTeacher())
                .parents(s.getParents() != null
                        ? s.getParents().stream()
                                .map(par -> StudentProfileResponse.ParentInfo.builder()
                                        .fullName(par.getFullName())
                                        .phone(par.getPhone())
                                        .occupation(par.getOccupation())
                                        .relationship(par.getRelationship())
                                        .build())
                                .collect(Collectors.toList())
                        : null)
                .build();
    }

    public List<GradeResponse> getChildGrades(UUID accountId, UUID studentId, String semester) {
        Parent p = resolveParent(accountId);
        Student s = guardChild(p, studentId);
        List<Grade> grades = (semester != null && !semester.isBlank())
                ? gradeRepository.findByStudentIdAndSemester(s.getId(), semester)
                : gradeRepository.findByStudentId(s.getId());
        return grades.stream()
                .map(g -> GradeResponse.builder()
                        .id(g.getId())
                        .subject(g.getSubject() != null ? g.getSubject().getName() : null)
                        .semester(g.getSemester())
                        .oralScore(g.getOralScore())
                        .fifteenMinScore(g.getFifteenMinScore())
                        .onePeriodScore(g.getOnePeriodScore())
                        .semesterScore(g.getSemesterScore())
                        .average(g.getAverage())
                        .build())
                .collect(Collectors.toList());
    }

    public List<ChildAttendanceResponse> getChildAttendance(UUID accountId, UUID studentId) {
        Parent p = resolveParent(accountId);
        Student s = guardChild(p, studentId);
        List<Attendance> records =
                attendanceRepository.findByStudentIdOrderByAttendanceDateDesc(s.getId());
        return records.stream()
                .map(a -> ChildAttendanceResponse.builder()
                        .id(a.getId())
                        .date(a.getAttendanceDate())
                        .subject(a.getSchedule() != null && a.getSchedule().getSubject() != null
                                ? a.getSchedule().getSubject().getName() : null)
                        .status(a.getStatus())
                        .note(a.getNote())
                        .markedBy(a.getMarkedBy() != null ? a.getMarkedBy().getFullName() : null)
                        .build())
                .collect(Collectors.toList());
    }

    public List<ScheduleResponse> getChildSchedule(UUID accountId, UUID studentId, Integer dayOfWeek) {
        Parent p = resolveParent(accountId);
        Student s = guardChild(p, studentId);
        List<Schedule> schedules;
        if (dayOfWeek != null) {
            schedules = scheduleRepository.findByStudentIdAndDayOfWeekOrderByStartTime(s.getId(), dayOfWeek);
        } else {
            schedules = scheduleRepository.findByStudentIdOrderByDayOfWeekAscStartTimeAsc(s.getId());
        }
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("HH:mm");
        return schedules.stream()
                .map(sc -> {
                    String start = sc.getStartTime().format(fmt);
                    String end = sc.getEndTime().format(fmt);
                    return ScheduleResponse.builder()
                            .id(sc.getId())
                            .subject(sc.getSubject() != null ? sc.getSubject().getName() : null)
                            .startTime(start)
                            .endTime(end)
                            .time(start + " - " + end)
                            .room(sc.getRoom())
                            .teacher(sc.getTeacher() != null ? sc.getTeacher().getFullName() : null)
                            .dayOfWeek(sc.getDayOfWeek())
                            .status(sc.getStatus())
                            .build();
                })
                .collect(Collectors.toList());
    }

    public List<NotificationResponse> getChildNotifications(UUID accountId, UUID studentId) {
        Parent p = resolveParent(accountId);
        Student s = guardChild(p, studentId);
        return notificationRepository.findByStudentIdOrderByCreatedAtDesc(s.getId())
                .stream()
                .map(n -> NotificationResponse.builder()
                        .id(n.getId())
                        .title(n.getTitle())
                        .body(n.getBody())
                        .category(n.getCategory())
                        .isRead(n.getIsRead())
                        .createdAt(n.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }
}