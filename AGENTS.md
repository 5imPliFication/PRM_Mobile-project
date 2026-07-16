# AGENTS.md

This repo holds two independent projects (not a monorepo workspace): a Spring
Boot backend in `fpt/` and a Flutter client in `myfschoolse1911/`. Run commands
from inside the relevant subdirectory, not the repo root.

## Layout

- `fpt/` — Java 21 / Spring Boot 4.1.0 backend (Maven). Package root
  `vn.edu.fpt` under `src/main/java/vn/edu/fpt/`. Entry point
  `FptApplication.java`.
- `myfschoolse1911/` — Flutter app (Dart SDK ^3.11.5). Dart path
  `lib/vn/edu/fpt/...` mirrors the backend Java package on purpose; do not
  "flatten" it. App entry `lib/main.dart`, HTTP layer
  `lib/vn/edu/fpt/api_service.dart`. Role-specific screens live under
  `lib/vn/edu/fpt/view/teacher/` (and future `parent/`) subfolders; the student
  screens remain directly under `view/`.

## Backend (`fpt/`)

- Build / run: `./mvnw spring-boot:run` (server on `:8080`, API base `/api`).
  On a fresh/empty DB, Flyway runs **before** Hibernate validate and builds the
  schema from `V1..V4`; the app then starts. If `spring.jpa.hibernate.ddl-auto`
  (`validate`) complains about a missing table on startup, Flyway isn't running
  first — the `spring-boot-flyway` auto-config dependency is required (Spring Boot
  4.1 split it out; `flyway-core` alone does NOT trigger Flyway auto-config). To
  reset a DB that was created outside Flyway (no `flyway_schema_history`), drop
  the schema and let Flyway rebuild: `DROP SCHEMA public CASCADE; CREATE SCHEMA
  public; CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`.
- Test: `./mvnw test`. Single test class:
  `./mvnw -Dtest=ClassName test`. `FptApplicationTests` is a full
  `@SpringBootTest` (needs PostgreSQL up + Flyway apply); it uses a mock web
  environment so it does not bind port 8080.
- Java 21 is required (Spring Boot 4.1.0 parent). No `module-info.java`.
- Lombok is used and wired as an annotation processor in
  `maven-compiler-plugin`; it is excluded from the Spring Boot fat jar — don't
  add Lombok to runtime scope.
- DB is PostgreSQL (`fptschool` on `localhost:5432`) with credentials hardcoded
  in `src/main/resources/application.yaml`. The app must connect to that DB; if
  you edit credentials, also update them here (no env var / profile setup).
- Schema is owned by **Flyway**, not Hibernate. `spring.jpa.hibernate.ddl-auto`
  is `validate`, so entity changes require a new migration in
  `src/main/resources/db/migration/` (currently `V1__init_schema`,
  `V2__seed_data`, `V3__add_attendance_and_parent_links`,
  `V4__expand_seed`). Never rely on Hibernate to create/alter tables.
- **Roles / auth:** `Account.Role` = `STUDENT, TEACHER, PARENT, ADMIN`. JWT
  subject = account id; claims include `phone` and `role`. Method security is
  on (`@EnableMethodSecurity` in `SecurityConfig`); `/api/auth/**` is public,
  everything else is `authenticated()`, and student-facing controllers are
  annotated `@PreAuthorize("hasRole('STUDENT')")`. Add `hasRole('TEACHER')` /
  `hasRole('PARENT')` to new role-specific controllers. `LoginResponse` carries
  `studentId` / `teacherId` / `parentId` (whichever applies) + `fullName`.
  Seeded logins (all password `password123`): student `0912345678`,
  teachers `0900000001`-`0900000009` (`0900000001` = math teacher), parent
  `0912987654`.
- **Schema additions (V3/V4):** `attendances(schedule_id, student_id,
  attendance_date, status, note, marked_by)` with a per-session unique
  `(schedule_id, student_id, attendance_date)`; `parent_students(parent_id,
  student_id)` join (a parent may have multiple children); `parents.account_id`
  (parents now authenticate); `parents.student_id` is legacy/nullable — new code
  reads `parent_students`. Teacher↔student link is via `schedules` they share.
