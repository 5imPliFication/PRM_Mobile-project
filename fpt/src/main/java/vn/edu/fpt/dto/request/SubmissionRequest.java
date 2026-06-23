package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class SubmissionRequest {

    @NotNull(message = "ID bài tập không được để trống")
    private UUID assignmentId;

    private String fileUrl;
}
