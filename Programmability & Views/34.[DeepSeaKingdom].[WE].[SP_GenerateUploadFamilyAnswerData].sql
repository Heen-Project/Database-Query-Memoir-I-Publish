USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateUploadFamilyAnswerData] (
	@Term NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.UploadFamilyResponsibilityAnswerData', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.UploadFamilyResponsibilityAnswerData;
IF OBJECT_ID('DeepSeaKingdom.WE.UploadFamilyOnsiteTestAnswerData', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.UploadFamilyOnsiteTestAnswerData;
IF OBJECT_ID('DeepSeaKingdom.WE.UploadFamilyVentureAnswerData', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.UploadFamilyVentureAnswerData;
;----------------------------------------------------------------------
SELECT * 
INTO DeepSeaKingdom.WE.UploadFamilyResponsibilityAnswerData
FROM DeepSeaKingdom.WE.V_UploadFamilyResponsibilityAnswerData ussad 
WHERE ussad.QuarterSessionId LIKE '%'+@QuarterSessionId+'%'
;------------------------------
SELECT * 
INTO DeepSeaKingdom.WE.UploadFamilyOnsiteTestAnswerData
FROM DeepSeaKingdom.WE.V_UploadFamilyOnsiteTestAnswerData usead 
WHERE usead.QuarterSessionId LIKE '%'+@QuarterSessionId+'%'
;------------------------------
SELECT * 
INTO DeepSeaKingdom.WE.UploadFamilyVentureAnswerData
FROM DeepSeaKingdom.WE.V_UploadFamilyVentureAnswerData uspad 
WHERE uspad.QuarterSessionId LIKE '%'+@QuarterSessionId+'%'
;----------------------------------------------------------------------
/*
Instead, for a permanent table you can use
IF OBJECT_ID('dbo.Marks', 'U') IS NOT NULL 
  DROP TABLE dbo.Marks;

Or, for a temporary table you can use
IF OBJECT_ID('tempdb.dbo.#T', 'U') IS NOT NULL
  DROP TABLE #T;
*/
END
