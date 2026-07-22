CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE accounts (
    id UUID PRIMARY KEY,
    phone VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE teachers (
    id UUID PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    specialization VARCHAR(255),
    account_id UUID REFERENCES accounts(id)
);

CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    grade_level INTEGER,
    academic_year VARCHAR(255),
    campus VARCHAR(255),
    homeroom_teacher_id UUID REFERENCES teachers(id)
);

CREATE TABLE students (
    id UUID PRIMARY KEY,
    student_code VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    class_id UUID REFERENCES classes(id),
    academic_year VARCHAR(255),
    campus VARCHAR(255),
    email VARCHAR(255),
    address VARCHAR(255),
    date_of_birth DATE,
    program VARCHAR(255),
    status VARCHAR(255),
    account_id UUID REFERENCES accounts(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE parents (
    id UUID PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(255),
    occupation VARCHAR(255),
    relationship VARCHAR(255),
    student_id UUID NOT NULL REFERENCES students(id)
);

CREATE TABLE subjects (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE schedules (
    id UUID PRIMARY KEY,
    day_of_week INTEGER NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(255) NOT NULL,
    status VARCHAR(255),
    subject_id UUID NOT NULL REFERENCES subjects(id),
    teacher_id UUID NOT NULL REFERENCES teachers(id),
    class_id UUID NOT NULL REFERENCES classes(id)
);

CREATE TABLE assignments (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date TIMESTAMP NOT NULL,
    target_class VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    subject_id UUID NOT NULL REFERENCES subjects(id),
    teacher_id UUID NOT NULL REFERENCES teachers(id)
);

CREATE TABLE submissions (
    id UUID PRIMARY KEY,
    file_url VARCHAR(255),
    grade DOUBLE PRECISION,
    submitted_at TIMESTAMP,
    assignment_id UUID NOT NULL REFERENCES assignments(id),
    student_id UUID NOT NULL REFERENCES students(id)
);

CREATE TABLE grades (
    id UUID PRIMARY KEY,
    semester VARCHAR(255) NOT NULL,
    fifteen_min_score DOUBLE PRECISION,
    forty_five_min_score DOUBLE PRECISION,
    half_semester_score DOUBLE PRECISION,
    end_semester_score DOUBLE PRECISION,
    average DOUBLE PRECISION,
    subject_id UUID NOT NULL REFERENCES subjects(id),
    student_id UUID NOT NULL REFERENCES students(id)
);

CREATE TABLE applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    response_note TEXT,
    student_id UUID NOT NULL REFERENCES students(id),
    responded_by UUID REFERENCES teachers(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    category VARCHAR(255) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    student_id UUID REFERENCES students(id),
    account_id UUID REFERENCES accounts(id)
);
