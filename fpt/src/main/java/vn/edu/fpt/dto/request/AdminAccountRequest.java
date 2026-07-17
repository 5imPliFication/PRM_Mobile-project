package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import vn.edu.fpt.entity.Account.Role;

@Data
public class AdminAccountRequest {
    @NotBlank(message = "Số điện thoại không được để trống")
    private String phone;
    private String password; // Optional on update, required on create
    @NotNull(message = "Vai trò không được để trống")
    private Role role;
    private Boolean isActive;
}
