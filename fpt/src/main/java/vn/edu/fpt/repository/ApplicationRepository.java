package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.edu.fpt.entity.Application;

import java.util.List;
import java.util.UUID;

public interface ApplicationRepository extends JpaRepository<Application, UUID> {

    List<Application> findByStudentIdOrderByCreatedAtDesc(UUID studentId);

    @Query("SELECT a FROM Application a WHERE a.student.schoolClass.name = :className ORDER BY a.createdAt DESC")
    List<Application> findByStudentClassNameOrderByCreatedAtDesc(@Param("className") String className);
}
