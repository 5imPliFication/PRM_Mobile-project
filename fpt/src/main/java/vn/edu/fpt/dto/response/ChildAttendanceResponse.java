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
public class ChildAttendanceResponse {
    private UUID id;
    private LocalDate date;
    private String subject;     // schedule's subject
    private String status;
    private String note;
    private String markedBy;    // teacher full name who marked
}