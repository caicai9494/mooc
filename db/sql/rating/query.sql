-- 1. Find the titles of all movies directed by Steven Spielberg. 
SELECT title 
FROM Movie
WHERE director = 'Steven Spielberg';

-- 2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
SELECT year
FROM Movie
WHERE mID in 
(SELECT mID
FROM Rating
WHERE stars >= 4)
ORDER BY year ASC;

-- 3. Find the titles of all movies that have no ratings. 
SELECT title
FROM Movie
WHERE mID NOT IN
(SELECT mID
FROM Rating
WHERE stars IS NOT NULL);

-- 4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 
SELECT name
FROM Reviewer
WHERE rID in
(SELECT rID
FROM Rating
WHERE ratingDate IS NULL);

-- 5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
SELECT name, title, stars, ratingDate
FROM Movie NATURAL JOIN 
(SELECT mID, rID, name, stars, ratingDate  
FROM Reviewer NATURAL JOIN Rating)
ORDER BY name, title, stars;

-- 6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
SELECT name, title
FROM Movie NATURAL JOIN
(SELECT name, mID
FROM Reviewer NATURAL JOIN
(SELECT r1.mID, r1.rID  
FROM Rating r1, Rating r2
WHERE r1.rID = r2.rID AND r1.mID = r2.mID AND r1.stars < r2.stars));

-- 7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 
SELECT title, mstars
FROM Movie NATURAL JOIN
(SELECT mID, MAX(stars) as mstars
FROM Rating
WHERE stars NOT NULL
GROUP BY mID)
ORDER BY title;

-- 8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
SELECT title, maxs-mins as spread 
FROM
(SELECT mID, title, MAX(stars) as maxs
FROM Movie NATURAL JOIN Rating
GROUP BY mID) NATURAL JOIN
(SELECT mID, title, MIN(stars) as mins
FROM Movie NATURAL JOIN Rating
GROUP BY mID) 
ORDER BY spread DESC, title;

-- 9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 

SELECT AVG(avg_before) - AVG(avg_after)
FROM
(SELECT mID, AVG(stars) as avg_before
FROM Rating
WHERE mID IN
(SELECT mID
FROM Movie
WHERE YEAR < 1980)
GROUP BY mID), 
(SELECT mID, AVG(stars) as avg_after
FROM Rating
WHERE mID IN
(SELECT mID
FROM Movie
WHERE YEAR > 1980)
GROUP BY mID);

