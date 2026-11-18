-- =====================================
-- RESET DATABASE
-- =====================================
DROP DATABASE IF EXISTS ElectionDB;
CREATE DATABASE ElectionDB;
USE ElectionDB;

-- =====================================
-- TABLES
-- =====================================

CREATE TABLE PoliticalParty (
    partyId INT PRIMARY KEY,
    partyShortName VARCHAR(50),  
    partyFullName VARCHAR(150),  
    partySymbol VARCHAR(50),
    partyLeaderId INT,
    foundedYear INT,
    partyFounderId INT,
    headquarters VARCHAR(100)
);

CREATE TABLE Constituency (
    constituencyId INT PRIMARY KEY,
    constituencyName VARCHAR(100),
    areaSqKm FLOAT,
    totalVoters INT,
    numberOfPollingBooths INT,
    districtName VARCHAR(100)
);

CREATE TABLE Candidate (
    candidateId INT PRIMARY KEY,
    firstName VARCHAR(50),   
    middleName VARCHAR(50),
    lastName VARCHAR(50),
    dateOfBirth DATE,
    age INT,
    gender VARCHAR(10),
    partyId INT NULL,
    constituencyId INT,
    ballotNumber INT,  
    nominationDate DATE,      
    FOREIGN KEY (partyId) REFERENCES PoliticalParty(partyId),
    FOREIGN KEY (constituencyId) REFERENCES Constituency(constituencyId)
);

CREATE TABLE CandidatePhone (
    candidateId INT,
    phoneNumber VARCHAR(15),
    PRIMARY KEY (candidateId, phoneNumber),
    FOREIGN KEY (candidateId) REFERENCES Candidate(candidateId)
);

CREATE TABLE Voter (
    voterId INT PRIMARY KEY,
    firstName VARCHAR(50),       
    middleName VARCHAR(50),
    lastName VARCHAR(50),
    dateOfBirth DATE,
    age INT CHECK (age >= 18),
    gender VARCHAR(10),
    constituencyId INT,
    FOREIGN KEY (constituencyId) REFERENCES Constituency(constituencyId)
);

CREATE TABLE VoterPhone (
    voterId INT,
    phoneNumber VARCHAR(15),
    PRIMARY KEY (voterId, phoneNumber),
    FOREIGN KEY (voterId) REFERENCES Voter(voterId)
);

CREATE TABLE PollingBooth (
    boothId INT PRIMARY KEY,
    location VARCHAR(100),
    constituencyId INT,
    capacity INT,
    boothNumber INT,
	UNIQUE (constituencyId, boothNumber),
    FOREIGN KEY (constituencyId) REFERENCES Constituency(constituencyId)
);

CREATE TABLE Vote (
    voteId INT PRIMARY KEY,
    voterId INT UNIQUE,
    candidateId INT,
    boothId INT,
    timestamp DATETIME,
    FOREIGN KEY (voterId) REFERENCES Voter(voterId),
    FOREIGN KEY (candidateId) REFERENCES Candidate(candidateId),
    FOREIGN KEY (boothId) REFERENCES PollingBooth(boothId)
);

CREATE TABLE ElectionOfficer (
    officerId INT PRIMARY KEY,
    firstName VARCHAR(50),     
    middleName VARCHAR(50),
    lastName VARCHAR(50),
    designation VARCHAR(50),
    reportsTo INT,
    voterId INT,
    assignedConstituency INT,
    FOREIGN KEY (assignedConstituency) REFERENCES Constituency(constituencyId),
    FOREIGN KEY (reportsTo) REFERENCES ElectionOfficer(officerId),
    FOREIGN KEY (voterId) REFERENCES Voter(voterId)
);

-- Junction table for M:N Officer <-> PollingBooth (assignedToBooths)
CREATE TABLE OfficerBoothAssignment (
    officerId INT,
    boothId INT,
    PRIMARY KEY (officerId, boothId),
    FOREIGN KEY (officerId) REFERENCES ElectionOfficer(officerId),
    FOREIGN KEY (boothId) REFERENCES PollingBooth(boothId)
);

CREATE TABLE FamilyMember (
    ID INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    relation VARCHAR(50),
    officerId INT UNIQUE, 
    FOREIGN KEY (officerId) REFERENCES ElectionOfficer(officerId)
);

CREATE TABLE CampaignEvent (
    eventId INT,
    candidateId INT,
    eventName VARCHAR(100),
    location VARCHAR(100),
    constituencyId INT,
    eventDate DATE,
    peopleAttended INT,
    PRIMARY KEY (eventId, candidateId),
    FOREIGN KEY (candidateId) REFERENCES Candidate(candidateId),
    FOREIGN KEY (constituencyId) REFERENCES Constituency(constituencyId)
);

