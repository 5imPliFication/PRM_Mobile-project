-- Reused bcrypt hash for password "password123" (same as the existing student account)
-- Hash: $2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi

-- ===== Teacher accounts (TEACHER role), linked to existing teachers =====
-- teachers ids: 33333333-3333-3333-3333-333333333330 .. 38
-- Primary teacher login for testing: 0900000001 / password123 (Thầy Nguyễn Văn B, Toán)
INSERT INTO accounts (id, phone, password, role, is_active, created_at) VALUES
('11111111-1111-1111-1111-111111111120', '0900000001', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW()),
('11111111-1111-1111-1111-111111111121', '0900000002', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW()),
('11111111-1111-1111-1111-111111111122', '0900000003', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW()),
('11111111-1111-1111-1111-111111111123', '0900000004', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW()),
('11111111-1111-1111-1111-111111111124', '0900000005', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW()),
('11111111-1111-1111-1111-111111111125', '0900000006', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW()),
('11111111-1111-1111-1111-111111111126', '0900000007', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW()),
('11111111-1111-1111-1111-111111111127', '0900000008', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW()),
('11111111-1111-1111-1111-111111111128', '0900000009', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'TEACHER', true, NOW());

UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111120' WHERE id = '33333333-3333-3333-3333-333333333330';
UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111121' WHERE id = '33333333-3333-3333-3333-333333333331';
UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111122' WHERE id = '33333333-3333-3333-3333-333333333332';
UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111123' WHERE id = '33333333-3333-3333-3333-333333333333';
UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111124' WHERE id = '33333333-3333-3333-3333-333333333334';
UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111125' WHERE id = '33333333-3333-3333-3333-333333333335';
UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111126' WHERE id = '33333333-3333-3333-3333-333333333336';
UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111127' WHERE id = '33333333-3333-3333-3333-333333333337';
UPDATE teachers SET account_id = '11111111-1111-1111-1111-111111111128' WHERE id = '33333333-3333-3333-3333-333333333338';

-- ===== Parent account (PARENT role), linked to the existing parent =====
-- Login for testing: 0912987654 / password123
INSERT INTO accounts (id, phone, password, role, is_active, created_at)
VALUES ('11111111-1111-1111-1111-111111111130', '0912987654', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'PARENT', true, NOW());

UPDATE parents SET account_id = '11111111-1111-1111-1111-111111111130' WHERE phone = '0912987654';

-- ===== More students in 11A1 (so a teacher has a class to manage) =====
INSERT INTO accounts (id, phone, password, role, is_active, created_at) VALUES
('11111111-1111-1111-1111-111111111112', '0912345679', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'STUDENT', true, NOW()),
('11111111-1111-1111-1111-111111111113', '0912345680', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'STUDENT', true, NOW()),
('11111111-1111-1111-1111-111111111114', '0912345681', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'STUDENT', true, NOW());

INSERT INTO students (id, student_code, full_name, class_name, academic_year, campus, email, address, date_of_birth, program, status, homeroom_teacher, account_id, created_at) VALUES
('22222222-2222-2222-2222-222222222223', 'FPT08922', 'Trần Thị B', '11A1', '2023 - 2026', 'FPT School Cần Thơ', 'btb.se191102@fpt.edu.vn', '45 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ', '2008-11-20', 'Phổ thông chất lượng cao', 'Đang học', 'Cô Trần Thị C', '11111111-1111-1111-1111-111111111112', NOW()),
('22222222-2222-2222-2222-222222222224', 'FPT08923', 'Lê Văn C', '11A1', '2023 - 2026', 'FPT School Cần Thơ', 'vlc.se191103@fpt.edu.vn', '12 Trần Hưng Đạo, Ninh Kiều, Cần Thơ', '2008-03-05', 'Phổ thông chất lượng cao', 'Đang học', 'Cô Trần Thị C', '11111111-1111-1111-1111-111111111113', NOW()),
('22222222-2222-2222-2222-222222222225', 'FPT08924', 'Phạm Thị D', '11A1', '2023 - 2026', 'FPT School Cần Thơ', 'dtp.se191104@fpt.edu.vn', '78 3/2, Ninh Kiều, Cần Thơ', '2008-06-18', 'Phổ thông chất lượng cao', 'Đang học', 'Cô Trần Thị C', '11111111-1111-1111-1111-111111111114', NOW());

