-- Insert Account for Student (Password is 'password123' hashed with bcrypt)
INSERT INTO accounts (id, phone, password, role, is_active, created_at)
VALUES ('11111111-1111-1111-1111-111111111111', '0912345678', '$2a$12$ZvfhG/4WM5nIkqgG57GbDeBaZOTSpg5Uc7MybbBoo8GPvIeL1Kdgi', 'STUDENT', true, NOW());

-- Insert Student
INSERT INTO students (id, student_code, full_name, class_name, academic_year, campus, email, address, date_of_birth, program, status, homeroom_teacher, account_id, created_at)
VALUES ('22222222-2222-2222-2222-222222222222', 'FPT08921', 'Nguyễn Văn A', '11A1', '2023 - 2026', 'FPT School Cần Thơ', 'anv.se191101@fpt.edu.vn', '123 Đường 3/2, Ninh Kiều, Cần Thơ', '2008-08-15', 'Phổ thông chất lượng cao', 'Đang học', 'Cô Trần Thị C', '11111111-1111-1111-1111-111111111111', NOW());

-- Insert Parent
INSERT INTO parents (id, full_name, phone, occupation, relationship, student_id)
VALUES (uuid_generate_v4(), 'Nguyễn Văn B', '0912987654', 'Kỹ sư', 'Cha', '22222222-2222-2222-2222-222222222222');

-- Insert Teachers
INSERT INTO teachers (id, full_name, specialization) VALUES
('33333333-3333-3333-3333-333333333330', 'Thầy Nguyễn Văn B', 'Toán học'),
('33333333-3333-3333-3333-333333333331', 'Cô Trần Thị C', 'Vật lý'),
('33333333-3333-3333-3333-333333333332', 'Cô Lê Thị D', 'Tiếng Anh'),
('33333333-3333-3333-3333-333333333333', 'Thầy Hiệu Trưởng', 'Khác'),
('33333333-3333-3333-3333-333333333334', 'Cô Nguyễn Thị E', 'Hóa học'),
('33333333-3333-3333-3333-333333333335', 'Cô Phạm Thị F', 'Ngữ văn'),
('33333333-3333-3333-3333-333333333336', 'Thầy Lê Văn G', 'Sinh học'),
('33333333-3333-3333-3333-333333333337', 'Cô Hoàng Thị H', 'Lịch sử'),
('33333333-3333-3333-3333-333333333338', 'Thầy Đỗ Văn I', 'Tin học');

-- Insert Subjects
INSERT INTO subjects (id, name, code) VALUES
('44444444-4444-4444-4444-444444444440', 'Toán học', 'MATH11'),
('44444444-4444-4444-4444-444444444441', 'Vật lý', 'PHYS11'),
('44444444-4444-4444-4444-444444444442', 'Tiếng Anh', 'ENG11'),
('44444444-4444-4444-4444-444444444443', 'Hóa học', 'CHEM11'),
('44444444-4444-4444-4444-444444444444', 'Ngữ văn', 'LIT11'),
('44444444-4444-4444-4444-444444444445', 'Sinh học', 'BIO11'),
('44444444-4444-4444-4444-444444444446', 'Lịch sử', 'HIST11'),
('44444444-4444-4444-4444-444444444447', 'Tin học', 'IT11'),
('44444444-4444-4444-4444-444444444448', 'Chào cờ', 'CC');

-- Insert Schedules
-- Monday (2)
INSERT INTO schedules (id, day_of_week, start_time, end_time, room, status, subject_id, teacher_id, student_id) VALUES
(uuid_generate_v4(), 2, '07:30', '08:15', 'Phòng A201', 'Đã học', '44444444-4444-4444-4444-444444444440', '33333333-3333-3333-3333-333333333330', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 2, '08:25', '09:10', 'Phòng B102', 'Đã học', '44444444-4444-4444-4444-444444444441', '33333333-3333-3333-3333-333333333331', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 2, '09:20', '10:05', 'Phòng C305', 'Đã học', '44444444-4444-4444-4444-444444444442', '33333333-3333-3333-3333-333333333332', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 2, '10:15', '11:00', 'Sân trường', 'Đã học', '44444444-4444-4444-4444-444444444448', '33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222');

-- Tuesday (3)
INSERT INTO schedules (id, day_of_week, start_time, end_time, room, status, subject_id, teacher_id, student_id) VALUES
(uuid_generate_v4(), 3, '07:30', '08:15', 'Phòng Hóa', 'Sắp học', '44444444-4444-4444-4444-444444444443', '33333333-3333-3333-3333-333333333334', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 3, '08:25', '09:10', 'Phòng A201', 'Sắp học', '44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333335', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 3, '09:20', '10:05', 'Phòng Sinh', 'Sắp học', '44444444-4444-4444-4444-444444444445', '33333333-3333-3333-3333-333333333336', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 3, '10:15', '11:00', 'Phòng A201', 'Sắp học', '44444444-4444-4444-4444-444444444446', '33333333-3333-3333-3333-333333333337', '22222222-2222-2222-2222-222222222222');

