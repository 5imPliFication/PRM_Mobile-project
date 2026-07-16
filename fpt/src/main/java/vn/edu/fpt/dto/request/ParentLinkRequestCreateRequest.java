package vn.edu.fpt.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ParentLinkRequestCreateRequest {
    @NotBlank
    private String parentPhone;
    private String parentName;
    private String relationship;
    private String message;
}