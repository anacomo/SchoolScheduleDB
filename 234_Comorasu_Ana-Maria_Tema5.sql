---------------------
-- Comorasu Ana-Maria 234
-- Tema 5
---------------------
-- Ex 1
SET SERVEROUTPUT ON;
DECLARE
TYPE st_cod IS TABLE OF emp_aco.employee_id%TYPE  
INDEX BY PLS_INTEGER;
TYPE st_salarii IS TABLE OF emp_aco.salary%TYPE;
coduri st_cod;
salarii st_salarii;

BEGIN
    SELECT employee_id, salary
    BULK COLLECT INTO coduri, salarii
    FROM
        (SELECT *
        FROM emp_aco
        ORDER BY SALARY)
    WHERE ROWNUM <= 5;
    
    FOR i IN 1..5 LOOP
    UPDATE emp_aco
        SET salary = salary * 1.05
        WHERE employee_id = coduri(i);
    DBMS_OUTPUT.PUT
    (coduri(i) || ' ' || salarii(i) || ' ' || salarii(i)*1.05);
    END LOOP;
END;
/
ROLLBACK;

-- ex 2
CREATE OR REPLACE TYPE tip_orase_aco IS TABLE OF VARCHAR(20);
/
CREATE TABLE excursie_aco (
    cod_excursie NUMBER(4), 
    denumire VARCHAR(20), 
    STATUS varchar(12)
    );
ALTER TABLE excursie_aco
ADD (orase tip_orase_aco)
NESTED TABLE orase STORE AS tabel_orase_aco;

-- a)
INSERT INTO excursie_aco
VALUES (1, 
        'UK', 
        'AVAILABLE',  
        tip_orase_aco('London', 'Hogwarts', 'Platform 9 3/4', 'Hogsmeade', 'Diagon Alley')
        );
INSERT INTO excursie_aco
VALUES (2, 
        'ROMA', 
        'ANULLED',  
        tip_orase_aco('Rome', 'Vatican', 'Torino', 'Firenze', 'Gardaland')
        );
INSERT INTO excursie_aco
VALUES (3, 
        'ROMANIA', 
        'AVAILABLE',  
        tip_orase_aco('Bucharest', 'Cluj', 'Constanta', 'Timisoara', 'Iasi')
        );
INSERT INTO excursie_aco
VALUES (4, 
        'EUROPE', 
        'AVAILABLE',  
        tip_orase_aco('Berlin', 'Helsinki', 'Oslo', 'Moscow', 'Paris')
        );
INSERT INTO excursie_aco
VALUES (5, 
        'ASIA', 
        'AVAILABLE',  
        tip_orase_aco('Tokyo', 'Beijing', 'Dubai', 'Shanghai', 'Hong Kong')
        );
COMMIT;
/
SELECT * 
FROM excursie_aco;
/

-- b)
DECLARE
    t tip_orase_aco := tip_orase_aco();
    nume_exc varchar2(20) := &exc;
BEGIN
    SELECT orase
    INTO t
    FROM excursie_aco
    WHERE denumire = nume_exc;
    t.extend;
    t(t.count):= &nume_oras;
UPDATE excursie_aco  
    SET orase = t
    WHERE denumire = nume_exc;
END;
/
ROLLBACK;

---------------
DECLARE  
    t1 tip_orase_aco := tip_orase_aco(); 
    t2 tip_orase_aco := tip_orase_aco();
    nume_exc varchar2(20) := &exc;
BEGIN
    SELECT orase
    INTO t1
    FROM excursie_aco
    WHERE denumire = nume_exc;

    FOR i IN 1..t1.COUNT LOOP 
        t2.EXTEND;
            IF i < 2 THEN 
                t2(i):= t1(i);
            END IF;
        IF i = 2 THEN
            t2(i) := &nume_oras;
            t2.EXTEND;
            t2(i+1) := t1(i);
        END IF;
        IF i > 2 THEN
            t2(i+1) := t1(i);
        END IF;
    END LOOP;

UPDATE excursie_aco  
    SET orase = t2
    WHERE denumire = nume_exc;
END;
/
ROLLBACK;

--------------------
DECLARE  
    t tip_orase_aco := tip_orase_aco();
    nume_exc varchar2(20) := &exc;
    oras1 VARCHAR(20) := &un_oras;
    oras2 VARCHAR(20):= &alt_oras;
