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
	isAvailable bit default 1,
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
	constraint FK_loans_books foreign key (bookId) references Books(id),
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
CREATE PROCEDURE insBranch @UserId, @Name varchar(30), @City varchar(20), @Employees int
AS
if 
INSERT INTO branches (name, city, employees)
VALUES (@Name, @City, @Employees)
GO
CREATE PROCEDURE delBranch @Id int
AS
UPDATE branches set active = 'n' 
WHERE id=@Id
GO
CREATE PROCEDURE updBranch @Id int,
	@Name varchar(30) = NULL,
	@City varchar(20) = NULL, 
	@Employees int = NULL
AS
	if (@Name is  NULL) SET @Name = (SELECT name FROM branches WHERE id = @Id);
	if (@City is NULL) SET @City = (SELECT city FROM branches WHERE id = @Id);
	if (@Employees is NULL) SET @Employees = (SELECT employees FROM branches WHERE id = @Id);
	UPDATE branches SET name = @Name, city = @City, employees = @Employees
	WHERE id = @Id
GO
--Rooms
CREATE PROCEDURE insRoom @Name varchar(30), @Branch_id int
AS
INSERT INTO rooms (name, branch_id)
VALUES (@Name, @Branch_id)
GO
CREATE PROCEDURE delRoom @Id int
AS
UPDATE rooms SET active = 'n'
WHERE id = @Id
GO

--Racks
CREATE PROCEDURE AddRack @Name varchar(30), @Room_id int
AS
INSERT INTO racks (name, room_id)
VALUES (@Name, @Room_id)
GO
CREATE PROCEDURE DeleteRack @Id int
AS
UPDATE racks SET active ='n'
WHERE id = @Id
GO

--Shelves
CREATE PROCEDURE AddShelf @Name varchar(30), @Rack_id int
AS
INSERT INTO shelves (name, rack_id)
VALUES (@Name, @Rack_id)
GO
CREATE PROCEDURE DeleteShelf @Id int
AS
UPDATE shelves SET active = 'n'
WHERE id = @Id
GO

--Sections
CREATE PROCEDURE AddSection @Name varchar(30), @Shelf_id int
AS
INSERT INTO sections (name, shelf_id)
VALUES (@Name, @Shelf_id)
GO
CREATE PROCEDURE DeleteSection @Id int
AS
UPDATE sections SET active ='n'
WHERE id = @Id
GO

--Books
CREATE PROCEDURE AddBook @Section_id int, @Title varchar(30), @Isbn varchar(13), @Synopsis text, @Rating int, @Status varchar(1)
AS
INSERT INTO books (section_id, title, isbn, synopsis, rating, status)
VALUES (@Section_id, @Title, @Isbn, @Synopsis, @Rating, @Status)
GO
CREATE PROCEDURE DeleteBook @Id int
AS
UPDATE books SET active = 'n'
WHERE id = @Id
GO

--Roles
--No se como manejarlo todavia, no tiene sentido crear ni borrar Roles.Ya que son fijos
--Users
CREATE PROCEDURE AddUser @First_name varchar(20), @Last_name varchar(30), @Dni varchar(9), @Birth_date datetime, @Telepone varchar(11), @Email varchar(30), @Rol_id int
AS
INSERT INTO users (first_name, last_name,dni,birth_date, telephone, email, rol_id)
VALUES (@First_name, @Last_name, @Dni, @Birth_date, @Telepone, @Email, @Rol_id)
GO
CREATE PROCEDURE DeleteUser @Id int
AS
UPDATE users SET active = 'n'
WHERE id = @Id
GO
--Loans
CREATE PROCEDURE AddLoan @Book_id int, @User_id int, @Branch_id int, @Date_of_issue datetime, @Date_of_Completion datetime, @Status varchar(10)
AS
INSERT INTO loans (book_id, user_id, branch_id, date_of_issue, date_of_completion, status)
VALUES (@Book_id, @User_id, @Branch_id, @Date_of_issue, @Date_of_Completion, @Status)
GO
CREATE PROCEDURE DeleteLoan @Id int
AS
UPDATE loans SET active='n'
WHERE id = @Id
GO

--VISTAS


--Crear Registros
insert into roles (name, description)
	values ('User', 'Usuario');
insert into roles (name, description)
	values ('No User', 'No Usuario');
insert into roles (name, description)
	values ('Admin', 'Administrador');

exec AddBranch 'La de Pilar', 'Pilar', 42;
exec AddBranch 'La de Campana', 'Campana', 55;
exec DeleteBranch 2;
SELECT * FROM branches;
exec AddRoom 'Room 1', 1;
exec AddRack 'Rack 1', 1;
exec AddShelf 'Shelf 1',1;
exec AddSection 'Section 1', 1;
exec AddBook 1, 'El hombre que calculaba', '33343434', 'Buen Libro?', 8, 'D';
set dateformat dmy;
exec AddUser 'Gonzalo', 'Lattanzio','43598878','27-09-2001','1167918562','gonzalattanzio@gmail.com',1;
exec AddLoan 1, 1, 1, '21-09-2023','23-10-2023', 'Activo';
SELECT * FROM loans;

