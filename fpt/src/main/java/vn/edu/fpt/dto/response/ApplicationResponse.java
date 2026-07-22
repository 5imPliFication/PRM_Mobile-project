package vn.edu.fpt.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApplicationResponse {

    private UUID id;
    private String type;
    private String title;
    private String content;
    private String status;
    private String responseNote;
    private UUID studentId;
    private String studentName;
    private String className;
    private String respondedByName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
