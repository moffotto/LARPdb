--STORED PROCEDURES 

CREATE PROCEDURE uspInsert_PlayerCharacter
@P_ID INT,
@C_ID INT,
@Date Date
AS
BEGIN TRAN InsPlayChar
INSERT INTO PLAYER_CHARACTER (PlayerID, CharacterID, [Date])
VALUES (@P_ID, @C_ID, @Date)
IF @@ERROR <> 0
	ROLLBACK TRAN InsPlayChar
ELSE
	COMMIT TRAN InsPlayChar


CREATE PROCEDURE uspInsert_PlayerCharacter_Wrapper
@Run INT
AS
DECLARE @DatePlayed Date
DECLARE @CharacterID INT
DECLARE @PlayerID INT
DECLARE @C_Count INT
DECLARE @P_Count INT

SET @C_Count = (SELECT COUNT(*) FROM [CHARACTER])
SET @P_Count = (SELECT COUNT(*) FROM [PLAYER])

WHILE @Run > 0
BEGIN

SET @PlayerID = (SELECT @P_Count * RAND())
IF @PlayerID < 1
BEGIN
PRINT '@PlayerID is less than 1; re-assigning value to another number'
SET @PlayerID = (SELECT @P_Count * RAND())
END

SET @CharacterID = (SELECT @C_Count * RAND())
IF @CharacterID < 1
BEGIN
PRINT '@CharacterID is less than 1; re-assigning value to another number'
SET @CharacterID = (SELECT @C_Count * RAND())
END

SET @DatePlayed = (SELECT GetDate() - (365.21 * 18 * Rand()))

EXEC uspInsert_PlayerCharacter @PlayerID, @CharacterID, @DatePlayed

SET @Run = @Run - 1
END



-- stored procedure to get ProvinceID
CREATE PROC uspGetProvinceID
@Province varchar(50),
@ProvinceID INT OUTPUT
AS
SET @ProvinceID = (SELECT P.ProvinceID FROM PROVINCE P
WHERE P.ProvinceName = @Province)
GO


-- stored procedure to get ResourceID
CREATE PROC uspGetResourceID
@Resource varchar(50),
@ResourceID INT OUTPUT
AS
SET @ResourceID = (SELECT R.ResourceID FROM [RESOURCE] R
WHERE R.ResourceName = @Resource)
GO


-- stored procedure for populating the province_resource table
CREATE PROCEDURE uspInsert_ProvinceResource
@ProvinceName varchar(50),
@ResourceName varchar(50)
AS
DECLARE @P_ID INT
DECLARE @R_ID INT

EXEC uspGetProvinceID
@Province = @ProvinceName,
@ProvinceID = @P_ID OUTPUT

IF @P_ID IS NULL
	BEGIN
	PRINT '@P_ID IS NULL and will fail on insert statement; process terminated'
	RAISERROR ('ProvinceID variable @P_ID cannot be NULL', 11,1)
	RETURN
	END

EXEC uspGetResourceID
@Resource = @ResourceName,
@ResourceID = @R_ID OUTPUT

IF @R_ID IS NULL
	BEGIN
	PRINT '@R_ID IS NULL and will fail on insert statement; process terminated'
	RAISERROR ('ResourceID variable @R_ID cannot be NULL', 11,1)
	RETURN
	END

BEGIN TRAN T1
INSERT INTO PROVINCE_RESOURCE(ProvinceID, ResourceID)
VALUES (@P_ID, @R_ID)
IF @@ERROR <> 0
	ROLLBACK TRAN T1
ELSE
	COMMIT TRAN T1
GO


-- wrapper stored procedure around uspProvinceResource
CREATE PROC uspInsert_ProvinceResource_Wrapper
@Run INT
AS
DECLARE @P varchar(50)
DECLARE @R varchar(50)
DECLARE @ProvID INT -- temp PK holder
DECLARE @ResID INT -- temp PK holder
DECLARE @P_Count INT
SET @P_Count = (SELECT COUNT(*) FROM PROVINCE)
DECLARE @R_Count INT
SET @R_Count = (SELECT COUNT(*) FROM [RESOURCE])

WHILE @Run > 0
BEGIN

SET @ProvID = (SELECT @P_Count * RAND())
IF @ProvID < 1
	BEGIN
	PRINT '@ProvID is less than 1; re-assigning value'
	SET @ProvID = (SELECT @P_Count * RAND())
	END

SET @ResID = (SELECT @R_Count * RAND())
IF @ResID < 1
	BEGIN
	PRINT '@ResID is less than 1; re-assigning value'
	SET @ResID = (SELECT @R_Count * RAND())
	END

SET @P = (SELECT Top 1 ProvinceName FROM PROVINCE
			WHERE ProvinceID = @ProvID)
SET @R = (SELECT Top 1 ResourceName FROM [RESOURCE]
			WHERE ResourceID = @ResID)

EXEC uspInsert_ProvinceResource
@ProvinceName = @P,
@ResourceName = @R

SET @RUN = @RUN - 1
END
GO

