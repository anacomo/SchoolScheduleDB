-- Comorasu Ana-Maria 
-- Grupa 234
-- Proiect Sisteme de Gestiune a Bazelor de Date
-- School Schedule

-- creare tabele
-- PROFESOR --
CREATE TABLE profesor(
    profesor_id NUMBER(10) PRIMARY KEY,
    titlu VARCHAR2(10),
    nume VARCHAR2(20) NOT NULL,
    prenume VARCHAR2(20) NOT NULL,
    initiala VARCHAR2(3)
    );

-- MATERIE --
CREATE TABLE materie(
    materie_id VARCHAR2(4) PRIMARY KEY,
    denumire VARCHAR2(20) NOT NULL,
    observatii VARCHAR2(20)
    );
    
-- CLASA --
CREATE TABLE clasa (
    clasa_id NUMBER(10) PRIMARY KEY,
    denumire VARCHAR2(20),
    litera VARCHAR2(1),
    nivel NUMBER(10) NOT NULL
    );

-- ELEV -- 
CREATE TABLE elev(
    elev_id NUMBER(10) PRIMARY KEY,
    nume VARCHAR2(20) NOT NULL,
    prenume VARCHAR2(20) NOT NULL, 
    initiala VARCHAR2(3), 
    clasa_id NUMBER(10) REFERENCES clasa(clasa_id) ON DELETE SET NULL
    );
    
-- ZI --
CREATE TABLE zi(
    zi_id NUMBER(10) PRIMARY KEY,
    nume VARCHAR2(20)
    );

-- ORA --
CREATE TABLE ora(
    ora_id NUMBER(10) PRIMARY KEY,
    ora_start VARCHAR2(20) NOT NULL, 
    ora_stop VARCHAR2(20)
    );

-- PROTOTIP ORAR --
CREATE TABLE prototip_orar(
    prototip_id NUMBER(10) PRIMARY KEY, 
    zi_id NUMBER(10) REFERENCES zi(zi_id) ON DELETE SET NULL,
    ora_id NUMBER(10) REFERENCES ora(ora_id) ON DELETE SET NULL,
    descriere VARCHAR2(20)
    );
    
-- PREDARE --
CREATE TABLE predare(
    predare_id VARCHAR2(20) PRIMARY KEY,
    profesor_id NUMBER(10) REFERENCES profesor(profesor_id) ON DELETE SET NULL,
    clasa_id NUMBER(10) REFERENCES clasa(clasa_id) ON DELETE SET NULL,
    materie_id VARCHAR2(4) REFERENCES materie(materie_id) ON DELETE SET NULL,
    descriere VARCHAR2(20)
    );
    
-- ORAR --
CREATE TABLE orar(
    orar_id VARCHAR(20) PRIMARY KEY,
    predare_id VARCHAR2(20) NOT NULL 
        REFERENCES predare(predare_id) ON DELETE SET NULL,
    prototip_id NUMBER(10) NOT NULL
        REFERENCES prototip_orar(prototip_id) ON DELETE SET NULL,
    descriere VARCHAR(20)
    );

-- CONFLICT --
CREATE TABLE conflict(
    conflict_id VARCHAR(20) PRIMARY KEY,
    conflict_tip VARCHAR(20) NOT NULL,
    orar_id VARCHAR(20) REFERENCES orar(orar_id) ON DELETE SET NULL,
    observatii VARCHAR(20)
    );

-------------------------------------
-- INSERTS--------------------------
------------------------------------
-- pentru inserts, accesati excelul 
-- https://unibucro0-my.sharepoint.com/:x:/g/personal/ana_comorasu_s_unibuc_ro/EQ0Yx-FdOzpPvkve02HNPtUBwPU3QVN0lincihow-_-80Q?e=32T4QF
-- cand am creat proiectul am importat direct din excel, dar la fiecare încercare de import ca script, se blocheaza sql developer

-----------------------------------------------------
------------------
-- Exercitiul 6 --
------------------
SET SERVEROUTPUT ON;
/
CREATE OR REPLACE TYPE confl_type AS OBJECT(
    pid    NUMBER(10),
    oid  VARCHAR2(20),
    pfid    NUMBER(10),
    cid     NUMBER(10),
    rnum    VARCHAR2(20)
    );
