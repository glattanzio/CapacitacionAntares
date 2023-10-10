use AtlasBook;
DELETE FROM Users;
DBCC CHECKIDENT (Users, RESEED,0);
insert into Users (firstName, lastName,dni, birthDate, telephone, email, rolId)
VALUES 
('Admin','Admin','00000000','01-01-1991','0000000000','admin@admin.com',3),
('Marcelo','Gallardo','37443891','12-21-1987','1123345822','marcelogallardo@mail.com',1),
('Ariel','Ortega','22567910','09-11-1983','1166644912','arielortega@mail.com',1),
('Enzo','Francescoli','37546900','01-17-1982','1164530028','enzofrancescoli@mail.com',1),
('Fernando','Cavenaghi','40233211','06-23-1987','1123349822','fernandocavenaghi@mail.com',1),
('Beto','Alonso','42995476','01-01-1991','1133254678','betoalonso@mail.com',1),
('Julian', 'Alvarez','43598878','09-27-2001','1167918562','julianalvarez@mail.com',1),
('Sandra','Rossi','33900012','09-10-1976','1123330019','sandrarossi@mail.com',1);
SELECT * FROM Users;
DELETE FROM Books;
DELETE FROM Sections;
DELETE FROM Shelves;
DELETE FROM Racks
DELETE FROM Rooms;
DELETE FROM Branches;

DBCC CHECKIDENT(Branches, RESEED,0);
insert into Branches (name, city, employees)
VALUES
('La de Pilar','Pilar',43),
('La de Campana','Campana',23),
('La de Escobar','Escobar',51);
SELECT * FROM Branches;

DBCC CHECKIDENT(Rooms, RESEED, 0);
insert into Rooms (name, branchId)
VALUES
('Room 1',1);
SELECT * FROM Rooms;

DBCC CHECKIDENT(Racks, RESEED, 0);
insert into Racks (name, roomId)
VALUES
('Rack 1',1);
SELECT * FROM Racks;

DBCC CHECKIDENT(Shelves, RESEED, 0);
insert into Shelves (name, rackId)
VALUES
('Shelf 1',1);
SELECT * FROM Shelves;

DBCC CHECKIDENT(Sections, RESEED, 0);
insert into Sections (name, shelfId)
VALUES
('Section 1',1);
SELECT * FROM Sections;

DBCC CHECKIDENT(Books, RESEED, 0);
insert into Books (sectionId, title,isbn,synopsis,rating)
VALUES
(1,'El hombre que calculaba','1234567890123','Cuentos',8.8),
(1,'La Biblia','3323412890456','Religion',9.2),
(1,'Breve historia de mi vida','3562827369920','Biografia',7.4),
(1,'Viaje al centro de la tierra','2680998295460','Cuento',8.5),
(1,'Teoria de conmutacion','3334501982402','Informatica',7.9);
SELECT * FROM Books;

DELETE FROM Loans;
DBCC CHECKIDENT(Loans, RESEED,0);
insert into Loans (bookId, userId, dateIssue, dateCompletion, statusId)
values (5,2,'10-10-2023','12-10-2023',1);
insert into Loans (bookId, userId, dateIssue, dateCompletion, statusId)
values (4,3,'9-10-2023','11-10-2023',1);
insert into Loans (bookId, userId, dateIssue, dateCompletion, statusId)
values (3,4,'8-10-2023','10-10-2023',1);
SELECT * FROM Loans;