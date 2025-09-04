/*01, Antal studerende
Lav en funktion get_student_count(), der returnerer det totale antal studerende i Students tabellen.*/
CREATE FUNCTION get_student_count() RETURNS integer
AS 'SELECT COUNT(id) FROM "Students"'
    LANGUAGE sql;

/*02, Gennemsnitlig karakter for programs
Lav en funktion get_avg_grade(programId INT) der tager et programId som parameter og returnerer den gennemsnitlige karakter for alle eksamener i det pågældende program.*/
CREATE FUNCTION get_avg_grade(programId INT) RETURNS integer
AS 'SELECT AVG(grade) as "Grade Average" FROM "Exams" WHERE programId = $1'
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT;

/*03, Studerende på bestemt kursus
Lav en funktion get_students_on_course(course_id INT) der returnerer en tabel med navne på alle studerende, der er tilmeldt et bestemt kursus.

Er dette den mest optimale måde at udføre denne handling på?*/
CREATE FUNCTION get_students_on_course(course_id INT)
RETURNS TABLE(studentName VARCHAR)
LANGUAGE SQL
AS
'SELECT s.name AS studentName
FROM "Students" s
  JOIN "Programs" p ON p.id = s.programId
  JOIN "Courses" c ON c.programId = p.id
WHERE c.id = $1';

--Kunne godt være mere optimalt, hvis studernede er tilmeldt forskellige kurser, uden at det er det pågældende program de er på
CREATE FUNCTION get_students_on_course(course_id)
    RETURNS TABLE(studentName VARCHAR)
    RETURNS NULL ON NULL INPUT
    LANGUAGE SQL
AS '
    SELECT s."name"
    FROM "Courses" c
      LEFT JOIN "Enrollments" e ON c.id = e.courseid
      LEFT JOIN "Students" s ON e.studentid = s.id
    WHERE c.id = $1';
