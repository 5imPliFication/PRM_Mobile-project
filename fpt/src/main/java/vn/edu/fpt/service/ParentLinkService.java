package vn.edu.fpt.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.dto.request.ParentLinkRequestCreateRequest;
import vn.edu.fpt.dto.response.ParentLinkRequestResponse;
import vn.edu.fpt.entity.Account;
import vn.edu.fpt.entity.Parent;
import vn.edu.fpt.entity.ParentLinkRequest;
import vn.edu.fpt.entity.Student;
import vn.edu.fpt.repository.AccountRepository;
import vn.edu.fpt.repository.ParentLinkRequestRepository;
import vn.edu.fpt.repository.ParentRepository;
import vn.edu.fpt.repository.StudentRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParentLinkService {

    private final ParentLinkRequestRepository linkRequestRepository;
    private final StudentRepository studentRepository;
    private final AccountRepository accountRepository;
    private final ParentRepository parentRepository;

    // ---------------- Student side ----------------

    @Transactional
    public ParentLinkRequestResponse createRequest(UUID studentAccountId, ParentLinkRequestCreateRequest req) {
        Student student = studentRepository.findByAccountId(studentAccountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));

        Account parentAccount = accountRepository.findByPhone(req.getParentPhone())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản phụ huynh với số điện thoại này"));

        if (parentAccount.getRole() != Account.Role.PARENT) {
            throw new RuntimeException("Số điện thoại không thuộc tài khoản phụ huynh");
        }

        // Already linked? nothing to do.
        Parent existing = parentRepository.findByAccountId(parentAccount.getId()).orElse(null);
        if (existing != null && parentRepository.isParentOf(existing.getId(), student.getId())) {
            throw new RuntimeException("Phụ huynh đã được liên kết với bạn");
        }

        // Reopen or update an existing request row (unique pair) instead of failing.
        ParentLinkRequest row = linkRequestRepository
                .findByStudentIdAndParentAccountId(student.getId(), parentAccount.getId())
                .orElseGet(() -> ParentLinkRequest.builder()
                        .student(student)
                        .parentAccount(parentAccount)
                        .build());

        if ("ACCEPTED".equals(row.getStatus())) {
            throw new RuntimeException("Phụ huynh đã chấp nhận lời mời");
        }

        row.setParentName(req.getParentName());
        row.setRelationship(req.getRelationship());
        row.setMessage(req.getMessage());
        row.setStatus("PENDING");
        row.setRespondedAt(null);
        linkRequestRepository.save(row);

        return toResponse(row, student);
    }

    public List<ParentLinkRequestResponse> getMyRequests(UUID studentAccountId) {
        Student student = studentRepository.findByAccountId(studentAccountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));
        return linkRequestRepository.findByStudentIdOrderByCreatedAtDesc(student.getId()).stream()
                .map(r -> toResponse(r, student))
                .collect(Collectors.toList());
    }

    @Transactional
    public void cancelRequest(UUID studentAccountId, UUID requestId) {
        Student student = studentRepository.findByAccountId(studentAccountId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin học sinh"));
        ParentLinkRequest row = linkRequestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lời mời"));
        if (!row.getStudent().getId().equals(student.getId())) {
            throw new RuntimeException("Bạn không có quyền xóa lời mời này");
        }
        linkRequestRepository.delete(row);
    }

    // ---------------- Parent side ----------------

    public List<ParentLinkRequestResponse> getIncomingRequests(UUID parentAccountId) {
        return linkRequestRepository.findByParentAccountIdOrderByCreatedAtDesc(parentAccountId).stream()
                .map(r -> toResponse(r, r.getStudent()))
                .collect(Collectors.toList());
    }

    @Transactional
    public ParentLinkRequestResponse acceptRequest(UUID parentAccountId, UUID requestId) {
        ParentLinkRequest row = linkRequestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lời mời"));
        if (!row.getParentAccount().getId().equals(parentAccountId)) {
            throw new RuntimeException("Lời mời không thuộc về bạn");
        }
        if ("ACCEPTED".equals(row.getStatus())) {
            throw new RuntimeException("Đã chấp nhận rồi");
        }

        // Find or create the Parent profile for this account.
        Parent parent = parentRepository.findByAccountId(parentAccountId).orElse(null);
        if (parent == null) {
            Account acc = row.getParentAccount();
            Parent fresh = Parent.builder()
                    .fullName(row.getParentName() != null && !row.getParentName().isBlank()
                            ? row.getParentName() : acc.getPhone())
                    .phone(acc.getPhone())
                    .relationship(row.getRelationship())
                    .account(acc)
                    .build();
            parentRepository.save(fresh);
            parentRepository.flush();
            // re-fetch so the ManyToMany collection is a managed PersistentBag
            parent = parentRepository.findByAccountId(parentAccountId)
                    .orElseThrow(() -> new RuntimeException("Không thể tạo phụ huynh"));
        }

        // Add student to parent.students if not already linked.
        Student student = row.getStudent();
        List<Student> students = parent.getStudents();
        if (students == null) students = new java.util.ArrayList<>();
        boolean alreadyLinked = students.stream()
                .anyMatch(s -> s != null && s.getId() != null && s.getId().equals(student.getId()));
        if (!alreadyLinked) {
            students.add(student);
            parent.setStudents(students);
            parentRepository.save(parent);
        }

        row.setStatus("ACCEPTED");
        row.setRespondedAt(LocalDateTime.now());
        linkRequestRepository.save(row);
        return toResponse(row, student);
    }

    @Transactional
    public ParentLinkRequestResponse rejectRequest(UUID parentAccountId, UUID requestId) {
        ParentLinkRequest row = linkRequestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lời mời"));
        if (!row.getParentAccount().getId().equals(parentAccountId)) {
            throw new RuntimeException("Lời mời không thuộc về bạn");
        }
        row.setStatus("REJECTED");
        row.setRespondedAt(LocalDateTime.now());
        linkRequestRepository.save(row);
        return toResponse(row, row.getStudent());
    }

    // ---------------- mapping ----------------

    private ParentLinkRequestResponse toResponse(ParentLinkRequest r, Student student) {
        String phone = r.getParentAccount() != null ? r.getParentAccount().getPhone() : null;
        return ParentLinkRequestResponse.builder()
                .id(r.getId())
                .studentId(student != null ? student.getId() : null)
                .studentName(student != null ? student.getFullName() : null)
                .studentCode(student != null ? student.getStudentCode() : null)
                .className(student != null ? student.getClassName() : null)
                .parentPhone(phone)
                .parentName(r.getParentName())
                .relationship(r.getRelationship())
                .message(r.getMessage())
                .status(r.getStatus())
                .createdAt(r.getCreatedAt())
                .respondedAt(r.getRespondedAt())
                .build();
    }
}