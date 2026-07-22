package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ApplicationRequest {

    @NotBlank(message = "Loại đơn không được để trống")
    private String type; // ABSENT_REQUEST, RESCHEDULE, REGRADE, OTHER

    @NotBlank(message = "Tiêu đề không được để trống")
    private String title;

    @NotBlank(message = "Nội dung không được để trống")
    private String content;
}
