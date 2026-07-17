-- Seed Admin Account (Password is '1231' hashed with bcrypt)
INSERT INTO accounts (id, phone, password, role, is_active, created_at)
VALUES ('11111111-1111-1111-1111-111111111140', '0900000000', '$2b$12$Bt6ZNIXnRfBHnrbQynN14uiNqdKsDPI2oETcA9IjVLpO.cTLsfkjC', 'ADMIN', true, NOW());
