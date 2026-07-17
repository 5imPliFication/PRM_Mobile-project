package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.util.UUID;

@Data
public class AdminTeacherRequest {
    @NotBlank(message = "Họ tên không được để trống")
    private String fullName;
    private String specialization;
    private UUID accountId;
}
