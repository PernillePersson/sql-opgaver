/*01, Wallet Transfer Formål: Øve BEGIN/COMMIT/ROLLBACK, validering før commit.
Setup: Opret en tabel til “pengepunge” (fx pr. student). Indsæt testdata med forskellige saldi.
Krav Overfør X beløb fra A til B i én transaktion. Hvis saldo på A < X: rollback kun til savepoint
og afbryd; ellers commit hele transaktionen. Log en tekstbesked i en separat “transfer_log”-tabel
med status OK eller INSUFFICIENT_FUNDS inden commit/rollback.*/

--Setup: LAd os sige hver studerende kun kan have én wallet
create table "StudentWallet" (
  studentId int,
  balance int
  ); 

alter table "StudentWallet" add constraint pk_StudentWallet primary key (studentId);
alter table "StudentWallet" add constraint fk_Wallet_Students_id foreign key (studentId) references "Students"(id);

--Testdata: Starter alle på 200
insert into "StudentWallet" (studentId, balance) values 
  (1, 200),
  (2, 200),
  (3, 200),
  (4, 200),
  (5, 200),
  (6, 200);


-- Logtabel til statusbeskeder
CREATE TABLE "TransferLogs" (
    logTime Timestamp DEFAULT now(),
    fromStudentId int,
    toStudentId int,
    status varchar(255)
);

alter table "TransferLogs" add constraint fk_log_fromStudents_id foreign key (fromStudentId) references "Students"(id);
alter table "TransferLogs" add constraint fk_log_toStudents_id foreign key (toStudentId) references "Students"(id);

-- Transaction:
DO $$
BEGIN

UPDATE "StudentWallet" SET balance = balance - 50 WHERE studentid = 1;

UPDATE "StudentWallet" SET balance = balance + 50 WHERE studentid = 2;

IF ((SELECT balance FROM "StudentWallet" WHERE studentid = 1) < 0 ) THEN
    INSERT INTO "TransferLogs"(fromstudentid, tostudentid, status) VALUES 
    (1,2, 'INSUFFICIENT_FUNDS');
    
    RAISE EXCEPTION 'INSUFFICIENT_FUNDS';
ELSE
    INSERT INTO "TransferLogs"(fromstudentid, tostudentid, status) VALUES
        (1,2, 'AOKAY');
END IF;

COMMIT;
END $$;

/*02, Batch-tilmeldinger som stored procedure
Formål: Transaktion inde i en stored procedure + constraint-fejl som rollback-trigger.

Krav
Skriv en stored procedure enroll_many_on_course(course_id, ...) der forsøger at tilmelde flere studerende til samme kursus i én transaktion.
Regler:
Hvis en eneste tilmelding vil bryde en constraint (fx dublet i Enrollments eller student findes ikke), skal hele transaktionen rulles tilbage.
Ved succes: commit og returnér antal tilmeldte.
Ved fejl: rollback og returnér’ en klar fejlbesked.
Hint: I SQL Server brug TRY…CATCH med ROLLBACK; i PostgreSQL EXCEPTION-blok i plpgsql; i MySQL brug handler.*/

CREATE OR REPLACE PROCEDURE Enroll_many_on_course(courseId INT, studentIds INT[])
LANGUAGE plpgsql
AS $$
    DECLARE
    studentId INT;
    inserted_count INT := 0;
    
    BEGIN

    FOREACH studentId IN ARRAY studentIds LOOP
        
        INSERT INTO "Enrollments" (studentid, courseid) VALUES 
            (studentid, courseId);
        
        inserted_count := inserted_count + 1; 
    END LOOP;

EXCEPTION 
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Student % is already enrolled in course %', studentId, courseId;

    COMMIT;
    
    RAISE NOTICE 'Successfully inserted % students', inserted_count;
END;
$$;

--Call:
BEGIN;
CALL Enroll_many_on_course(2, ARRAY[2,3,4]);
COMMIT;

