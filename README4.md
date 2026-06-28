# SQL Data Analysis Internship – Task 4 README
**Maincrafts Technology | Generating Analytical Reports with Joins, Aggregations & Subqueries**

---

## Report Summaries

### Report 1 – Average Grade by Gender
Female students outperformed male students on average.
- **Female avg grade: 79.69**
- **Male avg grade: 53.33**

### Report 2 – Pass Rate per Course (Pass ≥ 40)
| Course           | Total | Passed | Pass Rate |
|------------------|-------|--------|-----------|
| History          | 3     | 3      | 100.00%   |
| English          | 5     | 5      | 100.00%   |
| Computer Science | 3     | 3      | 100.00%   |
| Mathematics      | 6     | 5      | 83.33%    |
| Science          | 5     | 4      | 80.00%    |

> History, English, and Computer Science had a 100% pass rate. Mathematics had 1 failing student (Frank, grade 33).

### Report 3 – Top 3 Students Overall
| Rank | Student | Avg Grade | Courses |
|------|---------|-----------|---------|
| 1 | Eva   | 85.50 | 4 |
| 2 | Carol | 83.67 | 3 |
| 3 | Alice | 82.33 | 3 |

> Eva is the top performer, enrolled in 4 courses with the highest average.

### Report 4 – Students in More Than 2 Courses
| Student | Courses Enrolled |
|---------|-----------------|
| Eva     | 4 |
| Alice   | 3 |
| Bob     | 3 |
| Carol   | 3 |
| Grace   | 3 |

> 5 out of 8 students are enrolled in more than 2 courses.

### Report 5 (Advanced) – Improvement from Sem1 → Sem2
| Student | Sem1 Avg | Sem2 Avg | Improvement |
|---------|----------|----------|-------------|
| Frank   | 37.50    | 66.00    | +28.50      |
| Bob     | 46.00    | 51.50    | +5.50       |

> Frank showed the most dramatic improvement (+28.5 points), going from near-failing to a comfortable pass in Sem2. Bob also improved by 5.5 points.
