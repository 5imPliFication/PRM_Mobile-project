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
import java.util.Map;
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
    private final SchoolClassRepository schoolClassRepository;
    private final NotificationRepository notificationRepository;
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
                    .role(account.getRole() != null ? account.getRole().name() : null)
                    .isActive(account.getIsActive())
                    .createdAt(account.getCreatedAt())
                    .linkedName(linkedName)
                    .build();
        }).collect(Collectors.toList());
    }

    public AdminAccountResponse createAccount(AdminAccountRequest request) {
        if (accountRepository.findByPhone(request.getPhone()).isPresent()) {
            throw new IllegalArgumentException("Số điện thoại đã được sử dụng");
        }

        Account account = Account.builder()
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .build();

        Account saved = accountRepository.save(account);

        return AdminAccountResponse.builder()
                .id(saved.getId())
                .phone(saved.getPhone())
                .role(saved.getRole() != null ? saved.getRole().name() : null)
                .isActive(saved.getIsActive())
                .createdAt(saved.getCreatedAt())
                .linkedName("")
                .build();
    }

    public AdminAccountResponse updateAccount(UUID id, AdminAccountRequest request) {
        Account account = accountRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản"));

        accountRepository.findByPhone(request.getPhone()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new IllegalArgumentException("Số điện thoại đã được sử dụng");
            }
        });

        account.setPhone(request.getPhone());
        if (request.getPassword() != null && !request.getPassword().isBlank()) {
            account.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        if (request.getRole() != null) {
            account.setRole(request.getRole());
        }
        if (request.getIsActive() != null) {
            account.setIsActive(request.getIsActive());
        }

        Account saved = accountRepository.save(account);

        String linkedName = "";
        if (saved.getStudent() != null) {
            linkedName = saved.getStudent().getFullName() + " (Học sinh)";
        } else if (saved.getTeacher() != null) {
            linkedName = saved.getTeacher().getFullName() + " (Giáo viên)";
        } else if (saved.getParent() != null) {
            linkedName = saved.getParent().getFullName() + " (Phụ huynh)";
        } else if (saved.getRole() == Account.Role.ADMIN) {
            linkedName = "Quản trị viên";
        }

        return AdminAccountResponse.builder()
                .id(saved.getId())
                .phone(saved.getPhone())
                .role(saved.getRole() != null ? saved.getRole().name() : null)
                .isActive(saved.getIsActive())
                .createdAt(saved.getCreatedAt())
                .linkedName(linkedName)
                .build();
    }

    public void deleteAccount(UUID id) {
        Account account = accountRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản"));
        accountRepository.delete(account);
    }

    // ===== Classes =====
    @Transactional(readOnly = true)
    public List<AdminClassResponse> getAllClasses() {
        return schoolClassRepository.findAll().stream().map(c -> {
            Teacher hr = c.getHomeroomTeacher();
            int studentCount = studentRepository.findBySchoolClassId(c.getId()).size();
            return AdminClassResponse.builder()
                    .id(c.getId())
                    .name(c.getName())
                    .gradeLevel(c.getGradeLevel())
                    .academicYear(c.getAcademicYear())
                    .campus(c.getCampus())
                    .homeroomTeacherId(hr != null ? hr.getId() : null)
                    .homeroomTeacherName(hr != null ? hr.getFullName() : null)
                    .studentCount(studentCount)
                    .build();
        }).collect(Collectors.toList());
    }

    public AdminClassResponse createClass(AdminClassRequest request) {
        if (schoolClassRepository.findByName(request.getName()).isPresent()) {
            throw new IllegalArgumentException("Tên lớp đã tồn tại");
        }

        Teacher homeroomTeacher = null;
        if (request.getHomeroomTeacherId() != null) {
            homeroomTeacher = teacherRepository.findById(request.getHomeroomTeacherId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giáo viên chủ nhiệm"));
        }

        SchoolClass sc = SchoolClass.builder()
                .name(request.getName())
                .gradeLevel(request.getGradeLevel())
                .academicYear(request.getAcademicYear())
                .campus(request.getCampus())
                .homeroomTeacher(homeroomTeacher)
                .build();

        SchoolClass saved = schoolClassRepository.save(sc);
        return mapToClassResponse(saved);
    }

    public AdminClassResponse updateClass(UUID id, AdminClassRequest request) {
        SchoolClass sc = schoolClassRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lớp học"));

        schoolClassRepository.findByName(request.getName()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new IllegalArgumentException("Tên lớp đã tồn tại");
            }
        });

        Teacher homeroomTeacher = null;
        if (request.getHomeroomTeacherId() != null) {
            homeroomTeacher = teacherRepository.findById(request.getHomeroomTeacherId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giáo viên chủ nhiệm"));
        }

        sc.setName(request.getName());
        sc.setGradeLevel(request.getGradeLevel());
        sc.setAcademicYear(request.getAcademicYear());
        sc.setCampus(request.getCampus());
        sc.setHomeroomTeacher(homeroomTeacher);

        SchoolClass saved = schoolClassRepository.save(sc);
        return mapToClassResponse(saved);
    }

    public void deleteClass(UUID id) {
        SchoolClass sc = schoolClassRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lớp học"));

        // Delete schedules of this class
        scheduleRepository.deleteAll(scheduleRepository.findBySchoolClassIdOrderByDayOfWeekAscStartTimeAsc(id));

        // Unlink students from this class
        List<Student> students = studentRepository.findBySchoolClassId(id);
        for (Student s : students) {
            s.setSchoolClass(null);
            studentRepository.save(s);
        }

        schoolClassRepository.delete(sc);
    }

    private AdminClassResponse mapToClassResponse(SchoolClass sc) {
        Teacher hr = sc.getHomeroomTeacher();
        int studentCount = studentRepository.findBySchoolClassId(sc.getId()).size();
        return AdminClassResponse.builder()
                .id(sc.getId())
                .name(sc.getName())
                .gradeLevel(sc.getGradeLevel())
                .academicYear(sc.getAcademicYear())
                .campus(sc.getCampus())
                .homeroomTeacherId(hr != null ? hr.getId() : null)
                .homeroomTeacherName(hr != null ? hr.getFullName() : null)
                .studentCount(studentCount)
                .build();
    }

    // ===== Students =====
    @Transactional(readOnly = true)
    public List<AdminStudentResponse> getAllStudents() {
        return studentRepository.findAll().stream().map(this::mapToStudentResponse).collect(Collectors.toList());
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

        SchoolClass schoolClass = null;
        if (request.getClassId() != null) {
            schoolClass = schoolClassRepository.findById(request.getClassId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lớp học"));
        }

        Student student = Student.builder()
                .studentCode(request.getStudentCode())
                .fullName(request.getFullName())
                .schoolClass(schoolClass)
                .academicYear(request.getAcademicYear())
                .campus(request.getCampus())
                .email(request.getEmail())
                .address(request.getAddress())
                .dateOfBirth(request.getDateOfBirth())
                .program(request.getProgram())
                .status(request.getStatus() != null ? request.getStatus() : "Đang học")
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

        SchoolClass schoolClass = null;
        if (request.getClassId() != null) {
            schoolClass = schoolClassRepository.findById(request.getClassId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lớp học"));
        }

        student.setStudentCode(request.getStudentCode());
        student.setFullName(request.getFullName());
        student.setSchoolClass(schoolClass);
        student.setAcademicYear(request.getAcademicYear());
        student.setCampus(request.getCampus());
        student.setEmail(request.getEmail());
        student.setAddress(request.getAddress());
        student.setDateOfBirth(request.getDateOfBirth());
        student.setProgram(request.getProgram());
        if (request.getStatus() != null) {
            student.setStatus(request.getStatus());
        }
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
                .classId(student.getSchoolClass() != null ? student.getSchoolClass().getId() : null)
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
        return teacherRepository.findAll().stream().map(this::mapToTeacherResponse).collect(Collectors.toList());
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

        // Nullify homeroomTeacher in classes
        schoolClassRepository.findByHomeroomTeacherId(id).ifPresent(c -> {
            c.setHomeroomTeacher(null);
            schoolClassRepository.save(c);
        });

        teacher.setAccount(null);
        teacherRepository.save(teacher);
        teacherRepository.delete(teacher);
    }

    private AdminTeacherResponse mapToTeacherResponse(Teacher teacher) {
        Account acc = teacher.getAccount();
        String homeroomClass = schoolClassRepository.findByHomeroomTeacherId(teacher.getId())
                .map(SchoolClass::getName)
                .orElse(null);

        return AdminTeacherResponse.builder()
                .id(teacher.getId())
                .fullName(teacher.getFullName())
                .specialization(teacher.getSpecialization())
                .homeroomClass(homeroomClass)
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
        return scheduleRepository.findAll().stream().map(this::mapToScheduleResponse).collect(Collectors.toList());
    }

    public AdminScheduleResponse createSchedule(AdminScheduleRequest request) {
        Subject subject = subjectRepository.findById(request.getSubjectId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy môn học"));
        Teacher teacher = teacherRepository.findById(request.getTeacherId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giáo viên"));
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lớp học"));

        Schedule schedule = Schedule.builder()
                .dayOfWeek(request.getDayOfWeek())
                .startTime(LocalTime.parse(request.getStartTime()))
                .endTime(LocalTime.parse(request.getEndTime()))
                .room(request.getRoom())
                .status(request.getStatus() != null ? request.getStatus() : "Sắp học")
                .subject(subject)
                .teacher(teacher)
                .schoolClass(schoolClass)
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
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lớp học"));

        schedule.setDayOfWeek(request.getDayOfWeek());
        schedule.setStartTime(LocalTime.parse(request.getStartTime()));
        schedule.setEndTime(LocalTime.parse(request.getEndTime()));
        schedule.setRoom(request.getRoom());
        if (request.getStatus() != null) {
            schedule.setStatus(request.getStatus());
        }
        schedule.setSubject(subject);
        schedule.setTeacher(teacher);
        schedule.setSchoolClass(schoolClass);

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
                .classId(schedule.getSchoolClass().getId())
                .className(schedule.getSchoolClass().getName())
                .build();
    }

    // ===== Notifications =====
    @Transactional(readOnly = true)
    public List<AdminNotificationResponse> getAllAdminNotifications() {
        List<Notification> all = notificationRepository.findAll();
        Map<String, List<Notification>> grouped = new java.util.LinkedHashMap<>();
        for (Notification n : all) {
            String key = n.getTitle() + "|" + n.getBody() + "|" + (n.getCreatedAt() != null ? n.getCreatedAt().toString() : "");
            grouped.computeIfAbsent(key, k -> new ArrayList<>()).add(n);
        }

        List<AdminNotificationResponse> result = new ArrayList<>();
        for (List<Notification> group : grouped.values()) {
            if (group.isEmpty()) continue;
            Notification first = group.get(0);
            result.add(AdminNotificationResponse.builder()
                    .id(first.getId())
                    .title(first.getTitle())
                    .content(first.getBody())
                    .category(first.getCategory())
                    .targetGroup("Broadcasting (" + group.size() + " người nhận)")
                    .createdAt(first.getCreatedAt())
                    .recipientCount(group.size())
                    .build());
        }
        result.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));
        return result;
    }

    public AdminNotificationResponse sendNotification(AdminNotificationRequest request) {
        String category = (request.getCategory() != null && !request.getCategory().isBlank())
                ? request.getCategory()
                : "Thông báo";
        String targetGroup = request.getTargetGroup() != null ? request.getTargetGroup().toUpperCase() : "ALL";

        List<Notification> toSave = new ArrayList<>();

        if ("STUDENT".equals(targetGroup) || "ALL".equals(targetGroup)) {
            List<Student> students = studentRepository.findAll();
            for (Student s : students) {
                toSave.add(Notification.builder()
                        .title(request.getTitle())
                        .body(request.getContent())
                        .category(category)
                        .isRead(false)
                        .student(s)
                        .account(s.getAccount())
                        .build());
            }
        }

        if ("TEACHER".equals(targetGroup) || "ALL".equals(targetGroup)) {
            List<Teacher> teachers = teacherRepository.findAll();
            for (Teacher t : teachers) {
                if (t.getAccount() != null) {
                    toSave.add(Notification.builder()
                            .title(request.getTitle())
                            .body(request.getContent())
                            .category(category)
                            .isRead(false)
                            .account(t.getAccount())
                            .build());
                }
            }
        }

        if ("PARENT".equals(targetGroup) || "ALL".equals(targetGroup)) {
            List<Parent> parents = parentRepository.findAll();
            for (Parent p : parents) {
                if (p.getAccount() != null) {
                    toSave.add(Notification.builder()
                            .title(request.getTitle())
                            .body(request.getContent())
                            .category(category)
                            .isRead(false)
                            .account(p.getAccount())
                            .build());
                }
            }
        }

        if (toSave.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy người nhận nào phù hợp");
        }

        List<Notification> saved = notificationRepository.saveAll(toSave);
        Notification sample = saved.get(0);

        return AdminNotificationResponse.builder()
                .id(sample.getId())
                .title(sample.getTitle())
                .content(sample.getBody())
                .category(sample.getCategory())
                .targetGroup(targetGroup)
                .createdAt(sample.getCreatedAt())
                .recipientCount(saved.size())
                .build();
    }

    public void deleteAdminNotification(UUID id) {
        Notification n = notificationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy thông báo"));

        List<Notification> matching = notificationRepository.findAll().stream()
                .filter(item -> item.getTitle().equals(n.getTitle()) && item.getBody().equals(n.getBody()))
                .collect(Collectors.toList());

        notificationRepository.deleteAll(matching);
    }
}
