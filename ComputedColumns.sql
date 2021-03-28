--COMPUTED COLUMNS

-- Player age
CREATE FUNCTION dbo.GetAge(@dob Date)
RETURNS INT
AS
BEGIN
	DECLARE @RET INT
	SET @RET = DATEDIFF(year, @dob, GetDate())
RETURN @RET
END
GO

ALTER TABLE dbo.PLAYER
ADD Age AS (dbo.GetAge(PlayerDOB))
GO

-----

CREATE FUNCTION fn_ComputeItemsInLot(@LotID INT)
RETURNS INT
AS
BEGIN

DECLARE @Ret INT
SET @Ret = (SELECT COUNT(*) FROM ITEM WHERE ITEM.LotID = @LotID )
RETURN @Ret
END


GO
ALTER TABLE LOT
ADD TotalItems AS (dbo.fn_ComputeItemsInLot(LotID))
GO

---

CREATE FUNCTION fn_ComputeDistrictsInCity(@CityID INT)
RETURNS INT
AS
BEGIN

DECLARE @Ret INT
SET @Ret = (SELECT COUNT(*) FROM DISTRICT WHERE DISTRICT.CityID = @CityID )
RETURN @Ret
END


GO
ALTER TABLE CITY
ADD TotalDistricts AS (dbo.fn_ComputeDistrictsInCity(CityID))
GO
----

--Provides current compound XP of Character
CREATE FUNCTION fn_CurrentCharXP(@CharacterID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT
	SET @Ret = (SELECT SUM(XPamount)
				FROM XP_TRANSACTION
				WHERE CharacterID = @CharacterID)
	RETURN @Ret
END
GO

ALTER TABLE [CHARACTER]
ADD charXP AS (dbo.fn_CurrentCharXP(CharacterID))
GO

----

--Total number of characters owned by a player
CREATE FUNCTION fn_NumberOfCharsOwned(@PlayerID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT
	SET @Ret = (SELECT COUNT(PlayerCharacterID)
				FROM PLAYER_CHARACTER
				WHERE PlayerID = @PlayerID)
	RETURN @Ret
END
GO

ALTER TABLE [PLAYER]
ADD CharactersOwned AS (dbo.fn_NumberOfCharsOwned(PlayerID))
GO

----

-- total number of Player_Characters by event
CREATE FUNCTION fn_PlayCharByEvent(@EventID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT
	SET @Ret = (SELECT COUNT(EventPlayCharID)
		FROM EVENT_PLAY_CHAR
		WHERE EventID = @EventID
	)
	RETURN @Ret
END
GO

ALTER TABLE [EVENT]
ADD TotalPlayerCharacters AS (dbo.fn_PlayCharByEvent(EventID))
GO


-- Total amount of events a character has played (Character can be played by different players, as long as they are not playing at the same time)

CREATE FUNCTION fn_EventsAttendedByChar(@CharacterID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT
	SET @Ret = (SELECT SUM(EPC.PlayerCharacterID)
				FROM Character C
					JOIN PLAYER_CHAR PC on C.CharacterID = PC.CharacterID
JOIN EVENT_PLAY_CHAR EPC on PC.PlayerCharacterID = EPC.PlayerCharacterID
WHERE C.CharacterID = @CharacterID
	RETURN @Ret
END
GO

ALTER TABLE [CHARACTER]
ADD charEventCount AS (dbo.fn_EventsAttendedByChar(CharacterID))
GO

Total amount of Events a player has attended

CREATE FUNCTION fn_EventsAttendedByPlayer(@PlayerID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT
	SET @Ret = (SELECT SUM(EPC.PlayerCharacterID)
				FROM PLAYER P
					JOIN PLAYER_CHAR PC on P.PlayerID = PC.PlayerID
JOIN EVENT_PLAY_CHAR EPC on PC.PlayerCharacterID = EPC.PlayerCharacterID
WHERE P.PlayerID = @PlayerID
	RETURN @Ret
END
GO

ALTER TABLE [PLAYER]
ADD playEventCount AS (dbo.fn_EventsAttendedByPlayer(PlayerID))
GO
