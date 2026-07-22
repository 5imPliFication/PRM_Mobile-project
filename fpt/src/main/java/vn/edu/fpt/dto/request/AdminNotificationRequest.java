package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AdminNotificationRequest {
    @NotBlank(message = "Tiêu đề không được để trống")
    private String title;

    @NotBlank(message = "Nội dung không được để trống")
    private String content;

    private String category; // Default: "Thông báo"

    @NotBlank(message = "Đối tượng nhận không được để trống")
    private String targetGroup; // "ALL", "STUDENT", "TEACHER", "PARENT"
}
