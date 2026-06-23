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
public class GradeResponse {

    private UUID id;
    private String subject;
    private String semester;
    private Double oralScore;
    private Double fifteenMinScore;
    private Double onePeriodScore;
    private Double semesterScore;
    private Double average;
}
