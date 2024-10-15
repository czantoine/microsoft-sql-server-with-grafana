USE DemoDB;

DECLARE @RandomId INT = ABS(CHECKSUM(NEWID())) % 10000;
DECLARE @RandomName NVARCHAR(50) = 'Employee ' + CONVERT(NVARCHAR(10), @RandomId);
DECLARE @RandomPosition NVARCHAR(50) = CASE 
    WHEN (ABS(CHECKSUM(NEWID())) % 2) = 0 THEN 'Developer' 
    ELSE 'Manager' 
END;

INSERT INTO Employees (Name, Position, DepartmentId, HireDate, Salary) VALUES 
(@RandomName, @RandomPosition, 1, GETDATE(), (ABS(CHECKSUM(NEWID())) % 100000) + 30000.00);

DECLARE @RandomProjectName NVARCHAR(100) = 'Project ' + CONVERT(NVARCHAR(10), @RandomId) + ' - ' + CAST(NEWID() AS NVARCHAR(36));
INSERT INTO Projects (ProjectName, StartDate, Budget) VALUES 
(@RandomProjectName, GETDATE(), (ABS(CHECKSUM(NEWID())) % 50000) + 15000.00);
