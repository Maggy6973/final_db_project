# Simple Library Management System

## Project Overview

This is a straightforward MySQL database solution designed to manage the basic operations of a small library. The system allows librarians to track books, manage member information, and handle borrowing/returning processes efficiently.

## Features

- **Book Management**: Store and organize books with details like title, author, ISBN, and availability
- **Member Registration**: Keep track of library members and their contact information
- **Borrowing System**: Record when books are borrowed and returned
- **Category Organization**: Group books by categories for better organization
- **Useful Views**: Quick access to available books, active borrowings, and overdue books
- **Search Functionality**: Find books by title, author, or category

## Database Structure

The database consists of four main tables:

1. **Books**: Stores book information (title, author, ISBN, etc.)
2. **Members**: Contains member details (name, contact information, etc.)
3. **Borrowings**: Records borrowing transactions (borrow date, due date, return date)
4. **Categories**: Stores book categories/genres

## Setup Instructions

### Prerequisites
- MySQL Client or MySQL Workbench

### Installation Steps

1. **Download the SQL script**: Save the `library_management.sql` file to your computer

2. **Connect to MySQL Server**: Open your MySQL client or terminal and log in with your credentials
   ```
   mysql -u your_username -p
   ```

3. **Import the database**: Run the script to create the database and tables
   ```
   source /path/to/library_management.sql
   ```
   
   Alternatively, in MySQL Workbench:
   - Open MySQL Workbench and connect to your server
   - Go to File > Open SQL Script
   - Select the library_management.sql file
   - Click the lightning bolt icon to execute the script

4. **Verify installation**: The script will automatically:
   - Create the `library_management` database
   - Set up all necessary tables
   - Create views and stored procedures
   - Insert sample data

5. **Start using the system**: Once imported, you can begin using the database right away

## Using the System

### Viewing Data

The database includes several helpful SELECT queries for viewing data:

1. **View all books**:
   ```sql
   SELECT * FROM books;
   ```

2. **View all members**:
   ```sql
   SELECT * FROM members;
   ```

3. **Check available books**:
   ```sql
   SELECT * FROM available_books;
   ```

4. **View active borrowings**:
   ```sql
   SELECT * FROM active_borrowings;
   ```

5. **Check overdue books**:
   ```sql
   SELECT * FROM overdue_books;
   ```

### Managing Books and Borrowings

1. **Borrow a book**:
   ```sql
   CALL borrow_book(book_id, member_id, days_to_borrow);
   ```
   Example: `CALL borrow_book(1, 2, 14);` (Member #2 borrows Book #1 for 14 days)

2. **Return a book**:
   ```sql
   CALL return_book(borrowing_id);
   ```
   Example: `CALL return_book(3);` (Return the book from borrowing record #3)

3. **Search for books**:
   ```sql
   CALL search_books('search_term');
   ```
   Example: `CALL search_books('fiction');` (Find all books with "fiction" in title, author, or category)

## Customizing the System

You can extend this database by:

1. **Adding new books**:
   ```sql
   INSERT INTO books (title, author, isbn, category_id, publication_year, available_copies) 
   VALUES ('Book Title', 'Author Name', 'ISBN', category_id, year, copies);
   ```

2. **Adding new members**:
   ```sql
   INSERT INTO members (first_name, last_name, email, phone) 
   VALUES ('First', 'Last', 'email@example.com', 'phone-number');
   ```

3. **Creating new categories**:
   ```sql
   INSERT INTO categories (category_name, description) 
   VALUES ('Category Name', 'Description');
   ```

## Additional Information

- All tables include appropriate foreign key constraints to maintain data integrity
- The system automatically tracks book availability when items are borrowed or returned
- Sample data is included to demonstrate system functionality