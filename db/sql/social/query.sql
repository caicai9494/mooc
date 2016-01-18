-- 1. Find the names of all students who are friends with someone named Gabriel. 
SELECT name
FROM Highschooler
WHERE ID IN
(SELECT ID1
FROM Friend
WHERE ID2 IN
(SELECT ID 
FROM Highschooler
WHERE name = 'Gabriel'));

-- 2. For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. 
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Likes L, Highschooler H1, Highschooler H2 
WHERE H1.ID = L.ID1 AND H2.ID = L.ID2 AND ABS(H1.grade - H2.grade) >= 2;

-- 3. For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.

SELECT H1.name, H2.name
FROM
(SELECT L1.ID1, L1.ID2, L2.ID1
FROM Likes L1, Likes L2
WHERE L1.ID2 = L2.ID1 AND L1.ID1 = L2.ID2) LL, 
      Highschooler H1, Highschooler H2 
WHERE H1.ID = LL.ID1 AND H2.ID = LL.ID2 AND H1.name < H2.name;

-- 4. Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
SELECT name, grade
FROM Highschooler
WHERE ID NOT IN
(SELECT ID1
FROM Likes
UNION
SELECT ID2
FROM Likes)
ORDER BY grade ASC, name ASC;

-- 5. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 

SELECT H.name, H.grade, R1.name, R1.grade 
FROM Likes L, Highschooler H, 
(SELECT ID, name, grade
FROM Highschooler H1 
WHERE H1.ID IN (SELECT ID2 FROM Likes)
AND H1.ID NOT IN (SELECT ID1 FROM Likes)) R1
WHERE L.ID2 = R1.ID AND H.ID = L.ID1;

-- 6. Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 

SELECT H1.ID, H1.name, H1.grade--, H2.name, H2.grade
FROM Highschooler H1 
WHERE NOT EXISTS 
(SELECT * FROM Friend F, Highschooler H2 
WHERE F.ID1 = H1.ID AND F.ID2 = H2.ID AND H1.grade <> H2.grade);

-- 7. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 
SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Highschooler H1, Highschooler H2, Highschooler H3, 
(SELECT CF1.ID1 as cid1, CF1.ID2 as cid2, CF2.ID2 as cid3
FROM Friend CF1, Friend CF2, 
(SELECT L1.ID1 as sid1, L1.ID2 as sid2
FROM Likes L1
WHERE NOT EXISTS 
(SELECT * FROM Friend F WHERE F.ID1 = L1.ID1 AND F.ID2 = L1.ID2)) R
WHERE CF1.ID1 = CF2.ID1 AND CF1.ID2 = R.sid1 AND CF2.ID2 = r.sid2) RR
WHERE H1.ID = RR.cid1 AND H2.ID = RR.cid2 AND H3.ID = RR.cid3;

-- 8. Find the difference between the number of students in the school and the number of different first names. 
SELECT count_id - count_name
FROM 
(SELECT COUNT(ID) as count_id
FROM Highschooler),
(SELECT COUNT(DISTINCT name) as count_name
FROM Highschooler);

-- 9. Find the name and grade of all students who are liked by more than one other student. 
--1468, 1709
SELECT name, grade
FROM Highschooler 
WHERE ID IN
(SELECT ID2 
FROM Likes
GROUP BY ID2
HAVING COUNT(ID2) > 1);