/
CREATE OR REPLACE PROCEDURE adauga_conflict 
AS
    TYPE v_confl IS TABLE OF confl_type INDEX BY PLS_INTEGER;
    t   v_confl;
    CURSOR c IS
        SELECT prototip_id as pid, 
                orar_id as oid, 
                profesor_id as pfid, 
                clasa_id as cid, 
                to_number(row_number() over ( order by prototip_id )) as rnum
        FROM orar
        JOIN predare USING (predare_id)
        JOIN prototip_orar USING (prototip_id)
        ORDER BY clasa_id;
    cnt NUMBER := 1;
    nr  NUMBER := 1000;
BEGIN
    FOR it IN c LOOP
        t(cnt) := confl_type(it.pid, it.oid, it.pfid, it.cid, it.rnum);
        cnt := cnt + 1;
    END LOOP;
    DELETE FROM conflict;
    cnt := cnt - 1;
    FOR i IN 1..(cnt-1) LOOP
        FOR j IN (i+1)..cnt LOOP
            IF t(i).pid = t(j).pid and t(i).cid = t(j).cid THEN
                INSERT INTO conflict (conflict_id, conflict_tip, orar_id, observatii)
                VALUES('OC'||to_char(nr), 'clasa', t(i).oid, null);
                DBMS_OUTPUT.PUT_LINE('OC'||to_char(nr) || ' clasa ' || t(i).oid);
                nr := nr + 1;
                INSERT INTO conflict (conflict_id, conflict_tip, orar_id, observatii)
                VALUES('OC'||to_char(nr), 'clasa', t(j).oid, null);
                DBMS_OUTPUT.PUT_LINE('OC'||to_char(nr) || ' clasa ' || t(j).oid);
                nr := nr + 1;
            ELSIF t(i).pid = t(j).pid and t(i).pfid = t(j).pfid THEN
                INSERT INTO conflict (conflict_id, conflict_tip, orar_id, observatii)
                VALUES('OC'||to_char(nr), 'profesor', t(i).oid, null);
                DBMS_OUTPUT.PUT_LINE('OC'||to_char(nr) || ' profesor ' || t(i).oid);
                nr := nr + 1;
                INSERT INTO conflict (conflict_id, conflict_tip, orar_id, observatii)
                VALUES('OC'||to_char(nr), 'profesor', t(j).oid, null);
                DBMS_OUTPUT.PUT_LINE('OC'||to_char(nr) || ' profesor ' || t(j).oid);
                nr := nr + 1;
            END IF;
        END LOOP;
    END LOOP;
END;
/
EXECUTE ADAUGA_CONFLICT;
ROLLBACK;
/
------------------
-- Exercitiul 7 --
------------------
CREATE OR REPLACE PROCEDURE modificare_orar 
IS
    c_id ora.ora_id%TYPE;
    c_start ora.ora_start%TYPE;
    c_stop ora.ora_stop%TYPE;
    CURSOR c IS
        SELECT * 
        FROM ora
        FOR UPDATE OF ora_start, ora_stop NOWAIT;
    min5 NUMBER;
    i NUMBER;
    h VARCHAR(10);
BEGIN
    min5 := 1/288;
    i := 0;
    OPEN c;
    LOOP 
        FETCH c INTO c_id, c_start, c_stop;
        EXIT WHEN c%NOTFOUND;
        UPDATE ora
        SET ora_start = to_char(to_date(c_start, 'HH24:MI') + i*1/288, 'HH24:MI'), 
            ora_stop = to_char(to_date(c_stop, 'HH24:MI') + i*1/288, 'HH24:MI')
        WHERE CURRENT OF c;
        i := i + 1;
    END LOOP;
    CLOSE c;
END;
/
EXECUTE modificare_orar;
SELECT * FROM ora;
ROLLBACK;

------------------
-- Exercitiul 8 --
------------------
SET SERVEROUTPUT ON;
/
CREATE OR REPLACE FUNCTION suna_profesori(id NUMBER)
    RETURN VARCHAR2
