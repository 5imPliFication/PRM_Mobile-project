package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ForgotPasswordRequest {

    @NotBlank(message = "Số điện thoại không được để trống")
    private String phone;
}