-- Assignments
INSERT INTO assignments (id, title, description, due_date, target_class, created_at, subject_id, teacher_id) VALUES
('55555555-5555-5555-5555-555555555550', 'Bài tập 3: Cảm ứng điện từ', 'Làm các bài tập 1, 2, 3 trang 45 SGK Vật lý nâng cao. Chụp ảnh bài làm hoặc xuất file PDF để nộp.', NOW() + INTERVAL '2 DAYS', '11A1', NOW(), '44444444-4444-4444-4444-444444444441', '33333333-3333-3333-3333-333333333331'),
('55555555-5555-5555-5555-555555555551', 'Essay: School of the Future', 'Viết bài luận khoảng 250 từ nói về viễn cảnh trường học tương lai với sự hỗ trợ của AI công nghệ.', NOW() + INTERVAL '5 DAYS', '11A1', NOW(), '44444444-4444-4444-4444-444444444442', '33333333-3333-3333-3333-333333333332'),
('55555555-5555-5555-5555-555555555552', 'Đại số: Khảo sát hàm số lượng giác', 'Giải bài tập phần Ôn tập chương 1 Đại số và Giải tích lớp 11.', NOW() + INTERVAL '7 DAYS', '11A1', NOW(), '44444444-4444-4444-4444-444444444440', '33333333-3333-3333-3333-333333333330'),
('55555555-5555-5555-5555-555555555553', 'Bài thực hành số 2: Lập trình C++', 'Viết chương trình sắp xếp mảng và tìm kiếm nhị phân bằng C++.', NOW() - INTERVAL '2 DAYS', '11A1', NOW() - INTERVAL '5 DAYS', '44444444-4444-4444-4444-444444444447', '33333333-3333-3333-3333-333333333338'),
('55555555-5555-5555-5555-555555555554', 'Soạn văn bài: Chí Phèo', 'Trả lời các câu hỏi phần Soạn bài tác phẩm Chí Phèo của nhà văn Nam Cao.', NOW() - INTERVAL '5 DAYS', '11A1', NOW() - INTERVAL '10 DAYS', '44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333335'),
('55555555-5555-5555-5555-555555555555', 'Vẽ sơ đồ tư duy: Lịch sử nhà Nguyễn', 'Vẽ sơ đồ tư duy hệ thống hóa các sự kiện nổi bật của thời kỳ nhà Nguyễn.', NOW() - INTERVAL '8 DAYS', '11A1', NOW() - INTERVAL '15 DAYS', '44444444-4444-4444-4444-444444444446', '33333333-3333-3333-3333-333333333337');

-- Submissions
INSERT INTO submissions (id, file_url, grade, submitted_at, assignment_id, student_id) VALUES
(uuid_generate_v4(), 'http://example.com/bai_tap_cpp.pdf', 9.5, NOW() - INTERVAL '3 DAYS', '55555555-5555-5555-5555-555555555553', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'http://example.com/soan_van.pdf', 8.0, NOW() - INTERVAL '6 DAYS', '55555555-5555-5555-5555-555555555554', '22222222-2222-2222-2222-222222222222');

-- Grades
INSERT INTO grades (id, semester, oral_score, fifteen_min_score, one_period_score, semester_score, average, subject_id, student_id) VALUES
(uuid_generate_v4(), 'Học kỳ 1', 8.5, 9.0, 8.0, 8.5, 8.3, '44444444-4444-4444-4444-444444444440', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 1', 8.0, 7.5, 9.0, 8.5, 8.3, '44444444-4444-4444-4444-444444444441', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 1', 9.0, 9.5, 8.5, 9.0, 9.1, '44444444-4444-4444-4444-444444444443', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 1', 7.5, 8.0, 8.0, 8.5, 8.1, '44444444-4444-4444-4444-444444444445', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 1', 8.0, 8.0, 7.5, 8.0, 7.9, '44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 1', 9.0, 8.5, 9.0, 9.5, 9.1, '44444444-4444-4444-4444-444444444442', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 1', 9.5, 10.0, 9.5, 9.5, 9.6, '44444444-4444-4444-4444-444444444447', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 1', 8.0, 7.0, 8.0, 8.5, 7.9, '44444444-4444-4444-4444-444444444446', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 2', 9.0, 8.5, 9.0, 9.5, 9.1, '44444444-4444-4444-4444-444444444440', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Học kỳ 2', 8.5, 9.0, 8.5, 8.0, 8.4, '44444444-4444-4444-4444-444444444441', '22222222-2222-2222-2222-222222222222');

-- Notifications
INSERT INTO notifications (id, title, body, category, is_read, created_at, student_id) VALUES
(uuid_generate_v4(), 'Thay đổi lịch học môn Vật lý lớp 11A1', 'Lịch học môn Vật lý thứ 3 ngày 24/06 được dời từ tiết 2 sang tiết 4 do giáo viên bận công tác đột xuất.', 'Học tập', false, NOW(), '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Thông báo thu học phí kỳ Summer 2026', 'Thời hạn nộp học phí cho học kỳ mới đến hết ngày 30/06/2026. Quý phụ huynh vui lòng kiểm tra và đóng đúng hạn.', 'Học phí', false, NOW() - INTERVAL '2 HOURS', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Đăng ký tham gia Lễ hội mùa hè FPT School', 'Học sinh có nhu cầu đăng ký văn nghệ, hoạt động gian hàng hoặc tham gia ban tổ chức vui lòng gửi đơn đăng ký trước ngày 26/06.', 'Hoạt động', true, NOW() - INTERVAL '1 DAY', '22222222-2222-2222-2222-222222222222'),
(uuid_generate_v4(), 'Công bố điểm kiểm tra 1 tiết môn Hóa học', 'Điểm số bài kiểm tra chương 3 môn Hóa học đã được cập nhật. Học sinh truy cập Bảng điểm để xem chi tiết.', 'Học tập', true, NOW() - INTERVAL '2 DAYS', '22222222-2222-2222-2222-222222222222');
