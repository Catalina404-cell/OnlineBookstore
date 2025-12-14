USE OnlineBookstore;
GO

-- 1. 分类
INSERT INTO categories (category_name, parent_id) VALUES
('编程语言', NULL),
('Python', 1),('Java', 1),('JavaScript', 1),
('前端开发', NULL),
('React', 5),('Vue', 5),
('计算机基础', NULL),
('数据结构与算法', 8),('计算机网络', 8),
('人工智能', NULL),
('机器学习', 11);
GO

-- 2. 作者
INSERT INTO authors (author_name, brief) VALUES
('埃里克·马特斯', 'Python领域知名作者，著有《Python编程 从入门到实践》'),
('Cay S. Horstmann', 'Java核心技术系列作者，资深技术作家'),
('Joshua Bloch', 'Effective Java作者，Google首席Java架构师'),
('Robert C. Martin', 'Clean Code作者，敏捷开发先驱'),
('兰德尔·E·布莱恩特', '深入理解计算机系统作者，卡内基梅隆大学教授'),
('埃里克·弗里曼', 'Head First设计模式作者，专注于软件设计教育'),
('托马斯·科尔曼', '算法（第4版）作者，普林斯顿大学教授'),
('张良均', 'Python数据分析实战作者，数据挖掘专家'),
('上野宣', '图解HTTP作者，网络技术科普作家');
GO

-- 3. 用户
INSERT INTO users (username, password, email, phone, address) VALUES
('admin', '$2b$12$LpK6v2f7t9x9v7f8u5s4rO3i2u1y9t8r7e6w5q4e3r2t1y9u8i8o7', 'admin@book.com', '13800138000', '北京市海淀区中关村');
GO

-- 4. 插入10本书
INSERT INTO books (isbn, title, publisher, price, publish_date, description, cover_url, rating) VALUES
('9787111693918','Python编程 从入门到实践（第3版）', '电子工业出版社', 89.00, '2023-01-01', '全球Python入门第一书', 'https://img3.doubanio.com/view/subject/s/public/s34534175.jpg', 4.8),
('9787115587992','Java核心技术 卷I（第11版）', '人民邮电出版社', 129.00, '2022-05-01', 'Java程序员圣经', 'https://img2.doubanio.com/view/subject/s/public/s33757358.jpg', 4.7),
('9787111688990','Effective Java（第3版）', '人民邮电出版社', 99.00, '2021-09-01', 'Java最佳实践', 'https://img9.doubanio.com/view/subject/s/public/s33540424.jpg', 4.9),
('9787115518880','深入理解计算机系统（第3版）', '人民邮电出版社', 149.00, '2020-03-01', 'CS必读神书', 'https://img1.doubanio.com/view/subject/s/public/s33426880.jpg', 4.9),
('9787115624987','Head First 设计模式（第2版）', '电子工业出版社', 89.00, '2023-02-01', '最轻松的设计模式入门', 'https://img1.doubanio.com/view/subject/s/public/s34380588.jpg', 4.6),
('9787111694588','Clean Code（中文版）', '电子工业出版社', 79.00, '2022-07-01', '代码整洁之道', 'https://img3.doubanio.com/view/subject/s/public/s29444944.jpg', 4.8),
('9787302596431','计算机网络 自顶向下方法（第8版）', '清华大学出版社', 99.00, '2021-10-01', '网络原理经典', 'https://img2.doubanio.com/view/subject/s/public/s33716299.jpg', 4.7),
('9787302566588','算法（第4版）', '清华大学出版社', 128.00, '2020-08-01', '算法领域圣经', 'https://img1.doubanio.com/view/subject/s/public/s29165438.jpg', 4.9),
('9787115558428','Python数据分析与挖掘实战', '电子工业出版社', 79.00, '2022-04-01', '数据分析实战', 'https://img9.doubanio.com/view/subject/s/public/s34012345.jpg', 4.5),
('9787115620040','图解HTTP', '电子工业出版社', 59.00, '2021-05-01', '网络入门神书', 'https://img3.doubanio.com/view/subject/s/public/s27283822.jpg', 4.8);
GO

-- 5. 库存表
INSERT INTO inventory (book_id, stock_num)
SELECT book_id, 999 FROM books;
GO

-- 6. 书籍-作者关联
INSERT INTO book_authors (book_id, author_id)
SELECT b.book_id, a.author_id
FROM (
    VALUES
    ('9787111693918',1),
    ('9787115587992',2),
    ('9787111688990',3),
    ('9787115518880',4),
    ('9787115624987',6),
    ('9787111694588',4),
    ('9787302596431',5),
    ('9787302566588',7),
    ('9787115558428',8),
    ('9787115620040',9)
) AS temp(isbn, author_id)
JOIN books b ON temp.isbn = b.isbn
JOIN authors a ON temp.author_id = a.author_id;
GO

-- 7. 书籍-分类关联（适配book_categories表：基于book_id关联，先通过isbn查询book_id）
INSERT INTO book_categories (book_id, category_id)
SELECT b.book_id, c.category_id
FROM (
    VALUES
    ('9787111693918',2),
    ('9787115587992',3),
    ('9787111688990',3),
    ('9787115518880',8),
    ('9787115624987',9),
    ('9787111694588',9),
    ('9787302596431',10),
    ('9787302566588',9),
    ('9787115558428',2),
    ('9787115620040',10)
) AS temp(isbn, category_id)
JOIN books b ON temp.isbn = b.isbn
JOIN categories c ON temp.category_id = c.category_id;
GO