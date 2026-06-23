package vn.edu.fpt.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentProfileResponse {

    private UUID id;
    private String studentCode;
    private String fullName;
    private String className;
    private String academicYear;
    private String campus;
    private String email;
    private String phone;
    private String address;
    private LocalDate dateOfBirth;
    private String program;
    private String status;
    private String homeroomTeacher;
    private List<ParentInfo> parents;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ParentInfo {
        private String fullName;
        private String phone;
        private String occupation;
        private String relationship;
    }
}
