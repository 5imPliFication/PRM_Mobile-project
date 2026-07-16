-- Attendance: per session (schedule + date + student)
CREATE TABLE attendances (
    id UUID PRIMARY KEY,
    schedule_id UUID NOT NULL REFERENCES schedules(id),
    student_id UUID NOT NULL REFERENCES students(id),
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    note VARCHAR(255),
    marked_by UUID REFERENCES teachers(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (schedule_id, student_id, attendance_date)
);

-- Parent <-> Student: many-to-many (a parent may have multiple children)
CREATE TABLE parent_students (
    parent_id UUID NOT NULL REFERENCES parents(id),
    student_id UUID NOT NULL REFERENCES students(id),
    PRIMARY KEY (parent_id, student_id)
);

-- Parents gain an account so they can authenticate (PARENT role)
-- student_id becomes legacy/nullable; new code reads parent_students
ALTER TABLE parents ADD COLUMN account_id UUID REFERENCES accounts(id);
ALTER TABLE parents ALTER COLUMN student_id DROP NOT NULL;

-- Migrate existing single parent->student links into the join table
INSERT INTO parent_students (parent_id, student_id)
SELECT id, student_id FROM parents WHERE student_id IS NOT NULL;