--1
SELECT Forum.Nome, Forum.Descrição, Categoria.Nome, Categoria.Descrição FROM 
    Forum INNER JOIN Categoria ON Forum.RefIDCategoria = Categoria.IDCategoria 
    WHERE Forum.Bloqueado = 0

--2
SELECT Topico.IDTopico, Forum.IDForum, count(*) AS answers FROM 
    Resposta INNER JOIN Topico ON Resposta.RefIDTopico = Topico.IDTopico
    INNER JOIN Forum ON Forum.IDForum = Topico.RefIDForum
    GROUP BY Topico.IDTopico, Topico.IDForum

--3
CREATE TABLE messages(
    memberID INT NOT NULL,
    memberName VARCHAR(100) NOT NULL,
    message NTEXT,
    date DATETIME NOT NULL,
    PRIMARY KEY (memberID, date),
    FOREIGN KEY (memberID, memberName) REFERENCES Membro(IDMembro, Nome)
);

INSERT INTO messages
    SELECT Membro.ID, Membro.Nome, Resposta.Texto, Resposta.Data FROM
        Resposta INNER JOIN Membro ON Resposta.Autor = Membro.IDMembro

INSERT INTO messages
    SELECT Membro.IDMembro, Membro.Nome, Topico.Texto, Topico.Data FROM
        Topico INNER JOIN Membro ON Topico.Autor = Membro.IDMembro

SELECT memberName, message, date FROM messages ORDER BY memberName, date DESC

--4
UPDATE Topico
    SET Bloqueado = 1
    WHERE NumeroLeituras < 10;

--5
SELECT Topico.IDTopico, Topico.Titulo, MIN(Topico.NumeroLeituras) AS MinLeituras FROM
    Topico INNER JOIN Forum ON Topico.RefIDForum = Forum.IDForum
    INNER JOIN Categoria ON Forum.RefIDCategoria = Categoria.IDCategoria
    GROUP BY Categoria.IDCategoria, Topico.IDTopico, Topico.Titulo