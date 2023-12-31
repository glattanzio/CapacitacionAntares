USE [master]
GO
/****** Object:  Database [AtlasBook]    Script Date: 9/25/2023 11:14:58 PM ******/
CREATE DATABASE [AtlasBook]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'AtlasBook', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\AtlasBook.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'AtlasBook_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\AtlasBook_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [AtlasBook] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [AtlasBook].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [AtlasBook] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [AtlasBook] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [AtlasBook] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [AtlasBook] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [AtlasBook] SET ARITHABORT OFF 
GO
ALTER DATABASE [AtlasBook] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [AtlasBook] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [AtlasBook] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [AtlasBook] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [AtlasBook] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [AtlasBook] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [AtlasBook] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [AtlasBook] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [AtlasBook] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [AtlasBook] SET  ENABLE_BROKER 
GO
ALTER DATABASE [AtlasBook] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [AtlasBook] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [AtlasBook] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [AtlasBook] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [AtlasBook] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [AtlasBook] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [AtlasBook] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [AtlasBook] SET RECOVERY FULL 
GO
ALTER DATABASE [AtlasBook] SET  MULTI_USER 
GO
ALTER DATABASE [AtlasBook] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [AtlasBook] SET DB_CHAINING OFF 
GO
ALTER DATABASE [AtlasBook] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [AtlasBook] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [AtlasBook] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [AtlasBook] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'AtlasBook', N'ON'
GO
ALTER DATABASE [AtlasBook] SET QUERY_STORE = ON
GO
ALTER DATABASE [AtlasBook] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [AtlasBook]
GO
/****** Object:  UserDefinedFunction [dbo].[checkUserRole]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* Procedures- Agregar libro, borrar libro, mover libro, agregar usuario, modificar rol, borrar usuario, crear prestamo, concluir prestamo, devolver libro
	Vistas - Todos los salones, estanterias, estantes, secciones y libros de una sucursal
	Funciones- Buscar libros por sucursal, libros por salon, seccion, estante, buscar ubicacion de un libro, dado un usuario buscar el rol, dado un rol devolver todos los usuarios que lo usan
	Triggers: Modificar fechas de update, modificar estado de libros 
*/

--FUNCTIONS
CREATE FUNCTION [dbo].[checkUserRole] (@UserId int, @RolId int) RETURNS bit
AS
BEGIN
	IF exists(
		SELECT * FROM Users as u 
		INNER JOIN Roles as r ON u.rolId = r.id
		WHERE u.id =@UserId AND r.id = @RolId)
		BEGIN
				RETURN 1;
		END;
	ELSE
		BEGIN 
			return 0;
		END;
	RETURN 0;