CREATE TABLE Result (
    resultId INT PRIMARY KEY,
    candidateId INT,
    constituencyId INT,
    totalVotes INT,
    constituencyVotes INT,
    winnerStatus VARCHAR(20),
    FOREIGN KEY (candidateId) REFERENCES Candidate(candidateId),
    FOREIGN KEY (constituencyId) REFERENCES Constituency(constituencyId)
);

-- =====================================
-- DATA INSERTION
-- =====================================

-- Parties (FIX 1: partyName split into shortName + fullName)
INSERT INTO PoliticalParty VALUES
(1,'INC','Indian National Congress','Hand',101,1885,201,'New Delhi'),
(2,'BRS','Bharat Rashtra Samithi','Car',102,2001,202,'Hyderabad'),
(3,'BJP','Bharatiya Janata Party','Lotus',103,1980,203,'New Delhi');

-- Constituencies
INSERT INTO Constituency VALUES
(1,'Kamareddy',210,220000,250,'Kamareddy'),
(2,'Gajwel',180,210000,230,'Siddipet'),
(3,'Karimnagar',150,250000,270,'Karimnagar'),
(4,'Nizamabad Urban',130,200000,220,'Nizamabad'),
(5,'Warangal West',170,240000,260,'Warangal'),
(6,'Adilabad',300,180000,200,'Adilabad'),
(7,'Mahabubnagar',220,230000,240,'Mahabubnagar'),
(8,'Khammam',190,260000,280,'Khammam');

-- Candidates (FIX 1: name split; FIX 6: ballotNumber + nominationDate added)
INSERT INTO Candidate VALUES
(1,'A Revanth','','Reddy','1969-11-08',55,'Male',1,1,1,'2024-10-01'),
(2,'K Chandrashekar','','Rao','1954-02-17',70,'Male',2,1,2,'2024-10-01'),
(3,'Independent','','Rao','1970-01-01',54,'Male',NULL,1,3,'2024-10-02'),
(4,'Etela','','Rajender','1964-03-20',60,'Male',3,2,1,'2024-10-01'),
(5,'K Chandrashekar','','Rao','1954-02-17',70,'Male',2,2,2,'2024-10-01'),
(13,'Independent','','Kumar','1980-01-01',44,'Male',NULL,2,3,'2024-10-02'),
(6,'Bandi Sanjay','','Kumar','1971-07-11',53,'Male',3,3,1,'2024-10-01'),
(7,'Congress','Candidate','K','1975-05-05',49,'Male',1,3,2,'2024-10-01'),
(8,'Sudhakar','','Reddy','1978-02-02',46,'Male',1,4,1,'2024-10-01'),
(9,'BRS Candidate','','N','1976-06-06',48,'Male',2,4,2,'2024-10-01'),
(15,'BJP Candidate','','X','1985-05-05',39,'Male',3,4,3,'2024-10-01'),
(10,'Harish','','Rao','1972-06-03',52,'Male',2,5,1,'2024-10-01'),
(11,'BJP Candidate','','W','1980-03-03',44,'Male',3,5,2,'2024-10-01'),
(14,'Congress Candidate','','W','1977-07-07',47,'Female',1,5,3,'2024-10-01'),
(12,'Congress Candidate','','A','1982-08-08',42,'Male',1,6,1,'2024-10-01'),
(16,'BRS Candidate','','Y','1983-03-03',41,'Female',2,6,2,'2024-10-01'),
(17,'Congress Candidate','','M','1980-01-01',44,'Male',1,7,1,'2024-10-01'),
(18,'BRS Candidate','','M','1978-02-02',46,'Male',2,7,2,'2024-10-01'),
(19,'Independent','','Mahesh','1985-03-03',39,'Male',NULL,7,3,'2024-10-02'),
(20,'BJP Candidate','','K','1982-04-04',42,'Male',3,8,1,'2024-10-01'),
(21,'Congress Candidate','','K','1979-05-05',45,'Female',1,8,2,'2024-10-01'),
(22,'Independent','','Kavitha','1990-06-06',34,'Female',NULL,8,3,'2024-10-02');

-- Candidate phone numbers
INSERT INTO CandidatePhone VALUES
(1,'9876543210'), (1,'9123456780'),
(2,'9988776655'),
(3,'9000000001'),
(4,'9876501234'),
(5,'9888800000'),
(13,'9111111111'),
(6,'9777700000'),
(7,'9666600000'),
(8,'9555500000'),
(9,'9444400000'),
(15,'9333300000'),
(10,'9222200000'),
(11,'9111100000'),
(14,'9000012345'),
(12,'8888800000'),
(16,'8777700000'),
(17,'8666600000'),
(18,'8555500000'),
(19,'8444400000'),
(20,'8333300000'),
(21,'8222200000'),
(22,'8111100000');