- JWT: secret and `expiration-ms` come from `app.jwt.*` in `application.yaml`.
  Auth flow lives in `security/` (`JwtTokenProvider`,
  `JwtAuthenticationFilter`) + `config/SecurityConfig`; controllers under
  `controller/`, services under `service/`, repositories under `repository/`,
  DTOs split into `dto/request` and `dto/response`. All API responses are
  wrapped in `dto/response/ApiResponse`.

## Flutter client (`myfschoolse1911/`)

- Get deps: `flutter pub get`.
- Run: `flutter run`. Analyze: `flutter analyze`. Tests: `flutter test`
  (single file: `flutter test test/foo_test.dart`).
- API base URL `http://10.0.2.2:8080/api` is hardcoded in
  `lib/vn/edu/fpt/api_service.dart`. `10.0.2.2` maps the Android emulator to the
  host loopback; for a physical device, change `baseUrl` to the host machine's
  LAN IP (Clear-text HTTP is already allowed by the backend `CorsConfig`).
- JWT is persisted in `shared_preferences` under the key `jwt_token`; the role
  and full name are persisted under `user_role` / `user_name`. `main.dart` has
  an `AuthGate` that restores a session on boot and routes by role
  (student/teacher/parent). `logout()` clears token+role+name; views must call
  `apiService.logout()` (not just navigate).
- Lints: `flutter_lints` via `analysis_options.yaml`. `intl` is used for date
  formatting in the assignment view. Theme seed color `0xFFF36F21` (FPT orange)
  is set in `lib/main.dart`. Note: existing views use `Color.withOpacity(...)`
  (deprecated info-only lint), not `.withValues(...)` — keep the convention.

## Backend ↔ client contract

- All responses are wrapped in `ApiResponse` (`{ success, message, data }`). Keep
  paths and shape in sync across both projects.
- Student endpoints (`hasRole('STUDENT')`): `POST /api/auth/login`,
  `GET /api/students/profile`, `GET /api/schedules`, `GET /api/assignments`,
  `POST /api/assignments/{id}/submit`, `GET /api/grades`,
  `GET /api/notifications`, `PUT /api/notifications/{id}/read`,
  `PUT /api/notifications/read-all`.
- Teacher endpoints (`hasRole('TEACHER')`, controller `TeacherController`):
  `GET /api/teachers/me`, `GET /api/teachers/classes`,
  `GET /api/teachers/classes/{className}/students`, `GET /api/teachers/sessions`
  (`?dayOfWeek=`), `GET /api/teachers/subjects`,
  `GET /api/teachers/attendance?scheduleId=&date=`,
  `POST /api/teachers/attendance` (bulk mark), `GET /api/teachers/assignments`,
  `POST /api/teachers/assignments` (create), `GET /api/teachers/assignments/{id}/submissions`,
  `PUT /api/teachers/submissions/{id}/grade`. Teacher↔student link is via
  `schedules` they share; sessions are deduped by (day+subject+time+room).
  Attendance status values: `PRESENT / LATE / ABSENT / EXCUSED`.
- Parent endpoints (`hasRole('PARENT')`, controller `ParentController`):
  `GET /api/parents/me` (+ children list), and for each `studentId`
  `GET /api/parents/children/{studentId}/{profile|grades|attendance|schedule|notifications}`.
  Every child endpoint guards ownership via `ParentRepository.isParentOf`.
  A parent may have multiple children (`parent_students` join); schedule
  supports `?dayOfWeek=` and grades support `?semester=`.
- **Parent↔student link flow** (controller `ParentLinkController`): a student
  invites by parent phone → a `parent_link_requests` row (PENDING) is created
  for the PARENT account with that phone → the parent accepts/rejects.
  On accept, the `parents` profile is created if missing and a
  `parent_students` row is inserted. Student endpoints (`hasRole('STUDENT')`):
  `POST /api/students/parent-link/requests`, `GET .../requests`,
  `DELETE .../requests/{id}`. Parent endpoints (`hasRole('PARENT')`):
  `GET /api/parents/link-requests`, `POST .../{id}/accept`,
  `POST .../{id}/reject`. Service errors are wrapped as `ApiResponse.error`
  with HTTP 400 via `GlobalExceptionHandler`.
- For a working end-to-end run: start the backend first (DB must be up), then
  launch the Flutter app.

## Git

- Long-lived branches: `main` and `develop` (work happens on `develop`).
  Commits are short, lowercase, imperative (e.g. `fix account password`).