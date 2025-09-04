/*01, Scalar Subquery
Find alle studerende og vis samtidig gennemsnittet af alle eksamenskarakterer i databasen i en ekstra kolonne.

Hint: Brug en scalar subquery i SELECT.*/
SELECT name, (SELECT AVG(grade)
FROM "Exams") AS "Avg Grade"
FROM "Students";


/*02, Row Subquery
Find den studerende, hvis (id, programId) matcher (studentId, programId) for den bedst bedømte eksamen i hele databasen.

Hint: (a, b) = (SELECT x, y ...) i Postgres*/
SELECT s.*
FROM "Students" s
WHERE (s.id, s."programid") =
      (SELECT e."studentid", e."programid"
       FROM "Exams" e
       ORDER BY e.grade DESC
       LIMIT 1);

/*03, Table Subquery
Find navnene på de studerende, som er tilmeldt mindst ét kursus, hvor kurset hører til programmet "Multimediedesigner".

Hint: Subquery i WHERE ... IN (...).*/
SELECT name
FROM "Students"
WHERE programid IN (
    SELECT "id" FROM "Programs"
    WHERE name = 'Multimediedesigner'
);

/*04, Correlated Subquery
For hver studerende: vis deres navn og deres bedste karakter.

Hint: Correlated subquery i SELECT som refererer til Students.id.*/
SELECT
    s.Name,
    (SELECT MAX(e."grade") FROM "Exams" e WHERE e."studentid" = s."id")
FROM
    "Students" s;



