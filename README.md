# Election Database Management System

A relational database project for modelling and managing the key entities and activities involved in a state-level election. The project uses **MySQL** to represent political parties, constituencies, candidates, voters, polling booths, votes, election officers, campaign events, and election results.

## Project Overview

The database is designed to support the storage and retrieval of election-related information while maintaining relationships and integrity constraints between entities.

The schema includes:

- Political parties and their leadership details
- Constituencies and polling-booth information
- Candidates, party affiliations, nominations, and contact numbers
- Voters, demographic details, and contact numbers
- Votes cast by voters at polling booths
- Election officers, reporting relationships, booth assignments, and family-member details
- Candidate campaign events and attendance
- Constituency-wise candidate results and winner status

## Database Schema

The SQL schema in `data.sql` creates the `ElectionDB` database and defines the following tables:

| Table | Purpose |
|---|---|
| `PoliticalParty` | Political party details, symbol, leadership, founder, and headquarters |
| `Constituency` | Constituency details, area, voter count, booth count, and district |
| `Candidate` | Candidate identity, age, party, constituency, ballot number, and nomination date |
| `CandidatePhone` | Candidate contact numbers (supports multiple numbers per candidate) |
| `Voter` | Voter identity and constituency association; enforces a minimum age of 18 |
| `VoterPhone` | Voter contact numbers (supports multiple numbers per voter) |
| `PollingBooth` | Polling-booth location, capacity, and constituency-specific booth number |
| `Vote` | Vote record linking a voter, candidate, and polling booth |
| `ElectionOfficer` | Officer details, reporting hierarchy, voter association, and constituency assignment |
| `OfficerBoothAssignment` | Junction table mapping officers to polling booths |
| `FamilyMember` | Family-member/dependent information associated with officers |
| `CampaignEvent` | Campaign events conducted by candidates in constituencies |
| `Result` | Candidate vote totals and winner status by constituency |

### Relationships and Constraints

The schema uses primary keys and foreign keys to connect election entities. It also demonstrates:

- **One-to-many relationships:** for example, a constituency can have multiple candidates and polling booths.
- **Many-to-many relationships:** officers and polling booths are connected through `OfficerBoothAssignment`.
- **One-to-one constraint:** `FamilyMember.officerId` is unique in the supplied schema.
- **Voting constraint:** `Vote.voterId` is unique, so a voter can have at most one vote record.
- **Age constraint:** `Voter.age` must be at least 18.
- **Composite keys:** used for `CandidatePhone`, `VoterPhone`, `OfficerBoothAssignment`, and `CampaignEvent`.
- **Booth uniqueness:** a booth number is unique within its constituency.

## Repository Contents

```text
Election-DataBase-Management-System/
├── README.md
├── Design document.pdf
├── data.sql
└── electionData.sql
```

### SQL Files

- **`data.sql`** — self-contained setup script. It drops and recreates `ElectionDB`, creates the tables, and inserts a smaller illustrative dataset.
- **`electionData.sql`** — a MySQL 8.0 database dump for the `stateElection` database, containing a larger dataset and table definitions.

The two scripts represent separate database setups. Choose the one you intend to use; do not assume they create the same database or contain identical records.

### Design Document

[`Design document.pdf`](./Design%20document.pdf) contains the database design documentation.

## Getting Started

### Prerequisites

- MySQL Server (MySQL 8.0 or compatible)
- MySQL command-line client or a GUI such as MySQL Workbench

### 1. Clone the repository

```bash
git clone https://github.com/Sindhuu1007/Election-DataBase-Management-System.git
cd Election-DataBase-Management-System
```

### 2. Create the database using `data.sql`

From the project directory, run:

```bash
mysql -u YOUR_USERNAME -p < data.sql
```

The script creates and selects the `ElectionDB` database automatically. It begins by dropping any existing database with that name, so **existing data in `ElectionDB` will be deleted**.

To connect and inspect the database:

```bash
mysql -u YOUR_USERNAME -p
```

Then execute:

```sql
USE ElectionDB;
SHOW TABLES;
```

### Alternative: Load the MySQL dump

To load the separate `stateElection` dataset instead:

```bash
mysql -u YOUR_USERNAME -p < electionData.sql
```

This dump targets the `stateElection` database. Review the dump before importing it into an environment containing data you need to preserve.

## Example Queries

Once `data.sql` has been imported, these queries can be used to explore the database.

### Candidates contesting in each constituency

```sql
SELECT
    c.constituencyName,
    CONCAT_WS(' ', ca.firstName, ca.middleName, ca.lastName) AS candidateName,
    p.partyShortName
FROM Candidate AS ca
JOIN Constituency AS c
    ON ca.constituencyId = c.constituencyId
LEFT JOIN PoliticalParty AS p
    ON ca.partyId = p.partyId
ORDER BY c.constituencyName, ca.ballotNumber;
```

### Total votes received by each candidate

```sql
SELECT
    ca.candidateId,
    CONCAT_WS(' ', ca.firstName, ca.middleName, ca.lastName) AS candidateName,
    COUNT(v.voteId) AS votesReceived
FROM Candidate AS ca
LEFT JOIN Vote AS v
    ON ca.candidateId = v.candidateId
GROUP BY ca.candidateId, ca.firstName, ca.middleName, ca.lastName
ORDER BY votesReceived DESC;
```

### Polling booths in each constituency

```sql
SELECT
    c.constituencyName,
    COUNT(pb.boothId) AS boothCount
FROM Constituency AS c
LEFT JOIN PollingBooth AS pb
    ON c.constituencyId = pb.constituencyId
GROUP BY c.constituencyId, c.constituencyName
ORDER BY c.constituencyName;
```

### Campaign events and attendance

```sql
SELECT
    eventName,
    location,
    eventDate,
    peopleAttended
FROM CampaignEvent
ORDER BY eventDate;
```

## Concepts Demonstrated

This project provides practical experience with:

- Relational database design and entity relationships
- Primary keys, foreign keys, and referential integrity
- Composite keys and junction tables
- Unique, check, and not-null constraints
- SQL data definition and data manipulation
- Joins, aggregation, grouping, and ordering
- Modelling real-world election administration data

## Notes and Limitations

- This repository contains database schema, sample records, a database dump, and a design document; it does not currently expose an application/API layer in the repository root.
- The sample SQL data is illustrative project data and should not be treated as official election results or a production voter register.
- The schema stores a vote-to-voter association but does not, by itself, provide a complete secure/electronic voting system. Production election systems require additional security, privacy, auditability, and access-control mechanisms.

## Author

**Sindhu**

[GitHub Repository](https://github.com/Sindhuu1007/Election-DataBase-Management-System)