IS
    CURSOR c IS
        SELECT DISTINCT pf.titlu tit, pf.prenume ppn, pf.nume pn, e.nume en, e.prenume ep
        FROM elev e
        JOIN CLASA cl USING (CLASA_ID)
        JOIN PREDARE p USING (CLASA_ID)
        JOIN PROFESOR pf USING (PROFESOR_ID)
        WHERE e.nume IN (SELECT nume 
                    FROM elev 
                    WHERE elev_id = id)
        ORDER BY pf.NUME;
    prec    VARCHAR2(20) := 'null';
    nr      NUMBER(10) := 0;
    text    VARCHAR2(32767) := '';
BEGIN
    FOR i IN c LOOP
        IF prec = 'null' THEN 
            DBMS_OUTPUT.NEW_LINE();
            DBMS_OUTPUT.PUT(i.tit ||' '||i.ppn||' '||i.pn ||' sustine ore cu '|| i.ep);
            nr := nr + 1;
        ELSIF i.pn = prec THEN
            DBMS_OUTPUT.PUT(', '|| i.ep);
        ELSE 
            DBMS_OUTPUT.NEW_LINE();
            DBMS_OUTPUT.PUT(i.tit ||' '||i.ppn||' '||i.pn ||' sustine ore cu '|| i.ep);
            nr := nr + 1;
        END IF;
        prec := i.pn;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(nr-1);
    RETURN 'Aveti de sunat ' || to_char(nr-1) || ' profesori';
    EXCEPTION
        WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE (SQLCODE || ' - ' || SQLERRM);
END suna_profesori;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE(suna_profesori(114));
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE(suna_profesori(NULL));
END;

------------------
-- Exercitiul 9 --
------------------
/
CREATE OR REPLACE PROCEDURE generare_orar(cls_id NUMBER, procentaj NUMBER)
AS
    TYPE tablou_orar IS TABLE OF orar_type INDEX BY PLS_INTEGER;
    t   tablou_orar;
    TYPE vect IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    fr  vect;
    CURSOR c IS
        SELECT predare_id pid, ROUND(descriere * procentaj/100) nr, denumire, titlu, prenume, nume
        FROM predare
        JOIN profesor USING (profesor_id)
        JOIN materie USING (materie_id)
        WHERE clasa_id = cls_id;
    CURSOR p IS
        SELECT prototip_id pidp, nume, ora_start, ora_stop
        FROM prototip_orar
        JOIN zi using (zi_id)
        JOIN ora using (ora_id)
        ORDER BY DBMS_RANDOM.RANDOM;
    numar_ore   NUMBER;
    k       NUMBER := 1;
    it      NUMBER := 1;
BEGIN
    DELETE FROM orar
    WHERE predare_id IN 
        (SELECT predare_id FROM predare WHERE clasa_id = cls_id);
    SELECT COUNT(*)
    INTO numar_ore
    FROM prototip_orar;
    FOR cnt IN  1..numar_ore LOOP
        fr(cnt):= 0;
    END LOOP;
    FOR i IN c LOOP
        k := 0;
        FOR j IN p LOOP
            IF k >= i.nr THEN 
                EXIT;
            END IF;
            IF fr(j.pidp) < 2 THEN
                fr(j.pidp) := fr(j.pidp) + 1;
                t(it) := orar_type(to_char(j.pidp)||i.pid, i.pid, j.pidp, null);
                DBMS_OUTPUT.PUT_LINE(i.denumire||' cu '||i.titlu||' '||i.prenume||' '||i.nume||', '||j.nume||' de la '||j.ora_start||' la '||j.ora_stop);
                INSERT INTO orar(orar_id, predare_id, prototip_id, descriere)
                VALUES (to_char(j.pidp)||i.pid, i.pid, j.pidp, null);
                it := it + 1;
                k := k + 1;
            END IF;
        END LOOP; 
    END LOOP;
    EXCEPTION
        WHEN OTHERS THEN 
         DBMS_OUTPUT.PUT_LINE (' others: ' ||SQLCODE || '- ' || SQLERRM);
END;
/
SELECT * FROM CLASA;
EXECUTE generare_orar(91, 260);
COMMIT;
SELECT * from orar
JOIN predare using (predare_id)
WHERE clasa_id = 91;
/
-------------------
-- Exercitiul 10 --
-------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER inginer
    BEFORE INSERT OR UPDATE OR DELETE ON orar
