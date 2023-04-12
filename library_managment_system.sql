##Creating the database 
CREATE DATABASE db_LibraryManagement;

#Switching to the database
use db_LibraryManagement;

#Creating table publisher for the book publisher
CREATE TABLE table_publisher(
PublisherName VARCHAR(50) PRIMARY KEY NOT NULL,
PublisherAddress VARCHAR(100) NOT NULL,
PublisherPhone VARCHAR(20) NOT NULL);


#creating the table to store information about the book 
CREATE TABLE table_book (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    Book_Title VARCHAR(100) NOT NULL,
    PublisherName VARCHAR(100) NOT NULL
);
INSERT INTO table_book (Book_Title, PublisherName) 
VALUES 
  ('To Kill a Mockingbird', 'HarperCollins'),
  ('The Great Gatsby', 'Scribner'),
  ('Pride and Prejudice', 'Penguin Classics');


#Creating table for the branch of the library
CREATE TABLE table_library_branch (
  library_branch_BranchID INT NOT NULL AUTO_INCREMENT,
  library_branch_BranchName VARCHAR(100) NOT NULL,
  library_branch_BranchAddress VARCHAR(200) NOT NULL,
  PRIMARY KEY (library_branch_BranchID)
);
INSERT INTO table_library_branch (library_branch_BranchName, library_branch_BranchAddress) 
VALUES 
  ('Main Library', '123 Main St, Anytown USA'),
  ('North Branch', '456 North St, Anytown USA'),
  ('South Branch', '789 South St, Anytown USA');





#creating the table for the borrower to borrow books
CREATE TABLE table_borrower (
  CardNo INT NOT NULL AUTO_INCREMENT,
  BorrowerName VARCHAR(100) NOT NULL,
  BorrowerAddress VARCHAR(200) NOT NULL,
  BorrowerPhone VARCHAR(50),
  PRIMARY KEY (CardNo)
);


#Creating the table to store the information about copies available 
CREATE TABLE table_book_copies (
  CopiesID INT PRIMARY KEY NOT NULL,
  BookID INT NOT NULL,
  BranchID INT NOT NULL,
  NoOfCopies INT NOT NULL,
  FOREIGN KEY (BookID) REFERENCES table_book(BookID),
  FOREIGN KEY (BranchID) REFERENCES table_library_branch(library_branch_BranchID)
);
INSERT INTO table_book_copies (CopiesID, BookID, BranchID, NoOfCopies) 
VALUES 
  (1, 1, 1, 10),
  (2, 2, 1, 7),
  (3, 2, 2, 5),
  (4, 3, 2, 8),
  (5, 1, 3, 12),
  (6, 3, 3, 3);
;


#creating the table for the authors of the book info
CREATE TABLE table_book_authors (
  AuthorID INT NOT NULL AUTO_INCREMENT,
  BookID INT NOT NULL,
  AuthorName VARCHAR(50) NOT NULL,
  PRIMARY KEY (AuthorID),
  FOREIGN KEY (BookID) REFERENCES table_book(BookID) ON UPDATE CASCADE ON DELETE CASCADE
);





#creating the table for storing book details

CREATE TABLE IF NOT EXISTS `book` (

  `isbn` char(13) NOT NULL,

  `title` varchar(80) NOT NULL,

  `author` varchar(80) NOT NULL,

  `category` varchar(80) NOT NULL,

  `price` int(4) unsigned NOT NULL,

  `copies` int(10) unsigned NOT NULL

);


INSERT INTO `book` (`isbn`, `title`, `author`, `category`, `price`, `copies`) VALUES

('9788654552277', 'X-Men: God Loves, Man Kills', 'Chris', 'Comics', 98, 39),

('0964161484100', 'Mike Tyson : Undisputed Truth', 'Larry Sloman, Mike Tyson', 'Sports', 654, 79),

('6901142585540', 'V for Vendetta', 'Alan Moore', 'Comics', 600, 23),

('9094996245442', 'When Breath Becomes Air', 'Paul Kalanithi', 'Medical', 500, 94),

('8653491200700', 'The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', 432, 120);
#Structure of the table for book issue.



#creating table to store issued book information
CREATE TABLE IF NOT EXISTS `book_issue` (

`issue_id` int(11) NOT NULL,

  `member` varchar(20) NOT NULL,

  `book_isbn` varchar(13) NOT NULL,

  `due_date` date NOT NULL,

  `last_reminded` date DEFAULT NULL

) ;