BEGIN
    SELECT orase
    INTO t
    FROM excursie_aco
    WHERE denumire = nume_exc;

    FOR i IN 1..t.count LOOP
    IF t(i) = oras1 THEN 
        t(i):= oras2;
    ELSE
        IF t(i) = oras2 THEN 
            t(i):= oras1;
        END IF;
    END IF;
    END LOOP;

UPDATE excursie_aco  
    SET orase = t
    WHERE denumire = nume_exc;
END;
/
ROLLBACK;
--------------------
DECLARE  
    t tip_orase_aco := tip_orase_aco();
    t1 tip_orase_aco := tip_orase_aco();
    nume_exc varchar2(20) := &exc;
    oras varchar2(20) := &un_oras;
    j number := 1;
BEGIN
    SELECT orase
    INTO t
    FROM excursie_aco
    WHERE denumire = nume_exc;

    FOR i IN 1..t.count LOOP
        IF t(i) != oras THEN
            t1.EXTEND;
            t1(j):= t(i);
            j := j + 1;
        END IF;
    END LOOP;

UPDATE excursie_aco  
    SET orase = t1
    WHERE denumire = nume_exc;
END;
/
ROLLBACK;

-- c)
DECLARE  
    t tip_orase_aco := tip_orase_aco();
    code NUMBER(4) := &cod_ex;
BEGIN
    SELECT orase
    INTO t
    FROM excursie_aco
    WHERE cod_excursie = code;
    DBMS_OUTPUT.PUT_LINE('Excursia contine urmatoarele ' || t.count || ' orase: ');
    FOR i IN 1..t.COUNT LOOP 
        DBMS_OUTPUT.PUT_LINE(t(i) || ' ');
    END LOOP;
END;

-- d)
DECLARE  
    t tip_orase_aco := tip_orase_aco();
    TYPE codes IS TABLE OF NUMBER(4); 
    exc_codes codes := codes();
BEGIN
    SELECT cod_excursie
    BULK COLLECT INTO exc_codes
    FROM excursie_aco;

    FOR i IN 1..exc_codes.COUNT LOOP
        SELECT orase
        INTO t
        FROM excursie_acoe
        WHERE cod_excursie = exc_codes(i);
        DBMS_OUTPUT.PUT_LINE
            ('Excursia ' ||exc_codes(i) || ' contine urmatoarele ' || t.count || ' orase: ');
        FOR i IN 1..t.COUNT LOOP 
            DBMS_OUTPUT.PUT_LINE(t(i) || ' ');
        END LOOP;
    t.DELETE;
END LOOP;
END;
/

DECLARE  
    t tip_orase_aco := tip_orase_aco();
    TYPE codes IS TABLE OF NUMBER(4); 
    exc_codes codes := codes();
    exc_codes2 codes := codes();
    min_orase number := 1000;
    exc_code number(4);
    ind number := 1;
BEGIN
    SELECT cod_excursie
    BULK COLLECT INTO exc_codes
    FROM excursie_ACO;

    FOR i IN 1..exc_codes.COUNT LOOP
        SELECT orase
        INTO t
        FROM excursie_aco
        WHERE cod_excursie = exc_codes(i);
            IF t.COUNT < min_orase THEN
                        min_orase := t.COUNT;
            END IF;
        t.DELETE;
    END LOOP;
    
    FOR i IN 1..exc_codes.COUNT LOOP
    SELECT cod_excursie, orase
    INTO exc_code, t
        FROM excursie_aco
        WHERE cod_excursie = exc_codes(i);
        IF t.COUNT = min_orase THEN
            exc_codes2.EXTEND;
            exc_codes2(ind) := exc_code;
            ind := ind + 1;
        END IF;
        t.DELETE;
    END LOOP;
    
    FOR i IN 1..exc_codes2.COUNT LOOP
    UPDATE excursie_aco
        SET status = 'ANULLED'
        WHERE cod_excursie = exc_codes2(i);
    END LOOP;
END;
/
ROLLBACK;

select *
from excursie_aco;

--Ex 3
CREATE OR REPLACE TYPE tip_orase2_aco IS VARRAY(50) OF VARCHAR(20); 
/
CREATE TABLE excursie2_aco
(
    cod_excursie NUMBER(4),
    denumire VARCHAR2(20),
    status VARCHAR2(12),
    orase tip_orase2_lte
);