-- 
-- Comorasu Ana-Maria
-- Tema 5
--
SET SERVEROUTPUT ON;
-- ex 1
SELECT * FROM jobs;

-- a) cursoare clasice
DECLARE
    CURSOR job IS (SELECT * FROM jobs);
    CURSOR emp (x VARCHAR2) IS
        (SELECT * 
        FROM employees e
        WHERE e.job_id = x);
    v_job jobs%ROWTYPE;
    v_emp employees%ROWTYPE;
    cnt NUMBER;
BEGIN
    open job;
    LOOP
        FETCH job into v_job;
        EXIT WHEN job%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Job ' || v_job.job_title || ':');
        OPEN emp(v_job.job_id);
        cnt := 0;
    
        LOOP
            FETCH emp INTO v_emp;
            EXIT WHEN emp%NOTFOUND;
            cnt := cnt + 1;
            DBMS_OUTPUT.PUT_LINE(' ' || v_emp.first_name || ' ' || v_emp.last_name);
        END LOOP;
        CLOSE emp;
        IF cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nothing here');
        END IF;
    END LOOP;
    CLOSE job;
END;
/

-- b) ciclu cursoare
DECLARE
    CURSOR job IS (SELECT * FROM jobs);
    CURSOR emp (x VARCHAR2) IS
        (SELECT *
        FROM employees e
        WHERE e.job_id = x);
    cnt NUMBER;
BEGIN
    FOR v_job IN job LOOP
        DBMS_OUTPUT.PUT_LINE ('Job' || v_job.job_title || ':');
        cnt := 0;
        FOR v_emp IN emp(v_job.job_id) LOOP
            cnt := cnt + 1;
            DBMS_OUTPUT.PUT_LINE(' ' || v_emp.first_name || ' ' || v_emp.last_name);
        END LOOP;
        IF cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nothing here');
        END IF;
    END LOOP;
END;
/

-- c) ciclu cursoare cu subcereri
DECLARE
    cnt NUMBER;
BEGIN
    FOR v_job IN (SELECT * FROM jobs) LOOP
        DBMS_OUTPUT.PUT_LINE ('Job' || v_job.job_title || ':');
        cnt := 0;
        FOR v_emp IN (SELECT * FROM employees e 
                        where e.job_id = v_job.job_id) LOOP
            cnt := cnt + 1;
            DBMS_OUTPUT.PUT_LINE(' ' || v_emp.first_name || ' ' || v_emp.last_name);
        END LOOP;
        IF cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nothing here');
        END IF;
    END LOOP;
END;
/
-- d) ciclu expresii cursor


DECLARE
    TYPE x IS REF CURSOR;
    CURSOR job IS (SELECT j.job_title, 
                    CURSOR (SELECT *
                             FROM employees e
                            WHERE e.job_id = j.job_id)
                 FROM jobs j);
    v_job VARCHAR2(100);
    v_emp employees%ROWTYPE;
    c x;
    cnt NUMBER;     
BEGIN
    OPEN job;
    LOOP
        FETCH job INTO v_job, c;
        EXIT WHEN job%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Job ' || v_job || ':');
        cnt := 0;
        LOOP
            FETCH c INTO v_emp;
            EXIT WHEN c%NOTFOUND;
            cnt := cnt + 1;
            DBMS_OUTPUT.PUT_LINE(' ' || v_emp.first_name || ' ' || v_emp.last_name);
        END LOOP;
        IF cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nothing here');
        END IF;
    END LOOP;
    CLOSE job;
END;
/

-- ex 2
DECLARE
    nr_ang NUMBER;
    nr_total NUMBER;
    suma_ang NUMBER;
    suma_total NUMBER;
