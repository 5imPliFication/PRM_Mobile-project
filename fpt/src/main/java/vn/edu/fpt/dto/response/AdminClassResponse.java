package vn.edu.fpt.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class AdminClassResponse {
    private UUID id;
    private String name;
    private Integer gradeLevel;
    private String academicYear;
    private String campus;
    private UUID homeroomTeacherId;
    private String homeroomTeacherName;
    private Integer studentCount;
}
