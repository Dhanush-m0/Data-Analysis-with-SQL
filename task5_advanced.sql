-- =====================================================================
-- SQL Data Analysis Internship - Task 5 : task5_advanced.sql
-- Window functions, CTEs and Views on the academic schema
-- Works on SQLite 3.25+, MySQL 8+, PostgreSQL
-- (Views use DROP VIEW IF EXISTS + CREATE VIEW so they run on all three.)
-- =====================================================================

-- ============================ SETUP ==================================
DROP VIEW  IF EXISTS vw_student_progress;
DROP VIEW  IF EXISTS vw_student_ranking;
DROP VIEW  IF EXISTS vw_course_stats;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id     INTEGER PRIMARY KEY,
    name   VARCHAR(50) NOT NULL,
    gender VARCHAR(10)
);

CREATE TABLE courses (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE enrollments (
    student_id INTEGER,
    course_id  INTEGER,
    grade      INTEGER,
    semester   VARCHAR(10),            -- sortable, e.g. '2025-01'
    PRIMARY KEY (student_id, course_id, semester),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id)  REFERENCES courses(id)
);

INSERT INTO students (id, name, gender) VALUES
(1,'Aarav','M'),(2,'Priya','F'),(3,'Rohan','M'),(4,'Sneha','F'),
(5,'Kiran','M'),(6,'Meera','F'),(7,'Arjun','M'),(8,'Divya','F');

INSERT INTO courses (id, name) VALUES
(1,'SQL'),(2,'Python'),(3,'Statistics'),(4,'Excel');

INSERT INTO enrollments (student_id, course_id, grade, semester) VALUES
-- SQL
(1,1,70,'2025-01'),(1,1,85,'2025-02'),
(2,1,90,'2025-01'),(2,1,94,'2025-02'),
(3,1,35,'2025-01'),(3,1,48,'2025-02'),
(5,1,40,'2025-01'),(5,1,60,'2025-02'),
(7,1,85,'2025-02'),
-- Python
(1,2,72,'2025-01'),(1,2,80,'2025-02'),
(2,2,88,'2025-01'),(2,2,84,'2025-02'),
(4,2,95,'2025-01'),(4,2,90,'2025-02'),
(6,2,30,'2025-01'),(6,2,45,'2025-02'),
(8,2,65,'2025-02'),
-- Statistics
(1,3,38,'2025-01'),(1,3,52,'2025-02'),
(4,3,67,'2025-01'),(4,3,71,'2025-02'),
(5,3,55,'2025-01'),(5,3,50,'2025-02'),
(7,3,78,'2025-01'),(7,3,82,'2025-02'),
(8,3,60,'2025-01'),
-- Excel
(3,4,60,'2025-01'),(3,4,66,'2025-02'),
(4,4,44,'2025-01'),(4,4,58,'2025-02'),
(7,4,91,'2025-01'),(7,4,89,'2025-02'),
(8,4,52,'2025-01'),(8,4,70,'2025-02'),
(6,4,48,'2025-02');


-- ==================== QUERY 1: Top 3 students per course ==============
-- RANK() over each course by a student's average grade; ties share a rank.
WITH student_course_avg AS (
    SELECT e.course_id,
           c.name  AS course_name,
           e.student_id,
           s.name  AS student_name,
           ROUND(AVG(e.grade), 2) AS avg_grade
    FROM enrollments e
    JOIN students s ON s.id = e.student_id
    JOIN courses  c ON c.id = e.course_id
    GROUP BY e.course_id, c.name, e.student_id, s.name
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY course_id ORDER BY avg_grade DESC) AS rnk
    FROM student_course_avg
)
SELECT course_name, student_name, avg_grade, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY course_name, rnk, avg_grade DESC;


-- ============ QUERY 2: Percentile / quartile banding per course =======
-- PERCENT_RANK() = relative standing (0..1); NTILE(4) = quartile (4 = top).
WITH course_scores AS (
    SELECT e.course_id,
           c.name  AS course_name,
           e.student_id,
           s.name  AS student_name,
           ROUND(AVG(e.grade), 2) AS avg_grade
    FROM enrollments e
    JOIN students s ON s.id = e.student_id
    JOIN courses  c ON c.id = e.course_id
    GROUP BY e.course_id, c.name, e.student_id, s.name
)
SELECT course_name,
       student_name,
       avg_grade,
       ROUND(PERCENT_RANK() OVER (PARTITION BY course_id ORDER BY avg_grade), 2) AS pct_rank,
       NTILE(4) OVER (PARTITION BY course_id ORDER BY avg_grade)                 AS quartile
