/*01, Simpelt View
Lav et view student_overview, der viser studentens navn, programnavn og programniveau.

Hint: JOIN mellem Students og Programs.*/
CREATE OR REPLACE VIEW student_overview AS
SELECT s."name" AS studentName, p."name" as ProgramName, p."level"
FROM "Students" s
JOIN "Programs" p ON p.id = s.Programid;

/*02, View med Filter
Lav et view failed_exams, der viser alle studenter og karakterer hvor karakteren er under 02.

Hint: Filtrér i view-definitionen.*/
CREATE OR REPLACE VIEW failed_exams AS
SELECT s."name", e."grade"
FROM "Students" s
JOIN "Exams" e ON e.studentId = s.id
WHERE e."grade" < 02;


/*03, Aggregeret View
Lav et view program_avg_grades, der viser hvert programnavn og dets gennemsnitlige karakter baseret på Exams.

Hint: Brug GROUP BY.*/
CREATE OR REPLACE VIEW program_avg_grades AS
SELECT p."name" AS programName, (SELECT AVG(e."grade") FROM "Exams" e WHERE e."programid" = p."id") AS averageGrade
FROM "Programs" p;
--WAIT OPGAVE SAGDE GROUP BY?? ER DET NØDVENDIGT? (Siden det kun er et hint)

/*04, View med join over flere tabeller
Lav et view course_enrollments, der viser kursusnavn, programnavn og antallet af studerende der er tilmeldt hvert kursus.

Hint: COUNT().*/
CREATE OR REPLACE VIEW course_enrollments AS
SELECT c.name AS courseName, p.name AS programName, (SELECT COUNT(*) FROM "Students" s WHERE s.programID = p.id) AS Enrollments
FROM "Courses" c
JOIN "Programs" p ON c.programId = p.id


/*05, Opdatering via View
Lav et view active_students der viser alle studerende der har bestået mindst én eksamen (karakter >= 02).

Prøv at opdatere en studerendes navn via dette view.

Undersøg betingelserne for at opdatere via views.*/

CREATE OR REPLACE VIEW active_students AS
SELECT DISTINCT s.name AS studentName
FROM "Students" s
JOIN "Exams" e ON s.id = e.studentId
WHERE e."grade" >= 2;

--Når jeg laver DISTINCT bliver view'et ikke opdaterbart, fordi databasen ikke kan vide præcist hvilken af de underliggende rækker der skal ændres

