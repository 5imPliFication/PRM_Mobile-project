package vn.edu.fpt.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class AdminAccountResponse {
    private UUID id;
    private String phone;
    private String role;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private String linkedName; // Name of student/teacher/parent linked to this account
}
