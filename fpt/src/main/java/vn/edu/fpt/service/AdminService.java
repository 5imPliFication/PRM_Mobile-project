package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.dto.request.*;
import vn.edu.fpt.dto.response.*;
import vn.edu.fpt.entity.*;
import vn.edu.fpt.repository.*;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminService {

    private final AccountRepository accountRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final ParentRepository parentRepository;
    private final SubjectRepository subjectRepository;
    private final ScheduleRepository scheduleRepository;
    private final AssignmentRepository assignmentRepository;
    private final AttendanceRepository attendanceRepository;
    private final ParentLinkRequestRepository parentLinkRequestRepository;
    private final PasswordEncoder passwordEncoder;

    // ===== Stats =====
    @Transactional(readOnly = true)
    public AdminDashboardStatsResponse getStats() {
        return AdminDashboardStatsResponse.builder()
                .totalAccounts(accountRepository.count())
                .totalStudents(studentRepository.count())
                .totalTeachers(teacherRepository.count())
                .totalParents(parentRepository.count())
                .totalSchedules(scheduleRepository.count())
                .build();
    }

    // ===== Accounts =====
    @Transactional(readOnly = true)
    public List<AdminAccountResponse> getAllAccounts() {
        return accountRepository.findAll().stream().map(account -> {
            String linkedName = "";
            if (account.getStudent() != null) {
                linkedName = account.getStudent().getFullName() + " (Học sinh)";
            } else if (account.getTeacher() != null) {
                linkedName = account.getTeacher().getFullName() + " (Giáo viên)";
            } else if (account.getParent() != null) {
                linkedName = account.getParent().getFullName() + " (Phụ huynh)";
            } else if (account.getRole() == Account.Role.ADMIN) {
                linkedName = "Quản trị viên";
            }

            return AdminAccountResponse.builder()
                    .id(account.getId())
                    .phone(account.getPhone())
                    .role(account.getRole().name())
                    .isActive(account.getIsActive())
                    .createdAt(account.getCreatedAt())
                    .linkedName(linkedName)
                    .build();
        }).collect(Collectors.toList());
    }

    public AdminAccountResponse createAccount(AdminAccountRequest request) {
        if (accountRepository.findByPhone(request.getPhone()).isPresent()) {
            throw new IllegalArgumentException("Số điện thoại đã tồn tại trên hệ thống");
        }

        Account account = Account.builder()
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .build();

        Account saved = accountRepository.save(account);
        return mapToAccountResponse(saved);
    }

    public AdminAccountResponse updateAccount(UUID id, AdminAccountRequest request) {
        Account account = accountRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản"));

        accountRepository.findByPhone(request.getPhone()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new IllegalArgumentException("Số điện thoại đã tồn tại trên hệ thống");
            }
        });

        account.setPhone(request.getPhone());
        account.setRole(request.getRole());
        if (request.getIsActive() != null) {
            account.setIsActive(request.getIsActive());
        }
        if (request.getPassword() != null && !request.getPassword().trim().isEmpty()) {
            account.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        Account saved = accountRepository.save(account);
        return mapToAccountResponse(saved);
    }

    public void deleteAccount(UUID id) {
        Account account = accountRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản"));

        // Cascade parent deleting because of lack of JPA cascade
        parentRepository.findByAccountId(id).ifPresent(parent -> {
            parentLinkRequestRepository.deleteAll(parentLinkRequestRepository.findByParentAccountIdOrderByCreatedAtDesc(id));
            parent.getStudents().clear();
            parentRepository.save(parent);
            parentRepository.delete(parent);
        });

        // Linked Student & Teacher records are cascade deleted by mappedBy settings in Account entity
        accountRepository.delete(account);
    }

    private AdminAccountResponse mapToAccountResponse(Account account) {
        return AdminAccountResponse.builder()
                .id(account.getId())
                .phone(account.getPhone())
                .role(account.getRole().name())
                .isActive(account.getIsActive())
                .createdAt(account.getCreatedAt())
                .build();
    }

    // ===== Students =====
    @Transactional(readOnly = true)
    public List<AdminStudentResponse> getAllStudents() {
        return studentRepository.findAll().stream().map(student -> {
            Account acc = student.getAccount();
            return AdminStudentResponse.builder()
                    .id(student.getId())
                    .studentCode(student.getStudentCode())
                    .fullName(student.getFullName())
                    .className(student.getClassName())
                    .academicYear(student.getAcademicYear())
                    .campus(student.getCampus())
                    .email(student.getEmail())
                    .address(student.getAddress())
                    .dateOfBirth(student.getDateOfBirth())
                    .program(student.getProgram())
                    .status(student.getStatus())
                    .homeroomTeacher(student.getHomeroomTeacher())
                    .accountId(acc != null ? acc.getId() : null)
                    .accountPhone(acc != null ? acc.getPhone() : null)
                    .build();
        }).collect(Collectors.toList());
    }

    public AdminStudentResponse createStudent(AdminStudentRequest request) {
        if (studentRepository.findByStudentCode(request.getStudentCode()).isPresent()) {
            throw new IllegalArgumentException("Mã học sinh đã tồn tại");
        }

        Account account = null;
        if (request.getAccountId() != null) {
            account = accountRepository.findById(request.getAccountId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản để liên kết"));
            if (studentRepository.findByAccountId(request.getAccountId()).isPresent()) {
                throw new IllegalArgumentException("Tài khoản đã được liên kết với một học sinh khác");
            }
        }

        Student student = Student.builder()
                .studentCode(request.getStudentCode())
                .fullName(request.getFullName())
                .className(request.getClassName())
                .academicYear(request.getAcademicYear())
                .campus(request.getCampus())
                .email(request.getEmail())
                .address(request.getAddress())
                .dateOfBirth(request.getDateOfBirth())
                .program(request.getProgram())
                .status(request.getStatus() != null ? request.getStatus() : "Đang học")
                .homeroomTeacher(request.getHomeroomTeacher())
                .account(account)
                .build();

        Student saved = studentRepository.save(student);
        return mapToStudentResponse(saved);
    }

    public AdminStudentResponse updateStudent(UUID id, AdminStudentRequest request) {
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy học sinh"));

        studentRepository.findByStudentCode(request.getStudentCode()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new IllegalArgumentException("Mã học sinh đã tồn tại");
            }
        });

        Account account = null;
        if (request.getAccountId() != null) {
            account = accountRepository.findById(request.getAccountId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản để liên kết"));

            studentRepository.findByAccountId(request.getAccountId()).ifPresent(existingStudent -> {
                if (!existingStudent.getId().equals(id)) {
                    throw new IllegalArgumentException("Tài khoản đã được liên kết với một học sinh khác");
                }
            });
        }

        student.setStudentCode(request.getStudentCode());
        student.setFullName(request.getFullName());
        student.setClassName(request.getClassName());
        student.setAcademicYear(request.getAcademicYear());
        student.setCampus(request.getCampus());
        student.setEmail(request.getEmail());
        student.setAddress(request.getAddress());
        student.setDateOfBirth(request.getDateOfBirth());
        student.setProgram(request.getProgram());
        if (request.getStatus() != null) {
            student.setStatus(request.getStatus());
        }
        student.setHomeroomTeacher(request.getHomeroomTeacher());
        student.setAccount(account);

        Student saved = studentRepository.save(student);
        return mapToStudentResponse(saved);
    }

    public void deleteStudent(UUID id) {
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy học sinh"));

        // Unlink from Parents
        for (Parent parent : parentRepository.findByStudentId(id)) {
            parent.getStudents().remove(student);
            parentRepository.save(parent);
        }
        student.getParents().clear();

        // Delete Parent Link Requests
        parentLinkRequestRepository.deleteAll(parentLinkRequestRepository.findByStudentIdOrderByCreatedAtDesc(id));

        // Delete Attendances
        attendanceRepository.deleteAll(attendanceRepository.findByStudentIdOrderByAttendanceDateDesc(id));

        // Delete Schedules
        scheduleRepository.deleteAll(scheduleRepository.findByStudentIdOrderByDayOfWeekAscStartTimeAsc(id));

        student.setAccount(null);
        studentRepository.save(student);
        studentRepository.delete(student);
    }

    private AdminStudentResponse mapToStudentResponse(Student student) {
        Account acc = student.getAccount();
        return AdminStudentResponse.builder()
                .id(student.getId())
                .studentCode(student.getStudentCode())
                .fullName(student.getFullName())
                .className(student.getClassName())
                .academicYear(student.getAcademicYear())
                .campus(student.getCampus())
                .email(student.getEmail())
                .address(student.getAddress())
                .dateOfBirth(student.getDateOfBirth())
                .program(student.getProgram())
                .status(student.getStatus())
                .homeroomTeacher(student.getHomeroomTeacher())
                .accountId(acc != null ? acc.getId() : null)
                .accountPhone(acc != null ? acc.getPhone() : null)
                .build();
    }

    // ===== Teachers =====
    @Transactional(readOnly = true)
    public List<AdminTeacherResponse> getAllTeachers() {
        return teacherRepository.findAll().stream().map(teacher -> {
            Account acc = teacher.getAccount();
            return AdminTeacherResponse.builder()
                    .id(teacher.getId())
                    .fullName(teacher.getFullName())
                    .specialization(teacher.getSpecialization())
                    .accountId(acc != null ? acc.getId() : null)
                    .accountPhone(acc != null ? acc.getPhone() : null)
                    .build();
        }).collect(Collectors.toList());
    }

    public AdminTeacherResponse createTeacher(AdminTeacherRequest request) {
        Account account = null;
        if (request.getAccountId() != null) {
            account = accountRepository.findById(request.getAccountId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản để liên kết"));
            if (teacherRepository.findByAccountId(request.getAccountId()).isPresent()) {
                throw new IllegalArgumentException("Tài khoản đã được liên kết với một giáo viên khác");
            }
        }

        Teacher teacher = Teacher.builder()
                .fullName(request.getFullName())
                .specialization(request.getSpecialization())
                .account(account)
                .build();

        Teacher saved = teacherRepository.save(teacher);
        return mapToTeacherResponse(saved);
    }

    public AdminTeacherResponse updateTeacher(UUID id, AdminTeacherRequest request) {
        Teacher teacher = teacherRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giáo viên"));

        Account account = null;
        if (request.getAccountId() != null) {
            account = accountRepository.findById(request.getAccountId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản để liên kết"));

            teacherRepository.findByAccountId(request.getAccountId()).ifPresent(existingTeacher -> {
                if (!existingTeacher.getId().equals(id)) {
                    throw new IllegalArgumentException("Tài khoản đã được liên kết với một giáo viên khác");
                }
            });
        }

        teacher.setFullName(request.getFullName());
        teacher.setSpecialization(request.getSpecialization());
        teacher.setAccount(account);

        Teacher saved = teacherRepository.save(teacher);
        return mapToTeacherResponse(saved);
    }

    public void deleteTeacher(UUID id) {
        Teacher teacher = teacherRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giáo viên"));

        // Delete assignments of this teacher
        assignmentRepository.deleteAll(assignmentRepository.findByTeacherIdOrderByDueDateDesc(id));

        // Delete schedules of this teacher
        scheduleRepository.deleteAll(scheduleRepository.findByTeacherIdOrderByDayOfWeekAscStartTimeAsc(id));

        // Nullify marked_by in attendances
        attendanceRepository.nullifyMarkedByTeacher(id);

        teacher.setAccount(null);
        teacherRepository.save(teacher);
        teacherRepository.delete(teacher);
    }

    private AdminTeacherResponse mapToTeacherResponse(Teacher teacher) {
        Account acc = teacher.getAccount();
        return AdminTeacherResponse.builder()
                .id(teacher.getId())
                .fullName(teacher.getFullName())
                .specialization(teacher.getSpecialization())
                .accountId(acc != null ? acc.getId() : null)
                .accountPhone(acc != null ? acc.getPhone() : null)
                .build();
    }

    // ===== Parents =====
    @Transactional(readOnly = true)
    public List<AdminParentResponse> getAllParents() {
        return parentRepository.findAll().stream().map(parent -> {
            Account acc = parent.getAccount();
            List<UUID> studentIds = new ArrayList<>();
            List<String> studentNames = new ArrayList<>();
            if (parent.getStudents() != null) {
                studentIds = parent.getStudents().stream().map(Student::getId).collect(Collectors.toList());
                studentNames = parent.getStudents().stream().map(Student::getFullName).collect(Collectors.toList());
            }

            return AdminParentResponse.builder()
                    .id(parent.getId())
                    .fullName(parent.getFullName())
                    .phone(parent.getPhone())
                    .occupation(parent.getOccupation())
                    .relationship(parent.getRelationship())
                    .accountId(acc != null ? acc.getId() : null)
                    .accountPhone(acc != null ? acc.getPhone() : null)
                    .studentIds(studentIds)
                    .studentNames(studentNames)
                    .build();
        }).collect(Collectors.toList());
    }

    public AdminParentResponse createParent(AdminParentRequest request) {
        Account account = null;
        if (request.getAccountId() != null) {
            account = accountRepository.findById(request.getAccountId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản để liên kết"));
            if (parentRepository.findByAccountId(request.getAccountId()).isPresent()) {
                throw new IllegalArgumentException("Tài khoản đã được liên kết với một phụ huynh khác");
            }
        }

        Parent parent = Parent.builder()
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .occupation(request.getOccupation())
                .relationship(request.getRelationship())
                .account(account)
                .students(new ArrayList<>())
                .build();

        Parent saved = parentRepository.save(parent);
        return mapToParentResponse(saved);
    }

    public AdminParentResponse updateParent(UUID id, AdminParentRequest request) {
        Parent parent = parentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phụ huynh"));

        Account account = null;
        if (request.getAccountId() != null) {
            account = accountRepository.findById(request.getAccountId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản để liên kết"));

            parentRepository.findByAccountId(request.getAccountId()).ifPresent(existingParent -> {
                if (!existingParent.getId().equals(id)) {
                    throw new IllegalArgumentException("Tài khoản đã được liên kết với một phụ huynh khác");
                }
            });
        }

        parent.setFullName(request.getFullName());
        parent.setPhone(request.getPhone());
        parent.setOccupation(request.getOccupation());
        parent.setRelationship(request.getRelationship());
        parent.setAccount(account);

        Parent saved = parentRepository.save(parent);
        return mapToParentResponse(saved);
    }

    public void deleteParent(UUID id) {
        Parent parent = parentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phụ huynh"));

        if (parent.getAccount() != null) {
            parentLinkRequestRepository.deleteAll(parentLinkRequestRepository.findByParentAccountIdOrderByCreatedAtDesc(parent.getAccount().getId()));
        }

        parent.getStudents().clear();
        parentRepository.save(parent);
        parentRepository.delete(parent);
    }

    public void linkStudent(UUID parentId, UUID studentId) {
        Parent parent = parentRepository.findById(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phụ huynh"));
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy học sinh"));

        if (!parent.getStudents().contains(student)) {
            parent.getStudents().add(student);
            parentRepository.save(parent);
        }
    }

    public void unlinkStudent(UUID parentId, UUID studentId) {
        Parent parent = parentRepository.findById(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phụ huynh"));
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy học sinh"));

        if (parent.getStudents().contains(student)) {
            parent.getStudents().remove(student);
            parentRepository.save(parent);
        }
    }

    private AdminParentResponse mapToParentResponse(Parent parent) {
        Account acc = parent.getAccount();
        List<UUID> studentIds = new ArrayList<>();
        List<String> studentNames = new ArrayList<>();
        if (parent.getStudents() != null) {
            studentIds = parent.getStudents().stream().map(Student::getId).collect(Collectors.toList());
            studentNames = parent.getStudents().stream().map(Student::getFullName).collect(Collectors.toList());
        }

        return AdminParentResponse.builder()
                .id(parent.getId())
                .fullName(parent.getFullName())
                .phone(parent.getPhone())
                .occupation(parent.getOccupation())
                .relationship(parent.getRelationship())
                .accountId(acc != null ? acc.getId() : null)
                .accountPhone(acc != null ? acc.getPhone() : null)
                .studentIds(studentIds)
                .studentNames(studentNames)
                .build();
    }

    // ===== Subjects =====
    @Transactional(readOnly = true)
    public List<Subject> getAllSubjects() {
        return subjectRepository.findAll();
    }

    public Subject createSubject(AdminSubjectRequest request) {
        if (subjectRepository.findByCode(request.getCode()).isPresent()) {
            throw new IllegalArgumentException("Mã môn học đã tồn tại");
        }

        Subject subject = Subject.builder()
                .name(request.getName())
                .code(request.getCode())
                .build();

        return subjectRepository.save(subject);
    }

    public Subject updateSubject(UUID id, AdminSubjectRequest request) {
        Subject subject = subjectRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy môn học"));

        subjectRepository.findByCode(request.getCode()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new IllegalArgumentException("Mã môn học đã tồn tại");
            }
        });

        subject.setName(request.getName());
        subject.setCode(request.getCode());

        return subjectRepository.save(subject);
    }

    public void deleteSubject(UUID id) {
        Subject subject = subjectRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy môn học"));

        // Delete assignments linked to subject
        assignmentRepository.deleteAll(assignmentRepository.findBySubjectId(id));

        // Delete schedules linked to subject
        scheduleRepository.deleteAll(scheduleRepository.findBySubjectId(id));

        subjectRepository.delete(subject);
    }

    // ===== Schedules =====
    @Transactional(readOnly = true)
    public List<AdminScheduleResponse> getAllSchedules() {
        return scheduleRepository.findAll().stream().map(schedule -> AdminScheduleResponse.builder()
                .id(schedule.getId())
                .dayOfWeek(schedule.getDayOfWeek())
                .startTime(schedule.getStartTime())
                .endTime(schedule.getEndTime())
                .room(schedule.getRoom())
                .status(schedule.getStatus())
                .subjectId(schedule.getSubject().getId())
                .subjectName(schedule.getSubject().getName())
                .subjectCode(schedule.getSubject().getCode())
                .teacherId(schedule.getTeacher().getId())
                .teacherName(schedule.getTeacher().getFullName())
                .studentId(schedule.getStudent().getId())
                .studentName(schedule.getStudent().getFullName())
                .build()).collect(Collectors.toList());
    }

    public AdminScheduleResponse createSchedule(AdminScheduleRequest request) {
        Subject subject = subjectRepository.findById(request.getSubjectId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy môn học"));
        Teacher teacher = teacherRepository.findById(request.getTeacherId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giáo viên"));
        Student student = studentRepository.findById(request.getStudentId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy học sinh"));

        Schedule schedule = Schedule.builder()
                .dayOfWeek(request.getDayOfWeek())
                .startTime(LocalTime.parse(request.getStartTime()))
                .endTime(LocalTime.parse(request.getEndTime()))
                .room(request.getRoom())
                .status(request.getStatus() != null ? request.getStatus() : "Sắp học")
                .subject(subject)
                .teacher(teacher)
                .student(student)
                .build();

        Schedule saved = scheduleRepository.save(schedule);
        return mapToScheduleResponse(saved);
    }

    public AdminScheduleResponse updateSchedule(UUID id, AdminScheduleRequest request) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lịch học"));
        Subject subject = subjectRepository.findById(request.getSubjectId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy môn học"));
        Teacher teacher = teacherRepository.findById(request.getTeacherId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giáo viên"));
        Student student = studentRepository.findById(request.getStudentId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy học sinh"));

        schedule.setDayOfWeek(request.getDayOfWeek());
        schedule.setStartTime(LocalTime.parse(request.getStartTime()));
        schedule.setEndTime(LocalTime.parse(request.getEndTime()));
        schedule.setRoom(request.getRoom());
        if (request.getStatus() != null) {
            schedule.setStatus(request.getStatus());
        }
        schedule.setSubject(subject);
        schedule.setTeacher(teacher);
        schedule.setStudent(student);

        Schedule saved = scheduleRepository.save(schedule);
        return mapToScheduleResponse(saved);
    }

    public void deleteSchedule(UUID id) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lịch học"));
        scheduleRepository.delete(schedule);
    }

    private AdminScheduleResponse mapToScheduleResponse(Schedule schedule) {
        return AdminScheduleResponse.builder()
                .id(schedule.getId())
                .dayOfWeek(schedule.getDayOfWeek())
                .startTime(schedule.getStartTime())
                .endTime(schedule.getEndTime())
                .room(schedule.getRoom())
                .status(schedule.getStatus())
                .subjectId(schedule.getSubject().getId())
                .subjectName(schedule.getSubject().getName())
                .subjectCode(schedule.getSubject().getCode())
                .teacherId(schedule.getTeacher().getId())
                .teacherName(schedule.getTeacher().getFullName())
                .studentId(schedule.getStudent().getId())
                .studentName(schedule.getStudent().getFullName())
                .build();
    }
}