FROM course_scores
ORDER BY course_name, pct_rank;


-- ========= QUERY 3: Running (cumulative) average per student ==========
-- Time-series table: semester average and running average to date.
WITH student_sem_avg AS (
    SELECT e.student_id,
           s.name AS student_name,
           e.semester,
           AVG(e.grade) AS sem_avg
    FROM enrollments e
    JOIN students s ON s.id = e.student_id
    GROUP BY e.student_id, s.name, e.semester
)
SELECT student_name,
       semester,
       ROUND(sem_avg, 2) AS sem_avg,
       ROUND(AVG(sem_avg) OVER (
             PARTITION BY student_id
             ORDER BY semester
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_avg,
       ROUND(sem_avg - LAG(sem_avg) OVER (PARTITION BY student_id ORDER BY semester), 2) AS change_vs_prev_sem
FROM student_sem_avg
ORDER BY student_name, semester;


-- ======= QUERY 4: Student vs course benchmark by semester (CTE chain) =
WITH course_sem_avg AS (
    SELECT e.course_id,
           c.name AS course_name,
           e.semester,
           AVG(e.grade) AS course_avg
    FROM enrollments e
    JOIN courses c ON c.id = e.course_id
    GROUP BY e.course_id, c.name, e.semester
),
student_sem_avg AS (
    SELECT e.course_id,
           e.student_id,
           s.name AS student_name,
           e.semester,
           AVG(e.grade) AS student_avg
    FROM enrollments e
    JOIN students s ON s.id = e.student_id
    GROUP BY e.course_id, e.student_id, s.name, e.semester
)
SELECT s.student_name AS student,
       c.course_name  AS course,
       s.semester,
       ROUND(s.student_avg, 2)                AS student_avg,
       ROUND(c.course_avg, 2)                 AS course_avg,
       ROUND(s.student_avg - c.course_avg, 2) AS delta
FROM student_sem_avg s
JOIN course_sem_avg  c
  ON c.course_id = s.course_id AND c.semester = s.semester
ORDER BY c.course_name, s.semester, delta DESC;


-- ========================= QUERY 5: VIEWS =============================
-- View 1: course-level aggregates
CREATE VIEW vw_course_stats AS
SELECT c.id   AS course_id,
       c.name AS course_name,
       ROUND(AVG(e.grade), 2) AS avg_grade,
       MIN(e.grade)           AS min_grade,
       MAX(e.grade)           AS max_grade,
       COUNT(*)               AS assessments,
       COUNT(DISTINCT e.student_id) AS students
FROM enrollments e
JOIN courses c ON c.id = e.course_id
GROUP BY c.id, c.name;

-- View 2: ranking of every student within each course
-- (average across all semesters, plus the latest semester they were graded)
CREATE VIEW vw_student_ranking AS
WITH sc AS (
    SELECT e.course_id,
           e.student_id,
           AVG(e.grade)    AS avg_grade,
           MAX(e.semester) AS last_semester
    FROM enrollments e
    GROUP BY e.course_id, e.student_id
),
r AS (
    SELECT sc.*,
           RANK() OVER (PARTITION BY sc.course_id ORDER BY sc.avg_grade DESC) AS rnk
    FROM sc
)
SELECT c.name AS course_name,
       s.name AS student_name,
       ROUND(r.avg_grade, 2) AS avg_grade,
       r.rnk,
       r.last_semester
FROM r
JOIN students s ON s.id = r.student_id
JOIN courses  c ON c.id = r.course_id;

-- View 3 (bonus): student progress over time
CREATE VIEW vw_student_progress AS
WITH sem AS (
    SELECT e.student_id, e.semester, AVG(e.grade) AS sem_avg
    FROM enrollments e
    GROUP BY e.student_id, e.semester
)
SELECT s.name AS student_name,
       sem.semester,
       ROUND(sem.sem_avg, 2) AS sem_avg,
       ROUND(AVG(sem.sem_avg) OVER (PARTITION BY sem.student_id ORDER BY sem.semester
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_avg
FROM sem
JOIN students s ON s.id = sem.student_id;

-- ---- Test the views ----
SELECT * FROM vw_course_stats ORDER BY course_name;

SELECT * FROM vw_student_ranking ORDER BY course_name, rnk, student_name;

SELECT * FROM vw_student_progress ORDER BY student_name, semester;
