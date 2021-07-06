/*
CREATE SCHEMA hospital;
GO
*/
DROP TABLE [hospital.composicao]
GO
DROP TABLE [hospital.venda]
GO
DROP TABLE [hospital.farmaco]
GO
DROP TABLE [hospital.farmaceutica]
GO
DROP TABLE [hospital.prescricao]
GO
DROP TABLE [hospital.farmacia]
GO
DROP TABLE [hospital.paciente]
GO
DROP TABLE [hospital.medico]
GO

CREATE TABLE [hospital.medico](
[numero SNS] INT NOT NULL,
[nome] VARCHAR(25) NOT NULL,
[especialidade] VARCHAR(25) NOT NULL,
PRIMARY KEY ([numero SNS])
);

INSERT INTO [hospital.medico] VALUES(777,'Gilberto Gil', 'cardiologia')

SELECT * FROM [hospital.medico]

CREATE TABLE [hospital.paciente](
[numero utente] INT NOT NULL,
[nome] VARCHAR(25) NOT NULL,
[data de nascimento] TIME NOT NULL,
[endereco] VARCHAR(25) NOT NULL,
PRIMARY KEY ([numero utente])
);

INSERT INTO [hospital.paciente] VALUES(777, 'outro gilberto gil', '2000-01-11', 'rua da universidade n17')

SELECT * FROM [hospital.paciente]

CREATE TABLE [hospital.farmacia](
[NIF] INT NOT NULL,
[nome] VARCHAR(25) NOT NULL,
[endereco] VARCHAR(25) NOT NULL,
[telefone] INT NOT NULL,
PRIMARY KEY([NIF])
);

INSERT INTO [hospital.farmacia] VALUES (123,'farmacia nova', 'rua das farmacias n8', '123456')
SELECT * FROM [hospital.farmacia]


CREATE TABLE [hospital.prescricao](
[numero de prescricao] INT NOT NULL,
[data criacao] TIME NOT NULL,
[medico associado] INT NOT NULL,
[paciente associado] INT NOT NULL,
[data de processamento] TIME,
[farmacia] INT,
-- dados referentes ao processamento surgem como nullable porque, ao passar a prescricao, nao se tem maneira de saber quando sera e onde sera processada
PRIMARY KEY([numero de prescricao]),
FOREIGN KEY ([medico associado]) REFERENCES [hospital.medico]([numero SNS]),
FOREIGN KEY([paciente associado]) REFERENCES [hospital.paciente]([numero utente]),
FOREIGN KEY([farmacia]) REFERENCES [hospital.farmacia]([NIF])
);

INSERT INTO [hospital.prescricao] VALUES(1, '2021-04-14', 777, 777, NULL, NULL)

SELECT * FROM [hospital.prescricao]

CREATE TABLE [hospital.farmaceutica](
[numero de registo nacional] INT NOT NULL,
[nome] VARCHAR(25) NOT NULL,
[endereco] VARCHAR(25) NOT NULL,
[telefone] INT NOT NULL,
--nao temos em conta +351 porque esses dados sao assumidos do endereco
PRIMARY KEY([numero de registo nacional])
);

INSERT INTO [hospital.farmaceutica] VALUES (1, 'pharma','US, COLORADO', 12345)

SELECT * FROM [hospital.farmaceutica]

CREATE TABLE [hospital.farmaco](
[formula] VARCHAR(25) NOT NULL,
[nome comercial] VARCHAR(25) NOT NULL,
[nome de producao] VARCHAR(25) NOT NULL,
[farmaceutica] INT NOT NULL,
PRIMARY KEY([formula]),
UNIQUE([nome de producao]),
FOREIGN KEY([farmaceutica]) REFERENCES [hospital.farmaceutica]([numero de registo nacional])
);

INSERT INTO [hospital.farmaco] VALUES ('C2O3', 'brufen', 'brf', 1)
INSERT INTO [hospital.farmaco] VALUES ('C2O4', 'brufen2', 'brf2', 1)


SELECT * FROM [hospital.farmaco]

CREATE TABLE [hospital.venda](
[farmacia] INT NOT NULL,
[farmaco] VARCHAR(25) NOT NULL,
PRIMARY KEY ([farmacia], [farmaco]),
FOREIGN KEY ([farmacia]) REFERENCES [hospital.farmacia]([NIF]),
FOREIGN KEY ([farmaco]) REFERENCES [hospital.farmaco]([formula])
);

INSERT INTO [hospital.venda] VALUES(1, 'C2O3')

SELECT * FROM [hospital.venda]

CREATE TABLE [hospital.composicao](
[prescricao] INT NOT NULL,
[farmaco] VARCHAR(25) NOT NULL,
PRIMARY KEY([prescricao], [farmaco]),
FOREIGN KEY([prescricao]) REFERENCES [hospital.prescricao]([numero de prescricao]),
FOREIGN KEY ([farmaco]) REFERENCES [hospital.farmaco]([formula])
);


INSERT INTO [hospital.composicao] VALUES(1,'C2O3')
INSERT INTO [hospital.composicao] VALUES(1, 'C2O4')


SELECT * FROM [hospital.composicao]
