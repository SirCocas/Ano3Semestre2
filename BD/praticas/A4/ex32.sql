--every time a table is created we need to eliminate it to re-run the script
/*
CREATE SCHEMA voos;
go
*/

/*

DROP TABLE [voos.seat];
go
DROP TABLE [voos.leg instance];
go
DROP TABLE [voos.can land];
go
DROP TABLE [voos.airplane];
go
DROP TABLE [voos.airplane type];
go
DROP TABLE [voos.flight leg];
go
DROP TABLE [voos.fare];
go
DROP TABLE [voos.flight];
go
DROP TABLE [voos.airport];
go
*/

CREATE TABLE [voos.flight]
(
    [flight number] INT NOT NULL,
    [airline] VARCHAR(15) NOT NULL,
    [weekdays] VARCHAR(15) NOT NULL,
    CHECK( weekdays in ('Monday', 'Tuesday','Wednesday', 'Thursday','Friday', 'Saturday', 'Sunday')),
    PRIMARY KEY( [flight number])
);



CREATE TABLE [voos.fare]
(
    [fare code] INT NOT NULL,
    [flight number] INT NOT NULL,
    [amount] MONEY NOT NULL,
    [restrictions] VARCHAR(15),
    FOREIGN KEY ([flight number]) REFERENCES voos.flight([flight number]),
    CHECK(amount >0),
    PRIMARY KEY([fare code], [flight number]),
);




CREATE TABLE [voos.airport]
(
    [airport code] INT NOT NULL,
    [city] VARCHAR(25) NOT NULL,
    [airport name] VARCHAR(25) NOT NULL,
    [airport state] VARCHAR(25) NOT NULL,
    PRIMARY KEY([airport code])
);



CREATE TABLE [voos.flight leg]
(
    [flight number] INT NOT NULL,
    [leg number] INT NOT NULL,
    [departure airport] INT NOT NULL,
    [scheduled departure] TIME NOT NULL,
    [arrival airport] INT NOT NULL,
    [scheduled arrival] TIME NOT NULL,
    CHECK( [arrival airport] != [departure airport]),
    -- not checking if arrival happens later than departure as it could be an overnight flight (leaving Porto at 23:59 and arriving in Lisbon at 00:59)
    PRIMARY KEY ([flight number], [leg number]),
    FOREIGN KEY ([flight number]) REFERENCES voos.flight([flight number]),
    FOREIGN KEY ([departure airport]) REFERENCES [voos.airport]([airport code]),
    FOREIGN KEY ([arrival airport]) REFERENCES [voos.airport]([airport code])
);



CREATE TABLE [voos.airplane type]
(
    [type name] VARCHAR(25) NOT NULL,
    company VARCHAR(25) NOT NULL,
    [max seats] INT NOT NULL,
    PRIMARY KEY([type name])
);



CREATE TABLE [voos.can land]
(
    [airport code] INT NOT NULL,
    [type name] VARCHAR(25) NOT NULL,
    FOREIGN KEY ([airport code]) REFERENCES voos.airport([airport code]),
    FOREIGN KEY ([type name]) REFERENCES [voos.airplane type]([type name]),
    PRIMARY KEY([airport code], [type name])
);


--INSERT INTO [voos.can land] VALUES(1, 'biplane');

--INSERT INTO [voos.can land] VALUES(2, 'biplane');

SELECT * FROM [voos.can land]

CREATE TABLE [voos.airplane]
(
    [airplane ID] INT NOT NULL,
    [total number of seats] INT NOT NULL,
    [type] VARCHAR(25) NOT NULL,
    PRIMARY KEY([airplane ID]),
    FOREIGN KEY([type]) REFERENCES [voos.airplane type]([type name])
);


--INSERT INTO [voos.airplane] VALUES(1, 10, 'biplane');

SELECT * FROM [voos.airplane];


CREATE TABLE [voos.leg instance]
(
    [flight number] INT NOT NULL,
    [leg number] INT NOT NULL,
    [number of available seats] INT NOT NULL,
    [date] TIME NOT NULL,
    [departing from] INT NOT NULL,
    [departure time] TIME NOT NULL,
    [arriving at] INT NOT NULL,
    [arrival time] TIME NOT NULL,
    [assigned to] INT NOT NULL,
    PRIMARY KEY([date], [leg number], [flight number]),
    FOREIGN KEY([flight number], [leg number]) REFERENCES [voos.flight leg]([flight number], [leg number]),
    FOREIGN KEY([departing from]) REFERENCES [voos.airport]([airport code]),
    FOREIGN KEY([arriving at]) REFERENCES [voos.airport]([airport code]),
    FOREIGN KEY([assigned to]) REFERENCES [voos.airplane]([airplane ID]),
    CHECK([departing from]!=[arriving at])
);


--INSERT INTO [voos.leg instance] VALUES (1, 1, 10, '2021-04-13', 1, '12:00', 2, '13:00', '1');

SELECT * FROM [voos.leg instance];

CREATE TABLE [voos.seat]
(
    [flight number] INT NOT NULL,
    [leg number] INT NOT NULL,
    [seat number] INT NOT NULL,
    [date] TIME NOT NULL,
    [customer name] VARCHAR(25) NOT NULL,
    [customer phone number] VARCHAR(9) NOT NULL,
    PRIMARY KEY([seat number],[flight number], [leg number], [date]),
    FOREIGN KEY([date], [leg number],[flight number] ) REFERENCES [voos.leg instance]([date], [leg number],[flight number] ),
);


--INSERT INTO [voos.seat] VALUES (1, 1, 2, '2021-04-13', 'Gilberto', '12345');

SELECT * FROM [voos.seat];
