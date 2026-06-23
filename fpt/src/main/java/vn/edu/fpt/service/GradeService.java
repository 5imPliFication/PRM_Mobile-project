package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.edu.fpt.dto.response.GradeResponse;
import vn.edu.fpt.entity.Grade;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.repository.GradeRepository;
import vn.edu.fpt.repository.StudentRepository;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GradeService {

    private final GradeRepository gradeRepository;
    private final StudentRepository studentRepository;

    public List<GradeResponse> getGrades(UUID accountId, String semester) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        List<Grade> grades;
        if (semester != null && !semester.isEmpty()) {
            grades = gradeRepository.findByStudentIdAndSemester(student.getId(), semester);
        } else {
            grades = gradeRepository.findByStudentId(student.getId());
        }

        return grades.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private GradeResponse toResponse(Grade grade) {
        return GradeResponse.builder()
                .id(grade.getId())
                .subject(grade.getSubject().getName())
                .semester(grade.getSemester())
                .oralScore(grade.getOralScore())
                .fifteenMinScore(grade.getFifteenMinScore())
                .onePeriodScore(grade.getOnePeriodScore())
                .semesterScore(grade.getSemesterScore())
                .average(grade.getAverage())
                .build();
    }
}
