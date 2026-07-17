package vn.edu.fpt.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AdminDashboardStatsResponse {
    private long totalAccounts;
    private long totalStudents;
    private long totalTeachers;
    private long totalParents;
    private long totalSchedules;
}