END;
GO
/****** Object:  Table [dbo].[Books]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sectionId] [int] NOT NULL,
	[title] [varchar](30) NULL,
	[isbn] [varchar](13) NULL,
	[synopsis] [text] NULL,
	[rating] [decimal](18, 0) NULL,
	[status] [bit] NOT NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Branches]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Branches](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NULL,
	[city] [varchar](30) NULL,
	[employees] [int] NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Loans]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loans](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bookId] [int] NOT NULL,
	[userId] [int] NOT NULL,
	[dateIssue] [datetime] NOT NULL,
	[dateCompletion] [datetime] NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Racks]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Racks](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NULL,
	[roomId] [int] NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](15) NULL,
	[description] [text] NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rooms]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rooms](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NULL,
	[branchId] [int] NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sections]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sections](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NULL,
	[shelfId] [int] NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Shelves]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shelves](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NULL,
	[rackId] [int] NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[firstName] [varchar](30) NULL,
	[lastName] [varchar](30) NULL,
	[dni] [varchar](9) NULL,
	[birthDate] [datetime] NULL,
	[telephone] [varchar](11) NULL,
	[email] [varchar](30) NULL,
	[rolId] [int] NULL,
	[registerCreation] [datetime] NOT NULL,
	[registerUpdate] [datetime] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[dni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Books] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Books] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Books] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Branches] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Branches] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Branches] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Racks] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Racks] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Racks] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Rooms] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Rooms] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Rooms] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Sections] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Sections] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Sections] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Shelves] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Shelves] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Shelves] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [registerCreation]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [registerUpdate]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[Books]  WITH CHECK ADD  CONSTRAINT [FK_Books_Sections] FOREIGN KEY([sectionId])
REFERENCES [dbo].[Sections] ([id])
GO
ALTER TABLE [dbo].[Books] CHECK CONSTRAINT [FK_Books_Sections]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [FK_Loans_Books] FOREIGN KEY([bookId])
REFERENCES [dbo].[Books] ([id])
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [FK_Loans_Books]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [FK_Loans_Users] FOREIGN KEY([userId])
REFERENCES [dbo].[Users] ([id])
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [FK_Loans_Users]
GO
ALTER TABLE [dbo].[Racks]  WITH CHECK ADD  CONSTRAINT [FK_Racks_Rooms] FOREIGN KEY([roomId])
REFERENCES [dbo].[Rooms] ([id])
GO
ALTER TABLE [dbo].[Racks] CHECK CONSTRAINT [FK_Racks_Rooms]
GO
ALTER TABLE [dbo].[Rooms]  WITH CHECK ADD  CONSTRAINT [FK_Rooms_Branches] FOREIGN KEY([branchId])
REFERENCES [dbo].[Branches] ([id])
GO
ALTER TABLE [dbo].[Rooms] CHECK CONSTRAINT [FK_Rooms_Branches]
GO
ALTER TABLE [dbo].[Sections]  WITH CHECK ADD  CONSTRAINT [FK_Sections_Shelves] FOREIGN KEY([shelfId])
REFERENCES [dbo].[Shelves] ([id])
GO
ALTER TABLE [dbo].[Sections] CHECK CONSTRAINT [FK_Sections_Shelves]
GO
ALTER TABLE [dbo].[Shelves]  WITH CHECK ADD  CONSTRAINT [FK_Shelves_Racks] FOREIGN KEY([rackId])
REFERENCES [dbo].[Racks] ([id])
GO
ALTER TABLE [dbo].[Shelves] CHECK CONSTRAINT [FK_Shelves_Racks]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Roles] FOREIGN KEY([rolId])
REFERENCES [dbo].[Roles] ([id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Roles]
GO
/****** Object:  StoredProcedure [dbo].[delBook]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delBook] @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Books SET isActive = 0
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[delBranch]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delBranch] @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Branches set isActive = 0, registerUpdate = GETDATE()
	WHERE id=@Id
END;
GO
/****** Object:  StoredProcedure [dbo].[delLoan]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delLoan] @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Loans SET isActive=0
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[delRack]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delRack] @UserId int,@Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Racks SET isActive =0
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[delRoom]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delRoom] @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Rooms SET isActive = 0, registerUpdate = GETDATE()
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[delSection]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delSection] @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Sections SET isActive =0
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[delShelf]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delShelf] @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Shelves SET isActive = 0
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[delUser]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[delUser] @UserId int, @Id int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Users SET isActive = 0
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[insBook]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Books
CREATE PROCEDURE [dbo].[insBook] @UserId int, @SectionId int, @Title varchar(30), @Isbn varchar(13), @Synopsis text, @Rating decimal, @Status bit
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Books (sectionId, title, isbn, synopsis, rating, status)
	VALUES (@SectionId, @Title, @Isbn, @Synopsis, @Rating, @Status)
END;
GO
/****** Object:  StoredProcedure [dbo].[insBranch]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--PROCEDURES
--Branches
CREATE PROCEDURE [dbo].[insBranch] @UserId int, @Name varchar(30), @City varchar(30), @Employees int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Branches (name, city, employees)
	VALUES (@Name, @City, @Employees)
END;
GO
/****** Object:  StoredProcedure [dbo].[insLoan]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--updUser, chequear si es admin, si no que sea el mismo.
--Loans
CREATE PROCEDURE [dbo].[insLoan] @UserId1 int, @BookId int, @UserId2 int, @DateIssue datetime, @DateCompletion datetime 
AS
if (dbo.checkUserRole(@UserId1,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Loans (bookId, userId, dateIssue, dateCompletion)
	VALUES (@BookId, @UserId2, @DateIssue, @DateCompletion)
END;
GO
/****** Object:  StoredProcedure [dbo].[insRack]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Racks
CREATE PROCEDURE [dbo].[insRack] @UserId int, @Name varchar(30), @RoomId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Racks (name, roomId)
	VALUES (@Name, @RoomId)
END;
GO
/****** Object:  StoredProcedure [dbo].[insRoom]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Rooms
CREATE PROCEDURE [dbo].[insRoom] @UserId int, @Name varchar(30), @BranchId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Rooms (name, branchId)
	VALUES (@Name, @BranchId)
END;
GO
/****** Object:  StoredProcedure [dbo].[insSection]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Sections
CREATE PROCEDURE [dbo].[insSection] @UserId int, @Name varchar(30), @ShelfId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Sections (name, shelfId)
	VALUES (@Name, @ShelfId)
END;
GO
/****** Object:  StoredProcedure [dbo].[insShelf]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Shelves
CREATE PROCEDURE [dbo].[insShelf] @UserId int,@Name varchar(30), @RackId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin'))=1)
BEGIN
	INSERT INTO Shelves (name, rackId)
	VALUES (@Name, @RackId)
END;
GO
/****** Object:  StoredProcedure [dbo].[insUser]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Roles
--No se como manejarlo todavia, no tiene sentido crear ni borrar Roles.Ya que son fijos
--Users
CREATE PROCEDURE [dbo].[insUser] @UserId int, @FirstName varchar(20), @LastName varchar(30), @Dni varchar(9), @BirthDate datetime, @Telephone varchar(11), @Email varchar(30), @RolId int
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	INSERT INTO Users (firstName, lastName,dni,birthDate, telephone, email, rolId)
	VALUES (@FirstName, @LastName, @Dni, @BirthDate, @Telephone, @Email, @RolId)
END;
GO
/****** Object:  StoredProcedure [dbo].[updBook]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[updBook] @UserId int, @Id int, 
	@SectionId int = NULL,
	@Title varchar(30) = NULL,
	@Isbn varchar(13) = NULL,
	@Synopsis text = NULL,
	@Rating decimal = NULL,
	@Status bit = NULL
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	if (@SectionId is NULL) SET @SectionId = (SELECT sectionId from Books WHERE id = @Id);
	if (@Title is NULL) SET @Title = (SELECT title from Books WHERE id = @Id);
	if (@Isbn is NULL) SET @Isbn = (SELECT isbn from Books WHERE id = @Id);
	if (@Synopsis is NULL) SET @Synopsis = (SELECT synopsis from Books WHERE id = @Id);
	if (@Rating is NULL) SET @Rating = (SELECT rating from Books WHERE id = @Id);
	if (@Status is NULL) SET @Status = (SELECT status from Books WHERE id = @Id);
	UPDATE Books SET sectionId = @SectionId, title = @Title, isbn = @Isbn, synopsis = @Synopsis, rating = @Rating, status = @Status, registerUpdate = GETDATE()
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[updBranch]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[updBranch] @UserId int, @Id int,
	@Name varchar(30) = NULL,
	@City varchar(30) = NULL, 
	@Employees int = NULL
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	if (@Name is  NULL) SET @Name = (SELECT name FROM Branches WHERE id = @Id);
	if (@City is NULL) SET @City = (SELECT city FROM Branches WHERE id = @Id);
	if (@Employees is NULL) SET @Employees = (SELECT employees FROM Branches WHERE id = @Id);
	UPDATE Branches SET name = @Name, city = @City, employees = @Employees, registerUpdate = GETDATE()
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[updLoan]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[updLoan] @UserId1 int, @Id int, 
@UserId2 int = NULL, 
@DateIssue datetime = NULL, 
@DateCompletion datetime = NULL
AS
if (dbo.checkUserRole(@UserId1,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	if (@UserId2 is NULL) SET @UserId2 = (SELECT userId FROM Loans WHERE id = @Id);
	if (@DateIssue is NULL) SET @DateIssue = (SELECT dateIssue FROM Loans WHERE id = @Id);
	if (@DateCompletion is NULL) SET @DateCompletion = (SELECT @DateCompletion FROM Loans WHERE id = @Id);
	UPDATE Loans SET userId = @UserId2, dateIssue = @DateIssue, dateCompletion = @DateCompletion, registerUpdate = GETDATE()
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[updRack]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[updRack] @UserId int, @Id int, @RoomId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Racks SET roomId = @RoomId, registerUpdate = GETDATE()
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[updRoom]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[updRoom] @USerId int, @Id int, @BranchId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Rooms SET branchId = @BranchId, registerUpdate = GETDATE()
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[updSection]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[updSection] @UserId int, @Id int, @ShelfId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Sections SET shelfId = @ShelfId, registerUpdate = GETDATE()
	WHERE id = @Id
END;
GO
/****** Object:  StoredProcedure [dbo].[updShelf]    Script Date: 9/25/2023 11:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[updShelf] @UserId int, @Id int, @RackId int --no pongo valor por defecto, como es el unico dato a cargar lo tiene que cargar
AS
if (dbo.checkUserRole(@UserId,(SELECT id FROM Roles WHERE name = 'Admin')) = 1)
BEGIN
	UPDATE Shelves SET rackId = @RackId, registerUpdate = GETDATE()
	WHERE id = @Id
END;
GO
USE [master]
GO
ALTER DATABASE [AtlasBook] SET  READ_WRITE 
GO
