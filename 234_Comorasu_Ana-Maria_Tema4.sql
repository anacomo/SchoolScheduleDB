-- Tema 4 
-- Comorasu Ana-Maria
-- Grupa 234
-- Ex 1
-- a
SET SERVEROUTPUT ON;
DECLARE
        TYPE job_record IS RECORD
        (job_id jobs.job_id%TYPE, 
        job_title jobs.job_title%TYPE, 
        avg_salary jobs.min_salary%TYPE);
    v_job job_record;
    BEGIN
        v_job.job_id := 1;
        v_job.job_title := 'PROGRAMATOR';
        v_job.avg_salary := 2000;
        DBMS_OUTPUT.PUT_LINE('Jobul are codul '|| v_job.job_id || ' si jobul ' || v_job.job_title || ' are salariul ' ||  v_job.avg_salary);
END; 
/
-- b)
SET SERVEROUTPUT ON; 
DECLARE
        TYPE job_record IS RECORD
        (job_id jobs.job_id%TYPE, 
        job_title jobs.job_title%TYPE, 
        avg_salary jobs.min_salary%TYPE);
    v_job job_record;
    BEGIN
        SELECT job_id, job_title, (min_salary + max_salary) / 2
        INTO v_job
        FROM jobs
        WHERE job_id = 'IT_PROG';
        DBMS_OUTPUT.PUT_LINE('Jobul are codul '|| v_job.job_id || ' si jobul ' || v_job.job_title || ' are salariul ' ||  v_job.avg_salary);
END;
/
-- c)
CREATE TABLE jobs_aco
as (select * from jobs);

ALTER TABLE jobs_aco
ADD CONSTRAINT PK_jobs_aco PRIMARY KEY (job_id);

DECLARE
    TYPE job_record IS RECORD
        (job_id jobs.job_id%TYPE, 
        job_title jobs.job_title%TYPE, 
        avg_salary jobs.min_salary%TYPE);
    v_job job_record;
    BEGIN 
        DELETE FROM jobs_aco
        WHERE job_id = 'ST_MAN'
        RETURNING job_id, job_title, (min_salary + max_salary)/2 into v_job;
        ROLLBACK;
END;
/

-- 2
DECLARE
    v_ang1 emp_aco%ROWTYPE;
    v_ang2 emp_aco%ROWTYPE;
    BEGIN
        SELECT * 
        INTO v_ang1
        FROM (SELECT *
            FROM emp_aco
            ORDER BY salary desc)
            where rownum <= 1;

        SELECT * 
        INTO v_ang2
        FROM (SELECT *
            FROM emp_aco
            ORDER BY salary)
        WHERE ROWNUM <= 1;
            
        IF v_ang1.salary * 0.1 > v_ang2.salary
            THEN UPDATE emp_aco 
                SET salary = salary * 1.1
                WHERE employee_id = v_ang2.employee_id;
        ROLLBACK;
        END IF;
END;
/

-- 3
CREATE TABLE dept_aco
as (select * from departments);
DECLARE 
    v_dep1 dept_aco%ROWTYPE;
    v_dep2 dept_aco%ROWTYPE;
    BEGIN
        v_dep1.department_id := 1300;
        v_dep1.department_name := 'Research';
        v_dep1.manager_id := 103;
        v_dep1.location_id := 1700;
        INSERT INTO dept_aco
        VALUES v_dep1;
        DELETE FROM dept_aco
        WHERE department_id = '50'
        RETURNING department_id, department_name, manager_id, location_id into v_dep2;
        DBMS_OUTPUT.PUT_LINE(v_dep2.department_id || ' ' || v_dep2.department_name || ' ' || v_dep2.manager_id || ' ' || v_dep2.location_id);
        ROLLBACK;
END;
/
-- 4
create table emp_aco as (select * from employees);

DECLARE 
    TYPE indexed_table IS TABLE OF emp_aco%ROWTYPE INDEX BY BINARY_INTEGER;
    t indexed_table;
BEGIN
    DELETE FROM emp_aco
    WHERE commission_pct >= 0.1 AND commission_pct <= 0.3
    RETURNING employee_id, first_name, last_name, email,  phone_number, hire_date, 
        job_id, salary, commission_pct, manager_id, department_id
    BULK COLLECT INTO t;
    FOR i in t.FIRST..t.LAST LOOP
        DBMS_OUTPUT.PUT_LINE( t(i).employee_id || ' ' || t(i).commission_pct || ' ' );
    END LOOP;
    ROLLBACK;
END;
/
