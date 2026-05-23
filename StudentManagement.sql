DROP TABLE IF EXISTS Students;

CREATE TABLE Students (
    StudentID    INTEGER PRIMARY KEY AUTOINCREMENT,  -- PK, auto-increment
    Name         TEXT    NOT NULL,
    Gender       TEXT    NOT NULL CHECK(Gender IN ('Male','Female')),
    Age          INTEGER NOT NULL,
    Grade        TEXT    NOT NULL,
    MathScore    REAL    NOT NULL,
    ScienceScore REAL    NOT NULL,
    EnglishScore REAL    NOT NULL
);


2. INSERT DATA (12 varied records)

INSERT INTO Students (Name, Gender, Age, Grade, MathScore, ScienceScore, EnglishScore) VALUES
('Alice Johnson',   'Female', 16, '10', 92, 88, 95),
('Bob Smith',       'Male',   17, '11', 78, 82, 70),
('Clara Davis',     'Female', 15,  '9', 85, 79, 88),
('David Lee',       'Male',   18, '12', 95, 91, 87),
('Emma Wilson',     'Female', 16, '10', 65, 72, 80),
('Frank Brown',     'Male',   17, '11', 55, 60, 58),
('Grace Martinez',  'Female', 15,  '9', 88, 94, 91),
('Henry Taylor',    'Male',   18, '12', 76, 68, 74),
('Isabella Thomas', 'Female', 16, '10', 83, 77, 89),
('James White',     'Male',   17, '11', 91, 85, 82),
('Karen Harris',    'Female', 15,  '9', 70, 66, 75),
('Liam Robinson',   'Male',   18, '12', 60, 73, 65);

3a. SHOW ALL STUDENT DETAILS

SELECT StudentID, Name, Gender, Age, Grade,
       MathScore, ScienceScore, EnglishScore,
       ROUND(MathScore + ScienceScore + EnglishScore, 2) AS TotalScore
FROM Students
ORDER BY StudentID;


3b. AVERAGE SCORE IN EACH SUBJECT

SELECT
    ROUND(AVG(MathScore),    2) AS Avg_Math,
    ROUND(AVG(ScienceScore), 2) AS Avg_Science,
    ROUND(AVG(EnglishScore), 2) AS Avg_English
FROM Students;


3c. TOP PERFORMER (highest total score)

SELECT StudentID, Name, Grade,
       MathScore, ScienceScore, EnglishScore,
       ROUND(MathScore + ScienceScore + EnglishScore, 2) AS TotalScore
FROM Students
ORDER BY TotalScore DESC
LIMIT 1;

3d. COUNT STUDENTS PER GRADE

SELECT Grade, COUNT(*) AS StudentCount
FROM Students
GROUP BY Grade
ORDER BY Grade;

3e. AVERAGE SCORE BY GENDER

SELECT Gender,
    ROUND(AVG(MathScore),    2) AS Avg_Math,
    ROUND(AVG(ScienceScore), 2) AS Avg_Science,
    ROUND(AVG(EnglishScore), 2) AS Avg_English,
    ROUND(AVG(MathScore + ScienceScore + EnglishScore), 2) AS Avg_Total
FROM Students
GROUP BY Gender;

3f. STUDENTS WITH MATH > 80

SELECT StudentID, Name, Grade, MathScore
FROM Students
WHERE MathScore > 80
ORDER BY MathScore DESC;

3g. UPDATE A STUDENT'S GRADE (Frank Brown: Grade 11 → 12)

UPDATE Students
SET Grade = '12'
WHERE Name = 'Frank Brown';

Verify the update
SELECT StudentID, Name, Grade
FROM Students
WHERE Name = 'Frank Brown';
