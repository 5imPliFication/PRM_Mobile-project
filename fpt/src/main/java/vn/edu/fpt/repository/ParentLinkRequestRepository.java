package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.ParentLinkRequest;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ParentLinkRequestRepository extends JpaRepository<ParentLinkRequest, UUID> {
    List<ParentLinkRequest> findByStudentIdOrderByCreatedAtDesc(UUID studentId);
    List<ParentLinkRequest> findByParentAccountIdOrderByCreatedAtDesc(UUID parentAccountId);
    Optional<ParentLinkRequest> findByStudentIdAndParentAccountId(UUID studentId, UUID parentAccountId);
}