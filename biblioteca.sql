use master
if exists(select * from dbo.sysdatabases where name='AtlasBook')
	begin
		use master
		drop database AtlasBook
	end
create database AtlasBook;
use AtlasBook

create table branches(
	id int identity,
	name varchar(30),
	city varchar(20),
	employees int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id)
);

create table rooms(
	id int identity,
	name varchar(30),
	branch_id int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id),
	constraint FK_rooms_branches
	foreign key (branch_id)
	references branches(id)
);

create table racks(
	id int identity,
	name varchar(30),
	room_id int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id), 
	constraint FK_racks_rooms foreign key (room_id) references rooms(id)
);

create table shelves(
	id int identity,
	name varchar(30),
	rack_id int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id),
	constraint FK_shelves_racks foreign key(rack_id) references racks(id)
);

create table sections(
	id int identity,
	name varchar(30),
	shelf_id int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id),
	constraint FK_sections_shelves foreign key(shelf_id) references shelves(id)
);

create table books(
	id int identity,
	section_id int,
	title varchar(30),
	isbn varchar(13), --codigo alfanumerico International Standard Book Number, puede ser util para buscar un libro.
	synopsis text,
	rating int,
	status varchar(1),
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id),
	constraint FK_books_sections foreign key (section_id) references sections(id)
);

create table roles(
	id int identity,
	name varchar(15),
	description text,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key(id)
);
create table users(
	id int identity,
	first_name varchar(20),
	last_name varchar(30),
	dni varchar(9),
	birth_date datetime,
	telephone varchar(11),
	email varchar(30),
	rol_id int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id),
	constraint FK_users_roles foreign key (rol_id) references roles(id)
);

create table loans(
	id int identity,
	book_id int not null,
	user_id int not null,
	branch_id int not null,
	date_of_issue datetime,
	date_of_completion datetime,
	status varchar(10),
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id),
	constraint FK_loans_users foreign key (user_id) references users(id),
	constraint FK_loans_books foreign key (book_id) references books(id),
	constraint FK_loans_branches foreign key (branch_id) references branches(id)
);


GO
/* Procedures- Agregar libro, borrar libro, mover libro, agregar usuario, modificar rol, borrar usuario, crear prestamo, concluir prestamo, devolver libro
	Vistas - Todos los salones, estanterias, estantes, secciones y libros de una sucursal
	Funciones- Buscar libros por sucursal, libros por salon, seccion, estante, buscar ubicacion de un libro, dado un usuario buscar el rol, dado un rol devolver todos los usuarios que lo usan
	Triggers: Modificar fechas de update, modificar estado de libros 
*/

--PROCEDURES
--Branches
CREATE PROCEDURE AddBranch @Name varchar(30), @City varchar(20), @Employees int
AS
INSERT INTO branches (name, city, employees)
VALUES (@Name, @City, @Employees)
GO
CREATE PROCEDURE DeleteBranch @Id int
AS
UPDATE branches set active = 'n' 
WHERE id=@Id
GO
CREATE PROCEDURE ModifyBranch @Id int,
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
CREATE PROCEDURE AddRoom @Name varchar(30), @Branch_id int
AS
INSERT INTO rooms (name, branch_id)
VALUES (@Name, @Branch_id)
GO
CREATE PROCEDURE DeleteRoom @Id int
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

