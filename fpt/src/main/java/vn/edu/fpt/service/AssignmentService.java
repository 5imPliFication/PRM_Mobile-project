package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.edu.fpt.dto.request.SubmissionRequest;
import vn.edu.fpt.dto.response.AssignmentResponse;
import vn.edu.fpt.entity.Assignment;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.entity.Submission;
import vn.edu.fpt.repository.AssignmentRepository;
import vn.edu.fpt.repository.StudentRepository;
import vn.edu.fpt.repository.SubmissionRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AssignmentService {

    private final AssignmentRepository assignmentRepository;
    private final SubmissionRepository submissionRepository;
    private final StudentRepository studentRepository;

    public List<AssignmentResponse> getAssignments(UUID accountId, String status) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        List<Assignment> assignments = assignmentRepository
                .findByTargetClassOrderByDueDateDesc(student.getClassName());

        return assignments.stream()
                .map(a -> toResponse(a, student.getId()))
                .filter(r -> status == null || r.getStatus().equalsIgnoreCase(status))
                .collect(Collectors.toList());
    }

    public AssignmentResponse submitAssignment(UUID accountId, UUID assignmentId, SubmissionRequest request) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        Assignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bài tập"));

        if (submissionRepository.existsByAssignmentIdAndStudentId(assignmentId, student.getId())) {
            throw new RuntimeException("Bạn đã nộp bài tập này rồi");
        }

        Submission submission = Submission.builder()
                .assignment(assignment)
                .student(student)
                .fileUrl(request.getFileUrl())
                .build();

        submissionRepository.save(submission);

        return toResponse(assignment, student.getId());
    }

    private AssignmentResponse toResponse(Assignment assignment, UUID studentId) {
        Optional<Submission> submission = submissionRepository
                .findByAssignmentIdAndStudentId(assignment.getId(), studentId);

        String assignmentStatus;
        Double grade = null;
        LocalDateTime submittedAt = null;

        if (submission.isPresent()) {
            assignmentStatus = "SUBMITTED";
            grade = submission.get().getGrade();
            submittedAt = submission.get().getSubmittedAt();
        } else if (assignment.getDueDate().isBefore(LocalDateTime.now())) {
            assignmentStatus = "OVERDUE";
        } else {
            assignmentStatus = "TODO";
        }

        return AssignmentResponse.builder()
                .id(assignment.getId())
                .title(assignment.getTitle())
                .subject(assignment.getSubject().getName())
                .description(assignment.getDescription())
                .dueDate(assignment.getDueDate())
                .status(assignmentStatus)
                .grade(grade)
                .submittedAt(submittedAt)
                .build();
    }
}
