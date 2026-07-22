package vn.edu.fpt.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class AdminNotificationResponse {
    private UUID id;
    private String title;
    private String content;
    private String category;
    private String targetGroup;
    private LocalDateTime createdAt;
    private Integer recipientCount;
}