-- Voters (FIX 1: name split into firstName, middleName, lastName)
INSERT INTO Voter VALUES
(1,'Ramesh','','Kumar','1990-01-01',35,'Male',1),
(2,'Lakshmi','','Devi','1985-05-12',40,'Female',1),
(3,'Suresh','','Yadav','1992-03-10',33,'Male',2),
(4,'Anitha','','Reddy','1998-07-20',27,'Female',2),
(5,'Rahul','','Sharma','1995-09-09',30,'Male',3),
(6,'Priya','','Singh','1999-12-12',26,'Female',3),
(7,'Kiran','','Kumar','1988-04-04',37,'Male',4),
(8,'Sunita','','Devi','1993-08-18',32,'Female',5),
(9,'Arun','','Patel','1991-11-11',34,'Male',6),
(10,'Meena','','Kumari','1994-04-14',31,'Female',6),
(11,'Vikram','','Reddy','1991-02-02',34,'Male',1),
(12,'Pooja','','Sharma','1996-06-06',29,'Female',1),
(13,'Ravi','','Teja','1989-09-09',36,'Male',2),
(14,'Deepika','','Rao','1997-07-07',28,'Female',2),
(15,'Manoj','','Kumar','1993-03-03',32,'Male',3),
(16,'Sneha','','Gupta','2000-10-10',25,'Female',3),
(17,'Ajay','','Singh','1987-05-05',38,'Male',4),
(18,'Kavya','','Reddy','1999-11-11',26,'Female',4),
(19,'Sanjay','','Verma','1992-12-12',33,'Male',5),
(20,'Nisha','','Patel','1998-08-08',27,'Female',5),
(21,'Harish','','Kumar','1990-02-02',34,'Male',1),
(22,'Divya','','Sharma','1997-03-03',27,'Female',2),
(23,'Rohit','','Reddy','1993-04-04',31,'Male',3),
(24,'Swathi','','Devi','1998-05-05',26,'Female',4),
(25,'Karthik','','Rao','1991-06-06',33,'Male',5),
(26,'Anjali','','Gupta','1999-07-07',25,'Female',6),
(27,'Mahesh','','Reddy','1991-01-01',34,'Male',7),
(28,'Sowmya','','','1995-02-02',29,'Female',7),
(29,'Rakesh','','','1992-03-03',32,'Male',7),
(30,'Kavitha','','','1993-04-04',31,'Female',8),
(31,'Pradeep','','','1989-05-05',35,'Male',8),
(32,'Anusha','','','1998-06-06',26,'Female',8);

-- Voter phone numbers
INSERT INTO VoterPhone VALUES
(1,'9000011111'), (1,'9000011112'),
(2,'9000022222'),
(3,'9000033333'),
(4,'9000044444'), (4,'9000044445'),
(5,'9000055555'),
(6,'9000066666'),
(7,'9000077777'),
(8,'9000088888'),
(9,'9000099999'),
(10,'9010000000'),
(11,'9011111111'),
(12,'9012222222'),
(13,'9013333333'),
(14,'9014444444'),
(15,'9015555555'),
(16,'9016666666'),
(17,'9017777777'),
(18,'9018888888'),
(19,'9019999999'),
(20,'9020000000'),
(21,'9021111111'),
(22,'9022222222'),
(23,'9023333333'),
(24,'9024444444'),
(25,'9025555555'),
(26,'9026666666'),
(27,'9027777777'),
(28,'9028888888'),
(29,'9029999999'),
(30,'9030000000'),
(31,'9031111111'),
(32,'9032222222');

-- Booths
INSERT INTO PollingBooth VALUES
(1,'School Kamareddy',1,800,101),
(2,'Hall Gajwel',2,700,102),
(3,'School Karimnagar',3,900,103),
(4,'College Nizamabad',4,750,104),
(5,'Hall Warangal',5,850,105),
(6,'Adilabad Center',6,600,106),
(7,'Kamareddy Booth 2',1,750,107),
(8,'Gajwel Booth 2',2,650,108),
(9,'Karimnagar Booth 2',3,800,109),
(10,'Nizamabad Booth 2',4,700,110),
(11,'Warangal Booth 2',5,820,111),
(12,'Kamareddy Booth 3',1,700,112),
(13,'Gajwel Booth 3',2,650,113),
(14,'Karimnagar Booth 3',3,850,114),
(15,'Nizamabad Booth 3',4,750,115),
(16,'Mahabubnagar Booth 1',7,800,116),
(17,'Mahabubnagar Booth 2',7,750,117),
(18,'Khammam Booth 1',8,850,118),
(19,'Khammam Booth 2',8,800,119);

