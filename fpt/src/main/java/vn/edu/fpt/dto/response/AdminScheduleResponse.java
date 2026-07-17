package vn.edu.fpt.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalTime;
import java.util.UUID;

@Data
@Builder
public class AdminScheduleResponse {
    private UUID id;
    private Integer dayOfWeek;
    private LocalTime startTime;
    private LocalTime endTime;
    private String room;
    private String status;
    private UUID subjectId;
    private String subjectName;
    private String subjectCode;
    private UUID teacherId;
    private String teacherName;
    private UUID studentId;
    private String studentName;
}
