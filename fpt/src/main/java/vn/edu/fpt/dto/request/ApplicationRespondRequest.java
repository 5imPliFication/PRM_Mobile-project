package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ApplicationRespondRequest {

    @NotBlank(message = "Trạng thái không được để trống")
    private String status; // APPROVED or REJECTED

    private String responseNote;
}
