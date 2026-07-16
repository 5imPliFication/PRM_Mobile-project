package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Parent;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ParentRepository extends JpaRepository<Parent, UUID> {
    @Query("SELECT p FROM Parent p JOIN p.students s WHERE s.id = :studentId")
    List<Parent> findByStudentId(@Param("studentId") UUID studentId);

    Optional<Parent> findByAccountId(UUID accountId);

    @Query("SELECT CASE WHEN COUNT(p) > 0 THEN TRUE ELSE FALSE END " +
            "FROM Parent p JOIN p.students s WHERE p.id = :parentId AND s.id = :studentId")
    boolean isParentOf(@Param("parentId") UUID parentId, @Param("studentId") UUID studentId);
}