package vn.edu.fpt.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
public class AdminStudentResponse {
    private UUID id;
    private String studentCode;
    private String fullName;
    private String className;
    private String academicYear;
    private String campus;
    private String email;
    private String address;
    private LocalDate dateOfBirth;
    private String program;
    private String status;
    private String homeroomTeacher;
    private UUID accountId;
    private String accountPhone;
}
