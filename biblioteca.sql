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
	firstName varchar(20),
	lastName varchar(30),
	dni varchar(9) unique,
	birthDate datetime,
	telephone varchar(11) unique,
	email varchar(30) unique,
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
/* Procedures- Agregar libro, borrar libro, mover libro, agregar usuario, modificar rol, borrar usuario, crear prestamo, concluir prestamo, devolver libro
	Vistas - Todos los salones, estanterias, estantes, secciones y libros de una sucursal
	Funciones- Buscar libros por sucursal, libros por salon, seccion, estante, buscar ubicacion de un libro, dado un usuario buscar el rol, dado un rol devolver todos los usuarios que lo usan
	Triggers: Modificar fechas de update, modificar estado de libros 
*/
CREATE FUNCTION checkUserRole(@UserId int, @RolId int) RETURNS bit
BEGIN
	if exists(SELECT * FROM Users as u 
		INNER JOIN Roles as r ON u.rolId = r.id
		WHERE u.id =@UserId AND r.id = @RolId)
	BEGIN
		RETURN 1;
	END;
	RETURN 0;
END;
GO
--PROCEDURES
--Branches
CREATE PROCEDURE insBranch @UserId int, @Name varchar(30), @City varchar(30), @Employees int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Branches (name, city, employees)
	VALUES (@Name, @City, @Employees)
END;
GO
CREATE PROCEDURE delBranch @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Branches set isActive = 0, dateUpdate = GETDATE()
	WHERE id=@Id
END;
GO
CREATE PROCEDURE updBranch @UserId int, @Id int,
	@Name varchar(30) = NULL,
	@City varchar(30) = NULL, 
	@Employees int = NULL
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	if (@Name is  NULL) SET @Name = (SELECT name FROM Branches WHERE id = @Id);
	if (@City is NULL) SET @City = (SELECT city FROM Branches WHERE id = @Id);
	if (@Employees is NULL) SET @Employees = (SELECT employees FROM Branches WHERE id = @Id);
	UPDATE Branches SET name = @Name, city = @City, employees = @Employees, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO
--Rooms
CREATE PROCEDURE insRoom @UserId int, @Name varchar(30), @BranchId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Rooms (name, branchId)
	VALUES (@Name, @BranchId)
END;
GO
CREATE PROCEDURE delRoom @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Sections SET isActive =0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updRoom @UserId int, @Id int, @BranchId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Rooms SET branchId = @BranchId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO
--Racks
CREATE PROCEDURE insRack @UserId int, @Name varchar(30), @RoomId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Racks (name, roomId)
	VALUES (@Name, @RoomId)
END;
GO
CREATE PROCEDURE delRack @UserId int,@Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Racks SET isActive =0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updRack @UserId int, @Id int, @RoomId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Racks SET roomId = @RoomId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO

--Shelves
CREATE PROCEDURE insShelf @UserId int,@Name varchar(30), @RackId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin'))=1)
BEGIN
	INSERT INTO Shelves (name, rackId)
	VALUES (@Name, @RackId)
END;
GO
CREATE PROCEDURE delShelf @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Shelves SET isActive = 0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updShelf @UserId int, @Id int, @RackId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Shelves SET rackId = @RackId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO

--Sections
CREATE PROCEDURE insSection @UserId int, @Name varchar(30), @ShelfId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Sections (name, shelfId)
	VALUES (@Name, @ShelfId)
END;
GO
CREATE PROCEDURE delSection @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Sections SET isActive =0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updSection @UserId int, @Id int, @ShelfId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Sections SET shelfId = @ShelfId, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO

--Books
CREATE PROCEDURE insBook @UserId int, @SectionId int, @Title varchar(30), @Isbn varchar(13), @Synopsis text, @Rating decimal
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Books (sectionId, title, isbn, synopsis, rating)
	VALUES (@SectionId, @Title, @Isbn, @Synopsis, @Rating)
END;
GO
CREATE PROCEDURE delBook @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Books SET isActive = 0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updBook @UserId int, @Id int, 
	@SectionId int = NULL,
	@Title varchar(30) = NULL,
	@Isbn varchar(13) = NULL,
	@Synopsis text = NULL,
	@Rating decimal = NULL
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
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
CREATE PROCEDURE insUser @CreatorId int, @FirstName varchar(20), @LastName varchar(30), @Dni varchar(9), @BirthDate datetime, @Telephone varchar(11), @Email varchar(30), @RolId int
AS
if (dbo.checkUserRole(@CreatorId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Users (firstName, lastName,dni,birthDate, telephone, email, rolId)
	VALUES (@FirstName, @LastName, @Dni, @BirthDate, @Telephone, @Email, @RolId)
END;
GO
CREATE PROCEDURE delUser @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Users SET isActive = 0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
--Loans
CREATE PROCEDURE insLoan @UserId1 int, @BookId int, @UserId2 int, @DateIssue datetime, @DateCompletion datetime, @StatusId int
AS
if (dbo.checkUserRole(@UserId1,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Loans (bookId, userId, dateIssue, dateCompletion, statusId)
	VALUES (@BookId, @UserId2, @DateIssue, @DateCompletion, @StatusId)
END;
GO
CREATE PROCEDURE delLoan @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Loans SET isActive=0, dateUpdate = getdate()
	WHERE id = @Id
END;
GO
CREATE PROCEDURE updLoan @UserId1 int, @Id int, 
@UserId2 int = NULL, 
@DateIssue datetime = NULL, 
@DateCompletion datetime = NULL
AS
if (dbo.checkUserRole(@UserId1,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	if (@UserId2 is NULL) SET @UserId2 = (SELECT userId FROM Loans WHERE id = @Id);
	if (@DateIssue is NULL) SET @DateIssue = (SELECT dateIssue FROM Loans WHERE id = @Id);
	if (@DateCompletion is NULL) SET @DateCompletion = (SELECT @DateCompletion FROM Loans WHERE id = @Id);
	UPDATE Loans SET userId = @UserId2, dateIssue = @DateIssue, dateCompletion = @DateCompletion, dateUpdate = GETDATE()
	WHERE id = @Id
END;
GO

--VISTAS


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
SELECT * FROM branches;
exec insRoom 1,'Room 1', 1;
exec insRack 1,'Rack 1', 1;
exec insShelf 1,'Shelf 1',1;
exec insSection 1,'Section 1', 1;
exec insBook 1,1, 'El hombre que calculaba', '33343434', 'Buen Libro?', 8;
set dateformat dmy;
exec insUser 1,'Gonzalo', 'Lattanzio','43598878','27-09-2001','1167918562','gonzalattanzio@gmail.com',1;
exec insLoan 1, 1, 2, '21-09-2023','23-10-2023',1;
SELECT * FROM loans;