DECLARE
    correct     BOOLEAN := FALSE;
    nume_zi     zi.nume%TYPE;
    ora_inc     ora.ora_start%TYPE;
    ora_fin     ora.ora_stop%TYPE;
    nume_azi     VARCHAR (20);
    CURSOR weekly_prog IS
        SELECT nume, ora_start, ora_stop 
        FROM prototip_orar
        JOIN zi USING (zi_id)
        JOIN ora USING (ora_id);
BEGIN
    SELECT TO_CHAR(SYSDATE, 'DAY', 'NLS_DATE_LANGUAGE = ROMANIAN')
    INTO nume_azi
    FROM dual;
    OPEN weekly_prog;
    LOOP
        FETCH weekly_prog INTO nume_zi, ora_inc, ora_fin;
        EXIT WHEN weekly_prog%NOTFOUND;
        IF UPPER(nume_azi) = UPPER(nume_zi)
            AND TO_DATE(ora_inc, 'HH24:MI') <= TO_DATE(TO_CHAR(SYSDATE, 'HH24:MI'), 'HH24:MI')
            AND TO_DATE(ora_fin, 'HH24:MI') > TO_DATE(TO_CHAR(SYSDATE, 'HH24:MI'), 'HH24:MI')
        THEN
            correct := TRUE;
        END IF;
    END LOOP;
    CLOSE weekly_prog;
    IF correct = TRUE THEN
        DBMS_OUTPUT.PUT_LINE('Bine ati revenit, Domnule Stefan!');
    ELSE
        IF INSERTING THEN
            RAISE_APPLICATION_ERROR(-20001,'Nu ai deja destule ore? Vrei mai multe?');
        ELSIF UPDATING THEN
            RAISE_APPLICATION_ERROR(-20002,'Las-o balta, nu te las sa schimbi orele de chimie cu sport');
        ELSIF DELETING THEN
            RAISE_APPLICATION_ERROR(-20003,'Not on my watch!');
        END IF;
    END IF;
END;
/
DELETE FROM orar;
/

-------------------
-- Exercitiul 11 --
-------------------
CREATE OR REPLACE TRIGGER verifica_predare
BEFORE INSERT OR UPDATE ON predare
FOR EACH ROW
DECLARE
    v_predare   predare%ROWTYPE;
    predareid   VARCHAR2(20);
    cid         VARCHAR2(3);
BEGIN
    v_predare.predare_id := :NEW.predare_id;
    v_predare.profesor_id := :NEW.profesor_id;
    v_predare.clasa_id := :NEW.clasa_id;
    v_predare.materie_id := :NEW.materie_id;
    v_predare.descriere := :NEW.descriere;
    IF :NEW.clasa_id < 100 THEN
        cid := '0' ||  TO_CHAR(:NEW.clasa_id);
    ELSE
        cid := TO_CHAR(:NEW.clasa_id);
    END IF;
    predareid := TO_CHAR(v_predare.profesor_id) || cid || v_predare.materie_id;
    IF predareid <> v_predare.predare_id THEN
        RAISE_APPLICATION_ERROR(-20010, 'Ati gresit id-ul, va rugam sa corectati id-ul cu ' || predareid);
    END IF;
END;
/
INSERT INTO predare(predare_id, profesor_id, clasa_id, materie_id, descriere)
VALUES ('AAAAAA', 27, 91, 'MAT', NULL);
SELECT * from predare 
WHERE predare_id = 'AAAAAA';
ROLLBACK;
/
-------------------
-- Exercitiul 12 --
-------------------
CREATE TABLE user_audit(
    bd_nume     VARCHAR2(50),
    data        DATE,
    nume_user   VARCHAR2(30),
    operation   VARCHAR2(20), 
    tip_obiect  VARCHAR2(30),
    nume_obiect VARCHAR2(30)
);

CREATE OR REPLACE TRIGGER schema_audit
    AFTER CREATE OR ALTER OR DROP ON SCHEMA
BEGIN
    INSERT INTO user_audit VALUES (
        SYS.DATABASE_NAME,
        SYSDATE, 
        SYS.LOGIN_USER,
        SYS.SYSEVENT,
        SYS.DICTIONARY_OBJ_TYPE, 
        SYS.DICTIONARY_OBJ_NAME
    );
END;
/

