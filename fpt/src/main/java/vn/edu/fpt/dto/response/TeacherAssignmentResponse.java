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
public class TeacherAssignmentResponse {
    private UUID id;
    private String title;
    private String description;
    private LocalDateTime dueDate;
    private String targetClass;
    private String subject;
    private UUID subjectId;
    private int submissionCount;
}