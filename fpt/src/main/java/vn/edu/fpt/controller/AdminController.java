package vn.edu.fpt.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.request.*;
import vn.edu.fpt.dto.response.*;
import vn.edu.fpt.entity.Subject;
import vn.edu.fpt.service.AdminService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    // Stats
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<AdminDashboardStatsResponse>> getStats() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getStats()));
    }

    // Accounts
    @GetMapping("/accounts")
    public ResponseEntity<ApiResponse<List<AdminAccountResponse>>> getAllAccounts() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllAccounts()));
    }

    @PostMapping("/accounts")
    public ResponseEntity<ApiResponse<AdminAccountResponse>> createAccount(
            @Valid @RequestBody AdminAccountRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Tạo tài khoản thành công", adminService.createAccount(request)));
    }

    @PutMapping("/accounts/{id}")
    public ResponseEntity<ApiResponse<AdminAccountResponse>> updateAccount(
            @PathVariable UUID id, @Valid @RequestBody AdminAccountRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật tài khoản thành công", adminService.updateAccount(id, request)));
    }

    @DeleteMapping("/accounts/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteAccount(@PathVariable UUID id) {
        adminService.deleteAccount(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa tài khoản thành công", null));
    }

    // Classes
    @GetMapping("/classes")
    public ResponseEntity<ApiResponse<List<AdminClassResponse>>> getAllClasses() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllClasses()));
    }

    @PostMapping("/classes")
    public ResponseEntity<ApiResponse<AdminClassResponse>> createClass(
            @Valid @RequestBody AdminClassRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Tạo lớp học thành công", adminService.createClass(request)));
    }

    @PutMapping("/classes/{id}")
    public ResponseEntity<ApiResponse<AdminClassResponse>> updateClass(
            @PathVariable UUID id, @Valid @RequestBody AdminClassRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật lớp học thành công", adminService.updateClass(id, request)));
    }

    @DeleteMapping("/classes/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteClass(@PathVariable UUID id) {
        adminService.deleteClass(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa lớp học thành công", null));
    }

    // Students
    @GetMapping("/students")
    public ResponseEntity<ApiResponse<List<AdminStudentResponse>>> getAllStudents() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllStudents()));
    }

    @PostMapping("/students")
    public ResponseEntity<ApiResponse<AdminStudentResponse>> createStudent(
            @Valid @RequestBody AdminStudentRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Tạo học sinh thành công", adminService.createStudent(request)));
    }

    @PutMapping("/students/{id}")
    public ResponseEntity<ApiResponse<AdminStudentResponse>> updateStudent(
            @PathVariable UUID id, @Valid @RequestBody AdminStudentRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật học sinh thành công", adminService.updateStudent(id, request)));
    }

    @DeleteMapping("/students/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteStudent(@PathVariable UUID id) {
        adminService.deleteStudent(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa học sinh thành công", null));
    }

    // Teachers
    @GetMapping("/teachers")
    public ResponseEntity<ApiResponse<List<AdminTeacherResponse>>> getAllTeachers() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllTeachers()));
    }

    @PostMapping("/teachers")
    public ResponseEntity<ApiResponse<AdminTeacherResponse>> createTeacher(
            @Valid @RequestBody AdminTeacherRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Tạo giáo viên thành công", adminService.createTeacher(request)));
    }

    @PutMapping("/teachers/{id}")
    public ResponseEntity<ApiResponse<AdminTeacherResponse>> updateTeacher(
            @PathVariable UUID id, @Valid @RequestBody AdminTeacherRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật giáo viên thành công", adminService.updateTeacher(id, request)));
    }

    @DeleteMapping("/teachers/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteTeacher(@PathVariable UUID id) {
        adminService.deleteTeacher(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa giáo viên thành công", null));
    }

    // Parents
    @GetMapping("/parents")
    public ResponseEntity<ApiResponse<List<AdminParentResponse>>> getAllParents() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllParents()));
    }

    @PostMapping("/parents")
    public ResponseEntity<ApiResponse<AdminParentResponse>> createParent(
            @Valid @RequestBody AdminParentRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Tạo phụ huynh thành công", adminService.createParent(request)));
    }

    @PutMapping("/parents/{id}")
    public ResponseEntity<ApiResponse<AdminParentResponse>> updateParent(
            @PathVariable UUID id, @Valid @RequestBody AdminParentRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật phụ huynh thành công", adminService.updateParent(id, request)));
    }

    @DeleteMapping("/parents/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteParent(@PathVariable UUID id) {
        adminService.deleteParent(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa phụ huynh thành công", null));
    }

    @PostMapping("/parents/{parentId}/students/{studentId}")
    public ResponseEntity<ApiResponse<Void>> linkStudent(
            @PathVariable UUID parentId, @PathVariable UUID studentId) {
        adminService.linkStudent(parentId, studentId);
        return ResponseEntity.ok(ApiResponse.ok("Liên kết học sinh thành công", null));
    }

    @DeleteMapping("/parents/{parentId}/students/{studentId}")
    public ResponseEntity<ApiResponse<Void>> unlinkStudent(
            @PathVariable UUID parentId, @PathVariable UUID studentId) {
        adminService.unlinkStudent(parentId, studentId);
        return ResponseEntity.ok(ApiResponse.ok("Hủy liên kết học sinh thành công", null));
    }

    // Subjects
    @GetMapping("/subjects")
    public ResponseEntity<ApiResponse<List<Subject>>> getAllSubjects() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllSubjects()));
    }

    @PostMapping("/subjects")
    public ResponseEntity<ApiResponse<Subject>> createSubject(
            @Valid @RequestBody AdminSubjectRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Tạo môn học thành công", adminService.createSubject(request)));
    }

    @PutMapping("/subjects/{id}")
    public ResponseEntity<ApiResponse<Subject>> updateSubject(
            @PathVariable UUID id, @Valid @RequestBody AdminSubjectRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật môn học thành công", adminService.updateSubject(id, request)));
    }

    @DeleteMapping("/subjects/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteSubject(@PathVariable UUID id) {
        adminService.deleteSubject(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa môn học thành công", null));
    }

    // Schedules
    @GetMapping("/schedules")
    public ResponseEntity<ApiResponse<List<AdminScheduleResponse>>> getAllSchedules() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllSchedules()));
    }

    @PostMapping("/schedules")
    public ResponseEntity<ApiResponse<AdminScheduleResponse>> createSchedule(
            @Valid @RequestBody AdminScheduleRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Tạo lịch học thành công", adminService.createSchedule(request)));
    }

    @PutMapping("/schedules/{id}")
    public ResponseEntity<ApiResponse<AdminScheduleResponse>> updateSchedule(
            @PathVariable UUID id, @Valid @RequestBody AdminScheduleRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật lịch học thành công", adminService.updateSchedule(id, request)));
    }

    @DeleteMapping("/schedules/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteSchedule(@PathVariable UUID id) {
        adminService.deleteSchedule(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa lịch học thành công", null));
    }

    // Notifications
    @GetMapping("/notifications")
    public ResponseEntity<ApiResponse<List<AdminNotificationResponse>>> getAllAdminNotifications() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllAdminNotifications()));
    }

    @PostMapping("/notifications")
    public ResponseEntity<ApiResponse<AdminNotificationResponse>> sendNotification(
            @Valid @RequestBody AdminNotificationRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Gửi thông báo thành công", adminService.sendNotification(request)));
    }

    @DeleteMapping("/notifications/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteAdminNotification(@PathVariable UUID id) {
        adminService.deleteAdminNotification(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa thông báo thành công", null));
    }
}