#creating the triiger when book is issued automatically copies from book copies will reduce by 1
#and credit will get deducted from issuers account
delimiter //
CREATE TRIGGER `issue_book` BEFORE INSERT ON `book_issue`
FOR EACH ROW 
BEGIN
    DECLARE book_price INT;

    SELECT price INTO book_price FROM book WHERE isbn = NEW.book_isbn;

    UPDATE member SET balance = balance - book_price WHERE username = NEW.member;

    UPDATE book SET copies = copies - 1 WHERE isbn = NEW.book_isbn;

    DELETE FROM pending_book_requests WHERE member = NEW.member AND book_isbn = NEW.book_isbn;

    SET NEW.due_date = DATE_ADD(CURRENT_DATE, INTERVAL 20 DAY);
END;





#creating trigger for returning book when book returned copies will be increased by one and credit will be restored
delimiter //
CREATE TRIGGER `return_book` BEFORE DELETE ON `book_issue`
FOR EACH ROW
BEGIN
    UPDATE member SET balance = balance + (SELECT price FROM book WHERE isbn = OLD.book_isbn) WHERE username = OLD.member;

    UPDATE book SET copies = copies + 1 WHERE isbn = OLD.book_isbn;
END;

#table to store librarian information

CREATE TABLE IF NOT EXISTS `librarian` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` char(40) NOT NULL,
  PRIMARY KEY (`id`)
);



INSERT INTO `librarian` (`id`, `username`, `password`) VALUES

(1, 'Vani', 'xthds97@3h$yfc*jrk0%dfg$');



# creating table for library member

CREATE TABLE IF NOT EXISTS `member` (

`id` int(11) NOT NULL,

  `username` varchar(20) NOT NULL,

  `password` char(40) NOT NULL,

  `name` varchar(80) NOT NULL,

  `email` varchar(80) NOT NULL,

  `balance` int(4) NOT NULL

);


# user will request membership it will be stored in pending registration when the membership 
#is accepted data from pending registraion will be deleted for that member
delimiter //
CREATE TRIGGER `add_member` AFTER INSERT ON `member`
FOR EACH ROW 
BEGIN 
    DELETE FROM pending_registrations WHERE username = NEW.username;
END;

CREATE TRIGGER `remove_member` AFTER DELETE ON `member`
FOR EACH ROW 
BEGIN 
    DELETE FROM pending_book_requests WHERE member = OLD.username;
END;

# creating table to store requests pending for the member
CREATE TABLE IF NOT EXISTS `pending_book_requests` (

`request_id` int(11) NOT NULL,

  `member` varchar(20) NOT NULL,

  `book_isbn` varchar(13) NOT NULL,

  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE IF NOT EXISTS `pending_registrations` (

  `username` varchar(30) NOT NULL,

  `password` char(20) NOT NULL,

  `name` varchar(40) NOT NULL,

  `email` varchar(20) NOT NULL,

  `balance` int(10),

  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP

);

INSERT INTO `pending_registrations`

(`username`, `password`, `name`, `email`, `balance`, `time`)

VALUES

('Robin200', '7t6hg$56y^', 'Robin', 'robin@gmail.com', 200, '2021-03-21 08:59:00'),

('Aadhya100', 'Ujgf(76G5$#f@df', 'Aadhya', 'aadhya100@gmail.com', 1500, '2021-03-21 2:14:53');


# creating the procedure to see number of copies of the book name available in the specified library branch
delimiter //
CREATE PROCEDURE bookCopiesAtAllSharpstown (
    IN bookTitle VARCHAR(255),
    IN branchName VARCHAR(255)
)
BEGIN
    SELECT 
        copies.BranchID AS `Branch ID`, 
        branch.library_branch_BranchName AS `Branch Name`,
        copies.NoOfCopies AS `Number of Copies`,
        book.Book_Title AS `Book Title`
    FROM 
        table_book_copies AS copies
        INNER JOIN table_book AS book 
            ON copies.BookID = book.BookID
        INNER JOIN table_library_branch AS branch 
            ON copies.BranchID = branch.library_branch_BranchID
    WHERE 
        book.Book_Title = bookTitle 
        AND branch.library_branch_BranchName = branchName;
END//
delimiter ;
CALL bookCopiesAtAllSharpstown('To Kill a Mockingbird', 'Main Library');