BEGIN
    suma_total := 0;
    nr_total := 0;
    
    FOR v_job IN (SELECT * FROM jobs) LOOP
        DBMS_OUTPUT.PUT_LINE('Job ' || v_job.job_title || ':');
        nr_ang := 0;
        suma_ang := 0;
        FOR v_emp IN (SELECT *
                      FROM employees e
                      WHERE e.job_id = v_job.job_id) LOOP
            nr_ang := nr_ang + 1;
            suma_ang := suma_ang + v_emp.salary;
        END LOOP;
        suma_total := suma_total + suma_ang;
        nr_total := nr_total + nr_ang;
        DBMS_OUTPUT.PUT_LINE('Jobul are ' || nr_ang || ' angajati.');
        IF nr_ang > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Suma salariilor este ' || suma_ang || ' si media salariilor este ' || suma_ang / nr_ang);
            DBMS_OUTPUT.PUT_LINE('Lista de angajati este:'); 
        END IF;
        FOR v_emp IN (SELECT *
                      FROM employees e
                      WHERE e.job_id = v_job.job_id) LOOP
            DBMS_OUTPUT.PUT_LINE(' ' || v_emp.first_name || ' ' || v_emp.last_name);
        END LOOP;
        IF nr_ang = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nothing here!');
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('In total sunt ' || nr_total || ' angajati.');
    DBMS_OUTPUT.PUT_LINE('Salariul total: ' || suma_total);
    DBMS_OUTPUT.PUT_LINE('Salariul mediu: ' || suma_total / nr_total);
END;
/
-- ex 3
DECLARE
    suma_ang NUMBER;
    suma_total NUMBER;
BEGIN
    suma_total := 0;
    FOR v_emp IN (SELECT *
                  FROM employees) LOOP
        suma_total := suma_total + v_emp.salary;
        IF v_emp.commission_pct IS NOT NULL THEN
            suma_total := suma_total + v_emp.salary * v_emp.commission_pct;
        END IF;   
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(suma_total);
    FOR v_emp IN (SELECT *
                  FROM employees) LOOP
        suma_ang := v_emp.salary;
        IF v_emp.commission_pct IS NOT NULL THEN
            suma_ang := suma_ang * (1 + v_emp.commission_pct);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_emp.first_name || ' ' || v_emp.last_name || ': ' ||
                suma_ang || ', castiga ' || 100 * suma_ang / suma_total);
    END LOOP;
END;
/
-- ex 4
DECLARE
    nr NUMBER;
BEGIN
    FOR v_job IN (SELECT * FROM jobs) LOOP
        DBMS_OUTPUT.PUT_LINE('Job ' || v_job.job_title || ':');
        nr := 0;
        FOR v_ang IN (SELECT *
                      FROM employees e
                      WHERE e.job_id = v_job.job_id
                      ORDER BY salary DESC) LOOP
            IF nr = 5 THEN
                EXIT;
            END IF;
            nr := nr + 1;
            DBMS_OUTPUT.PUT_LINE(v_ang.first_name || ' ' || v_ang.last_name || ' are salariul ' || v_ang.salary);
        END LOOP;
        IF nr < 5 THEN
            DBMS_OUTPUT.PUT_LINE('Mai putin de 5 angajati');
        END IF;
    END LOOP;
END;
/
-- ex 5
DECLARE
    cnt NUMBER;
    max_sal NUMBER;
BEGIN
    FOR v_job IN (SELECT *
                  FROM jobs) LOOP
        DBMS_OUTPUT.PUT_LINE('Job ' || v_job.job_title || ':');
        cnt := 0;
        FOR v_ang IN (SELECT *
                      FROM employees e
                      WHERE e.job_id = v_job.job_id
                      ORDER BY salary DESC) LOOP
            IF cnt = 5 THEN
                EXIT;
            END IF;
            cnt := cnt + 1;
            max_sal := v_ang.salary;
        END LOOP;
        FOR v_ang IN (SELECT *
                      FROM employees e
                      WHERE e.job_id = v_job.job_id
                      ORDER BY salary DESC) LOOP
            IF v_ang.salary < max_sal THEN
                EXIT;
            END IF;
            DBMS_OUTPUT.PUT_LINE(v_ang.first_name || ' ' || v_ang.last_name || ' cu salariul ' || v_ang.salary);
        END LOOP;
        IF cnt < 5 THEN
            DBMS_OUTPUT.PUT_LINE('Mai putin de 5 angajati');
        END IF;
    END LOOP;
END;
/