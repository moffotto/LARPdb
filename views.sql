--VIEWS

---Most Common 3 Skills across all characters
CREATE VIEW Top_3_Skills
AS
SELECT TOP 3 WITH TIES SKILL.SkillName, COUNT(CHARACTER_SKILL_LEVEL.CharacterID) AS CharactersWithSkill FROM SKILL
JOIN CHARACTER_SKILL_LEVEL ON CHARACTER_SKILL_LEVEL.SkillID = SKILL.SkillID
GROUP BY SKILL.SkillName
ORDER BY CharactersWithSkill DESC

---

---Top 10 Characters by Total Skill Levels
CREATE VIEW Top10Characters
AS
SELECT TOP 10 WITH TIES [CHARACTER].CharName, SUM(CHARACTER_SKILL_LEVEL.LevelID) AS TotalLevels FROM

CHARACTER_SKILL_LEVEL JOIN [CHARACTER] ON CHARACTER_SKILL_LEVEL.CharacterID = [CHARACTER].CharacterID
GROUP BY [CHARACTER].CharName

ORDER BY TotalLevels DESC

---

-- Number of characters grouped by low, medium, and high skill levels
CREATE VIEW levelGroupTotals
AS
SELECT (CASE
	WHEN L.LevelDescr IN (1,2)THEN 'Low'
	WHEN L.LevelDescr IN (3,4) THEN 'Medium'
	WHEN L.LevelDescr = 5 THEN 'High'
	ELSE 'Unknown'
END) AS 'LevelGroup', COUNT(CSL.CharacterID) AS 'TotalCharacters'
FROM [Level] L JOIN CHARACTER_SKILL_LEVEL CSL
	ON L.LevelID = CSL.LevelID
GROUP BY (CASE
	WHEN L.LevelDescr IN (1,2)THEN 'Low'
	WHEN L.LevelDescr IN (3,4) THEN 'Medium'
	WHEN L.LevelDescr = 5 THEN 'High'
	ELSE 'Unknown'
END)
GO
--Top 10 most common items of type 'Armament', having at least 20 in existence
CREATE VIEW Top_10_Common_Items
AS
SELECT TOP(10) WITH TIES I.ItemName, COUNT(ItemLotID) AS NumberOfItems
FROM ITEM_LOT IL
	JOIN ITEM I ON IL.ItemID = I.ItemID
	JOIN ITEM_TYPE IT ON I.ItemTypeID = IT.ItemTypeID
WHERE IT.ItemTypeName = 'Armament'
GROUP BY I.ItemName
HAVING COUNT(ItemLotID) >= 20
ORDER BY NumberOfItems DESC

----

-- Total Number of events by Theatre where there have been at least 3 events
CREATE VIEW EventsByTheatre
AS
SELECT T.TheatreName, COUNT(E.EventID) AS TotalEvents
FROM [EVENT] E JOIN THEATRE T
	ON E.TheatreID = T.TheatreID
GROUP BY T.TheatreName
HAVING Count(E.EventID) >= 3
GO

--List of events that have more than 10 twenty-one year old players, with the count of 21 year --old players for each event
CREATE VIEW [AMOUNT OF PLAYERS PER EVENT OVER 21] AS
SELECT L.LocationName, COUNT(P.PlayerID) as over21
FROM LOCATION L
	JOIN [EVENT] E on L.LocationID = E.LocationID
	JOIN EVENT_PLAY_CHAR EPC ON E.EventID = EPC.EventID
	JOIN PLAYER_CHARACTER PC ON EPC.PlayerCharacterID = PC.PlayerCharacterID
	JOIN PLAYER P ON PC.PlayerID = P.PlayerID
WHERE P.Age > '21'
GROUP BY L.LocationName
Having COUNT(P.PlayerID) > 10


CREATE VIEW [Category for Characters with Different Weapons] AS
SELECT (CASE
WHEN (S.SkillName = 'Archery')
THEN 'Can I get you a feathered hat?'
WHEN (S.SkillName = 'Firearms')
THEN 'Is the safety on there sir?'
WHEN (S.SkillName = 'Fitness')
THEN 'How often do you pick things up and put them down?'
WHEN (S.SkillName = 'Herbalism')
THEN 'Make me some tea please'
ELSE 'Unknown'
END
) AS 'Category'
FROM SKILL S
JOIN CHARACTER_SKILL_LEVEL CSK ON S.SKillID = CSK.SkillID
JOIN [CHARACTER] C ON CSK.CharacterID = C.CharacterID
GROUP BY (CASE
WHEN (S.SkillName = 'Archery')
THEN 'Can I get you a feathered hat?'
WHEN (S.SkillName = 'Firearms')
THEN 'Is the safety on there sir?'
WHEN (S.SkillName = 'Fitness')
THEN 'How often do you pick things up and put them down?'
WHEN (S.SkillName = 'Herbalism')
THEN 'Make me some tea please'
ELSE 'Unknown'
END
)

--Number of 'advanced', 'intermediate', and 'beginner' characters
CREATE VIEW NumberAtExperienceLevel
AS
SELECT Experience.ExperienceLevel, Count(Experience.CharacterID) AS CountAtLevel
FROM (
SELECT CharLev.CharacterID, (CASE
	WHEN (CharLev.TotalLevel <= 10)
		THEN 'Beginner'
	WHEN (CharLev.TotalLevel < 10) AND (CharLev.TotalLevel <= 30)
		THEN 'Intermediate'
	WHEN (CharLev.TotalLevel > 30)
		THEN 'Expert'
	ELSE 'Something Else'
END) AS ExperienceLevel
FROM (SELECT CharacterID, SUM(LevelID) AS TotalLevel FROM CHARACTER_SKILL_LEVEL GROUP BY CharacterID) CharLev
) Experience
GROUP BY Experience.ExperienceLevel

--A characters experience level, either 'advanced', 'intermediate', or 'beginner'
CREATE VIEW CharacterExperienceLevels
AS
SELECT C.CharName, Experience.ExperienceLevel
FROM (
SELECT CharLev.CharacterID, (CASE
	WHEN (CharLev.TotalLevel <= 10)
		THEN 'Beginner'
	WHEN (CharLev.TotalLevel < 10) AND (CharLev.TotalLevel <= 30)
		THEN 'Intermediate'
	WHEN (CharLev.TotalLevel > 30)
		THEN 'Expert'
	ELSE 'Something Else'
END) AS ExperienceLevel
FROM (SELECT CharacterID, SUM(LevelID) AS TotalLevel FROM CHARACTER_SKILL_LEVEL GROUP BY CharacterID) CharLev
) Experience JOIN [CHARACTER] C ON Experience.CharacterID = C.CharacterID
