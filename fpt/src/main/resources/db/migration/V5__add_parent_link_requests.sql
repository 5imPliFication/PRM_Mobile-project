-- Pending link requests from a student to a parent account.
-- A student enters the parent's phone; we look up the PARENT account by phone,
-- create a PENDING row, and the parent accepts/rejects from their app.
CREATE TABLE parent_link_requests (
    id UUID PRIMARY KEY,
    student_id UUID NOT NULL REFERENCES students(id),
    parent_account_id UUID NOT NULL REFERENCES accounts(id),
    parent_name VARCHAR(255),       -- hint entered by the student
    relationship VARCHAR(255),      -- e.g. "Cha", "Mẹ"
    message VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',  -- PENDING / ACCEPTED / REJECTED
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    responded_at TIMESTAMP,
    UNIQUE (student_id, parent_account_id)  -- at most one request per (student, parent) pair
);