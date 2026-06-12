-- ============================================================
--   STUDENT MANAGEMENT DATABASE - COMPLETE SQL SCRIPT
-- ============================================================

-- ============================================================
-- PART 1: DATABASE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS StudentManagement;
USE StudentManagement;

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- Create Students Table
CREATE TABLE students (
    StudentID   INT          PRIMARY KEY AUTO_INCREMENT,
    Name        VARCHAR(100) NOT NULL,
    Gender      CHAR(1)      NOT NULL,   -- 'M' or 'F'
    Age         INT          NOT NULL,
    Grade       VARCHAR(5)   NOT NULL,   -- e.g. '10A', '10B'
    MathScore   INT          NOT NULL,
    ScienceScore INT         NOT NULL,
    EnglishScore INT         NOT NULL
);

-- ============================================================
-- PART 2: INSERT DATA (15 students with variety)
-- ============================================================

INSERT INTO students (Name, Gender, Age, Grade, MathScore, ScienceScore, EnglishScore) VALUES
('Aarav Sharma',    'M', 16, '10A', 92, 88, 75),
('Priya Reddy',     'F', 15, '10B', 78, 82, 90),
('Rohan Mehta',     'M', 16, '10A', 65, 70, 68),
('Sneha Iyer',      'F', 15, '10B', 85, 91, 88),
('Vikram Nair',     'M', 17, '11A', 55, 60, 72),
('Ananya Gupta',    'F', 17, '11A', 95, 93, 97),
('Karan Singh',     'M', 16, '10A', 82, 76, 80),
('Divya Pillai',    'F', 15, '10B', 40, 45, 55),
('Arjun Rao',       'M', 17, '11B', 73, 68, 62),
('Meera Joshi',     'F', 16, '10A', 88, 84, 91),
('Siddharth Kumar', 'M', 17, '11B', 30, 38, 42),
('Lakshmi Devi',    'F', 16, '10B', 67, 72, 78),
('Nikhil Verma',    'M', 17, '11A', 90, 87, 83),
('Pooja Bhat',      'F', 15, '10A', 76, 80, 74),
('Rahul Desai',     'M', 17, '11B', 58, 63, 69);

-- ============================================================
-- PART 3: SQL QUERIES - BASIC
-- ============================================================

-- Q1: Show all student details
SELECT * FROM students;

-- Q2: Average score in each subject
SELECT
    ROUND(AVG(MathScore),    2) AS Avg_Math,
    ROUND(AVG(ScienceScore), 2) AS Avg_Science,
    ROUND(AVG(EnglishScore), 2) AS Avg_English
FROM students;

-- Q3: Top performer (highest total score)
SELECT
    StudentID,
    Name,
    MathScore + ScienceScore + EnglishScore AS TotalScore
FROM students
ORDER BY TotalScore DESC
LIMIT 1;

-- Q4: Count students per grade
SELECT Grade, COUNT(*) AS StudentCount
FROM students
GROUP BY Grade
ORDER BY Grade;

-- Q5: Average score by gender
SELECT
    Gender,
    ROUND(AVG(MathScore),    2) AS Avg_Math,
    ROUND(AVG(ScienceScore), 2) AS Avg_Science,
    ROUND(AVG(EnglishScore), 2) AS Avg_English,
    ROUND(AVG(MathScore + ScienceScore + EnglishScore), 2) AS Avg_Total
FROM students
GROUP BY Gender;

-- Q6: Students with Math > 80
SELECT StudentID, Name, Grade, MathScore
FROM students
WHERE MathScore > 80
ORDER BY MathScore DESC;

-- Q7: Update a student's grade (Vikram Nair promoted to 11B)
UPDATE students
SET Grade = '11B'
WHERE StudentID = 5;

-- Verify update
SELECT StudentID, Name, Grade FROM students WHERE StudentID = 5;

-- ============================================================
-- PART 4: EXTENDED DATABASE - COURSES & ENROLLMENTS
-- ============================================================