-- Votes
INSERT INTO Vote VALUES
(1,1,1,1,NOW()),(2,2,2,1,NOW()),
(3,3,4,2,NOW()),(4,4,5,2,NOW()),
(5,5,6,3,NOW()),(6,6,6,3,NOW()),
(7,7,8,4,NOW()),(8,8,10,5,NOW()),
(9,9,12,6,NOW()),(10,10,12,6,NOW()),
(11,11,1,7,NOW()),(12,12,2,7,NOW()),
(13,13,4,8,NOW()),(14,14,5,8,NOW()),
(15,15,6,9,NOW()),(16,16,7,9,NOW()),
(17,17,8,10,NOW()),(18,18,9,10,NOW()),
(19,19,10,11,NOW()),(20,20,11,11,NOW()),
(21,21,1,12,NOW()),(22,22,4,13,NOW()),
(23,23,6,14,NOW()),(24,24,8,15,NOW()),
(25,25,10,11,NOW()),(26,26,12,6,NOW()),
(27,27,17,16,NOW()),(28,28,18,16,NOW()),
(29,29,19,17,NOW()),
(30,30,20,18,NOW()),(31,31,21,18,NOW()),
(32,32,22,19,NOW());

-- Officers (FIX 1: name split into firstName, middleName, lastName)
INSERT INTO ElectionOfficer VALUES
(1,'Raju','','Officer','Returning Officer',NULL,1,1),
(2,'Meena','','Officer','Assistant',1,2,2),
(3,'Khan','','Officer','Supervisor',1,3,3),
(4,'Rao','','Officer','Supervisor',2,4,4),
(5,'Das','','Officer','Assistant',3,5,5),
(6,'Kumar','','Officer','Supervisor',1,6,7),
(7,'Priya','','Officer','Assistant',2,7,8);

-- FIX 4: Officer-Booth assignments (M:N junction table)
INSERT INTO OfficerBoothAssignment VALUES
(1,1),(1,7),(1,12),
(2,2),(2,8),(2,13),
(3,3),(3,9),(3,14),
(4,4),(4,10),(4,15),
(5,5),(5,11),
(6,16),(6,17),
(7,18),(7,19);

-- Family members (FIX 2: officerId is UNIQUE — only one dependent per officer)
INSERT INTO FamilyMember VALUES
(1,'Sita',45,'Spouse',1),
(2,'Arjun',20,'Child',2),
(3,'Sara',18,'Child',3),
(4,'Rani',40,'Spouse',6),
(5,'Rahul',18,'Child',7);

-- Campaign Events
INSERT INTO CampaignEvent VALUES
(1,1,'Congress Rally','Kamareddy',1,'2024-11-20',20000),
(2,2,'BRS Rally','Kamareddy',1,'2024-11-18',25000),
(3,4,'BJP Rally','Gajwel',2,'2024-11-22',15000),
(4,6,'BJP Rally','Karimnagar',3,'2024-11-25',18000),
(5,10,'BRS Rally','Warangal',5,'2024-11-26',22000),
(6,1,'Youth Rally','Kamareddy College',1,'2024-11-15',12000),
(7,13,'Independent Rally','Gajwel Village',2,'2024-11-21',8000),
(8,14,'Women Rally','Warangal',5,'2024-11-24',17000),
(9,15,'BJP Youth Meet','Nizamabad',4,'2024-11-23',14000),
(10,17,'Congress Rally Mahabubnagar','Mahabubnagar Ground',7,'2024-11-20',15000),
(11,18,'BRS Rally Mahabubnagar','Mahabubnagar Center',7,'2024-11-21',18000),
(12,20,'BJP Rally Khammam','Khammam Stadium',8,'2024-11-22',20000),
(13,22,'Independent Meet','Khammam Town',8,'2024-11-23',7000);

-- Results
INSERT INTO Result VALUES
(1,1,1,80000,150000,'Winner'),
(2,2,1,70000,150000,'Not Winner'),
(3,5,2,95000,160000,'Winner'),
(4,6,3,110000,200000,'Winner'),
(5,8,4,75000,180000,'Winner'),
(6,10,5,120000,210000,'Winner'),
(7,12,6,60000,140000,'Winner'),
(8,3,1,20000,150000,'Not Winner'),
(9,13,2,20000,160000,'Not Winner'),
(10,14,5,85000,210000,'Not Winner'),
(11,15,4,60000,180000,'Not Winner'),
(12,16,6,50000,140000,'Not Winner'),
(13,17,7,90000,170000,'Winner'),
(14,18,7,70000,170000,'Not Winner'),
(15,19,7,10000,170000,'Not Winner'),
(16,20,8,95000,180000,'Winner'),
(17,21,8,70000,180000,'Not Winner'),
(18,22,8,15000,180000,'Not Winner');
