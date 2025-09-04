/*01, Simpel procedure uden parametre
Lav en procedure list_all_students() der henter 
og viser alle studerendes navne og deres tilknyttede 
programnavne fra Students og Programs tabellerne.*/
CREATE OR REPLACE PROCEDURE list_all_students()
LANGUAGE plpgsql
AS $$
BEGIN
   SELECT s.name AS studentName, p.name AS ProgramName
FROM "Students" s
JOIN "Programs" p ON s.programId = p.id
END;
$$;
--Dette fungerer ikke da stored procedures ikke kan returnere noget direkte
--Dette skulle være en function istedet


/*02, Procedure med 1 parameter
Lav en procedure list_students_by_program(program_id INT)
der tager et programId som parameter og viser alle studerendes
navne, der er tilknyttet det pågældende program.*/
--Igen, det skal være en funktion



/*03, Procedure med insert
Lav en procedure add_new_student(name VARCHAR, program_id INT)
der indsætter en ny studerende i Students tabellen med det givne
navn og programId.*/
CREATE OR REPLACE PROCEDURE add_new_student(p_name VARCHAR, program_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
INSERT INTO "Students"(name, programId) VALUES(p_name, program_id)
END;
$$;


/*04, Procedure med update
Lav en procedure update_student_program(student_id INT, new_program_id INT)
der opdaterer programId for en studerende baseret på deres studentId.*/
CREATE OR REPLACE PROCEDURE update_student_program(student_id INT, new_program_id INT)
    LANGUAGE plpgsql
AS $$
    BEGIN
    
    UPDATE "Students" S SET programid = new_program_id WHERE s.id = student_id;
    
    COMMIT;

    END;
$$;
