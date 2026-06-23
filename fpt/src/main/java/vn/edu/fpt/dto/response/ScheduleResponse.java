package vn.edu.fpt.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScheduleResponse {

    private UUID id;
    private String subject;
    private String startTime;
    private String endTime;
    private String time; // formatted "HH:mm - HH:mm"
    private String room;
    private String teacher;
    private Integer dayOfWeek;
    private String status;
}
