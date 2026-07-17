package vn.edu.fpt.dto.response;

import lombok.Builder;
import lombok.Data;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class AdminParentResponse {
    private UUID id;
    private String fullName;
    private String phone;
    private String occupation;
    private String relationship;
    private UUID accountId;
    private String accountPhone;
    private List<UUID> studentIds;
    private List<String> studentNames;
}
