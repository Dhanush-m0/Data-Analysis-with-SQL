-- =====================================================
-- SQL Data Analysis Internship - Task 3
-- Complex queries: JOIN, GROUP BY, HAVING, Subqueries
-- Compatible with SQLite / MySQL / DB Fiddle
-- =====================================================

-- ---------- SETUP (from Task 1 & 2) ----------
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE courses (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE enrollments (
    student_id INTEGER,
    course_id  INTEGER,
    grade      INTEGER,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id)  REFERENCES courses(id)
);

INSERT INTO students (id, name) VALUES
(1,'Aarav'),(2,'Priya'),(3,'Rohan'),(4,'Sneha'),
(5,'Kiran'),(6,'Meera'),(7,'Arjun'),(8,'Divya');

INSERT INTO courses (id, name) VALUES
(1,'SQL'),(2,'Python'),(3,'Statistics'),(4,'Excel');

INSERT INTO enrollments (student_id, course_id, grade) VALUES
(1,1,85),(1,2,72),(1,3,38),
(2,1,92),(2,2,88),
(3,1,35),(3,4,60),
(4,2,95),(4,3,67),(4,4,44),
(5,1,40),(5,3,55),
(6,2,30),
(7,3,78),(7,4,91),
(8,4,52);

-- ---------- QUERY 1: Top student per course ----------
-- Subquery finds each course's max grade; JOIN returns the student(s).
-- (Handles ties; the plain MAX + GROUP BY starter can pair the wrong student.)
SELECT c.name AS course, s.name AS student, e.grade AS top_grade
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses  c ON e.course_id  = c.id
WHERE e.grade = (SELECT MAX(e2.grade)
                 FROM enrollments e2
                 WHERE e2.course_id = e.course_id)
ORDER BY c.name;

-- ---------- QUERY 2: Pass rate per course (grade >= 40) ----------
SELECT c.name AS course,
       COUNT(*) AS total_students,
       SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END) AS passed,
       COUNT(*) - SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END) AS failed,
       ROUND(SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pass_rate_pct
FROM enrollments e
JOIN courses c ON e.course_id = c.id
GROUP BY c.name
ORDER BY pass_rate_pct DESC;

-- ---------- QUERY 3: Overall topper across all courses ----------
-- 3a) Highest single grade
SELECT s.name AS student, c.name AS course, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses  c ON e.course_id  = c.id
WHERE e.grade = (SELECT MAX(grade) FROM enrollments);

-- 3b) Highest average grade (fairer overall measure)
SELECT s.name AS student,
       ROUND(AVG(e.grade), 2) AS avg_grade,
       COUNT(*) AS courses_taken
FROM enrollments e
JOIN students s ON e.student_id = s.id
GROUP BY s.id, s.name
HAVING AVG(e.grade) = (SELECT MAX(avg_g)
                       FROM (SELECT AVG(grade) AS avg_g
                             FROM enrollments
                             GROUP BY student_id) t);

-- ---------- QUERY 4: Students enrolled in multiple courses ----------
SELECT s.name AS student,
       COUNT(e.course_id) AS total_courses
FROM enrollments e
JOIN students s ON e.student_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(e.course_id) > 1
ORDER BY total_courses DESC, s.name;

-- ---------- BONUS: Student ranking by average grade ----------
-- (Window function: SQLite 3.25+, MySQL 8+)
SELECT s.name AS student,
       ROUND(AVG(e.grade), 2) AS avg_grade,
       RANK() OVER (ORDER BY AVG(e.grade) DESC) AS overall_rank
FROM enrollments e
JOIN students s ON e.student_id = s.id
GROUP BY s.id, s.name;