-------------------
-- Exercitiul 13 --
-------------------
CREATE OR REPLACE PACKAGE pachet_anacomo AS
    PROCEDURE adauga_conflict;
    PROCEDURE modificare_orar;
    FUNCTION suna_profesori(id NUMBER)
        RETURN VARCHAR2;
    PROCEDURE generare_orar(cls_id NUMBER, procentaj NUMBER);
END pachet_anacomo;
/
CREATE OR REPLACE PACKAGE BODY pachet_anacomo AS
--------------------------------- PRIMA PROCEDURA
    PROCEDURE adauga_conflict 
AS
    TYPE v_confl IS TABLE OF confl_type INDEX BY PLS_INTEGER;
    t   v_confl;
    CURSOR c IS
        SELECT prototip_id as pid, 
                orar_id as oid, 
                profesor_id as pfid, 
                clasa_id as cid, 
                to_number(row_number() over ( order by prototip_id )) as rnum
        FROM orar
        JOIN predare USING (predare_id)
        JOIN prototip_orar USING (prototip_id)
        ORDER BY clasa_id;
    cnt NUMBER := 1;
    nr  NUMBER := 1000;
BEGIN
    FOR it IN c LOOP
        t(cnt) := confl_type(it.pid, it.oid, it.pfid, it.cid, it.rnum);
        cnt := cnt + 1;
    END LOOP;
    DELETE FROM conflict;
    cnt := cnt - 1;
    FOR i IN 1..(cnt-1) LOOP
        FOR j IN (i+1)..cnt LOOP
            IF t(i).pid = t(j).pid and t(i).cid = t(j).cid THEN
                INSERT INTO conflict (conflict_id, conflict_tip, orar_id, observatii)
                VALUES('OC'||to_char(nr), 'clasa', t(i).oid, null);
                DBMS_OUTPUT.PUT_LINE('OC'||to_char(nr) || ' clasa ' || t(i).oid);
                nr := nr + 1;
                INSERT INTO conflict (conflict_id, conflict_tip, orar_id, observatii)
                VALUES('OC'||to_char(nr), 'clasa', t(j).oid, null);
                DBMS_OUTPUT.PUT_LINE('OC'||to_char(nr) || ' clasa ' || t(j).oid);
                nr := nr + 1;
            ELSIF t(i).pid = t(j).pid and t(i).pfid = t(j).pfid THEN
                INSERT INTO conflict (conflict_id, conflict_tip, orar_id, observatii)
                VALUES('OC'||to_char(nr), 'profesor', t(i).oid, null);
                DBMS_OUTPUT.PUT_LINE('OC'||to_char(nr) || ' profesor ' || t(i).oid);
                nr := nr + 1;
                INSERT INTO conflict (conflict_id, conflict_tip, orar_id, observatii)
                VALUES('OC'||to_char(nr), 'profesor', t(j).oid, null);
                DBMS_OUTPUT.PUT_LINE('OC'||to_char(nr) || ' profesor ' || t(j).oid);
                nr := nr + 1;
            END IF;
        END LOOP;
    END LOOP;
END;

------------------------------- A DOUA PROCEDURA
PROCEDURE modificare_orar 
IS
    c_id ora.ora_id%TYPE;
    c_start ora.ora_start%TYPE;
    c_stop ora.ora_stop%TYPE;
    CURSOR c IS
        SELECT * 
        FROM ora
        FOR UPDATE OF ora_start, ora_stop NOWAIT;
    min5 NUMBER;
    i NUMBER;
    h VARCHAR(10);
BEGIN
    min5 := 1/288;
    i := 0;
    OPEN c;
    LOOP 
        FETCH c INTO c_id, c_start, c_stop;
        EXIT WHEN c%NOTFOUND;
        UPDATE ora
        SET ora_start = to_char(to_date(c_start, 'HH24:MI') + i*1/288, 'HH24:MI'), 
            ora_stop = to_char(to_date(c_stop, 'HH24:MI') + i*1/288, 'HH24:MI')
        WHERE CURRENT OF c;
        i := i + 1;
    END LOOP;
    CLOSE c;
END;
------------------------------- a TREIA
FUNCTION suna_profesori(id NUMBER)
    RETURN VARCHAR2
