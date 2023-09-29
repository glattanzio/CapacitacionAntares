use master
if exists(select * from dbo.sysdatabases where name='AtlasBook')
	begin
		use master
		drop database AtlasBook
	end
create database AtlasBook;
use AtlasBook

create table Branches(
	id int identity,
	name varchar(30) unique,
	city varchar(30),
	employees int,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id)
);
create table Rooms(
	id int identity,
	name varchar(30) unique,
	branchId int,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id),
	constraint FK_Rooms_Branches foreign key (branchId) references Branches(id)
);
create table Racks(
	id int identity,
	name varchar(30) unique,
	roomId int,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id), 
	constraint FK_Racks_Rooms foreign key (roomId) references Rooms(id)
);
create table Shelves(
	id int identity,
	name varchar(30) unique,
	rackId int,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id),
	constraint FK_Shelves_Racks foreign key(rackId) references Racks(id)
);
create table Sections(
	id int identity,
	name varchar(30) unique,
	shelfId int,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id),
	constraint FK_Sections_Shelves foreign key(shelfId) references Shelves(id)
);
create table Books(
	id int identity,
	sectionId int,
	title varchar(30),
	isbn varchar(13), --codigo alfanumerico International Standard Book Number, puede ser util para buscar un libro.
	synopsis text,
	rating int,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id),
	constraint FK_Books_Sections foreign key (sectionId) references Sections(id)
);
create table Roles(
	id int identity,
	name varchar(15) unique,
	description text,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key(id)
);
create table Users(
	id int identity,
	firstName varchar(30),
	lastName varchar(30),
	dni varchar(9) unique,
	birthDate datetime,
	telephone varchar(11) unique,
	email varchar(50) unique,
	rolId int,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id),
	constraint FK_Users_Roles foreign key (rolId) references Roles(id)
);
create table States(
	id int identity,
	name varchar(30) unique,
	description text,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id)
);
create table Loans(
	id int identity,
	bookId int not null,
	userId int not null,
	dateIssue datetime,
	dateCompletion datetime,
	statusId int not null,
	dateCreation datetime default getdate() not null,
	dateUpdate datetime default getdate() not null,
	isActive bit default 1 not null,
	primary key (id),
	constraint FK_Loans_Users foreign key (userId) references Users(id),
	constraint FK_Loans_Books foreign key (bookId) references Books(id),
	constraint FK_Loans_States foreign key (statusId) references States(id)
);
GO
--Funciones para filtrar por activos
CREATE FUNCTION ActiveBranches(@Active bit)
RETURNS @ActiveBranches table(
	id int,
	name varchar(30),
	city varchar(30),
	employees int,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveBranches 
		SELECT * FROM Branches
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION ActiveRooms (@Active bit)
RETURNS @ActiveRooms table(
	id int,
	name varchar(30),
	branchId int,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveRooms 
		SELECT * FROM Rooms
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION ActiveRacks (@Active bit)
RETURNS @ActiveRacks table(
	id int,
	name varchar(30),
	roomId int,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveRacks 
		SELECT * FROM Racks
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION ActiveShelves (@Active bit)
RETURNS @ActiveShelves table(
	id int,
	name varchar(30),
	rackId int,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveShelves 
		SELECT * FROM Shelves
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION activeSections (@Active bit)
RETURNS @ActiveSections table(
	id int,
	name varchar(30),
	shelfId int,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveSections 
		SELECT * FROM Sections
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION activeBooks (@Active bit)
RETURNS @ActiveBooks table(
	id int,
	sectionId int,
	title varchar(30),
	isbn varchar(13),
	synopsis text,
	rating int,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveBooks 
		SELECT * FROM Books
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION activeRoles (@Active bit)
RETURNS @ActiveRoles table(
	id int,
	name varchar(30),
	description text,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveRoles 
		SELECT * FROM Roles
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION activeUsers (@Active bit)
RETURNS @ActiveUsers table(
	id int,
	firstName varchar(30),
	lastName varchar(30),
	dni varchar(9),
	birthDate datetime,
	telephone varchar(11),
	emaill varchar(50),
	rolId int,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveUsers 
		SELECT * FROM Users
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION activeLoans (@Active bit)
RETURNS @ActiveLoans table(
	id int,
	bookId int,
	userId int,
	dateIssue datetime,
	dateCompletion datetime,
	statusId int,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveLoans 
		SELECT * FROM Loans
		WHERE isActive = @Active
	RETURN
END;
GO
CREATE FUNCTION activeStates (@Active bit)
RETURNS @ActiveStates table(
	id int,
	name varchar(30),
	description text,
	dateCreation datetime,
	DateUpdate datetime,
	isActive bit 
	) 
BEGIN
	INSERT @ActiveStates 
		SELECT * FROM States
		WHERE isActive = @Active
	RETURN
END;
GO
--VISTAS
CREATE VIEW LoanedBooks AS 
	SELECT * FROM activeBooks(1) 
	WHERE id IN(SELECT bookId FROM activeLoans(1) WHERE statusId = 1);
GO
CREATE VIEW AvailableBooks AS 
	SELECT * FROM activeBooks(1) 
	WHERE id NOT IN (SELECT bookId FROM activeLoans(1) WHERE statusId = 1);
GO
CREATE VIEW UsersWithLoans AS 
	SELECT * FROM activeUsers(1) 
	WHERE id IN(SELECT userId FROM activeLoans(1) WHERE statusId = 1);
GO
CREATE VIEW UsersWithoutLoans AS
	SELECT * FROM activeUsers(1) 
	WHERE id NOT IN(SELECT userId FROM activeLoans(1) WHERE statusId = 1);
GO
CREATE VIEW LoansUsersBooks  AS 
	SELECT l.id,u.id as 'User Id', u.firstName, u.lastName,b.id as 'Book Id', b.title, dateIssue, dateCompletion FROM  activeLoans(1) as l
	JOIN activeUsers(1) AS u ON userId = u.id
	JOIN activeBooks(1) AS b on bookId = b.id;
GO
CREATE VIEW BooksLocations AS
	SELECT  bo.id AS BookId , bo.title AS BookName,
		se.id AS SectionId, se.name AS SectionName, 
		sh.id AS ShelfId, sh.name as ShelfName, 
		ra.id AS RackId, ra.name AS RackName,
		ro.id AS RoomId, ro.name AS RoomName,
		br.id AS BranchId, br.name AS BranchName
		FROM activeBooks(1) as bo
	JOIN activeSections(1) AS se ON bo.sectionId = se.id
	JOIN activeShelves(1) AS sh ON se.ShelfId = sh.id
	JOIN activeRacks(1) AS ra ON sh.rackId = ra.id
	JOIN activeRooms(1) AS ro ON ra.roomId = ro.id
	JOIN activeBranches(1) AS br ON ro.branchId = br.id;
GO --hice esta vista porque es la mas amplia, con algunos WHERE podes ver todos los libros de una sucursal, o seccion, etc. Ademas, tambien podes limitar los campos

/*	Vistas - Todos los salones, estanterias, estantes, secciones y libros de una sucursal
	Funciones- Buscar libros por sucursal, libros por salon, seccion, estante, buscar ubicacion de un libro, dado un usuario buscar el rol, dado un rol devolver todos los usuarios que lo usan
	Triggers: Modificar fechas de update, modificar estado de libros 
*/
CREATE FUNCTION checkUserRole(@UserId int, @RolId int) RETURNS bit
BEGIN
	if exists(SELECT * FROM activeUsers(1) as u 
		INNER JOIN activeRoles(1) as r ON u.rolId = r.id
		WHERE u.id =@UserId AND r.id = @RolId)
	BEGIN
		RETURN 1;
	END;
	RETURN 0;
END;
GO
CREATE FUNCTION allBooksInBranch (@BranchId int) 
RETURNS @BooksInBranch table (bookId int, bookName varchar(30))
AS
BEGIN
	INSERT @BooksInBranch
		SELECT BookId, BookName FROM BooksLocations
		WHERE BranchId = @branchId
	RETURN
END;
GO
CREATE FUNCTION allBooksInRoom (@RoomId int) 
RETURNS @BooksInRoom table (bookId int, bookName varchar(30))
AS
BEGIN
	INSERT @BooksInRoom
		SELECT BookId, BookName FROM BooksLocations
		WHERE RoomId = @roomId
	RETURN
END;
GO
CREATE FUNCTION allBooksInRack (@RackId int) 
RETURNS @BooksInRack table (bookId int, bookName varchar(30))
AS
BEGIN
	INSERT @BooksInRack
		SELECT BookId, BookName FROM BooksLocations
		WHERE RackId = @RackId
	RETURN
END;
GO
CREATE FUNCTION allBooksInShelf (@ShelfId int) 
RETURNS @BooksInShelf table (bookId int, bookName varchar(30))
AS
BEGIN
	INSERT @BooksInShelf
		SELECT BookId, BookName FROM BooksLocations
		WHERE shelfId = @ShelfId
	RETURN
END;
GO
CREATE FUNCTION allBooksInSection (@SectionId int) 
RETURNS @BooksInSection table (bookId int, bookName varchar(30))
AS
BEGIN
	INSERT @BooksInSection
		SELECT BookId, BookName FROM BooksLocations
		WHERE SectionId = @sectionId
	RETURN
END;
GO
CREATE FUNCTION searchBooksByName (@Title varchar(30))
RETURNS @BooksWithName table (bookId int, bookName varchar(30), sectionId int)
AS
BEGIN
	INSERT @BooksWithName
		SELECT id, title, sectionId FROM activeBooks(1)
		WHERE title = @Title
	RETURN
END;
GO
CREATE FUNCTION searchBook (@Id int)
RETURNS @Ubication table 
(bookId int, bookName varchar(30), 
sectionId int, sectionName varchar(30),
shelfId int, shelfName varchar(30),
rackId int, rackName varchar(30),
roomId int, roomName varchar(30),
branchId int, branchName varchar(30))
BEGIN
	INSERT @Ubication 
		SELECT * FROM BooksLocations
		WHERE BookId = @Id;
	RETURN
END;
GO
CREATE FUNCTION userHasALoan(@Id int) RETURNS bit
BEGIN
	if exists(SELECT * FROM activeLoans(1) 
				WHERE userId = @Id AND statusId = 1)
		RETURN 1;
	RETURN 0;
END;
GO
CREATE FUNCTION userHasTwoLoans(@Id int) RETURNS BIT
BEGIN 
	IF ((SELECT COUNT(*) FROM activeLoans(1) 
		WHERE userId = @Id AND statusId = 1) 
		= 2)
		RETURN 1;
	RETURN 0;
END;
GO
CREATE FUNCTION bookInTwoLoans(@Id int) RETURNS BIT
BEGIN 
	IF ((SELECT COUNT(*) FROM activeLoans(1) 
		WHERE bookId = @Id AND statusId = 1) 
		= 2)
		RETURN 1;
	RETURN 0;
END;
GO
--PROCEDURES
--Branches
CREATE PROCEDURE insBranch @CreatorId int, @Name varchar(30), @City varchar(30), @Employees int
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Branches (name, city, employees)
	VALUES (@Name, @City, @Employees)
END;
GO
CREATE PROCEDURE delBranch @DeleterId int, @Id int
AS
if (dbo.checkUserRole(@DeleterId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Branches set isActive = 0, dateUpdate = GETDATE()
	WHERE id=@Id
END;
GO
CREATE PROCEDURE updBranch @ModifierId int, @Id int,
	@Name varchar(30) = NULL,
	@City varchar(30) = NULL, 
	@Employees int = NULL
AS
if (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	if (@Name is  NULL) SET @Name = (SELECT name FROM Branches WHERE id = @Id);
	if (@City is NULL) SET @City = (SELECT city FROM Branches WHERE id = @Id);
	if (@Employees is NULL) SET @Employees = (SELECT employees FROM Branches WHERE id = @Id);
	UPDATE Branches SET name = @Name, city = @City, employees = @Employees, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO
--Rooms
CREATE PROCEDURE insRoom @CreatorId int, @Name varchar(30), @BranchId int
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Rooms (name, branchId)
	VALUES (@Name, @BranchId)
END;
GO
CREATE PROCEDURE delRoom @DeleterId int, @Id int
AS
if (dbo.checkUserRole(@DeleterId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Sections SET isActive =0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updRoom @ModifierId int, @Id int, @BranchId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Rooms SET branchId = @BranchId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO
--Racks
CREATE PROCEDURE insRack @CreatorId int, @Name varchar(30), @RoomId int
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Racks (name, roomId)
	VALUES (@Name, @RoomId)
END;
GO
CREATE PROCEDURE delRack @DeleterId int,@Id int
AS
if (dbo.checkUserRole(@DeleterId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Racks SET isActive =0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updRack @ModifierId int, @Id int, @RoomId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Racks SET roomId = @RoomId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO
--Shelves
CREATE PROCEDURE insShelf @CreatorId int,@Name varchar(30), @RackId int
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin'))=1)
BEGIN
	INSERT INTO Shelves (name, rackId)
	VALUES (@Name, @RackId)
END;
GO
CREATE PROCEDURE delShelf @DeleterId int, @Id int
AS
if (dbo.checkUserRole(@DeleterId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Shelves SET isActive = 0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updShelf @ModifierId int, @Id int, @RackId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Shelves SET rackId = @RackId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO
--Sections
CREATE PROCEDURE insSection @CreatorId int, @Name varchar(30), @ShelfId int
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Sections (name, shelfId)
	VALUES (@Name, @ShelfId)
END;
GO
CREATE PROCEDURE delSection @DeleterId int, @Id int
AS
if (dbo.checkUserRole(@DeleterId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Sections SET isActive =0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updSection @ModifierId int, @Id int, @ShelfId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Sections SET shelfId = @ShelfId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO
--Books
CREATE PROCEDURE insBook @CreatorId int, @SectionId int, @Title varchar(30), @Isbn varchar(13), @Synopsis text, @Rating decimal
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Books (sectionId, title, isbn, synopsis, rating)
	VALUES (@SectionId, @Title, @Isbn, @Synopsis, @Rating)
END;
GO
CREATE PROCEDURE delBook @DeleterId int, @Id int
AS
if (dbo.checkUserRole(@DeleterId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Books SET isActive = 0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updBook @ModifierId int, @Id int, 
	@SectionId int = NULL,
	@Title varchar(30) = NULL,
	@Isbn varchar(13) = NULL,
	@Synopsis text = NULL,
	@Rating decimal = NULL
AS
if (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	if (@SectionId is NULL) SET @SectionId = (SELECT sectionId from Books WHERE id = @Id);
	if (@Title is NULL) SET @Title = (SELECT title from Books WHERE id = @Id);
	if (@Isbn is NULL) SET @Isbn = (SELECT isbn from Books WHERE id = @Id);
	if (@Synopsis is NULL) SET @Synopsis = (SELECT synopsis from Books WHERE id = @Id);
	if (@Rating is NULL) SET @Rating = (SELECT rating from Books WHERE id = @Id);
	UPDATE Books SET sectionId = @SectionId, title = @Title, isbn = @Isbn, synopsis = @Synopsis, rating = @Rating, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO
--Roles
--No se como manejarlo todavia, no tiene sentido crear ni borrar Roles.Ya que son fijos
--Users
CREATE PROCEDURE insUser @CreatorId int, @FirstName varchar(30), @LastName varchar(30), @Dni varchar(9), @BirthDate datetime, @Telephone varchar(11), @Email varchar(50), @RolId int
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Users (firstName, lastName,dni,birthDate, telephone, email, rolId)
	VALUES (@FirstName, @LastName, @Dni, @BirthDate, @Telephone, @Email, @RolId)
END;
GO
CREATE PROCEDURE delUser @DeleterId int, @Id int
AS
if (dbo.checkUserRole(@DeleterId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Users SET isActive = 0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updUser @ModifierId int, @Id int,
	@FirstName varchar(30) = NULL,
	@LastName varchar(30) =  NULL,
	@Dni varchar(9) = NULL,
	@BirthDate datetime = NULL,
	@Telephone varchar(11) = NULL,
	@Email varchar(50) = NULL,
	@RolId int = NULL --VERIFICAR QUE UN USUARIO NO SE CAMBIE DE ROL A SI MISMO
AS
IF (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Users SET firstName = @FirstName, lastName = @LastName, dni = @Dni,birthDate = @BirthDate,telephone= @Telephone, email = @Email, rolId=@RolId ,dateUpdate=getdate()
	WHERE id = @Id
END;
ELSE
BEGIN
	IF (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'uSER')) = 1) AND (@ModifierId = @Id)
	BEGIN
		UPDATE Users SET firstName = @FirstName, lastName = @LastName, dni = @Dni,birthDate = @BirthDate,telephone= @Telephone, email = @Email ,dateUpdate=getdate()
		WHERE id = @Id
	END;
END;
GO
--Loans
CREATE PROCEDURE insLoan @CreatorId int, @BookId int, @UserId int, @DateIssue datetime, @DateCompletion datetime, @StatusId int
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Loans (bookId, userId, dateIssue, dateCompletion, statusId)
	VALUES (@BookId, @UserId, @DateIssue, @DateCompletion, @StatusId)
END;
GO
CREATE PROCEDURE delLoan @DeleterId int, @Id int
AS
if (dbo.checkUserRole(@DeleterId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Loans SET isActive=0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updLoan @ModifierId int, @Id int, 
@UserId int = NULL, 
@DateIssue datetime = NULL, 
@DateCompletion datetime = NULL,
@StatusId int = NULL
AS
if (dbo.checkUserRole(@ModifierId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	if (@UserId is NULL) SET @UserId = (SELECT userId FROM Loans WHERE id = @Id);
	if (@DateIssue is NULL) SET @DateIssue = (SELECT dateIssue FROM Loans WHERE id = @Id);
	if (@DateCompletion is NULL) SET @DateCompletion = (SELECT dateCompletion FROM Loans WHERE id = @Id);
	if (@StatusId is NULL) SET @StatusId = (SELECT statusId FROM Loans WHERE id = @Id);
	UPDATE Loans SET userId = @UserId, dateIssue = @DateIssue, dateCompletion = @DateCompletion,statusId = @StatusId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO

CREATE TRIGGER LoansInsUpd 
ON Loans
FOR INSERT, UPDATE
AS
BEGIN
	IF ((SELECT dbo.userHasTwoLoans(inserted.userId) FROM inserted) = 1)
	BEGIN
		raiserror('Ese usuario ya tiene un prestamo activo',16,1)
		rollback transaction
	END
	IF ((SELECT dbo.bookInTwoLoans(inserted.bookId) FROM inserted) = 1) 
	BEGIN
		raiserror('Ese libro ya esta en un prestamo activo',16,1)
		rollback transaction
	END
END;
GO
--Crear Registros
insert into Roles (name, description)
	values ('User', 'Usuario');
insert into Roles (name, description)
	values ('No User', 'No Usuario');
insert into Roles (name, description)
	values ('Admin', 'Administrador');
insert into States (name, description)
	values ('Active','Activo');
insert into States (name, description)
	values ('Finished','Terminado');
insert into Users (firstName, lastName,dni, birthDate, telephone, email, rolId)
VALUES ('Pedro','Admin','12345678','01-01-1991','1234567890','pedro@admin.com',3);

exec insBranch 1,'La de Pilar', 'Pilar', 42;
exec insBranch 1,'La de Campana', 'Campana', 55;
exec delBranch 1,2;
exec insRoom 1,'Room 1', 1;
exec insRack 1,'Rack 1', 1;
exec insShelf 1,'Shelf 1',1;
exec insSection 1,'Section 1', 1;
exec insBook 1,1, 'El hombre que calculaba', '33343434', 'Buen Libro?', 8;
exec insBook 1,1, 'La Biblia', '33343434', 'Buen Libro?', 7;
set dateformat dmy;
exec insUser 1,'Gonzalo', 'Lattanzio','43598878','27-09-2001','1167918562','gonzalattanzio@gmail.com',1;
exec insLoan 1, 1, 2, '21-09-2023','23-10-2023',1;
exec insLoan 1, 2, 1, '21-09-2023','23-10-2023',1;
--exec updLoan 1, 1, @userId = 1;
SELECT * FROM dbo.searchBooksByName('El hombre que calculaba');
SELECT * FROM dbo.searchBook(1);
SELECT * FROM dbo.ActiveLoans(1);