CREATE DATABASE DemoDB;
GO

USE DemoDB;
GO

CREATE TABLE Departments (
    DepartmentId INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(50) NOT NULL,
    Location NVARCHAR(50) NOT NULL
);
GO

INSERT INTO Departments (DepartmentName, Location) VALUES 
('IT', 'Headquarters'),
('HR', 'Headquarters'),
('Finance', 'Headquarters'),
('Marketing', 'Regional Office'),
('Sales', 'Branch Office'),
('Research', 'Innovation Center'),
('Operations', 'Warehouse'),
('Customer Service', 'Headquarters');
GO

CREATE TABLE Employees (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    DepartmentId INT NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId)
);
GO

INSERT INTO Employees (Name, Position, DepartmentId, HireDate, Salary) VALUES 
('John Doe', 'Developer', 1, '2022-01-15', 70000.00),
('Jane Smith', 'Manager', 2, '2021-03-22', 85000.00),
('Alice Johnson', 'Analyst', 3, '2023-07-10', 60000.00),
('Bob Brown', 'Designer', 4, '2020-11-05', 65000.00),
('Charlie Davis', 'Developer', 1, '2019-05-30', 72000.00),
('Eve White', 'Manager', 5, '2022-09-18', 90000.00),
('Frank Black', 'Intern', 1, '2024-01-01', 40000.00),
('Grace Green', 'HR Assistant', 2, '2021-05-15', 45000.00),
('Henry Hall', 'Finance Manager', 3, '2020-12-01', 95000.00),
('Ivy Lewis', 'Marketing Specialist', 4, '2023-03-01', 55000.00),
('Jack King', 'Sales Executive', 5, '2019-07-25', 60000.00),
('Karen Adams', 'Customer Support', 8, '2022-08-01', 48000.00),
('Larry Martin', 'Research Scientist', 6, '2021-06-15', 80000.00),
('Mona Clark', 'Operations Supervisor', 7, '2020-10-10', 70000.00),
('Nina Carter', 'Product Manager', 4, '2023-02-20', 72000.00);
GO

CREATE TABLE Projects (
    ProjectId INT PRIMARY KEY IDENTITY(1,1),
    ProjectName NVARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Budget DECIMAL(15, 2) NOT NULL
);
GO

INSERT INTO Projects (ProjectName, StartDate, EndDate, Budget) VALUES 
('Website Redesign', '2023-01-15', '2023-06-15', 50000.00),
('Mobile App Development', '2023-02-01', NULL, 75000.00),
('Market Research', '2023-03-01', '2023-12-01', 30000.00),
('Data Migration', '2023-05-01', NULL, 60000.00),
('Customer Feedback System', '2023-04-01', '2023-09-30', 25000.00),
('Inventory Management System', '2023-06-01', NULL, 40000.00),
('Sales Data Analysis', '2023-08-01', '2024-01-01', 35000.00),
('HR Portal Development', '2023-07-15', NULL, 45000.00),
('New Product Launch', '2023-09-01', '2024-03-01', 100000.00),
('Social Media Campaign', '2023-10-01', '2024-01-01', 30000.00);
GO

CREATE TABLE EmployeeProjects (
    EmployeeId INT NOT NULL,
    ProjectId INT NOT NULL,
    PRIMARY KEY (EmployeeId, ProjectId),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(Id),
    FOREIGN KEY (ProjectId) REFERENCES Projects(ProjectId)
);
GO

INSERT INTO EmployeeProjects (EmployeeId, ProjectId) VALUES 
(1, 1),
(2, 3),
(3, 2),
(4, 1),
(5, 4),
(6, 2),
(7, 5),
(8, 6),
(9, 7),
(10, 8),
(11, 9),
(12, 10),
(13, 1),
(14, 3);
GO
