;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1610'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------

/******************************************************************************************
 *				Generate Family That Get Equated Mark for Responsibility
 ******************************************************************************************/
	--EXECUTE [WE].[SP_GenerateFamilyEquatedResponsibility] @Term = @Term
	SELECT * FROM DeepSeaKingdom.WE.FamilyEquatedResponsibility