IS
    CURSOR c IS
        SELECT DISTINCT pf.titlu tit, pf.prenume ppn, pf.nume pn, e.nume en, e.prenume ep
        FROM elev e
        JOIN CLASA cl USING (CLASA_ID)
        JOIN PREDARE p USING (CLASA_ID)
        JOIN PROFESOR pf USING (PROFESOR_ID)
        WHERE e.nume IN (SELECT nume 
                    FROM elev 
                    WHERE elev_id = id)
        ORDER BY pf.NUME;
    prec    VARCHAR2(20) := 'null';
    nr      NUMBER(10) := 0;
    text    VARCHAR2(32767) := '';
BEGIN
    FOR i IN c LOOP
        IF prec = 'null' THEN 
            DBMS_OUTPUT.NEW_LINE();
            DBMS_OUTPUT.PUT(i.tit ||' '||i.ppn||' '||i.pn ||' sustine ore cu '|| i.ep);
            nr := nr + 1;
        ELSIF i.pn = prec THEN
            DBMS_OUTPUT.PUT(', '|| i.ep);
        ELSE 
            DBMS_OUTPUT.NEW_LINE();
            DBMS_OUTPUT.PUT(i.tit ||' '||i.ppn||' '||i.pn ||' sustine ore cu '|| i.ep);
            nr := nr + 1;
        END IF;
        prec := i.pn;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(nr-1);
    RETURN 'Aveti de sunat ' || to_char(nr-1) || ' profesori';
    EXCEPTION
        WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE (SQLCODE || ' - ' || SQLERRM);
END suna_profesori;
------------------------------ A PATRA
PROCEDURE generare_orar(cls_id NUMBER, procentaj NUMBER)
AS
    TYPE tablou_orar IS TABLE OF orar_type INDEX BY PLS_INTEGER;
    t   tablou_orar;
    TYPE vect IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    fr  vect;
    CURSOR c IS
        SELECT predare_id pid, ROUND(descriere * procentaj/100) nr, denumire, titlu, prenume, nume
        FROM predare
        JOIN profesor USING (profesor_id)
        JOIN materie USING (materie_id)
        WHERE clasa_id = cls_id;
    CURSOR p IS
        SELECT prototip_id pidp, nume, ora_start, ora_stop
        FROM prototip_orar
        JOIN zi using (zi_id)
        JOIN ora using (ora_id)
        ORDER BY DBMS_RANDOM.RANDOM;
    numar_ore   NUMBER;
    k       NUMBER := 1;
    it      NUMBER := 1;
BEGIN
    DELETE FROM orar
    WHERE predare_id IN 
        (SELECT predare_id FROM predare WHERE clasa_id = cls_id);
    SELECT COUNT(*)
    INTO numar_ore
    FROM prototip_orar;
    FOR cnt IN  1..numar_ore LOOP
        fr(cnt):= 0;
    END LOOP;
    FOR i IN c LOOP
        k := 0;
        FOR j IN p LOOP
            IF k >= i.nr THEN 
                EXIT;
            END IF;
            IF fr(j.pidp) < 2 THEN
                fr(j.pidp) := fr(j.pidp) + 1;
                t(it) := orar_type(to_char(j.pidp)||i.pid, i.pid, j.pidp, null);
                DBMS_OUTPUT.PUT_LINE(i.denumire||' cu '||i.titlu||' '||i.prenume||' '||i.nume||', '||j.nume||' de la '||j.ora_start||' la '||j.ora_stop);
                INSERT INTO orar(orar_id, predare_id, prototip_id, descriere)
                VALUES (to_char(j.pidp)||i.pid, i.pid, j.pidp, null);
                it := it + 1;
                k := k + 1;
            END IF;
        END LOOP; 
    END LOOP;
    EXCEPTION
        WHEN OTHERS THEN 
         DBMS_OUTPUT.PUT_LINE (' others: ' ||SQLCODE || '- ' || SQLERRM);
END;
END PACHET_ANACOMO;
/
EXECUTE pachet_anacomo.generare_orar(91, 260);
/
-------------------
-- Exercitiul 14 --
-------------------
CREATE OR REPLACE PACKAGE pachet2_anacomo
AS
    TYPE elevi IS VARRAY(2) OF NUMBER;
    date_elevi  ELEVI := ELEVI();
    PROCEDURE set_my_id(my_id NUMBER);
    PROCEDURE get_my_id;
    PROCEDURE afiseaza_colegi;
    PROCEDURE afiseaza_profesori;
    PROCEDURE afiseaza_orar;