CREATE TABLE courses (
    id   INT          PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE enrollments (
    student_id INT NOT NULL,
    course_id  INT NOT NULL,
    grade      INT NOT NULL,          -- marks out of 100
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(StudentID),
    FOREIGN KEY (course_id)  REFERENCES courses(id)
);

-- Insert Courses
INSERT INTO courses (name) VALUES
('Mathematics'),
('Science'),
('English Literature'),
('Computer Science'),
('History');

-- Insert Enrollments (varied grades, some failing < 40)
INSERT INTO enrollments (student_id, course_id, grade) VALUES
-- Mathematics
(1,  1, 92), (2,  1, 78), (3,  1, 65), (4,  1, 85), (6,  1, 95),
(7,  1, 82), (10, 1, 88), (13, 1, 90),
-- Science
(1,  2, 88), (4,  2, 91), (5,  2, 35), (6,  2, 93), (8,  2, 45),
(9,  2, 68), (11, 2, 38), (14, 2, 80),
-- English Literature
(2,  3, 90), (4,  3, 88), (6,  3, 97), (7,  3, 80), (10, 3, 91),
(12, 3, 78), (15, 3, 69),
-- Computer Science
(1,  4, 95), (3,  4, 55), (6,  4, 98), (9,  4, 72), (11, 4, 30),
(13, 4, 87), (15, 4, 60),
-- History
(2,  5, 82), (5,  5, 48), (7,  5, 76), (8,  5, 33), (10, 5, 89),
(12, 5, 71), (14, 5, 74);

-- ============================================================
-- PART 5: EXTENDED QUERIES
-- ============================================================

-- Q8: List all students enrolled in each course
SELECT
    c.name        AS Course,
    s.Name        AS Student,
    s.Grade       AS Class,
    e.grade       AS Marks
FROM enrollments e
JOIN students s ON e.student_id = s.StudentID
JOIN courses  c ON e.course_id  = c.id
ORDER BY c.name, e.grade DESC;

-- Q9: Average grade per course
SELECT
    c.name                         AS Course,
    ROUND(AVG(e.grade), 2)         AS Avg_Grade,
    COUNT(e.student_id)            AS Enrolled_Students
FROM enrollments e
JOIN courses c ON e.course_id = c.id
GROUP BY c.id, c.name
ORDER BY Avg_Grade DESC;

-- Q10: Top 3 students overall (by average grade across all courses)
SELECT
    s.Name,
    ROUND(AVG(e.grade), 2) AS Avg_Grade,
    COUNT(e.course_id)     AS Courses_Taken
FROM enrollments e
JOIN students s ON e.student_id = s.StudentID
GROUP BY s.StudentID, s.Name
ORDER BY Avg_Grade DESC
LIMIT 3;

-- Q11: Count students who failed (grade < 40)
SELECT COUNT(DISTINCT student_id) AS Failed_Students
FROM enrollments
WHERE grade < 40;

-- ============================================================
-- PART 6: ADVANCED QUERIES (JOIN + GROUP BY + HAVING)
-- ============================================================

-- Q12: Top student per course
SELECT
    c.name    AS Course,
    s.Name    AS Top_Student,
    e.grade   AS Highest_Grade
FROM enrollments e
JOIN courses  c ON e.course_id  = c.id
JOIN students s ON e.student_id = s.StudentID
WHERE (e.course_id, e.grade) IN (
    SELECT course_id, MAX(grade)
    FROM enrollments
    GROUP BY course_id
)
ORDER BY c.name;

-- Q13: Pass rate per course (grade >= 40)
SELECT
    c.name                                                      AS Course,
    COUNT(e.student_id)                                         AS Total_Students,
    SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END)             AS Passed,
    SUM(CASE WHEN e.grade  < 40 THEN 1 ELSE 0 END)             AS Failed,
    ROUND(
        SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(e.student_id), 1
    )                                                           AS Pass_Rate_Pct
FROM enrollments e
JOIN courses c ON e.course_id = c.id
GROUP BY c.id, c.name
ORDER BY Pass_Rate_Pct DESC;

-- Q14: Overall topper across all courses (best single average)
SELECT
    s.Name,
    ROUND(AVG(e.grade), 2) AS Overall_Avg
FROM enrollments e
JOIN students s ON e.student_id = s.StudentID
GROUP BY s.StudentID, s.Name
ORDER BY Overall_Avg DESC
LIMIT 1;

-- Q15: Students enrolled in multiple courses (>= 2)
SELECT
    s.Name,
    COUNT(e.course_id)     AS Num_Courses,
    ROUND(AVG(e.grade), 2) AS Avg_Grade
FROM enrollments e
JOIN students s ON e.student_id = s.StudentID
GROUP BY s.StudentID, s.Name
HAVING COUNT(e.course_id) >= 2
ORDER BY Num_Courses DESC, Avg_Grade DESC;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
