create view LateRating as 
  select distinct R.mID, title, stars, ratingDate 
  from Rating R, Movie M 
  where R.mID = M.mID 
  and ratingDate > '2011-01-20';

create view HighlyRated as 
  select mID, title 
  from Movie 
  where mID in (select mID from Rating where stars > 3);

create view NoRating as 
  select mID, title 
  from Movie 
  where mID not in (select mID from Rating);

-- 1. Updates to attribute title in LateRating should update Movie.title for the corresponding movie. (You may assume attribute mID is a key for table Movie.) Make sure the mID attribute of view LateRating has not also been updated -- if it has been updated, don't make any changes. Don't worry about updates to stars or ratingDate.

CREATE TRIGGER R1
INSTEAD OF UPDATE OF title ON LateRating
FOR EACH ROW
BEGIN
    UPDATE Movie
    SET title = New.title
    WHERE mID = Old.mID AND New.mID = Old.mID;
END;

DROP TRIGGER R1;

-- 2. Updates to attribute stars in LateRating should update Rating.stars for the corresponding movie rating. (You may assume attributes [mID,ratingDate] together are a key for table Rating.) Make sure the mID and ratingDate attributes of view LateRating have not also been updated -- if either one has been updated, don't make any changes. Don't worry about updates to title.

CREATE TRIGGER R2
INSTEAD OF UPDATE OF stars ON LateRating
FOR EACH ROW
BEGIN
    UPDATE Rating
    SET stars = New.stars
    WHERE mID = Old.mID AND new.ratingDate = old.ratingDate
    AND Old.mID = New.mID;
END;

DROP TRIGGER R2;

-- 3. Updates to attribute mID in LateRating should update Movie.mID and Rating.mID for the corresponding movie. Update all Rating tuples with the old mID, not just the ones contributing to the view. Don't worry about updates to title, stars, or ratingDate.

CREATE TRIGGER R3
INSTEAD OF UPDATE OF mID ON LateRating
FOR EACH ROW
BEGIN
    UPDATE Movie
    SET mID = New.mID
    WHERE mID = Old.mID; 

    UPDATE Rating
    SET mID = New.mID
    WHERE mID = Old.mID; 
END;

DROP TRIGGER R3;

-- 4. Finally, write a single instead-of trigger that combines all three of the previous triggers to enable simultaneous updates to attributes mID, title, and/or stars in view LateRating. Combine the view-update policies of the three previous problems, with the exception that mID may now be updated. Make sure the ratingDate attribute of view LateRating has not also been updated -- if it has been updated, don't make any changes.

-- 5. Deletions from view HighlyRated should delete all ratings for the corresponding movie that have stars > 3.

CREATE TRIGGER R5
INSTEAD OF DELETE ON HighlyRated
FOR EACH ROW
BEGIN
    DELETE FROM Rating
    WHERE stars > 3 AND mID = Old.mID;
END;

DROP TRIGGER R5;

-- 6. Deletions from view HighlyRated should update all ratings for the corresponding movie that have stars > 3 so they have stars = 3.

CREATE TRIGGER R6
INSTEAD OF DELETE ON HighlyRated
FOR EACH ROW
BEGIN
    UPDATE Rating
    SET stars = 3
    WHERE stars > 3 AND mID = Old.mID;
END;

DROP TRIGGER R6;

-- 7. An insertion should be accepted only when the (mID,title) pair already exists in the Movie table. (Otherwise, do nothing.) Insertions into view HighlyRated should add a new rating for the inserted movie with rID = 201, stars = 5, and NULL ratingDate.

CREATE TRIGGER R7
INSTEAD OF INSERT ON HighlyRated
FOR EACH ROW
WHEN EXISTS (SELECT * FROM Movie WHERE mID = New.mID AND title = New.title)
BEGIN
    INSERT INTO Rating
    VALUES(201, New.mID, 5, NULL);
END;

DROP TRIGGER R7;

-- 8. An insertion should be accepted only when the (mID,title) pair already exists in the Movie table. (Otherwise, do nothing.) Insertions into view NoRating should delete all ratings for the corresponding movie.

CREATE TRIGGER R8
INSTEAD OF INSERT ON NoRating
FOR EACH ROW
WHEN EXISTS (SELECT * FROM Movie WHERE mID = New.mID AND title = New.title)
BEGIN
    DELETE FROM Rating
    WHERE mID = New.mID; 
END;

DROP TRIGGER R8;

-- 9. Deletions from view NoRating should delete the corresponding movie from the Movie table.

CREATE TRIGGER R9
INSTEAD OF DELETE ON NoRating
FOR EACH ROW
BEGIN
    DELETE FROM Movie
    WHERE mID = Old.mID AND title = Old.title;
END;

DROP TRIGGER R9;

-- 10. Deletions from view NoRating should add a new rating for the deleted movie with rID = 201, stars = 1, and NULL ratingDate.

CREATE TRIGGER R10
INSTEAD OF DELETE ON NoRating
FOR EACH ROW
BEGIN
    INSERT INTO NoRating
    VALUES(201, Old.mID, 1, NULL);
END;
    
DROP TRIGGER R10;


