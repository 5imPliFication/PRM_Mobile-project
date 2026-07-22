package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.dto.request.ApplicationRequest;
import vn.edu.fpt.dto.request.ApplicationRespondRequest;
import vn.edu.fpt.dto.response.ApplicationResponse;
import vn.edu.fpt.entity.Application;
import vn.edu.fpt.entity.SchoolClass;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.entity.Teacher;
import vn.edu.fpt.repository.ApplicationRepository;
import vn.edu.fpt.repository.SchoolClassRepository;
import vn.edu.fpt.repository.StudentRepository;
import vn.edu.fpt.repository.TeacherRepository;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ApplicationService {

    private final ApplicationRepository applicationRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final SchoolClassRepository schoolClassRepository;

    /** Student: submit a new application. */
    @Transactional
    public ApplicationResponse submit(UUID accountId, ApplicationRequest req) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        Application app = Application.builder()
                .type(req.getType().toUpperCase())
                .title(req.getTitle())
                .content(req.getContent())
                .status("PENDING")
                .student(student)
                .build();
        applicationRepository.save(app);
        return toResponse(app);
    }

    /** Student: get my applications. */
    public List<ApplicationResponse> getMyApplications(UUID accountId) {
        Student student = studentRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));
        return applicationRepository.findByStudentIdOrderByCreatedAtDesc(student.getId())
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    /** Teacher (homeroom): get applications from students in the homeroom class. */
    public List<ApplicationResponse> getClassApplications(UUID accountId) {
        Teacher teacher = teacherRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin giáo viên"));
        String homeroomClass = schoolClassRepository.findByHomeroomTeacherId(teacher.getId())
                .map(SchoolClass::getName)
                .orElse(null);
        if (homeroomClass == null || homeroomClass.isBlank()) {
            throw new RuntimeException("Bạn không phải là giáo viên chủ nhiệm");
        }
        return applicationRepository.findByStudentClassNameOrderByCreatedAtDesc(homeroomClass)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    /** Teacher (homeroom): approve or reject an application. */
    @Transactional
    public ApplicationResponse respond(UUID accountId, UUID applicationId, ApplicationRespondRequest req) {
        Teacher teacher = teacherRepository.findByAccountId(accountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin giáo viên"));
        String homeroomClass = schoolClassRepository.findByHomeroomTeacherId(teacher.getId())
                .map(SchoolClass::getName)
                .orElse(null);
        if (homeroomClass == null || homeroomClass.isBlank()) {
            throw new RuntimeException("Bạn không phải là giáo viên chủ nhiệm");
        }

        Application app = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn"));
        if (app.getStudent().getClassName() == null || !app.getStudent().getClassName().equals(homeroomClass)) {
            throw new RuntimeException("Bạn không có quyền xử lý đơn này");
        }
        if (!"PENDING".equals(app.getStatus())) {
            throw new RuntimeException("Đơn đã được xử lý");
        }

        String status = req.getStatus().toUpperCase();
        if (!"APPROVED".equals(status) && !"REJECTED".equals(status)) {
            throw new RuntimeException("Trạng thái không hợp lệ");
        }

        app.setStatus(status);
        app.setResponseNote(req.getResponseNote());
        app.setRespondedBy(teacher);
        applicationRepository.save(app);
        return toResponse(app);
    }

    private ApplicationResponse toResponse(Application app) {
        return ApplicationResponse.builder()
                .id(app.getId())
                .type(app.getType())
                .title(app.getTitle())
                .content(app.getContent())
                .status(app.getStatus())
                .responseNote(app.getResponseNote())
                .studentId(app.getStudent().getId())
                .studentName(app.getStudent().getFullName())
                .className(app.getStudent().getClassName())
                .respondedByName(app.getRespondedBy() != null ? app.getRespondedBy().getFullName() : null)
                .createdAt(app.getCreatedAt())
                .updatedAt(app.getUpdatedAt())
                .build();
    }
}
