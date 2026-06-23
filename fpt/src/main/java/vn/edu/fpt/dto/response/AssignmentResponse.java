package vn.edu.fpt.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AssignmentResponse {

    private UUID id;
    private String title;
    private String subject;
    private String description;
    private LocalDateTime dueDate;
    private String status; // "TODO", "SUBMITTED", "OVERDUE"
    private Double grade;
    private LocalDateTime submittedAt;
}
