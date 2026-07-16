package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Student;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface StudentRepository extends JpaRepository<Student, UUID> {
    Optional<Student> findByAccountId(UUID accountId);
    Optional<Student> findByStudentCode(String studentCode);
    Optional<Student> findByAccountPhone(String phone);

    List<Student> findByClassName(String className);

    @Query("SELECT DISTINCT s FROM Student s WHERE s.className = :className AND EXISTS " +
            "(SELECT sc FROM Schedule sc WHERE sc.student.id = s.id AND sc.teacher.id = :teacherId)")
    List<Student> findStudentsOfTeacherInClass(@Param("teacherId") UUID teacherId,
                                                @Param("className") String className);
}