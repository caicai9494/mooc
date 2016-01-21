-- 1. It's time for the seniors to graduate. Remove all 12th graders from Highschooler.
--DELETE FROM Highschooler
--WHERE grade = 12;

--SELECT * FROM Highschooler;

---- 2. If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.
--DELETE
--FROM Likes 
--WHERE NOT EXISTS 
--(SELECT * FROM Likes L2 WHERE L2.ID1 = Likes.ID2 AND L2.ID2 = Likes.ID1)
--AND EXISTS (SELECT * FROM Friend F WHERE Likes.ID1 = F.ID1 AND Likes.ID2 = F.ID2); 

-- 3. For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)
INSERT INTO Friend
SELECT F1.ID1, F2.ID2
FROM Friend F1, Friend F2
WHERE F1.ID2 = F2.ID1 AND F1.ID1 <> F2.ID2 --AND F1.ID1 < F2.ID2 
AND NOT EXISTS 
(SELECT * FROM Friend F3 WHERE F3.ID1 = F1.ID1 AND F3.ID2 = F2.ID2);


SELECT F1.ID1, F1.ID2, F2.ID2
FROM Friend F1, Friend F2
WHERE F1.ID2 = F2.ID1 AND F1.ID1 <> F2.ID2 --AND F1.ID1 < F2.ID2 
AND NOT EXISTS 
(SELECT * FROM Friend F3 WHERE F3.ID1 = F1.ID1 AND F3.ID2 = F2.ID2);


