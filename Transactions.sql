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
create table transfer_log (
    id serial primary key,
    from_student int not null,
    to_student int not null,
    amount int not null,
    status text not null,
    created_at timestamp default now()
);

-- Eksempel på en overførsel
BEGIN;

-- Sæt et savepoint så vi kan rulle tilbage hertil ved valideringsfejl
SAVEPOINT before_transfer;

-- Definer parametre (kun til demo – i praksis kommer de fx fra en app)
-- Vi vil flytte 150 fra student 1 til student 2
DO $$
DECLARE
    from_id int := 1;
    to_id int := 2;
    amount int := 150;
    current_balance int;
BEGIN
    -- Tjek saldo på afsender
    SELECT balance INTO current_balance
    FROM "StudentWallet"
    WHERE "studentId" = from_id
    FOR UPDATE; -- låser rækken i transaktionen

    IF current_balance < amount THEN
        -- Ikke nok penge → rollback til savepoint
        ROLLBACK TO SAVEPOINT before_transfer;

        -- Log fejlstatus
        INSERT INTO transfer_log (from_student, to_student, amount, status)
        VALUES (from_id, to_id, amount, 'INSUFFICIENT_FUNDS');
    ELSE
        -- Nok penge → gennemfør opdateringer
        UPDATE "StudentWallet"
        SET balance = balance - amount
        WHERE "studentId" = from_id;

        UPDATE "StudentWallet"
        SET balance = balance + amount
        WHERE "studentId" = to_id;

        -- Log succes
        INSERT INTO transfer_log (from_student, to_student, amount, status)
        VALUES (from_id, to_id, amount, 'OK');
    END IF;
END;
$$;

COMMIT;


/*02, Batch-tilmeldinger som stored procedure
Formål: Transaktion inde i en stored procedure + constraint-fejl som rollback-trigger.

Krav
Skriv en stored procedure enroll_many_on_course(course_id, ...) der forsøger at tilmelde flere studerende til samme kursus i én transaktion.
Regler:
Hvis en eneste tilmelding vil bryde en constraint (fx dublet i Enrollments eller student findes ikke), skal hele transaktionen rulles tilbage.
Ved succes: commit og returnér antal tilmeldte.
Ved fejl: rollback og returnér’ en klar fejlbesked.
Hint: I SQL Server brug TRY…CATCH med ROLLBACK; i PostgreSQL EXCEPTION-blok i plpgsql; i MySQL brug handler.*/

--Måske en løsning:
CREATE OR REPLACE PROCEDURE enroll_many_on_course(p_course_id int, p_student_ids int[])
LANGUAGE plpgsql
AS $$
DECLARE
    stu int;
    inserted_count int := 0;
BEGIN
    -- Start eksplicit transaktion
    BEGIN
        FOREACH stu IN ARRAY p_student_ids LOOP
            INSERT INTO Enrollments(student_id, course_id)
            VALUES (stu, p_course_id);
            inserted_count := inserted_count + 1;
        END LOOP;

        -- Commit hvis alle lykkes
        COMMIT;
        RAISE NOTICE 'Enrolled % students on course %', inserted_count, p_course_id;

    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback hvis noget fejler
            ROLLBACK;
            RAISE NOTICE 'Enrollment failed: %', SQLERRM;
    END;
END;
$$;
