--CREATE SCHEMA atl;


DROP TABLE [atl.presenca na atividade]
DROP TABLE [atl.atividade]
DROP TABLE [atl.presenca na turma]
DROP TABLE [atl.turma]
DROP TABLE [atl.autorizacao]
DROP TABLE [atl.aluno]
DROP TABLE [atl.adulto relacionado]
DROP TABLE [atl.professor]
DROP TABLE [atl.adulto]
DROP TABLE [atl.pessoa]



CREATE TABLE [atl.pessoa](
[cc] INT NOT NULL,
[nome] VARCHAR(25) NOT NULL,
[morada] VARCHAR(25) NOT NULL,
[data de nascimento] TIME NOT NULL,
PRIMARY KEY([cc])
);

INSERT INTO [atl.pessoa] VALUES (12345, 'child', 'rua sésamo', '2019-04-15')

INSERT INTO [atl.pessoa] VALUES(123, 'teacher', 'south park', '1960-04-15')

INSERT INTO [atl.pessoa] VALUES(1234, 'resp', 'south park', '1960-04-15')


SELECT * FROM [atl.pessoa]

CREATE TABLE [atl.adulto](
[contacto] INT NOT NULL,
[email] VARCHAR(25) NOT NULL,
[cc] INT NOT NULL,
FOREIGN KEY([cc]) REFERENCES [atl.pessoa]([cc]),
PRIMARY KEY([cc])
);

INSERT INTO	[atl.adulto] VALUES(93933,'asd@ua.pt', 123)

INSERT INTO [atl.adulto] VALUES(1234556,'dad@ua.pt', 1234)

SELECT * FROM [atl.adulto]

CREATE TABLE [atl.professor](
[numero funcionario] INT IDENTITY(1,1),
[cc] INT NOT NULL,
FOREIGN KEY ([cc]) REFERENCES [atl.adulto]([cc]),
UNIQUE([cc]),
PRIMARY KEY ([numero funcionario])
);

INSERT INTO [atl.professor] VALUES(123)

SELECT * FROM [atl.professor]

CREATE TABLE [atl.adulto relacionado](
[cc] INT NOT NULL,
[parentesco] VARCHAR(25) NOT NULL,
FOREIGN KEY ([cc]) REFERENCES [atl.adulto]([cc]),
PRIMARY KEY([cc])
);

INSERT INTO [atl.adulto relacionado] VALUES(1234, 'pai')

SELECT * FROM [atl.adulto relacionado]

CREATE TABLE [atl.aluno](
[encarregado de educacao] INT NOT NULL,
[cc] INT NOT NULL,
PRIMARY KEY ([cc]),
FOREIGN KEY([cc]) REFERENCES [atl.pessoa]([cc]),
FOREIGN KEY([encarregado de educacao]) REFERENCES [atl.adulto relacionado]([cc])
)

INSERT INTO [atl.aluno] VALUES(1234,12345)

SELECT * FROM [atl.aluno]

CREATE TABLE [atl.autorizacao](
[adulto] INT NOT NULL,
[aluno] INT NOT NULL,
PRIMARY KEY ([aluno], [adulto]),
FOREIGN KEY ([adulto]) REFERENCES [atl.adulto relacionado]([cc]),
FOREIGN KEY ([aluno]) REFERENCES [atl.aluno]([cc])
);

INSERT INTO [atl.autorizacao] VALUES (1234,12345)

SELECT * FROM [atl.autorizacao]

CREATE TABLE [atl.turma](
[professor] INT NOT NULL,
[maximo de alunos] INT NOT NULL,
[classe] INT NOT NULL,
[designacao] VARCHAR(25) NOT NULL,
[identificador] INT IDENTITY (1,1),
CHECK([classe] < 5),
CHECK([classe] > -1),
FOREIGN KEY ([professor]) REFERENCES [atl.professor]([numero funcionario]),
PRIMARY KEY ([identificador])
);

INSERT INTO [atl.turma] VALUES (1,31,4,'ilha das flores')
SELECT * FROM [atl.turma]

CREATE TABLE [atl.presenca na turma](
[aluno] INT NOT NULL,
[turma] INT NOT NULL,
PRIMARY KEY ([aluno], [turma]),
FOREIGN KEY ([aluno]) REFERENCES [atl.aluno]([cc]),
FOREIGN KEY ([turma]) REFERENCES [atl.turma]([identificador])
);

INSERT INTO [atl.presenca na turma] VALUES (12345,1)

SELECT * FROM [atl.presenca na turma]


CREATE TABLE [atl.atividade](
[identificador] INT NOT NULL,
[custo] MONEY NOT NULL,
--custo não é nullable mas poderá ser 0 (atividade gratuita)
[designacao] VARCHAR(25) NOT NULL,
CHECK(CUSTO>=0),
PRIMARY KEY ([identificador])
);

INSERT INTO [atl.atividade] VALUES (1,0,'danca')

SELECT * FROM [atl.atividade]

CREATE TABLE [atl.presenca na atividade](
[aluno] INT NOT NULL,
[atividade] INT NOT NULL,
PRIMARY KEY([aluno], [atividade]),
FOREIGN KEY ([aluno]) REFERENCES [atl.aluno]([cc]),
FOREIGN KEY ([atividade]) REFERENCES [atl.atividade]([identificador])
);

INSERT INTO [atl.presenca na atividade] VALUES(12345,1)

SELECT * FROM [atl.presenca na atividade]

CREATE TABLE [atl.disponibilidade](
[turma] INT NOT NULL,
[atividade] INT NOT NULL,
PRIMARY KEY([turma], [atividade]),
FOREIGN KEY([turma]) REFERENCES [atl.turma]([identificador]),
FOREIGN KEY([atividade]) REFERENCES [atl.atividade]([identificador])
);

INSERT INTO [atl.disponibilidade] VALUES(1,1)
SELECT * FROM [atl.disponibilidade]