package vn.edu.fpt.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttendanceResponse {
    private UUID id;
    private UUID scheduleId;
    private UUID studentId;
    private String studentName;
    private LocalDate attendanceDate;
    private String status;
    private String note;
    private UUID markedBy;
    private boolean marked;   // true if attendance already recorded for this student on this date
}