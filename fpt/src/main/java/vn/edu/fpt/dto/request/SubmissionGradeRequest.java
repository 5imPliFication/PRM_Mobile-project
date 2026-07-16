package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SubmissionGradeRequest {
    @NotNull
    private Double grade;
    private String feedback;
}