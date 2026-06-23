package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Student;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface StudentRepository extends JpaRepository<Student, UUID> {
    Optional<Student> findByAccountId(UUID accountId);
    Optional<Student> findByStudentCode(String studentCode);
    Optional<Student> findByAccountPhone(String phone);
}
