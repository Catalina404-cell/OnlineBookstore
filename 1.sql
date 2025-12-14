-- 强制创建管理员账号：admin / admin123
IF NOT EXISTS (SELECT * FROM Users WHERE username = 'admin')
BEGIN
    INSERT INTO Users (username, password_hash, email, full_name, is_admin)
    VALUES ('admin', 
            '$2b$12$LpK6v2f7t9x9v7f8u5s4rO3i2u1y9t8r7e6w5q4e3r2t1y9u8i8o7', 
            'admin@123.com', '超级管理员', 1)
    PRINT '管理员账号创建成功：admin / admin123'
END