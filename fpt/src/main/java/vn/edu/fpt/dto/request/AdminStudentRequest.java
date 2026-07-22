package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.time.LocalDate;
import java.util.UUID;

@Data
public class AdminStudentRequest {
    @NotBlank(message = "Mã học sinh không được để trống")
    private String studentCode;
    @NotBlank(message = "Họ tên không được để trống")
    private String fullName;
    private UUID classId;
    private String academicYear;
    private String campus;
    private String email;
    private String address;
    private LocalDate dateOfBirth;
    private String program;
    private String status;
    private UUID accountId;
}
