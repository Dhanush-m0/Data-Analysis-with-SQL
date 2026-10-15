-- ============================================================
--  STUDENT MANAGEMENT SYSTEM — Extended SQL Script
--  New tables: courses, enrollments + 4 new queries
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 1. EXTEND DATABASE
-- ──────────────────────────────────────────────────────────
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

CREATE TABLE enrollments (
    student_id INTEGER NOT NULL,
    course_id  INTEGER NOT NULL,
    grade      REAL    NOT NULL,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(StudentID),
    FOREIGN KEY (course_id)  REFERENCES courses(id)
);

-- ──────────────────────────────────────────────────────────
-- 2. INSERT COURSES
-- ──────────────────────────────────────────────────────────
INSERT INTO courses (name) VALUES
('Mathematics'), ('Science'), ('English'), ('Computer Science'), ('History');

-- ──────────────────────────────────────────────────────────
-- 3. INSERT ENROLLMENTS (48 records, varied grades)
-- ──────────────────────────────────────────────────────────
INSERT INTO enrollments (student_id, course_id, grade) VALUES
(1,1,88),(1,2,91),(1,3,95),(1,4,85),(1,5,78),
(2,1,72),(2,3,65),(2,4,58),(2,5,45),
(3,1,80),(3,2,76),(3,3,88),(3,5,62),
(4,1,95),(4,2,90),(4,4,92),(4,5,88),
(5,1,35),(5,2,70),(5,3,80),(5,5,55),
(6,1,28),(6,2,33),(6,3,55),(6,4,38),
(7,1,90),(7,2,94),(7,3,91),(7,4,88),(7,5,76),
(8,2,65),(8,3,72),(8,5,60),
(9,1,83),(9,3,89),(9,4,77),
(10,1,91),(10,2,85),(10,4,88),(10,5,80),
(11,1,36),(11,3,72),(11,5,58),
(12,1,60),(12,2,70),(12,4,55),(12,5,42);

-- ──────────────────────────────────────────────────────────
-- QUERY 1: All students enrolled in each course
-- ──────────────────────────────────────────────────────────
SELECT
    c.name          AS Course,
    s.StudentID     AS ID,
    s.Name          AS Student,
    s.Grade         AS SchoolGrade,
    e.grade         AS EnrollmentGrade
FROM enrollments e
JOIN courses  c ON c.id        = e.course_id
JOIN Students s ON s.StudentID = e.student_id
ORDER BY c.name, e.grade DESC;

-- ──────────────────────────────────────────────────────────
-- QUERY 2: Average grade per course
-- ──────────────────────────────────────────────────────────
SELECT
    c.name                   AS Course,
    COUNT(e.student_id)      AS Enrolled,
    ROUND(AVG(e.grade), 2)   AS Avg_Grade,
    MAX(e.grade)             AS Highest,
    MIN(e.grade)             AS Lowest
FROM enrollments e
JOIN courses c ON c.id = e.course_id
GROUP BY c.id
ORDER BY Avg_Grade DESC;

-- ──────────────────────────────────────────────────────────
-- QUERY 3: Top 3 students overall (by avg grade)
-- ──────────────────────────────────────────────────────────
SELECT
    s.StudentID,
    s.Name,
    s.Grade                  AS SchoolGrade,
    COUNT(e.course_id)       AS CoursesEnrolled,
    ROUND(AVG(e.grade), 2)   AS Avg_Grade,
    ROUND(SUM(e.grade), 2)   AS Total_Marks
FROM enrollments e
JOIN Students s ON s.StudentID = e.student_id
GROUP BY e.student_id
ORDER BY Avg_Grade DESC
LIMIT 3;

-- ──────────────────────────────────────────────────────────
-- QUERY 4: Students who failed (grade < 40)
-- ──────────────────────────────────────────────────────────
SELECT
    s.Name     AS Student,
    c.name     AS Course,
    e.grade    AS FailingGrade
FROM enrollments e
JOIN Students s ON s.StudentID = e.student_id
JOIN courses  c ON c.id        = e.course_id
WHERE e.grade < 40
ORDER BY e.grade ASC;

-- Failure summary
SELECT
    COUNT(*)                     AS Total_Failures,
    COUNT(DISTINCT e.student_id) AS Students_With_Failures,
    ROUND(AVG(e.grade), 2)       AS Avg_Failing_Grade
FROM enrollments e WHERE e.grade < 40;
