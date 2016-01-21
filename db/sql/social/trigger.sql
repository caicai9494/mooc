-- 1. Write a trigger that makes new students named 'Friendly' automatically like everyone else in their grade. That is, after the trigger runs, we should have ('Friendly', A) in the Likes table for every other Highschooler A in the same grade as 'Friendly'.

CREATE TRIGGER R1
AFTER INSERT ON Highschooler
FOR EACH ROW
WHEN "Friendly" = New.name
BEGIN 
    INSERT INTO Likes
    SELECT New.ID, R.hid 
    FROM (SELECT H.ID as hid
    FROM Highschooler H
    WHERE H.ID <> New.ID AND H.grade = New.grade) R;
END;

-- 2. Write one or more triggers to manage the grade attribute of new Highschoolers. If the inserted tuple has a value less than 9 or greater than 12, change the value to NULL. On the other hand, if the inserted tuple has a null value for grade, change it to 9. 

CREATE TRIGGER R2A
AFTER INSERT ON Highschooler
FOR EACH ROW
WHEN (New.grade < 9 OR New.grade > 12)
BEGIN 
UPDATE Highschooler
SET grade = NULL
WHERE New.ID = ID;
END;


CREATE TRIGGER R2B
AFTER INSERT ON Highschooler
FOR EACH ROW
WHEN (New.grade IS NULL)
BEGIN 
UPDATE Highschooler
SET grade = 9
WHERE New.ID = ID;
END;


-- 3. Write one or more triggers to maintain symmetry in friend relationships. Specifically, if (A,B) is deleted from Friend, then (B,A) should be deleted too. If (A,B) is inserted into Friend then (B,A) should be inserted too. Don't worry about updates to the Friend table. 

CREATE TRIGGER R3A
AFTER INSERT ON Friend
FOR EACH ROW
WHEN NOT EXISTS (SELECT * FROM Friend WHERE ID1 = New.ID2 AND ID2 = New.ID1)
BEGIN
INSERT INTO Friend
VALUES(New.ID2, New.ID1);
END;

	
CREATE TRIGGER R3B
BEFORE INSERT ON Friend
FOR EACH ROW
WHEN EXISTS (SELECT * FROM Friend WHERE ID1 = New.ID1 AND ID2 = New.ID2)
BEGIN
SELECT RAISE(IGNORE);
END;


CREATE TRIGGER R3C
AFTER DELETE ON Friend
FOR EACH ROW
WHEN EXISTS (SELECT * FROM Friend WHERE ID1 = Old.ID2 AND ID2 = Old.ID1)
BEGIN
DELETE FROM Friend
WHERE ID1 = Old.ID2 AND ID2 = Old.ID1;
END;


-- 4. Write a trigger that automatically deletes students when they graduate, i.e., when their grade is updated to exceed 12. 
CREATE TRIGGER R4
AFTER UPDATE ON Highschooler
FOR EACH ROW
WHEN (New.grade > 12)
BEGIN
DELETE FROM Highschooler 
WHERE New.ID = ID;
END;

--
-- 5. Write a trigger that automatically deletes students when they graduate, i.e., when their grade is updated to exceed 12 (same as Question 4). In addition, write a trigger so when a student is moved ahead one grade, then so are all of his or her friends. 


CREATE TRIGGER R5
AFTER DELETE ON Highschooler
FOR EACH ROW
WHEN (Old.grade = 11)
BEGIN
DELETE FROM Highschooler
WHERE ID IN 
(SELECT ID2 FROM Friend WHERE ID1 = Old.ID AND ID2 <> Old.ID);
END;

-- 6. Write a trigger to enforce the following behavior: If A liked B but is updated to A liking C instead, and B and C were friends, make B and C no longer friends. Don't forget to delete the friendship in both directions, and make sure the trigger only runs when the "liked" (ID2) person is changed but the "liking" (ID1) person is not changed. 
CREATE TRIGGER R6
AFTER UPDATE ON Likes
FOR EACH ROW
WHEN EXISTS (SELECT * FROM Friend WHERE ID1 = Old.ID2 AND ID2 = New.ID2) AND Old.ID1 = New.ID1
BEGIN
DELETE FROM Friend
WHERE ID1 = Old.ID2 AND ID2 = New.ID2;
DELETE FROM Friend
WHERE ID1 = New.ID2 AND ID2 = Old.ID2;
END;
