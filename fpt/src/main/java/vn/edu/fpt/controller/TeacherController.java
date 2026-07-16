package vn.edu.fpt.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.request.AssignmentCreateRequest;
import vn.edu.fpt.dto.request.AttendanceSheetRequest;
import vn.edu.fpt.dto.request.SubmissionGradeRequest;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.AttendanceResponse;
import vn.edu.fpt.dto.response.ClassStudentResponse;
import vn.edu.fpt.dto.response.ScheduleResponse;
import vn.edu.fpt.dto.response.SubmissionResponse;
import vn.edu.fpt.dto.response.SubjectOptionResponse;
import vn.edu.fpt.dto.response.TeacherAssignmentResponse;
import vn.edu.fpt.dto.response.TeacherProfileResponse;
import vn.edu.fpt.service.TeacherService;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/teachers")
@RequiredArgsConstructor
@PreAuthorize("hasRole('TEACHER')")
public class TeacherController {

    private final TeacherService teacherService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<TeacherProfileResponse>> me(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(teacherService.getProfile(accountId)));
    }

    @GetMapping("/classes")
    public ResponseEntity<ApiResponse<List<String>>> classes(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(teacherService.getClasses(accountId)));
    }

    @GetMapping("/classes/{className}/students")
    public ResponseEntity<ApiResponse<List<ClassStudentResponse>>> studentsInClass(
            Authentication auth, @PathVariable String className) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(teacherService.getStudentsInClass(accountId, className)));
    }

    @GetMapping("/sessions")
    public ResponseEntity<ApiResponse<List<ScheduleResponse>>> sessions(
            Authentication auth,
            @RequestParam(value = "dayOfWeek", required = false) Integer dayOfWeek) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(teacherService.getSessions(accountId, dayOfWeek)));
    }

    @GetMapping("/subjects")
    public ResponseEntity<ApiResponse<List<SubjectOptionResponse>>> subjects(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(teacherService.getSubjects(accountId)));
    }

    @GetMapping("/attendance")
    public ResponseEntity<ApiResponse<List<AttendanceResponse>>> attendanceSheet(
            Authentication auth,
            @RequestParam("scheduleId") UUID scheduleId,
            @RequestParam("date") LocalDate date) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(teacherService.getAttendanceSheet(accountId, scheduleId, date)));
    }

    @PostMapping("/attendance")
    public ResponseEntity<ApiResponse<List<AttendanceResponse>>> markAttendance(
            Authentication auth,
            @Valid @RequestBody AttendanceSheetRequest request) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok("Đã lưu điểm danh", teacherService.markAttendance(accountId, request)));
    }

    @GetMapping("/assignments")
    public ResponseEntity<ApiResponse<List<TeacherAssignmentResponse>>> assignments(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(teacherService.getAssignments(accountId)));
    }

    @PostMapping("/assignments")
    public ResponseEntity<ApiResponse<TeacherAssignmentResponse>> createAssignment(
            Authentication auth,
            @Valid @RequestBody AssignmentCreateRequest request) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok("Tạo bài tập thành công",
                        teacherService.createAssignment(accountId, request)));
    }

    @GetMapping("/assignments/{assignmentId}/submissions")
    public ResponseEntity<ApiResponse<List<SubmissionResponse>>> submissions(
            Authentication auth, @PathVariable UUID assignmentId) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(teacherService.getSubmissions(accountId, assignmentId)));
    }

    @PutMapping("/submissions/{submissionId}/grade")
    public ResponseEntity<ApiResponse<SubmissionResponse>> gradeSubmission(
            Authentication auth,
            @PathVariable UUID submissionId,
            @Valid @RequestBody SubmissionGradeRequest request) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok("Đã lưu điểm",
                        teacherService.gradeSubmission(accountId, submissionId, request)));
    }
}