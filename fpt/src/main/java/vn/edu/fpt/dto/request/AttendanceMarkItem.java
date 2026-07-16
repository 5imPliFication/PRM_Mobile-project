package vn.edu.fpt.dto.request;

import lombok.Data;

import java.util.UUID;

@Data
public class AttendanceMarkItem {
    private UUID studentId;
    private String status;   // PRESENT / ABSENT / LATE / EXCUSED
    private String note;
}