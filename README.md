# School Schedule Database Management System

## Author: Ana-Maria Comorasu

1. Database presentation  
  1.1. Technologies  
For the Database Management Systems Course Project, I used Oracle Database **o11g**.  
  Apps:
  * Oracle SQL Developer
  * Oracle Database Express Edition  
     
 I have more details about _Oracle Database Express Edition_, how the database was created and user rights in my first essay, [Using Oracle Express edition for creating a local DataBase](https://github.com/anacomo/SchoolScheduleDB/blob/main/Comorasu_Ana-Maria_Referat_Curs.pdf).
 
  1.2. Project purpose
The idea of the project is generating a schedule for a school/high school. This will contain the following entities:
* **Profesor** entity, which will contain the teachers' list, where each one teaches one or more subjects at one or more classes, in the same school.
* **Elev** entity (which is the student entity), which contains a table with all the students in the school, which take part in only one class
* **Clasa**, an entity which groups more students, depending on the learning level. On a single level, there can exist one or more classes, if the total number of students from the same level exceeds a limit (generally, 20-30 students).
* **Materie**, which is the subject entity.
* On the other side, there are **Zi**(day) and **Ora**(hour). The first entity reffers to the day in the week in which the schedule will occur, and the hours will be a model for every day of the week.
* From the 2 entities mentioned earlier, there will be an associative table created for them, named **Prototip Orar** (schedule prototype), from which there will be created an available learning schedule for every day of the week.
* On the other side, the associative table **Predare** (Teaching), will be constrained by 3 foreign keys, for class, student and subject. That is because a teacher can have more classes and can teach multiple subjects, and also a class can study multiple subjects with different teachers.
* The last two tables will be united in the **Orar** (Schedule) table, which is the main purpose of the project,
* Because the schedule table can not constrain the compatibility between the learning hours, I created the table **Conflict** which will retain the conflicts from the schedule.


The course essays can be found here:
* [Using Oracle Express edition for creating a local DataBase](https://github.com/anacomo/SchoolScheduleDB/blob/main/Comorasu_Ana-Maria_Referat_Curs.pdf)
* [Importing Excel data into a database](https://github.com/anacomo/SchoolScheduleDB/blob/main/Comorasu_Ana-Maria_referat2_curs.pdf)

Also, the full tasks can be found
[here](https://github.com/anacomo/SchoolScheduleDB/blob/main/234_Comorasu_Ana-Maria_Proiect.pdf).

Full [source code](https://github.com/anacomo/SchoolScheduleDB/blob/main/234_Comorasu_Ana-Maria_Sursa.sql)
