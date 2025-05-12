-- Create the database
CREATE DATABASE IF NOT EXISTS librar_management;
USE librar_management;

-- Create Categories table
CREATE TABLE IF NOT EXISTS categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

-- Create Books table
CREATE TABLE IF NOT EXISTS books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    category_id INT,
    publication_year INT,
    available_copies INT DEFAULT 1,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Create Members table
CREATE TABLE IF NOT EXISTS members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    join_date DATE ,
    active BOOLEAN DEFAULT TRUE
);

-- Create Borrowings table
CREATE TABLE IF NOT EXISTS borrowings (
    borrowing_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    member_id INT,
    borrow_date DATE NOT NULL ,
    due_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- Insert sample data for Categories
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Novels, short stories and other fictional works'),
('Non-Fiction', 'Factual books on various subjects'),
('Science Fiction', 'Works of speculative fiction'),
('Mystery', 'Crime and detective novels');

-- Insert sample data for Books
INSERT INTO books (title, author, isbn, category_id, publication_year, available_copies) VALUES
('To Kill a Mockingbird', 'Harper Lee', '9780061120084', 1, 1960, 3),
('1984', 'George Orwell', '9780451524935', 3, 1949, 2),
('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 1, 1925, 1),
('Brief Answers to the Big Questions', 'Stephen Hawking', '9781473695986', 2, 2018, 2),
('Murder on the Orient Express', 'Agatha Christie', '9780062693662', 4, 1934, 1);

-- Insert sample data for Members
INSERT INTO members (first_name, last_name, email, phone, join_date) VALUES
('John', 'Smith', 'john.smith@email.com', '555-123-4567', '2023-01-15'),
('Emily', 'Johnson', 'emily.j@email.com', '555-234-5678', '2023-02-20'),
('Michael', 'Williams', 'mike.w@email.com', '555-345-6789', '2023-03-10');

-- Insert sample data for Borrowings
INSERT INTO borrowings (book_id, member_id, borrow_date, due_date, return_date) VALUES
(1, 1, '2023-04-01', '2023-04-15', '2023-04-12'),
(2, 2, '2023-04-05', '2023-04-19', NULL),
(3, 3, '2023-04-10', '2023-04-24', NULL),
(4, 1, '2023-04-15', '2023-04-29', NULL);

-- Create a view to see available books
CREATE VIEW available_books AS
SELECT b.book_id, b.title, b.author, c.category_name, b.available_copies
FROM books b
JOIN categories c ON b.category_id = c.category_id
WHERE b.available_copies > 0;

-- Create a view to see active borrowings
CREATE VIEW active_borrowings AS
SELECT br.borrowing_id, b.title, b.author, 
       CONCAT(m.first_name, ' ', m.last_name) as member_name,
       br.borrow_date, br.due_date
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
JOIN members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL;

-- Create a view to see overdue books
CREATE VIEW overdue_books AS
SELECT br.borrowing_id, b.title, b.author, 
       CONCAT(m.first_name, ' ', m.last_name) as member_name,
       br.borrow_date, br.due_date,
       DATEDIFF(CURRENT_DATE, br.due_date) as days_overdue
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
JOIN members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL AND br.due_date < CURRENT_DATE;

-- Create a stored procedure to borrow a book
DELIMITER //
CREATE PROCEDURE borrow_book(IN p_book_id INT, IN p_member_id INT, IN p_days INT)
BEGIN
    DECLARE book_available INT;
    
    -- Check if the book is available
    SELECT available_copies INTO book_available FROM books WHERE book_id = p_book_id;
    
    IF book_available > 0 THEN
        -- Insert borrowing record
        INSERT INTO borrowings (book_id, member_id, borrow_date, due_date)
        VALUES (p_book_id, p_member_id, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL p_days DAY));
        
        -- Update available copies
        UPDATE books SET available_copies = available_copies - 1 WHERE book_id = p_book_id;
        
        SELECT 'Book borrowed successfully.' AS message;
    ELSE
        SELECT 'Book not available for borrowing.' AS message;
    END IF;
END //
DELIMITER ;

-- Create a stored procedure to return a book
DELIMITER //
CREATE PROCEDURE return_book(IN p_borrowing_id INT)
BEGIN
    DECLARE book_id_var INT;
    DECLARE is_returned DATE;
    
    -- Check if the book is already returned
    SELECT book_id, return_date INTO book_id_var, is_returned FROM borrowings WHERE borrowing_id = p_borrowing_id;
    
    IF is_returned IS NULL THEN
        -- Update borrowing record
        UPDATE borrowings SET return_date = CURRENT_DATE WHERE borrowing_id = p_borrowing_id;
        
        -- Update available copies
        UPDATE books SET available_copies = available_copies + 1 WHERE book_id = book_id_var;
        
        SELECT 'Book returned successfully.' AS message;
    ELSE
        SELECT 'This book has already been returned.' AS message;
    END IF;
END //
DELIMITER ;

-- Example stored procedure to search books by title, author, or category
DELIMITER //
CREATE PROCEDURE search_books(IN search_term VARCHAR(100))
BEGIN
    SELECT b.book_id, b.title, b.author, c.category_name, b.available_copies
    FROM books b
    JOIN categories c ON b.category_id = c.category_id
    WHERE b.title LIKE CONCAT('%', search_term, '%')
    OR b.author LIKE CONCAT('%', search_term, '%')
    OR c.category_name LIKE CONCAT('%', search_term, '%');
END //
DELIMITER ;

-- ======================================================
-- SELECT QUERIES FOR VIEWING THE LIBRARY SYSTEM
-- ======================================================

-- 1. View all books with their categories
SELECT 
    b.book_id,
    b.title,
    b.author,
    b.isbn,
    c.category_name,
    b.publication_year,
    b.available_copies
FROM books b
JOIN categories c ON b.category_id = c.category_id
ORDER BY b.title;

-- 2. View all library members
SELECT 
    member_id,
    first_name,
    last_name,
    email,
    phone,
    join_date,
    CASE WHEN active = 1 THEN 'Active' ELSE 'Inactive' END AS status
FROM members
ORDER BY last_name, first_name;

-- 3. View all current borrowings with member details
SELECT 
    br.borrowing_id,
    b.title AS book_title,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    br.borrow_date,
    br.due_date,
    CASE 
        WHEN br.return_date IS NULL AND br.due_date < CURRENT_DATE THEN 'Overdue'
        WHEN br.return_date IS NULL THEN 'Borrowed'
        ELSE 'Returned'
    END AS status,
    DATEDIFF(br.due_date, CURRENT_DATE) AS days_remaining
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
JOIN members m ON br.member_id = m.member_id
ORDER BY status, days_remaining;

-- 4. Check borrowing history for a specific member
-- Replace '1' with the actual member_id you want to check
SELECT 
    b.title,
    br.borrow_date,
    br.due_date,
    br.return_date,
    CASE 
        WHEN br.return_date IS NULL AND br.due_date < CURRENT_DATE THEN 'Overdue'
        WHEN br.return_date IS NULL THEN 'Borrowed'
        ELSE 'Returned'
    END AS status
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
WHERE br.member_id = 1  -- Change this value to check different members
ORDER BY br.borrow_date DESC;

-- 5. Find most popular books (most frequently borrowed)
SELECT 
    b.title,
    b.author,
    COUNT(br.borrowing_id) AS times_borrowed
FROM books b
LEFT JOIN borrowings br ON b.book_id = br.book_id
GROUP BY b.book_id, b.title, b.author
ORDER BY times_borrowed DESC
LIMIT 5;

-- 6. Check book availability by title or author (partial match)
-- Example: Find all books with "the" in the title
SELECT 
    b.book_id,
    b.title,
    b.author,
    c.category_name,
    b.available_copies,
    CASE WHEN b.available_copies > 0 THEN 'Available' ELSE 'Not Available' END AS status
FROM books b
JOIN categories c ON b.category_id = c.category_id
WHERE b.title LIKE '%the%'  -- Change this to search for different titles
ORDER BY b.title;