--CHECK CONSTRAINTS/ BUSINESS RULES

--One province may not contain more than 1 city
CREATE FUNCTION [dbo].[fn_OneCityPerProvince]()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF
		EXISTS (SELECT * FROM CITY
		GROUP BY ProvinceID
		HAVING COUNT (CityID) > 1)
	SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE CITY WITH NOCHECK
ADD CONSTRAINT CK_OneCity
CHECK(dbo.fn_OneCityPerProvince() = 0)


-- Players must be 18 or older
CREATE FUNCTION fn_PlayerAtLeast18()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF EXISTS( SELECT *
		FROM PLAYER P
		WHERE P.PlayerDOB > (SELECT GetDate() - (365.25 * 18))
	)
		SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE PLAYER WITH NOCHECK
ADD CONSTRAINT CK_playerAge
CHECK (dbo.fn_PlayerAtLeast18() = 0)





--XP transactions cannot complete if character does not have enough XP
CREATE FUNCTION [dbo].[fn_DebitXPCorrectly]()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF
		EXISTS (SELECT * FROM [CHARACTER]
		WHERE XPcomp < 0)
	SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE [XP_TRANSACTION] WITH NOCHECK
ADD CONSTRAINT CK_DebitXPCorrectly
CHECK(dbo.fn_DebitXPCorrectly() = 0)


--One character cannot have multiple players
CREATE FUNCTION [dbo].[fn_NoMultiplePlayersForCharacter]()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF
		EXISTS (SELECT * FROM [PLAYER_CHARACTER]
		GROUP BY CharacterID
		HAVING COUNT(PlayerID) > 1)
	SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE [PLAYER_CHARACTER] WITH NOCHECK
ADD CONSTRAINT CK_NoMultiplePlayersForCharacter
CHECK(dbo.fn_NoMultiplePlayersForCharacter() = 0)


-- Player can only have one active character at any given time
CREATE FUNCTION fn_OneActiveCharacter()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF EXISTS(SELECT *
		FROM PLAYER_CHARACTER PC
			JOIN [CHARACTER] C ON PC.CharacterID = C.CharacterID
			JOIN CHARACTER_STATUS CS ON C.CharacterStatusID = CS.CharacterStatusID
		WHERE CS.StatusName = 'Active'
		GROUP BY PC.PlayerID
		HAVING COUNT(PC.CharacterID) > 1
	)
		SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE PLAYER_CHARACTER WITH NOCHECK
ADD CONSTRAINT CK_onlyOneActiveCharacter
CHECK (dbo.fn_OneActiveCharacter() = 0)


--Players can't make a new character if the player is inactive
CREATE FUNCTION [dbo].[fn_NoNewCharIfInactive]()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF
		EXISTS (SELECT PC.PlayerID, PC.CharacterID FROM [PLAYER_CHARACTER] PC
			JOIN PLAYER P ON PC.PlayerID = P.PlayerID
			JOIN PLAYER_STATUS PS ON P.PlayerID = PS.PlayerID
			JOIN PLAYER_STATUS_TYPE PST ON PS.PlayerStatusTypeID = PST.PlayerStatusTypeID
		WHERE PST.PlayerStatusTypeName = 'Inactive'
		)
	SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE [PLAYER_CHARACTER] WITH NOCHECK
ADD CONSTRAINT CK_NoNewCharIfInactive
CHECK(dbo.fn_NoNewCharIfInactive() = 0)


--Business Rule for Players 21 and younger can not have a ‘firearms’ skill
CREATE FUNCTION fn_PlayerAtLeast21()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF EXISTS( SELECT *
		FROM PLAYER P
		JOIN PLAYER_CHARACTER PC ON P.PlayerID = PC.PlayerID
		JOIN CHARACTER C ON PC.CharacterID = C.CharacterID
		JOIN CHARACTER_SKILL_LEVEL CSK ON C.CharacterID = CSK.CharacterID
		JOIN SKILL S on CSK.SkillID = S.SkillID
		WHERE P.PlayerDOB > (SELECT GetDate() - (365.25 * 21)) AND S.SkillName = ‘Firearms’
	)
		SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE PLAYER
ADD CONSTRAINT CK_playerAge21
CHECK (dbo.fn_PlayerAtLeast21() = 0)

--Greg Hay can not LARP
CREATE FUNCTION [dbo].[fn_NoLARPIfGregHay]()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF
		EXISTS (SELECT *
FROM CITY C
JOIN PROVINCE P ON C.ProvinceID = P.ProvinceID
JOIN THEATRE T ON P.TheatreID = T.TheatreID
JOIN EVENT E ON T.TheatreID = E.TheatreID
JOIN EVENT_PLAY_CHAR EPC ON E.EventID = EPC.EVENT ID
JOIN PLAY_CHARACTER PC ON EPC.PlayCharacterID = PC.PlayerCharacterID
JOIN PLAYER P ON PC.PlayerID = P.PlayerID
WHERE P.PlayerFname = ‘Greg’ and P.PlayerLname = ‘Hay’ and C.City = ‘Seattle’

	SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE PLAYER
ADD CONSTRAINT CK_NoGregHayLARPING
CHECK(dbo.fn_NoLARPIfGregHay() = 0)

--A lot may have no more than 1 item
CREATE FUNCTION [dbo].[fn_OneItemPerLot]()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF
		EXISTS (SELECT * FROM ITEM_LOT
		GROUP BY LotID
		HAVING COUNT (ItemID) > 1)
	SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE ITEM_LOT WITH NOCHECK
ADD CONSTRAINT CK_OneItemPerLot
CHECK(dbo.fn_OneItemPerLot() = 0)
