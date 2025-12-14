CREATE DATABASE OnlineBookstore;
GO
USE OnlineBookstore;
CREATE TABLE books (
    book_id INT IDENTITY(1,1) PRIMARY KEY ,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    publish_date DATE,
    publisher VARCHAR(100),
    description TEXT,
    cover_url VARCHAR(255),
    rating DECIMAL(2,1) DEFAULT 0 CHECK (rating BETWEEN 0 AND 5)
);

-- 2. 作者表（authors）
CREATE TABLE authors (
    author_id INT IDENTITY(1,1) PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    brief VARCHAR(500)
);

-- 3. 书籍-作者关联表（book_authors）
CREATE TABLE book_authors (
    ba_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- 4. 分类表（categories）
CREATE TABLE categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

-- 5. 书籍-分类关联表（book_categories）
CREATE TABLE book_categories (
    bc_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 6. 用户表（users）
CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    create_time DATETIME NOT NULL DEFAULT GETDATE()
);

-- 7. 订单表（orders）
CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    order_time DATETIME NOT NULL DEFAULT GETDATE(),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount > 0),
    status VARCHAR(20) NOT NULL,
    receiver VARCHAR(50) NOT NULL,
    receiver_phone VARCHAR(20) NOT NULL,
    receiver_address TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE order_items (
    item_id INT IDENTITY(1,1) PRIMARY KEY ,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 1),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
CREATE TABLE inventory (
    inventory_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id INT UNIQUE NOT NULL,
    stock_num INT NOT NULL CHECK (stock_num >= 0),
    update_time DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_price ON books(price);
CREATE INDEX idx_categories_name ON categories(category_name);