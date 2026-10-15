-- ============================================================
-- SQL Data Analysis Internship - Task 4
-- Maincrafts Technology
-- Generating Analytical Reports with Joins, Aggregations, Subqueries
-- ============================================================

-- ============================================================
-- DATABASE SETUP (students, courses, enrollments)
-- ============================================================

CREATE TABLE students (
    id     INTEGER PRIMARY KEY,
    name   TEXT NOT NULL,
    gender TEXT NOT NULL
);

CREATE TABLE courses (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE enrollments (
    id         INTEGER PRIMARY KEY,
    student_id INTEGER,
    course_id  INTEGER,
    grade      INTEGER,
    semester   TEXT
);

-- Sample Data
INSERT INTO students VALUES
(1,'Alice','Female'),(2,'Bob','Male'),(3,'Carol','Female'),
(4,'David','Male'),(5,'Eva','Female'),(6,'Frank','Male'),
(7,'Grace','Female'),(8,'Henry','Male');

INSERT INTO courses VALUES
(1,'Mathematics'),(2,'Science'),(3,'English'),
(4,'History'),(5,'Computer Science');

INSERT INTO enrollments VALUES
(1,1,1,85,'Sem1'),(2,1,2,72,'Sem1'),(3,1,3,90,'Sem1'),
(4,2,1,45,'Sem1'),(5,2,2,38,'Sem1'),(6,2,3,55,'Sem1'),
(7,3,1,78,'Sem1'),(8,3,4,82,'Sem1'),(9,3,5,91,'Sem1'),
(10,4,2,60,'Sem1'),(11,4,3,74,'Sem1'),
(12,5,1,95,'Sem1'),(13,5,2,88,'Sem1'),(14,5,3,76,'Sem1'),(15,5,4,83,'Sem1'),
(16,6,1,33,'Sem1'),(17,6,5,42,'Sem1'),
(18,7,2,67,'Sem1'),(19,7,3,71,'Sem1'),(20,7,4,58,'Sem1'),
(21,8,1,50,'Sem1'),(22,8,5,63,'Sem1'),
(23,2,1,55,'Sem2'),(24,2,2,48,'Sem2'),
(25,6,1,62,'Sem2'),(26,6,5,70,'Sem2'),
(27,4,2,45,'Sem2'),(28,4,3,60,'Sem2');

-- ============================================================
-- REPORT 1: Average Grade by Gender
-- Compare male vs. female average grades across all courses
-- ============================================================
SELECT
    s.gender                  AS Gender,
    ROUND(AVG(e.grade), 2)   AS avg_grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
GROUP BY s.gender;

-- ============================================================
-- REPORT 2: Pass Rate per Course (Pass = grade >= 40)
-- Show each course with its pass percentage
-- ============================================================
SELECT
    c.name                                                                      AS course_name,
    COUNT(*)                                                                    AS total_students,
    SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END)                            AS passed,
    ROUND(
        100.0 * SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END) / COUNT(*), 2
    )                                                                           AS pass_rate_percent
FROM enrollments e
JOIN courses c ON e.course_id = c.id
WHERE e.semester = 'Sem1'
GROUP BY c.name
ORDER BY pass_rate_percent DESC;

-- ============================================================
-- REPORT 3: Top 3 Students Overall
-- Based on average grade across all enrolled courses
-- ============================================================
SELECT
    s.name                          AS student_name,
    ROUND(AVG(e.grade), 2)         AS avg_grade,
    COUNT(e.course_id)              AS courses_enrolled
FROM students s
JOIN enrollments e ON s.id = e.student_id
WHERE e.semester = 'Sem1'
GROUP BY s.id, s.name
ORDER BY avg_grade DESC
LIMIT 3;

-- ============================================================
-- REPORT 4: Students in Multiple Courses (more than 2)
-- ============================================================
SELECT
    s.name              AS student_name,
    COUNT(e.course_id)  AS num_courses
FROM students s
JOIN enrollments e ON s.id = e.student_id
WHERE e.semester = 'Sem1'
GROUP BY s.id, s.name
HAVING COUNT(e.course_id) > 2
ORDER BY num_courses DESC;

-- ============================================================
-- REPORT 5 (Advanced): Improvement Report
-- Students whose average grade improved from Sem1 to Sem2
-- ============================================================
SELECT
    s.name                                                                         AS student_name,
    ROUND(AVG(CASE WHEN e.semester = 'Sem1' THEN e.grade END), 2)                AS sem1_avg,
    ROUND(AVG(CASE WHEN e.semester = 'Sem2' THEN e.grade END), 2)                AS sem2_avg,
    ROUND(
        AVG(CASE WHEN e.semester = 'Sem2' THEN e.grade END) -
        AVG(CASE WHEN e.semester = 'Sem1' THEN e.grade END), 2
    )                                                                              AS improvement
FROM students s
JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name
HAVING sem2_avg IS NOT NULL AND improvement > 0
ORDER BY improvement DESC;
