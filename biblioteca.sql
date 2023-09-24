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
	name varchar(10),
	city varchar(20),
	employees int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id)
);

create table rooms(
	id int identity,
	name varchar(10),
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
	name varchar(10),
	room_id int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id), 
	constraint FK_racks_rooms foreign key (room_id) references rooms(id)
);

create table shelves(
	id int identity,
	name varchar(10),
	rack_id int,
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id),
	constraint FK_shelves_racks foreign key(rack_id) references racks(id)
);

create table sections(
	id int identity,
	name varchar(10),
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
	isbn varchar(13), --codigoalfanumerico International Standard Book Number, puede ser util para buscar un libro.
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
	stat varchar(10),
	register_creation datetime default getdate() not null,
	register_update datetime default getdate() not null,
	active varchar(1) default 'y' not null,
	primary key (id),
	constraint FK_loans_users foreign key (user_id) references users(id),
	constraint FK_loans_books foreign key (book_id) references books(id),
	constraint FK_loans_branches foreign key (branch_id) references branches(id)
);

insert into roles (name, description)
	values ('User', 'Usuario');
insert into roles (name, description)
	values ('No User', 'No Usuario');
insert into roles (name, description)
	values ('Admin', 'Administrador');

select * from roles;

/* Procedures- Agregar libro, borrar libro, mover libro, agregar usuario, modificar rol, borrar usuario, crear prestamo, concluir prestamo, devolver libro
	Vistas - Todos los salones, estanterias, estantes, secciones y libros de una sucursal
	Funciones- Buscar libros por sucursal, libros por salon, seccion, estante, buscar ubicacion de un libro, dado un usuario buscar el rol, dado un rol devolver todos los usuarios que lo usan
	Triggers: Modificar fechas de update, modificar estado de libros 
*/
