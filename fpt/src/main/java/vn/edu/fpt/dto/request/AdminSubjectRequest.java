package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AdminSubjectRequest {
    @NotBlank(message = "Tên môn học không được để trống")
    private String name;
    @NotBlank(message = "Mã môn học không được để trống")
    private String code;
}
