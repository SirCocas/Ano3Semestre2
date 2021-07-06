GO
--alinea B:
--Crie um stored procedure que retorne um record-set  
CREATE PROC alineaB	AS
	--com os funcion�rios gestores de departamentos,
	SELECT Fname, Lname, Dname, Ssn FROM company.department INNER JOIN company.employee ON company.department.Mgr_ssn = company.employee.Ssn;
	--assim como o ssn e n�mero de anos (como gestor) do funcion�rio mais antigo dessa lista.
	SELECT TOP 1 company.employee.Ssn, (DATEDIFF(year, company.department.Mgr_start_date, GETDATE())) AS Years
	FROM company.department INNER JOIN company.employee ON company.department.Mgr_ssn = company.employee.Ssn ORDER BY company.department.Mgr_start_date;
GO

--alinea D
GO
CREATE TRIGGER company.alineaD ON company.employee
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @employeeSalary AS INT;
	DECLARE @employeeDep AS INT;
	SELECT @employeeSalary = Salary, @employeeDep = Dno FROM inserted;
	DECLARE @maximum AS INT;
	SET @maximum = (SELECT TOP 1 company.employee.Salary FROM company.department INNER JOIN company.employee ON company.department.Mgr_ssn = company.employee.Ssn WHERE company.department.Dnumber LIKE @employeeDep ORDER BY company.employee.Salary ASC)
	-- if there are several department managers, we're taking into account the smallest income
	-- coalesce is used because if the department doesn't have a salary associated to its manager it'll return null (instead of 0)
	IF(COALESCE(@maximum, 0) < @employeeSalary)
	BEGIN
		DECLARE @employeeFname AS VARCHAR(15);
		DECLARE @employeeMinit AS CHAR;
		DECLARE @employeeLname VARCHAR(15);
		DECLARE @employeeSSN AS INT;
		DECLARE @employeeBdate AS DATE;
		DECLARE @employeeAddress AS VARCHAR(30);
		DECLARE @employeeSex AS CHAR;
		DECLARE @employeeSuper_ssn AS INT;
		SELECT @employeeFname = Fname, @employeeMinit = Minit, @employeeLname = Lname, @employeeSSN = SSN, @employeeBdate = Bdate, @employeeAddress = Address, @employeeSex = Sex,  @employeeSuper_ssn = Super_ssn  FROM inserted;
		INSERT INTO company.employee VALUES (@employeeFname, @employeeMinit, @employeeLname, @employeeSSN, @employeeBdate, @employeeAddress, @employeeSex, @maximum - 1, @employeeSuper_ssn, @employeeDep);
	END
	ELSE
		INSERT INTO company.employee SELECT * FROM inserted;
END
GO

GO
CREATE TRIGGER company.alineaDUpdate ON company.employee
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @employeeSalary AS INT;
	DECLARE @employeeDep AS INT;
	SELECT @employeeSalary = Salary, @employeeDep = Dno FROM inserted;
	DECLARE @maximum AS INT;
	SET @maximum = (SELECT TOP 1 company.employee.Salary FROM company.department INNER JOIN company.employee ON company.department.Mgr_ssn = company.employee.Ssn WHERE company.department.Dnumber LIKE @employeeDep ORDER BY company.employee.Salary ASC)
	DECLARE @employeeFname AS VARCHAR(15);
	DECLARE @employeeMinit AS CHAR;
	DECLARE @employeeLname VARCHAR(15);
	DECLARE @employeeSSN AS INT;
	DECLARE @employeeBdate AS DATE;
	DECLARE @employeeAddress AS VARCHAR(30);
	DECLARE @employeeSex AS CHAR;
	DECLARE @employeeSuper_ssn AS INT;
	SELECT @employeeFname = Fname, @employeeMinit = Minit, @employeeLname = Lname, @employeeSSN = SSN, @employeeBdate = Bdate, @employeeAddress = Address, @employeeSex = Sex,  @employeeSuper_ssn = Super_ssn  FROM inserted;
		
	-- if there are several department managers, we're taking into account the smallest income
	-- coalesce is used because if the department doesn't have a salary associated to its manager it'll return null (instead of 0)
	IF(COALESCE(@maximum, 0) < @employeeSalary)
	BEGIN
		UPDATE company.employee SET Fname = @employeeFname, Minit = @employeeMinit, Lname = @employeeLname, Bdate = @employeeBdate, Address = @employeeAddress, Sex = @employeeSex, Salary = @maximum - 1, Super_ssn = @employeeSuper_ssn, Dno = @employeeDep 
									WHERE SSN = @employeeSSN;
	END
	ELSE
		UPDATE company.employee SET Fname = @employeeFname, Minit = @employeeMinit, Lname = @employeeLname, Bdate = @employeeBdate, Address = @employeeAddress, Sex = @employeeSex, Salary = @employeeSalary, Super_ssn = @employeeSuper_ssn, Dno = @employeeDep 
									WHERE SSN = @employeeSSN;
END
GO




--alinea F:
GO
DROP FUNCTION company.alineaF;
GO
CREATE FUNCTION company.alineaF (@department int) RETURNS @table TABLE (Fname VARCHAR(15),
																		Minit CHAR,
																		Lname VARCHAR(15),
																		SSN INT,
																		Bdate DATE,
																		Address VARCHAR(30),
																		Sex CHAR,
																		Salary DECIMAL(10,2),
																		Super_ssn INT,
																		Dno INT)
AS
	BEGIN
		DECLARE @mean AS INT
		SET @mean = (SELECT avg(Salary) FROM company.employee WHERE Dno LIKE @department)
		INSERT @table SELECT * FROM company.employee WHERE Dno LIKE @department AND Salary>@mean
		RETURN;
	END;
GO




--alinea H:
GO
CREATE TRIGGER alineaHA ON company.department
AFTER DELETE
AS
	IF (NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'company' AND TABLE_NAME = 'department_deleted'))
		CREATE TABLE company.department_deleted(
								Dname VARCHAR(25),
								Dnumber INT,
								Mgr_ssn INT,
								Mgr_start_date DATE);
	INSERT INTO company.department_deleted SELECT * FROM deleted
GO

GO
CREATE TRIGGER alineaHB ON company.department
INSTEAD OF DELETE
AS
	IF (NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'company' AND TABLE_NAME = 'department_deleted'))
		CREATE TABLE company.department_deleted(
								Dname VARCHAR(25),
								Dnumber INT,
								Mgr_ssn INT,
								Mgr_start_date DATE);
	INSERT INTO company.department_deleted SELECT * FROM deleted
	DELETE FROM company.department WHERE Dnumber IN (SELECT deleted.Dnumber FROM deleted)
GO

/*
Diferenca entre as duas opcoes: 
	o codigo e similar em ambas, no entanto, na opcao do instead of e necessario correr o comando DELETE FROM
	em termos logicos, o AFTER ocorre num momento da execuaoo que os valores ja foram eliminados, isto e, na recuperacao de um erro sera necessario reintroduzi-los
	no INSTEAD OF, no entanto, caso o DELETE nao seja viavel, este sera cancelado, e nao havera complexidade acrescida
*/