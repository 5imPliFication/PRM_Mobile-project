package vn.edu.fpt.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ParentProfileResponse {
    private UUID id;
    private String fullName;
    private String phone;
    private String occupation;
    private String relationship;
    private List<ChildInfo> children;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ChildInfo {
        private UUID id;
        private String fullName;
        private String className;
        private String studentCode;
    }
}