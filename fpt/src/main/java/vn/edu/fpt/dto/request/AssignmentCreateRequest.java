package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class AssignmentCreateRequest {
    @NotBlank
    private String title;
    private String description;
    @NotNull
    private LocalDateTime dueDate;
    @NotBlank
    private String targetClass;
    @NotNull
    private UUID subjectId;
}