package vn.edu.fpt.dto.response;

import lombok.Builder;
import lombok.Data;
import java.util.UUID;

@Data
@Builder
public class AdminTeacherResponse {
    private UUID id;
    private String fullName;
    private String specialization;
    private UUID accountId;
    private String accountPhone;
}