-- Parent B also has Trần Thị B as a second child (multi-child demo)
INSERT INTO parent_students (parent_id, student_id)
SELECT p.id, '22222222-2222-2222-2222-222222222223' FROM parents p WHERE p.phone = '0912987654';

-- ===== Wednesday Toán session for the math teacher, one schedule row per student =====
-- Used as the attendance sheet for the class. day_of_week=4 (Wednesday), period 1.
INSERT INTO schedules (id, day_of_week, start_time, end_time, room, status, subject_id, teacher_id, student_id) VALUES
('66666666-6666-6666-6666-666666666610', 4, '07:30', '08:15', 'Phòng A201', 'Sắp học', '44444444-4444-4444-4444-444444444440', '33333333-3333-3333-3333-333333333330', '22222222-2222-2222-2222-222222222222'),
('66666666-6666-6666-6666-666666666611', 4, '07:30', '08:15', 'Phòng A201', 'Sắp học', '44444444-4444-4444-4444-444444444440', '33333333-3333-3333-3333-333333333330', '22222222-2222-2222-2222-222222222223'),
('66666666-6666-6666-6666-666666666612', 4, '07:30', '08:15', 'Phòng A201', 'Sắp học', '44444444-4444-4444-4444-444444444440', '33333333-3333-3333-3333-333333333330', '22222222-2222-2222-2222-222222222224'),
('66666666-6666-6666-6666-666666666613', 4, '07:30', '08:15', 'Phòng A201', 'Sắp học', '44444444-4444-4444-4444-444444444440', '33333333-3333-3333-3333-333333333330', '22222222-2222-2222-2222-222222222225');

-- Attendance for that Wednesday Toán session on the day the migration runs (demo "today")
INSERT INTO attendances (id, schedule_id, student_id, attendance_date, status, note, marked_by, created_at) VALUES
(uuid_generate_v4(), '66666666-6666-6666-6666-666666666610', '22222222-2222-2222-2222-222222222222', CURRENT_DATE, 'PRESENT', NULL, '33333333-3333-3333-3333-333333333330', NOW()),
(uuid_generate_v4(), '66666666-6666-6666-6666-666666666611', '22222222-2222-2222-2222-222222222223', CURRENT_DATE, 'PRESENT', NULL, '33333333-3333-3333-3333-333333333330', NOW()),
(uuid_generate_v4(), '66666666-6666-6666-6666-666666666612', '22222222-2222-2222-2222-222222222224', CURRENT_DATE, 'ABSENT', 'Nghỉ không phép', '33333333-3333-3333-3333-333333333330', NOW()),
(uuid_generate_v4(), '66666666-6666-6666-6666-666666666613', '22222222-2222-2222-2222-222222222225', CURRENT_DATE, 'LATE', 'Đi trễ 10 phút', '33333333-3333-3333-3333-333333333330', NOW());

-- ===== Submissions to grade for the math teacher's assignment (Đại số - 5555...52) =====
INSERT INTO submissions (id, file_url, grade, submitted_at, assignment_id, student_id) VALUES
(uuid_generate_v4(), 'http://example.com/b_khaosat_ham.pdf', NULL, NOW() - INTERVAL '1 DAY', '55555555-5555-5555-5555-555555555552', '22222222-2222-2222-2222-222222222223'),
(uuid_generate_v4(), 'http://example.com/c_khaosat_ham.pdf', NULL, NOW() - INTERVAL '6 HOURS', '55555555-5555-5555-5555-555555555552', '22222222-2222-2222-2222-222222222224');

-- ===== A couple notifications for the new students =====
INSERT INTO notifications (id, title, body, category, is_read, created_at, student_id) VALUES
(uuid_generate_v4(), 'Nhắc nộp bài Đại số', 'Học sinh vui lòng nộp bài tập Khảo sát hàm số lượng giác trước hạn chót.', 'Học tập', false, NOW() - INTERVAL '1 DAY', '22222222-2222-2222-2222-222222222223'),
(uuid_generate_v4(), 'Lịch học Toán thứ 4', 'Nhắc nhở: tiết Toán sáng thứ 4 tại phòng A201.', 'Học tập', false, NOW() - INTERVAL '2 DAYS', '22222222-2222-2222-2222-222222222224');