-- 1. Add the reviewer Roger Ebert to your database, with an rID of 209.
INSERT INTO Reviewer
VALUES(209, 'Roger Ebert');

SELECT *
FROM Reviewer;

-- 2. Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL.

INSERT INTO Rating
SELECT (SELECT rID FROM Reviewer WHERE name = 'James Cameron'), mID, 5, NULL
FROM Rating;

SELECT * 
FROM Rating;

-- 3. For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)
UPDATE Movie
SET year = year + 25
WHERE mID in 
(SELECT mID
FROM (SELECT mID, AVG(stars) as avg_stars
FROM Rating
GROUP BY mID)
WHERE avg_stars >= 4);

SELECT * 
FROM Movie;

-- 4. Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.

DELETE FROM Rating 
WHERE stars < 4 and mID in 
(SELECT mID 
FROM Movie
WHERE year < 1970 or year > 2000);

SELECT * 
FROM Rating;

