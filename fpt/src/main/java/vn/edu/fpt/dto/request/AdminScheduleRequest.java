package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.UUID;

@Data
public class AdminScheduleRequest {
    @NotNull(message = "Thứ không được để trống")
    private Integer dayOfWeek;
    @NotBlank(message = "Giờ bắt đầu không được để trống")
    private String startTime; // format HH:mm
    @NotBlank(message = "Giờ kết thúc không được để trống")
    private String endTime; // format HH:mm
    @NotBlank(message = "Phòng học không được để trống")
    private String room;
    private String status;
    @NotNull(message = "Môn học không được để trống")
    private UUID subjectId;
    @NotNull(message = "Giáo viên không được để trống")
    private UUID teacherId;
    @NotNull(message = "Lớp học không được để trống")
    private UUID classId;
}
