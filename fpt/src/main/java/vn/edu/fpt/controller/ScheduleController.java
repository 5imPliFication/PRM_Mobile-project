package vn.edu.fpt.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.dto.response.ApiResponse;
import vn.edu.fpt.dto.response.ScheduleResponse;
import vn.edu.fpt.service.ScheduleService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<List<ScheduleResponse>>> getSchedules(
            Authentication authentication,
            @RequestParam(required = false) Integer dayOfWeek) {

        UUID accountId = (UUID) authentication.getPrincipal();
        List<ScheduleResponse> schedules = scheduleService.getSchedules(accountId, dayOfWeek);
        return ResponseEntity.ok(ApiResponse.ok(schedules));
    }
}
