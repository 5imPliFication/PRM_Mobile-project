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
public class ParentLinkRequestResponse {
    private UUID id;
    private UUID studentId;
    private String studentName;
    private String studentCode;
    private String className;
    private String parentPhone;     // parent account's phone
    private String parentName;      // hint entered by student
    private String relationship;
    private String message;
    private String status;          // PENDING / ACCEPTED / REJECTED
    private LocalDateTime createdAt;
    private LocalDateTime respondedAt;
}