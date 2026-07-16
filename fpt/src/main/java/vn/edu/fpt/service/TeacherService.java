package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.dto.request.AssignmentCreateRequest;
import vn.edu.fpt.dto.request.AttendanceMarkItem;
import vn.edu.fpt.dto.request.AttendanceSheetRequest;
import vn.edu.fpt.dto.request.SubmissionGradeRequest;
import vn.edu.fpt.dto.response.AttendanceResponse;
import vn.edu.fpt.dto.response.ClassStudentResponse;
import vn.edu.fpt.dto.response.ScheduleResponse;
import vn.edu.fpt.dto.response.SubjectOptionResponse;
import vn.edu.fpt.dto.response.SubmissionResponse;
import vn.edu.fpt.dto.response.TeacherAssignmentResponse;
import vn.edu.fpt.dto.response.TeacherProfileResponse;
import vn.edu.fpt.entity.Assignment;
import vn.edu.fpt.entity.Attendance;
import vn.edu.fpt.entity.Schedule;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.entity.Submission;
import vn.edu.fpt.entity.Subject;
import vn.edu.fpt.entity.Teacher;
import vn.edu.fpt.repository.AssignmentRepository;
import vn.edu.fpt.repository.AttendanceRepository;
import vn.edu.fpt.repository.ScheduleRepository;
import vn.edu.fpt.repository.StudentRepository;
import vn.edu.fpt.repository.SubjectRepository;
import vn.edu.fpt.repository.SubmissionRepository;
import vn.edu.fpt.repository.TeacherRepository;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeacherService {

    private final TeacherRepository teacherRepository;
    private final ScheduleRepository scheduleRepository;
    private final StudentRepository studentRepository;
    private final AttendanceRepository attendanceRepository;
    private final AssignmentRepository assignmentRepository;
    private final SubmissionRepository submissionRepository;
    private final SubjectRepository subjectRepository;

    public Teacher resolveTeacher(UUID accountId) {
        return teacherRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin giáo viên"));
    }

    public TeacherProfileResponse getProfile(UUID accountId) {
        Teacher t = resolveTeacher(accountId);
        return TeacherProfileResponse.builder()
                .id(t.getId())
                .fullName(t.getFullName())
                .specialization(t.getSpecialization())
                .phone(accountPhone(t))
                .build();
    }

    private String accountPhone(Teacher t) {
        return t.getAccount() != null ? t.getAccount().getPhone() : null;
    }

    /** Distinct class names this teacher teaches (from their schedules). */
    public List<String> getClasses(UUID accountId) {
        Teacher t = resolveTeacher(accountId);
        List<Schedule> sessions = scheduleRepository.findByTeacherIdOrderByDayOfWeekAscStartTimeAsc(t.getId());
        return sessions.stream()
                .map(Schedule::getStudent)
                .filter(java.util.Objects::nonNull)
                .map(Student::getClassName)
                .filter(c -> c != null && !c.isBlank())
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    /** Students in a class that this teacher teaches. */
    public List<ClassStudentResponse> getStudentsInClass(UUID accountId, String className) {
        Teacher t = resolveTeacher(accountId);
        List<Student> students = studentRepository.findStudentsOfTeacherInClass(t.getId(), className);
        return students.stream()
                .map(s -> ClassStudentResponse.builder()
                        .id(s.getId())
                        .studentCode(s.getStudentCode())
                        .fullName(s.getFullName())
                        .className(s.getClassName())
                        .build())
                .collect(Collectors.toList());
    }

    /** Distinct subjects this teacher teaches (for the create-assignment picker). */
    public List<SubjectOptionResponse> getSubjects(UUID accountId) {
        Teacher t = resolveTeacher(accountId);
        List<Schedule> sessions = scheduleRepository.findByTeacherIdOrderByDayOfWeekAscStartTimeAsc(t.getId());
        Map<UUID, Subject> seen = new LinkedHashMap<>();
        for (Schedule s : sessions) {
            if (s.getSubject() != null) seen.putIfAbsent(s.getSubject().getId(), s.getSubject());
        }
        return seen.values().stream()
                .map(sub -> SubjectOptionResponse.builder()
                        .id(sub.getId())
                        .name(sub.getName())
                        .code(sub.getCode())
                        .build())
                .collect(Collectors.toList());
    }

    /** Sessions (schedules) of this teacher, optionally filtered by day-of-week. */
    public List<ScheduleResponse> getSessions(UUID accountId, Integer dayOfWeek) {
        Teacher t = resolveTeacher(accountId);
        List<Schedule> sessions;
        if (dayOfWeek != null) {
            sessions = scheduleRepository.findByTeacherIdAndDayOfWeekOrderByStartTime(t.getId(), dayOfWeek);
        } else {
            sessions = scheduleRepository.findByTeacherIdOrderByDayOfWeekAscStartTimeAsc(t.getId());
        }
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("HH:mm");
        // Schedule is per-student; dedupe by (day, subject, start, end, room) so the
        // teacher sees one row per class period rather than one per enrolled student.
        Map<String, ScheduleResponse> deduped = new LinkedHashMap<>();
        for (Schedule s : sessions) {
            String start = s.getStartTime().format(fmt);
            String end = s.getEndTime().format(fmt);
            String subject = s.getSubject() != null ? s.getSubject().getName() : "";
            String key = s.getDayOfWeek() + "|" + subject + "|" + start + "|" + end + "|" + s.getRoom();
            deduped.computeIfAbsent(key, k -> ScheduleResponse.builder()
                    .id(s.getId())
                    .subject(subject)
                    .startTime(start)
                    .endTime(end)
                    .time(start + " - " + end)
                    .room(s.getRoom())
                    .teacher(s.getTeacher() != null ? s.getTeacher().getFullName() : null)
                    .dayOfWeek(s.getDayOfWeek())
                    .status(s.getStatus())
                    .build());
        }
        return new ArrayList<>(deduped.values());
    }

    /** Attendance sheet for a session+date: one row per enrolled student (marked or not). */
    public List<AttendanceResponse> getAttendanceSheet(UUID accountId, UUID scheduleId, LocalDate date) {
        Teacher t = resolveTeacher(accountId);
        Schedule session = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tiết học"));
        if (!session.getTeacher().getId().equals(t.getId())) {
            throw new RuntimeException("Bạn không có quyền với tiết học này");
        }

        // Schedule is per-student; collect all schedule rows of this teacher for the same
        // subject+day+time+room on that date. Simpler: any student linked to this teacher via
        // a schedule whose subject/day/time/room match the session. We approximate by class.
        String className = session.getStudent().getClassName();
        List<Student> students = studentRepository.findStudentsOfTeacherInClass(t.getId(), className);

        List<Attendance> existing = attendanceRepository
                .findByScheduleIdAndAttendanceDate(scheduleId, date);
        Map<UUID, Attendance> byStudent = new LinkedHashMap<>();
        for (Attendance a : existing) {
            byStudent.put(a.getStudent().getId(), a);
        }

        List<AttendanceResponse> out = new ArrayList<>();
        for (Student s : students) {
            Attendance a = byStudent.get(s.getId());
            out.add(AttendanceResponse.builder()
                    .id(a != null ? a.getId() : null)
                    .scheduleId(scheduleId)
                    .studentId(s.getId())
                    .studentName(s.getFullName())
                    .attendanceDate(date)
                    .status(a != null ? a.getStatus() : null)
                    .note(a != null ? a.getNote() : null)
                    .markedBy(a != null ? a.getMarkedBy() != null ? a.getMarkedBy().getId() : null : null)
                    .marked(a != null)
                    .build());
        }
        return out;
    }

    /** Bulk mark/refresh attendance for a session+date. */
    @Transactional
    public List<AttendanceResponse> markAttendance(UUID accountId, AttendanceSheetRequest req) {
        Teacher t = resolveTeacher(accountId);
        Schedule session = scheduleRepository.findById(req.getScheduleId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tiết học"));
        if (!session.getTeacher().getId().equals(t.getId())) {
            throw new RuntimeException("Bạn không có quyền cho tiết học này");
        }

        List<AttendanceResponse> out = new ArrayList<>();
        for (AttendanceMarkItem item : req.getItems()) {
            UUID studentId = item.getStudentId();
            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy học sinh"));
            String status = item.getStatus() == null ? "PRESENT" : item.getStatus().toUpperCase();

            Attendance existing = attendanceRepository
                    .findByScheduleIdAndStudentIdAndAttendanceDate(
                            req.getScheduleId(), studentId, req.getAttendanceDate())
                    .orElse(null);
            if (existing == null) {
                Attendance a = Attendance.builder()
                        .schedule(session)
                        .student(student)
                        .attendanceDate(req.getAttendanceDate())
                        .status(status)
                        .note(item.getNote())
                        .markedBy(t)
                        .build();
                attendanceRepository.save(a);
                out.add(toAttendanceResponse(a, student));
            } else {
                existing.setStatus(status);
                existing.setNote(item.getNote());
                existing.setMarkedBy(t);
                attendanceRepository.save(existing);
                out.add(toAttendanceResponse(existing, student));
            }
        }
        return out;
    }

    private AttendanceResponse toAttendanceResponse(Attendance a, Student s) {
        return AttendanceResponse.builder()
                .id(a.getId())
                .scheduleId(a.getSchedule().getId())
                .studentId(s.getId())
                .studentName(s.getFullName())
                .attendanceDate(a.getAttendanceDate())
                .status(a.getStatus())
                .note(a.getNote())
                .markedBy(a.getMarkedBy() != null ? a.getMarkedBy().getId() : null)
                .marked(true)
                .build();
    }

    /** Assignments created by this teacher. */
    public List<TeacherAssignmentResponse> getAssignments(UUID accountId) {
        Teacher t = resolveTeacher(accountId);
        List<Assignment> assignments = assignmentRepository.findByTeacherIdOrderByDueDateDesc(t.getId());
        return assignments.stream()
                .map(a -> TeacherAssignmentResponse.builder()
                        .id(a.getId())
                        .title(a.getTitle())
                        .description(a.getDescription())
                        .dueDate(a.getDueDate())
                        .targetClass(a.getTargetClass())
                        .subject(a.getSubject() != null ? a.getSubject().getName() : null)
                        .subjectId(a.getSubject() != null ? a.getSubject().getId() : null)
                        .submissionCount(submissionRepository.findByAssignmentId(a.getId()).size())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public TeacherAssignmentResponse createAssignment(UUID accountId, AssignmentCreateRequest req) {
        Teacher t = resolveTeacher(accountId);
        Subject subject = subjectRepository.findById(req.getSubjectId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học"));
        Assignment a = Assignment.builder()
                .title(req.getTitle())
                .description(req.getDescription())
                .dueDate(req.getDueDate())
                .targetClass(req.getTargetClass())
                .subject(subject)
                .teacher(t)
                .build();
        assignmentRepository.save(a);
        return TeacherAssignmentResponse.builder()
                .id(a.getId())
                .title(a.getTitle())
                .description(a.getDescription())
                .dueDate(a.getDueDate())
                .targetClass(a.getTargetClass())
                .subject(subject.getName())
                .subjectId(subject.getId())
                .submissionCount(0)
                .build();
    }

    /** Submissions for an assignment owned by this teacher. */
    public List<SubmissionResponse> getSubmissions(UUID accountId, UUID assignmentId) {
        Teacher t = resolveTeacher(accountId);
        Assignment a = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bài tập"));
        if (!a.getTeacher().getId().equals(t.getId())) {
            throw new RuntimeException("Bạn không có quyền cho bài tập này");
        }
        List<Submission> subs = submissionRepository.findByAssignmentId(assignmentId);
        return subs.stream()
                .map(s -> SubmissionResponse.builder()
                        .id(s.getId())
                        .assignmentId(assignmentId)
                        .studentId(s.getStudent().getId())
                        .studentName(s.getStudent().getFullName())
                        .studentCode(s.getStudent().getStudentCode())
                        .fileUrl(s.getFileUrl())
                        .grade(s.getGrade())
                        .submittedAt(s.getSubmittedAt())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public SubmissionResponse gradeSubmission(UUID accountId, UUID submissionId, SubmissionGradeRequest req) {
        Teacher t = resolveTeacher(accountId);
        Submission sub = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bài nộp"));
        Assignment a = sub.getAssignment();
        if (!a.getTeacher().getId().equals(t.getId())) {
            throw new RuntimeException("Bạn không có quyền chấm bài này");
        }
        sub.setGrade(req.getGrade());
        submissionRepository.save(sub);
        return SubmissionResponse.builder()
                .id(sub.getId())
                .assignmentId(a.getId())
                .studentId(sub.getStudent().getId())
                .studentName(sub.getStudent().getFullName())
                .studentCode(sub.getStudent().getStudentCode())
                .fileUrl(sub.getFileUrl())
                .grade(sub.getGrade())
                .submittedAt(sub.getSubmittedAt())
                .build();
    }
}