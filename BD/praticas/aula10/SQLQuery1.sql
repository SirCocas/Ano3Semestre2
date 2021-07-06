--CREATE SCHEMA company;

DROP TABLE company.dependent;
GO

DROP TABLE company.works_on;
GO

DROP TABLE company.project;
GO

DROP TABLE company.dept_locations;
GO

DROP TABLE company.employee;
GO
DROP TABLE company.department;
GO

CREATE TABLE company.department(
Dname VARCHAR(25),
Dnumber INT,
Mgr_ssn INT,
Mgr_start_date DATE,
PRIMARY KEY (Dnumber)
);

CREATE TABLE company.employee(
Fname VARCHAR(15),
Minit CHAR,
Lname VARCHAR(15),
SSN INT,
Bdate DATE,
Address VARCHAR(30),
Sex CHAR,
Salary DECIMAL(10,2),
Super_ssn INT,
Dno INT,
PRIMARY KEY (Ssn),
FOREIGN KEY (Super_ssn) REFERENCES company.employee(SSN),
FOREIGN KEY (Dno) REFERENCES company.department
);

CREATE TABLE company.dept_locations(
Dnumber INT NOT NULL,
DLocation VARCHAR(25) NOT NULL,
PRIMARY KEY (Dnumber, Dlocation),
FOREIGN KEY (Dnumber) REFERENCES company.department(Dnumber)
);

CREATE TABLE company.project(
Pname VARCHAR(25),
Pnumber INT NOT NULL,
Plocation VARCHAR(25),
Dnum INT,
PRIMARY KEY(Pnumber),
FOREIGN KEY (Dnum) REFERENCES company.department(Dnumber)
);

CREATE TABLE company.works_on(
Essn INT NOT NULL,
Pno INT NOT NULL,
Hours INT,
PRIMARY KEY (Essn, Pno),
FOREIGN KEY (Essn) REFERENCES company.employee(Ssn),
FOREIGN KEY (Pno) REFERENCES company.project(Pnumber)
);

CREATE TABLE company.dependent(
Essn INT NOT NULL,
Dependent_name VARCHAR(25),
Sex CHAR,
Bdate DATE,
Relationship VARCHAR(25),
PRIMARY KEY (Essn, Dependent_name),
FOREIGN KEY (Essn) REFERENCES company.employee(Ssn)
);


INSERT INTO company.department VALUES('Investigacao',1,21312332 ,'2010-08-02');
INSERT INTO company.department VALUES('Comercial',2,321233765,'2013-05-16');
INSERT INTO company.department VALUES('Logistica',3,41124234 ,'2013-05-16');
INSERT INTO company.department VALUES('Recursos Humanos', 4,12652121,'2014-04-02');
INSERT INTO company. department VALUES ('Desporto',5,NULL,NULL);

INSERT INTO company.employee VALUES ('Paula','A','Sousa',183623612,'2001-08-11','Rua da FRENTE','F',1450.00,NULL,3);
INSERT INTO company.employee VALUES('Carlos','D','Gomes',21312332 ,'2000-01-01','Rua XPTO','M',1200.00,NULL,1);
INSERT INTO company.employee VALUES('Juliana','A','Amaral',321233765,'1980-08-11','Rua BZZZZ','F',1350.00,NULL,3);
INSERT INTO company.employee VALUES('Maria','I','Pereira',342343434,'2001-05-01','Rua JANOTA','F',1250.00,21312332,2)
INSERT INTO company.employee VALUES('Joao','G','Costa',41124234 ,'2001-01-01','Rua YGZ','M',1300.00,21312332,2);
INSERT INTO company.employee VALUES('Ana','L','Silva',12652121 ,'1990-03-03','Rua ZIG ZAG','F',1400.00,21312332,2);

INSERT INTO company.dependent VALUES (21312332 ,'Maria Costa','F','1990-10-05','Neto');
INSERT INTO company.dependent VALUES (21312332 ,'Joana Costa','F','2008-04-01', 'Filho');
INSERT INTO company.dependent VALUES (21312332 ,'Rui Costa','M','2000-08-04','Neto');
INSERT INTO company.dependent VALUES (321233765,'Filho Lindo','M','2001-02-22','Filho');
INSERT INTO company.dependent VALUES (342343434,'Rosa Lima','F','2006-03-11','Filho');
INSERT INTO company.dependent VALUES (41124234 ,'Ana Sousa','F','2007-04-13','Neto');
INSERT INTO company.dependent VALUES (41124234 ,'Gaspar Pinto','M','2006-02-08','Sobrinho');

INSERT INTO company.dept_locations VALUES (2, 'Aveiro');
INSERT INTO company.dept_locations VALUES (3, 'Coimbra');

INSERT INTO company.project VALUES ('Aveiro Digital',1,'Aveiro',3);
INSERT INTO company.project VALUES ('BD Open Day',2,'Espinho',2);
INSERT INTO company.project VALUES ('Dicoogle',3,'Aveiro',3);
INSERT INTO company.project VALUES ('GOPACS',4,'Aveiro',3);


INSERT INTO company.works_on VALUES (183623612,1,20.0);
INSERT INTO company.works_on VALUES (183623612,3,10.0);
INSERT INTO company.works_on VALUES (21312332 ,1,20.0);
INSERT INTO company.works_on VALUES (321233765,1,25.0);
INSERT INTO company.works_on VALUES (342343434,1,20.0);
INSERT INTO company.works_on VALUES (342343434,4,25.0);
INSERT INTO company.works_on VALUES (41124234 ,2,20.0);
INSERT INTO company.works_on VALUES (41124234 ,3,30.0);


DROP PROC alineaB

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

EXEC alineaB

--alinea D:
--Crie um trigger que n�o permita que determinado funcion�rio tenha um vencimento superior ao vencimento do gestor do seu departamento. Nestes casos, o trigger deve ajustar o sal�rio do funcion�rio para um valor igual ao sal�rio do gestor menos uma unidade.
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
--Crie uma UDF que, para determinado departamento(dno), retorne os funcion�rios com um vencimento superior � m�dia dos vencimentos desse departamento;
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


SELECT * FROM company.employee
SELECT * FROM company.alineaF(3);



--alinea H:
--Pretende-se criar um trigger que, quando se elimina um departamento, este passe para uma tabela department_deleted com a mesma estrutura da department. 
--Caso esta tabela n�o exista ent�o deve criar uma nova e s� depois inserir o registo. 
--Implemente a  solu��o  com  um  trigger  de  cadatipo(after e instead of).
--Discuta  vantagens  e desvantagem de cada implementa��o.
--Utilize a seguinte instru��o para verificar se determinada tabela existe:IF (EXISTS(SELECT*FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='myschema' AND TABLE_NAME ='mytable'))

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
	--DELETE FROM company.department WHERE Dnumber IN (SELECT deleted.Dnumber FROM deleted)

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
Diferen�a entre as duas op��es: 
	o c�digo � similar em ambas, no entanto, na op��o do instead of � necess�rio correr o comando DELETE FROM
	em termos l�gicos, o AFTER ocorre num momento da execu��o que os valores j� foram eliminados, isto �, na recupera��o de um erro ser� necess�rio reintroduzi-los
	no INSTEAD OF, no entanto, caso o DELETE n�o seja vi�vel, este ser� cancelado, e n�o haver� complexidade acrescida
*/


INSERT INTO company.department VALUES ('teste', 6,NULL,NULL);

DELETE FROM company.department WHERE Dnumber=6
SELECT * FROM company.department
SELECT * FROM company.department_deleted