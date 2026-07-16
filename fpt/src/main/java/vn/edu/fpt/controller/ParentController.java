package vn.edu.fpt.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.ChildAttendanceResponse;
import vn.edu.fpt.dto.response.GradeResponse;
import vn.edu.fpt.dto.response.NotificationResponse;
import vn.edu.fpt.dto.response.ParentProfileResponse;
import vn.edu.fpt.dto.response.ScheduleResponse;
import vn.edu.fpt.dto.response.StudentProfileResponse;
import vn.edu.fpt.service.ParentService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/parents")
@RequiredArgsConstructor
@PreAuthorize("hasRole('PARENT')")
public class ParentController {

    private final ParentService parentService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<ParentProfileResponse>> me(Authentication auth) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.ok(parentService.getProfile(accountId)));
    }

    @GetMapping("/children/{studentId}/profile")
    public ResponseEntity<ApiResponse<StudentProfileResponse>> childProfile(
            Authentication auth, @PathVariable UUID studentId) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(parentService.getChildProfile(accountId, studentId)));
    }

    @GetMapping("/children/{studentId}/grades")
    public ResponseEntity<ApiResponse<List<GradeResponse>>> childGrades(
            Authentication auth,
            @PathVariable UUID studentId,
            @RequestParam(value = "semester", required = false) String semester) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(parentService.getChildGrades(accountId, studentId, semester)));
    }

    @GetMapping("/children/{studentId}/attendance")
    public ResponseEntity<ApiResponse<List<ChildAttendanceResponse>>> childAttendance(
            Authentication auth, @PathVariable UUID studentId) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(parentService.getChildAttendance(accountId, studentId)));
    }

    @GetMapping("/children/{studentId}/schedule")
    public ResponseEntity<ApiResponse<List<ScheduleResponse>>> childSchedule(
            Authentication auth,
            @PathVariable UUID studentId,
            @RequestParam(value = "dayOfWeek", required = false) Integer dayOfWeek) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(parentService.getChildSchedule(accountId, studentId, dayOfWeek)));
    }

    @GetMapping("/children/{studentId}/notifications")
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> childNotifications(
            Authentication auth, @PathVariable UUID studentId) {
        UUID accountId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(
                ApiResponse.ok(parentService.getChildNotifications(accountId, studentId)));
    }
}