package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.UUID;

@Data
public class AdminClassRequest {
    @NotBlank(message = "Tên lớp không được để trống")
    private String name;
    private Integer gradeLevel;
    private String academicYear;
    private String campus;
    private UUID homeroomTeacherId;
}
