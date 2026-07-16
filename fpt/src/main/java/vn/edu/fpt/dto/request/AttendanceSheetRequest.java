package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Data
public class AttendanceSheetRequest {
    @NotNull
    private UUID scheduleId;

    @NotNull
    private LocalDate attendanceDate;

    @NotEmpty
    private List<AttendanceMarkItem> items;
}