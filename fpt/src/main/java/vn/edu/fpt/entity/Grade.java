package vn.edu.fpt.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "grades")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Grade {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String semester; // "HK1", "HK2"

    @Column(name = "oral_score")
    private Double oralScore;

    @Column(name = "fifteen_min_score")
    private Double fifteenMinScore;

    @Column(name = "one_period_score")
    private Double onePeriodScore;

    @Column(name = "semester_score")
    private Double semesterScore;

    @Column
    private Double average;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;
}
