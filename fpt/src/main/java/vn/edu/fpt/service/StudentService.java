package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.edu.fpt.dto.response.StudentProfileResponse;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.repository.StudentRepository;

import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StudentService {

    private final StudentRepository studentRepository;

    public StudentProfileResponse getProfile(UUID accountId) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        return StudentProfileResponse.builder()
                .id(student.getId())
                .studentCode(student.getStudentCode())
                .fullName(student.getFullName())
                .className(student.getClassName())
                .academicYear(student.getAcademicYear())
                .campus(student.getCampus())
                .email(student.getEmail())
                .phone(student.getAccount() != null ? student.getAccount().getPhone() : null)
                .address(student.getAddress())
                .dateOfBirth(student.getDateOfBirth())
                .program(student.getProgram())
                .status(student.getStatus())
                .homeroomTeacher(student.getHomeroomTeacher())
                .parents(student.getParents() != null
                        ? student.getParents().stream()
                        .map(p -> StudentProfileResponse.ParentInfo.builder()
                                .fullName(p.getFullName())
                                .phone(p.getPhone())
                                .occupation(p.getOccupation())
                                .relationship(p.getRelationship())
                                .build())
                        .collect(Collectors.toList())
                        : null)
                .build();
    }
}