Mary’s Code
ALTER PROCEDURE uspGetPlayerStatusTypetID_huibrm
@PlayStatTypeName1 varchar(50),
@PST_ID1 INT OUTPUT
AS
SET @PST_ID1 = (SELECT PlayerStatusTypeID FROM PLAYER_STATUS_TYPE WHERE PlayerStatusTypeName = @PlayStatTypeName1)

GO

ALTER PROCEDURE uspGetPlayerID_huibrm
@PFname1 varchar(50),
@PLname1 varchar(50),
@PDOB1 date,
@P_ID1 INT OUTPUT
AS
SET @P_ID1 = (SELECT PlayerID FROM PLAYER WHERE PlayerFName = @PFname1 AND PlayerLname = @PLname1 AND PlayerDOB = @PDOB1)


GO



ALTER PROCEDURE uspPopPlayerStatus_huibrm (Mary)
@PFname varchar(50),
@PLname varchar(50),
@PDOB date,
@PSTName varchar(50)
AS
DECLARE @P_ID INT
DECLARE @PST_ID INT

Print @PFname + ' playerFname is popPlayerStatus'
print @PLname + ' playerLname in popPlayerStatus'
Print @PDOB
Print @PSTName + ' PlayerStatusTypeName in popPlayerStatus'

If (@PFname =  ‘Greg’ and @PLname = ‘Hay’ and @PDOB > (select getdate() - (30 * 365))
Begin
Print ‘Go LARP Somewhere else Greg’
Raiserror(‘Greg belongs in school, transaction terminated’, 11,1)
Return
End



EXEC uspGetPlayerID_huibrm @PFname1 = @PFname, @PLname1 = @PLname, @PDOB1 = @PDOB, @P_ID1 = @P_ID OUTPUT
IF @P_ID is Null
		BEGIN
		PRINT 'PlayerID is null inside SPROC popPlayerStatus'
		RAISERROR('transaction terminated',11,1)
		RETURN
		END
print @P_ID
print 'PlayerID inside popPlayerStatus'

EXEC uspGetPlayerStatusTypetID_huibrm @PlayStatTypeName1 = @PSTName, @PST_ID1 = @PST_ID OUTPUT
IF @PST_ID is Null
		BEGIN
		PRINT'PlayerStatusTypeID is null inside SPROC popPlayerStatus'
		RAISERROR('transaction terminated',11,1)
		RETURN
		END
print @PST_ID
print 'playerstatustypeID inside PopPlayerStatus'

BEGIN TRAN
INSERT INTO PLAYER_STATUS (PlayerID, PlayerStatusTypeID)
VALUES (
@P_ID,
@PST_ID)
COMMIT TRAN
GO

ALTER PROCEDURE uspPopPlayerStatus_WRAPPER_huibrm (Mary)
@Run int
As
DECLARE @F varchar(50)
DECLARE @L varchar(50)
DECLARE @BD DATE
DECLARE @PSTName1 varchar(50)
DECLARE @P_ID INT
Declare @PST_ID INT
DECLARE @P_Count INT

DECLARE @PST_Count INT
DECLARE @RANDY INT
SET @RANDY = (SELECT RAND() * 100)+1
SET @P_Count = (SELECT COUNT(*)FROM PLAYER)
SET @PST_Count = (CASE
	WHEN @Randy > 50
	THEN 2
	Else 1
	END)

WHILE @Run > 0

BEGIN

SET @P_ID = (SELECT @P_Count*RAND())
	IF @P_ID <1
		BEGIN
		PRINT'PlayerID is less than one, will re-ass'
		SET @P_ID = (SELECT @P_Count * RAND())
		END
SET @PST_ID = (SELECT @PST_Count * RAND())
	IF @PST_ID <1
		BEGIN
		PRINT'PlayerStatyTypeID is less than one, will re-ass'
		SET @PST_ID = (SELECT @PST_Count * RAND())
		END
PRINT @Run

SET @F = (SELECT PlayerFname FROM PLAYER WHERE PlayerID = @P_ID)
SET @L = (SELECT PlayerLname FROM PLAYER WHERE PlayerID = @P_ID)
SET @BD = (SELECT PlayerDOB FROM PLAYER WHERE PlayerID = @P_ID)
SET @PSTName1 = (SELECT PlayerStatusTypeName FROM PLAYER_STATUS_TYPE WHERE PlayerStatusTypeID = @PST_ID)
Print @P_ID
print 'playerid inside of wrapper'
print @PST_ID
print 'playerStatusType id inside of wrapper'
IF @P_ID IS NULL
	BEGIN
	PRINT 'P_ID is null, there is no matching namae. go home'
	RAISERROR('NULL value for playerName, transaction terminated',11,1)
	RETURN
	END
EXEC uspPopPlayerStatus_huibrm
@PFname = @F,
@PLname = @L,
@PDOB = @BD,
@PSTName = @PSTName1
/*
print @F + ' inside wrapper player first name'
print @L + ' inside wrapper player last name'
print @BD
print ' inside wrapper dob'
print @PSTName1 + ' inside wappper playerstatusname'

*/
SET @Run = @Run-1
END

----


ALTER PROCEDURE [dbo].[uspPopulateLotsinDistrict] (
@DistrictID INT)
AS
--For use when creating new Districts. Takes in the DistrictID, then
--names 50 new lots in the format "DistrictName 1", DistrictName 2" etc
--Intended to be called as part of a Create Distirct Stored Procedure.
DECLARE @DistrictName nvarchar(50) = (SELECT DistrictName FROM DISTRICT WHERE District.DistrictID = @DistrictID)
DECLARE @Run INT = 1

WHILE @Run <= 50
BEGIN

DECLARE @LotName nvarchar(50) = CONCAT(@DistrictName,' ', @Run)
INSERT INTO LOT (DistrictID, LotName)
VALUES (@DistrictID, @LotName)

SET @Run = @Run + 1

END
GO


ALTER PROCEDURE [dbo].[uspCreateDistrict]
@CityID INT,
@DistrictName nvarchar(50)
--Takes in a CityID and creates a new District, which in turn creates 50 lots within that District.
--If this is the first District (as in, created from a new city), the default DistrictName is "Downtown"
AS
BEGIN
INSERT INTO DISTRICT (CityID, DistrictName)
VALUES (@CityID, @DistrictName)
DECLARE @DistrictID INT = @@IDENTITY

EXEC [dbo].[uspPopulateLotsinDistrict]
@DistrictID = @DistrictID

END
GO


ALTER PROCEDURE [dbo].[uspCreateCity]
@ProvinceID INT,
@CityName nvarchar(50)

--Takes in a ProvinceID and creates a new City, which creates its first District, which creates 50 new lots,
--using nested stored procedures.
AS
BEGIN

INSERT INTO CITY (ProvinceID, CityName)
VALUES (@ProvinceID, @CityName)
DECLARE @CityID INT = @@IDENTITY

--Finds incidents of brand new cities
IF ((SELECT COUNT(CityID) FROM DISTRICT WHERE District.CityID = @CityID) = 0)
	DECLARE @DistName nvarchar(50) = 'Downtown'
EXEC uspCreateDistrict
@CityID = @CityID,
@DistrictName = @DistName
END
GO

------


CREATE PROCEDURE uspInsert_Event_Play_Char
@PlayerCharacterID INT,
@EventID INT
AS
BEGIN TRAN
INSERT INTO EVENT_PLAY_CHAR (PlayerCharacterID, EventID)
VALUES (@PlayerCharacterID, @EventID)
IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN
GO


CREATE PROCEDURE uspInsert_Event_Play_Char_Wrapper
@Run INT
AS
DECLARE @PC_ID INT
DECLARE @PC_Count INT
DECLARE @E_ID INT
DECLARE @E_Count INT

SET @PC_Count = (SELECT COUNT(*) FROM PLAYER_CHARACTER)
SET @E_Count = (SELECT COUNT(*) FROM [EVENT])

WHILE @Run > 0
BEGIN

SET @PC_ID = (SELECT @PC_Count * RAND())
IF @PC_ID < 1
BEGIN
PRINT '@CharacterID is less than 1; re-assigning value to another number'
SET @PC_ID = (SELECT @PC_Count * RAND())
END

SET @E_ID = (SELECT @E_Count * RAND())
IF @E_ID < 1
BEGIN
PRINT '@CharacterID is less than 1; re-assigning value to another number'
SET @E_ID = (SELECT @E_Count * RAND())
END

EXEC uspInsert_Event_Play_Char
@PlayerCharacterID = @PC_ID,
@EventID = @E_ID

SET @Run = @Run-1
END
GO


-------

CREATE PROCEDURE uspInsert_Payment
@PaymentTypeID INT,
@EventPlayCharID INT
AS
BEGIN TRAN
INSERT INTO PAYMENT (PaymentTypeID, EventPlayCharID)
VALUES (@PaymentTypeID, @EventPlayCharID)
IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN
GO


ALTER PROCEDURE uspInsert_Payment_Wrapper
@Run INT
AS
DECLARE @PT_ID INT
DECLARE @PT_Count INT
DECLARE @EPC_ID INT
DECLARE @EPC_Count INT

SET @PT_Count = (SELECT COUNT(*) FROM PAYMENT_TYPE)
SET @EPC_Count = (SELECT COUNT(*) FROM EVENT_PLAY_CHAR)

WHILE @Run > 0
BEGIN

SET @PT_ID = (SELECT @PT_Count * RAND())
IF @PT_ID < 1
BEGIN
PRINT '@CharacterID is less than 1; re-assigning value to another number'
SET @PT_ID = (SELECT @PT_Count * RAND())
END

SET @EPC_ID = (SELECT @EPC_Count * RAND())
IF @EPC_ID < 1
BEGIN
PRINT '@CharacterID is less than 1; re-assigning value to another number'
SET @EPC_ID = (SELECT @EPC_Count * RAND())
END

PRINT @EPC_ID

EXEC uspInsert_Payment
@PaymentTypeID = @PT_ID,
@EventPlayCharID = @EPC_ID

SET @Run = @Run-1
END
GO