END pachet2_anacomo;
/
CREATE OR REPLACE PACKAGE BODY pachet2_anacomo AS
-- set my id
    PROCEDURE set_my_id(my_id NUMBER)
    AS
        cid     NUMBER;
        cnt     NUMBER;
    BEGIN
        SELECT COUNT (*)
        INTO cnt
        FROM elev
        WHERE elev_id = my_id;
        IF cnt = 1 THEN
            pachet2_anacomo.date_elevi.extend();
            pachet2_anacomo.date_elevi(1) := my_id;
            SELECT elev.clasa_id
                INTO cid
                FROM elev
                WHERE elev.elev_id = pachet2_anacomo.date_elevi(1);
                pachet2_anacomo.date_elevi.extend();
                pachet2_anacomo.date_elevi(2) := cid;
            dbms_output.put_line('Id-ul dvs este '||pachet2_anacomo.date_elevi(1));
        ELSE
            dbms_output.put_line('va rugam sa introduceti un id valid!');
        END IF;
    END;
-- get my id
    PROCEDURE get_my_id
    AS
    BEGIN
        dbms_output.put_line('Id-ul dvs este '|| pachet2_anacomo.date_elevi(1));
    END;
-- afiseaza-mi colegii de clasa
    PROCEDURE afiseaza_colegi
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Colegii dumneavoastra sunt:');
        FOR i IN (SELECT nume, prenume, initiala 
                    FROM elev e
                    WHERE e.clasa_id = pachet2_anacomo.date_elevi(2)) LOOP
            DBMS_OUTPUT.PUT_LINE(i.prenume || ' ' || i.initiala || ' ' ||i.prenume);
        END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             DBMS_OUTPUT.PUT_LINE('No data found');
            WHEN OTHERS THEN 
             DBMS_OUTPUT.PUT_LINE('Others');
    END;
-- afiseaza-mi profesorii
    PROCEDURE afiseaza_profesori
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Profesorii dumneavoastra sunt:');
        FOR i IN (SELECT DISTINCT profesor.titlu pt, profesor.nume pn, profesor.prenume ppn
                    FROM clasa
                    JOIN predare USING (clasa_id)
                    JOIN profesor USING (profesor_id)
                    WHERE clasa_id = pachet2_anacomo.date_elevi(2)) LOOP
            DBMS_OUTPUT.PUT_LINE(i.pt || ' ' || i.pn || ' ' ||i.ppn);
        END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             DBMS_OUTPUT.PUT_LINE('No data found');
            WHEN OTHERS THEN 
             DBMS_OUTPUT.PUT_LINE('Others');
    END;
-- afiseaza-mi orarul
    PROCEDURE afiseaza_orar
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Orarul dumneavoastra este:');
        FOR i IN (SELECT zi.nume zn, ora.ora_start ost, ora.ora_stop ostp, materie.denumire den
                    FROM CLASA
                    JOIN PREDARE USING (clasa_id)
                    JOIN ORAR USING (predare_id)
                    JOIN MATERIE USING (materie_id)
                    JOIN PROTOTIP_ORAR on orar.prototip_id = prototip_orar.prototip_id
                    JOIN ZI USING (zi_id)
                    JOIN ORA USING (ora_id)
                    WHERE clasa_id = pachet2_anacomo.date_elevi(2)
                    ORDER BY orar.prototip_id) LOOP
            DBMS_OUTPUT.PUT_LINE(i.zn || ' de la ' || i.ost || ' la  ' ||i.ostp || ' aveti ' || i.den);
        END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             DBMS_OUTPUT.PUT_LINE('No data found');
            WHEN OTHERS THEN 
             DBMS_OUTPUT.PUT_LINE('Others');
    END;

END pachet2_anacomo;
/
EXECUTE pachet2_anacomo.set_my_id(120);
EXECUTE pachet2_anacomo.get_my_id;
EXECUTE pachet2_anacomo.afiseaza_colegi;
EXECUTE pachet2_anacomo.afiseaza_profesori;
EXECUTE pachet2_anacomo.afiseaza_orar;
/

